-- ============================================================
-- WORKER INVITES — lets an owner generate a one-time code that
-- a worker uses at signup to join the SAME company (instead of
-- creating a new one).
-- ============================================================
create table company_invites (
  code        text primary key,
  company_id  uuid not null references companies(id) on delete cascade,
  created_by  uuid not null references profiles(id),
  used        boolean not null default false,
  used_by     uuid references profiles(id),
  created_at  timestamptz not null default now()
);
alter table company_invites enable row level security;

-- Owners can see the invites they've created (to track/share codes).
-- No client-facing INSERT policy — invites are only ever created via
-- the security-definer function below.
create policy "owner views own invites" on company_invites
  for select using (company_id = my_company_id() and my_role() = 'owner');

-- ---------- OWNER: generate a worker invite code ----------
create or replace function create_worker_invite()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  new_code text;
  cid uuid;
  r text;
begin
  select company_id, role into cid, r from profiles where id = auth.uid();
  if r is null or r <> 'owner' then
    raise exception 'Only the owner can create worker invites';
  end if;
  new_code := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 8));
  insert into company_invites (code, company_id, created_by) values (new_code, cid, auth.uid());
  return new_code;
end;
$$;
grant execute on function create_worker_invite() to authenticated;

-- ---------- NEW SIGNUP: join an existing company as a worker ----------
create or replace function join_company_with_invite(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  inv record;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  if exists (select 1 from profiles where id = auth.uid()) then
    raise exception 'This account already belongs to a company';
  end if;
  select * into inv from company_invites where code = upper(trim(p_invite_code)) and used = false;
  if inv is null then
    raise exception 'That invite code is invalid or has already been used';
  end if;
  insert into profiles (id, company_id, role) values (auth.uid(), inv.company_id, 'worker');
  update company_invites set used = true, used_by = auth.uid() where code = inv.code;
  return inv.company_id;
end;
$$;
grant execute on function join_company_with_invite(text) to authenticated;
