import {createClient} from '@supabase/supabase-js';
export const adminDb=()=>createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.SUPABASE_SERVICE_ROLE_KEY!,{auth:{persistSession:false}});
export async function userFromToken(req:Request){const auth=req.headers.get('authorization')||'';const token=auth.startsWith('Bearer ')?auth.slice(7):'';if(!token)return null;const {data,error}=await adminDb().auth.getUser(token);return error?null:data.user;}
