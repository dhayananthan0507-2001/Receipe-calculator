# Homies Kit

Production-oriented multi-user recipe and production manager frontend.

## Files
- `auth.html` — Supabase authentication, registration, worker invite and password reset.
- `index.html` — authenticated workspace dashboard, product/recipe calculator, ingredient pricing and cost calculator.
- `worker_invites.sql` — Supabase SQL for worker invitations/RPC support.
- `learning_hub_schema.sql` — Supabase SQL for the Learning Hub (curated videos, watch progress, saved videos, app-admin flag).
- `extra_ingredients_schema.sql` — Supabase SQL for the shared, company-wide ingredient master list. Run once before deploying.
- `company_directory_and_domain.sql` — **new**. Supabase SQL backing the company-based login emails and the new Team screen (see Changelog). Run this once, after `worker_invites.sql`.
- `seed_learning_hub_videos.sql` — **new**. Adds two real starter videos to the Learning Hub so it isn't empty on first login. Run once, after `learning_hub_schema.sql`.

This zip assumes the base schema (companies, profiles, products, ingredients, ingredient_prices, production_costs, subscriptions, my_company_id(), my_role(), and the `create_company_and_owner` RPC) is already set up in your Supabase project from earlier work — it isn't included here since it wasn't part of this upload.

## Deploy
1. Run the SQL files in this order (skip any you've already run): `worker_invites.sql` → `learning_hub_schema.sql` → `extra_ingredients_schema.sql` → `company_directory_and_domain.sql` → `seed_learning_hub_videos.sql`.
2. **Supabase Auth settings**: turn **off** "Confirm email" (Authentication → Providers → Email). Login emails are now auto-generated (see below) and are not real mailboxes, so a confirmation email would never arrive.
3. Upload the HTML files to GitHub Pages, Netlify, Vercel static hosting, or another static host.

## Important
The dashboard UI has been redesigned without removing the existing product, recipe calculator, ingredient price and cost-calculator logic. Configure the corresponding Supabase tables/RLS/RPCs before production use.

## Changelog (this pass — corrections you asked for)
1. **Removed duplicate entry points.** The dashboard's "＋ New Product" / "Calculate Batch" hero buttons and the whole "Quick Actions" card are gone — they just repeated what the sidebar (Products, Recipe Calculator, Ingredient Prices, Cost Calculator, Invite Worker) already does. One path per action now.
2. **Full-screen background photography.** Both `auth.html` and `index.html` now use large, real cooking/spice-market and crop-field photos as full-page backgrounds (with a green tint overlay so text stays readable), instead of the small decorative touches before.
3. **Overview rewritten.** The old duplicate stats card is gone (the top metrics row already covered that). In its place is an "About Homies Kit" panel explaining what the app does and its benefits, over a crop-field photo background.
4. **Learning Hub seeded with real videos.** `seed_learning_hub_videos.sql` adds two genuine, verified YouTube videos on food-business pricing. Add more anytime from Learning Hub → Manage Videos.
5. **Subscription monthly/yearly toggle** — `billing.html` wasn't part of your upload, so I couldn't edit it directly. If it has a monthly/yearly pricing toggle you want hidden for now, send me that file and I'll remove it.
6. **Login is now company-scoped.** Signing up no longer asks for a free-typed email. Instead:
   - The **owner** enters their company name + their own name; the app generates their login as `name.initial@companyslug.com`.
   - A **worker** enters the invite code + their name; the app looks up the inviting company's domain (via the new `get_invite_company_domain` SQL function) and generates a matching `name.initial@companyslug.com` login.
   - This guarantees everyone in the same business shares one email domain, and people from different businesses can never collide.
   - **Caveat**: these are not real mailboxes — see the "Confirm email" note under Deploy above.
7. **Team directory, owner-only edit.** A new "Team" screen (sidebar → Team) lists everyone signed in under your company's domain via `list_company_members()` — so, e.g., only `@abc.com` logins ever show up for company "abc". Any member can view it; only the owner sees a "Remove" action (`remove_company_member`, enforced server-side too).
8. **Top-right user menu.** The bottom-left avatar/email/logout block in the sidebar is gone. There's now a user chip in the top-right of the header — click it to see your email and role, with Log Out inside that dropdown.

## Still carried over from the previous pass
- Recipe Calculator / Cost Calculator unit-family fix (g/kg vs ml/L), shared `extra_ingredients` table, `.maybeSingle()` subscription lookup, Learning Hub admin error alerts.

### Known limitations not addressed in this pass
- The free-text Recipe Calculator (the "5kg Sambar Powder, 3kg Podi" textarea) still only parses weight quantities (kg/g). Flag it if you want ml/L support added there too.
- `billing.html` (monthly/yearly subscription toggle) wasn't in either upload, so it's untouched — send it over if you want that edited.
- The generated login emails are a convention enforced by this app, not real, receivable mailboxes — password-reset emails and "Confirm email" verification will not work unless you turn confirmation off as noted above.
