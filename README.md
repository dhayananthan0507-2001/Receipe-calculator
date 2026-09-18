# Homies Kit

Production-oriented multi-user recipe and production manager frontend.

## Files
- `auth.html` — Supabase authentication, registration, worker invite and password reset.
- `index.html` — authenticated workspace dashboard, product/recipe calculator, ingredient pricing and cost calculator.
- `worker_invites.sql` — Supabase SQL for worker invitations/RPC support.
- `learning_hub_schema.sql` — Supabase SQL for the Learning Hub (curated videos, watch progress, saved videos, app-admin flag).
- `extra_ingredients_schema.sql` — **new**. Supabase SQL for the shared, company-wide ingredient master list (see Changelog below). Run this once in the Supabase SQL editor before deploying this build.

This zip assumes the base schema (companies, profiles, products, ingredients, ingredient_prices, production_costs, subscriptions, my_company_id(), my_role()) is already set up in your Supabase project from earlier work — it isn't included here since it wasn't part of this upload.

## Deploy
Upload these files to GitHub Pages, Netlify, Vercel static hosting, or another static host. Supabase provides the authentication and database backend.

## Important
The dashboard UI has been redesigned without removing the existing product, recipe calculator, ingredient price and cost-calculator logic. Configure the corresponding Supabase tables/RLS/RPCs before production use.

## Changelog (this pass)
Bug fixes and cleanup applied to the app you uploaded — see the full write-up given alongside these files for details:
1. Recipe Calculator and Cost Calculator only offered g/kg, silently mis-scaling any product whose unit is ml or L (liquids). Fixed to detect the product's unit family (weight vs volume) and offer/compute the right units.
2. The "cost by pack size" table assumed weight-based pack sizes even for liquid products. Fixed to show ml/L pack sizes for volume products.
3. The ingredient master list ("Ingredient Names" screen) was stored per-device in `localStorage`, so a worker on one device couldn't see ingredients a colleague added on another. Migrated to a new Supabase table, `extra_ingredients`, shared by the whole company — run `extra_ingredients_schema.sql` once to enable it.
4. Removed duplicated "Add Product" / "Recipe Calculator" buttons that appeared three times across the dashboard (hero actions, "Start something" panel, Quick Actions card) — one clear path per action now.
5. Removed dead CSS/JS left over from an earlier top-tab navigation design that no longer exists in the markup.
6. Subscription lookup used `.single()`, which throws a noisy error for a brand-new company with no subscription row yet. Switched to `.maybeSingle()`.
7. Learning Hub admin actions (publish/feature toggle, delete) silently swallowed database errors. They now alert the admin if a save fails, consistent with the rest of the app.

### Known limitations not addressed in this pass
- The free-text Recipe Calculator (the "5kg Sambar Powder, 3kg Podi" textarea) still only parses weight quantities (kg/g). Extending its regex-based parser to also understand ml/L carries more regression risk than the structured dropdown fixes above, so it was left as-is — flag it if you want that extended too.
- This pass did not attempt the full 36-section rewrite from the accompanying spec document (company email-domain validation, subscription activation, a full RLS audit, complete visual redesign, seeded demo videos, etc.). Some of that appears to already exist from earlier work, but the base schema file wasn't part of this upload, so it couldn't be verified here. Treat this as a bug-fix and cleanup pass on the exact files provided, not a ground-up rebuild.
