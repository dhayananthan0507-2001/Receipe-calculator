# Homies Kit

Production-oriented multi-user recipe and production manager frontend.

## Files
- `auth.html` — Supabase authentication, registration, worker invite and password reset.
- `index.html` — authenticated workspace dashboard, product/recipe calculator, ingredient pricing and cost calculator.
- `worker_invites.sql` — Supabase SQL for worker invitations/RPC support.

## Deploy
Upload these files to GitHub Pages, Netlify, Vercel static hosting, or another static host. Supabase provides the authentication and database backend.

## Important
The dashboard UI has been redesigned without removing the existing product, recipe calculator, ingredient price and cost-calculator logic. Configure the corresponding Supabase tables/RLS/RPCs before production use.
