create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade, store_name text not null default '', whatsapp text not null default '', credits integer not null default 1 check (credits >= 0), created_at timestamptz default now());
create table if not exists public.charts (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, title text not null, category text not null, sizes jsonb not null, rows jsonb not null, unit text not null, store_name text not null, whatsapp text not null, created_at timestamptz default now());
create table if not exists public.payments (id text primary key, user_id uuid not null references auth.users(id), status text not null default 'created', amount integer not null, created_at timestamptz default now());
alter table public.profiles enable row level security;
alter table public.charts enable row level security;
alter table public.payments enable row level security;
create policy "profile read own" on public.profiles for select to authenticated using (auth.uid()=id);
create policy "charts read own" on public.charts for select to authenticated using (auth.uid()=user_id);
-- Chart creation is performed only by the server-side atomic RPC below.
create or replace function public.create_chart_with_credit(p_title text,p_category text,p_sizes jsonb,p_rows jsonb,p_unit text,p_store text,p_whatsapp text)
returns uuid language plpgsql security definer set search_path=public as $$
declare uid uuid := auth.uid(); chart_id uuid;
begin
 if uid is null then raise exception 'Not authenticated'; end if;
 insert into profiles(id,credits) values(uid,1) on conflict(id) do nothing;
 update profiles set credits=credits-1,store_name=p_store,whatsapp=p_whatsapp where id=uid and credits>0;
 if not found then raise exception 'No chart credits remaining'; end if;
 insert into charts(user_id,title,category,sizes,rows,unit,store_name,whatsapp) values(uid,p_title,p_category,p_sizes,p_rows,p_unit,p_store,p_whatsapp) returning id into chart_id;
 return chart_id;
end $$;
revoke all on function public.create_chart_with_credit(text,text,jsonb,jsonb,text,text,text) from public;
grant execute on function public.create_chart_with_credit(text,text,jsonb,jsonb,text,text,text) to authenticated;
-- Idempotent, transactional crediting: never credit the same order twice.
create or replace function public.credit_verified_payment(p_order_id text,p_user_id uuid)
returns boolean language plpgsql security definer set search_path=public as $$
declare changed integer;
begin
 update payments set status='paid' where id=p_order_id and user_id=p_user_id and status='created' and amount=49900;
 get diagnostics changed=row_count;
 if changed=0 then return false; end if;
 insert into profiles(id,credits) values(p_user_id,7) on conflict(id) do update set credits=profiles.credits+6;
 return true;
end $$;
revoke all on function public.credit_verified_payment(text,uuid) from public,anon,authenticated;
