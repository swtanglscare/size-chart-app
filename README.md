# SIZE CHART — retailer size chart builder

Next.js app with Google OAuth (Supabase), one free saved chart per account, category-specific editable measurement grids, PDF export, WhatsApp share handoff, and ₹499 Razorpay checkout for six additional chart credits.

## Setup
1. Create a Supabase project. Run `schema.sql` in SQL Editor. Enable Google OAuth in Supabase Auth Providers; configure Google OAuth consent screen/client in Google Cloud and use the **Supabase callback URL** provided by Supabase as the authorized redirect URI. Add your local and production URLs to Supabase Auth URL configuration.
2. Copy `.env.example` to `.env.local`; fill Supabase URL, anon/publishable key, **server-only** service role key, Razorpay test key ID/secret, and public Razorpay key ID. Never expose the service role key or secret in browser code.
3. `npm install && npm run dev` to test. Configure Razorpay test mode and verify payment flows, then switch to live credentials after KYC/activation.
4. Push the folder to GitHub. Import repository in Vercel; add the same environment variables. Use a Vercel plan that permits commercial use. Configure Google and Supabase allowed production domains.
5. Test: fresh Google account gets 1 credit, chart saves once, PDF opens, WhatsApp share works, second save blocked, verified test payment credits 6, repeated verification cannot double-credit.

## Important production notes
- WhatsApp click-to-chat cannot automatically attach/send a PDF to a recipient. On supported phones, the Web Share API can share the PDF; otherwise the app downloads the PDF and opens a WhatsApp chat where the retailer must attach it. Fully automatic delivery requires WhatsApp Business Platform API, opt-in, templates and messaging costs.
- Google account identity is not a perfect anti-abuse mechanism (users can create multiple accounts).
- Razorpay order verification currently checks the signed checkout result and atomically grants credits. Before public launch, add a Razorpay webhook for reliable fulfillment when a browser closes, verify webhook signature and event payment status, and reconcile pending orders. Consider confirming captured payment through Razorpay API before crediting.
- For production, add rate limits, audit logging, privacy/terms pages, data deletion, input constraints and automated tests. No automated live payment or browser end-to-end testing was performed here.
- `profiles` credits initialize on first save, rather than at sign-in; UI displays 1 until the first chart is saved.
- Existing charts are stored in Supabase but this starter does not yet include a history/re-download screen. Chart credits are consumed for each successful new save, not per PDF download.

## Version 1.1 — Baby and kids weight guidance
- Choose Babies, Kids or Adults. For Babies/Kids, add optional recommended **weight ranges (kg)**, **height ranges (cm)** and age labels for each size. They appear in the PDF and are saved with the chart. Measurements are retailer-supplied, never invented or inferred.
- Google OAuth uses `/auth/callback`; add `https://YOUR-PROJECT.vercel.app/auth/callback` to Supabase Authentication > URL Configuration > Redirect URLs, plus `http://localhost:3000/auth/callback` for local development. In Google Cloud, the OAuth redirect URI is the **Supabase** callback URL, not Vercel's.
- Payment verification additionally checks Razorpay's API for a captured payment and matching amount/order before granting credits. **Still add a signed Razorpay webhook and reconciliation before production** so users who close the browser receive their credits.

## Deploy using GitHub and Vercel
1. Extract this ZIP, create a new private GitHub repository, and upload the *contents* of the `size-chart-app` folder to the repository root. Never upload `.env.local` or any API secret.
2. In Supabase create a project, run `schema.sql` in SQL Editor, configure Authentication > Providers > Google using your Google OAuth client credentials. Copy the Supabase callback URI into Google Cloud's Authorized redirect URIs.
3. In Vercel choose Add New > Project > Import your GitHub repository. Framework preset: Next.js; root directory: repository root. Add all six environment variables listed in `.env.example` in Vercel Project Settings > Environment Variables. Use a plan permitting commercial use.
4. Deploy. Copy your final Vercel URL and set it as the Supabase Auth Site URL; add `https://YOUR-PROJECT.vercel.app/auth/callback` to allowed Redirect URLs. Redeploy after changing environment variables.
5. Enable Razorpay **test mode** first; put test key ID/secret into the Vercel environment variables. Test fresh Google sign-in, saving the one free chart, PDF output, second-save rejection, and six credits after a captured test payment. Then activate Razorpay live keys only after your merchant account is approved.
6. Keep the repo private until you have implemented privacy/terms, abuse protection, payment webhooks and full QA. Supabase service role key and Razorpay secret must NEVER be prefixed `NEXT_PUBLIC_`.

## Known limitations
- This release is source code, not a fully tested production app. `npm install`/build could not be completed in the creation environment; run `npm install && npm run build` locally or in Vercel and resolve any reported dependency issues before launch.
- No automatic PDF attachment through WhatsApp; native file sharing or manual attachment only.
- Fit guidance is retailer-entered and cannot guarantee correct size.
- PDF tables with many columns may be cramped; for best readability limit sizes per chart to around 6–8.
- Chart history/re-download, webhook fulfillment, privacy policy and production rate limiting are future improvements.
