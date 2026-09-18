-- ============================================================
-- EXTRA INGREDIENTS — the "ingredient master list" entries that
-- don't yet belong to any product (added ahead of time from the
-- Products → Ingredient Names screen). Previously this lived in
-- per-device localStorage, which meant a worker on one device
-- couldn't see ingredients a colleague added on another. This
-- table makes it company-wide, cloud-backed data like everything
-- else in Homies Kit.
--
-- Assumes the base schema already in your Supabase project
-- (companies, profiles, my_company_id(), my_role()) — the same
-- helpers used by worker_invites.sql and learning_hub_schema.sql.
-- ============================================================

create table extra_ingredients (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete cascade,
  name         text not null,
  tamil_name   text default '',
  unit         text not null default 'g',
  supplier     text default '',
  notes        text default '',
  created_by   uuid references profiles(id),
  created_at   timestamptz not null default now(),
  unique (company_id, name)
);
alter table extra_ingredients enable row level security;

-- Any signed-in member of the company (owner or worker) can view,
-- add and remove ingredient-master entries — this list is a shared
-- team convenience, not owner-restricted like pricing/costing data.
create policy "company members read extra ingredients" on extra_ingredients
  for select using (company_id = my_company_id());
create policy "company members insert extra ingredients" on extra_ingredients
  for insert with check (company_id = my_company_id());
create policy "company members delete extra ingredients" on extra_ingredients
  for delete using (company_id = my_company_id());
