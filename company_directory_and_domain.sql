-- ============================================================
-- COMPANY EMAIL DOMAIN + TEAM DIRECTORY
--
-- Supports two things added in this pass:
--   1. auth.html now generates every login email as
--      name.initial@<companyslug>.com instead of letting people
--      type any address. get_invite_company_domain() lets the
--      signup page look up the RIGHT company domain for a given
--      invite code (so a worker's email always matches their
--      employer's domain) before the account is created.
--   2. index.html's new "Team" screen lists everyone in the
--      caller's own company (so, e.g., only @abc.com logins show
--      up for company "abc") — visible to any signed-in member,
--      but the remove action only works for the owner.
--
-- Assumes the base schema already in your Supabase project
-- (companies(id, name, ...), profiles(id, company_id, role),
-- my_company_id(), my_role()) — same assumption as the other
-- SQL files in this project.
-- ============================================================

-- Turns a company name into the same slug algorithm used client-side
-- in auth.html's companySlug(): lowercase, letters/digits only.
create or replace function company_slug(p_name text)
returns text
language sql
immutable
as $$
  select coalesce(nullif(left(lower(regexp_replace(p_name, '[^a-zA-Z0-9]', '', 'g')), 24), ''), 'company');
$$;

-- ---------- Look up a company's email domain from an invite code ----------
-- Callable by anonymous visitors (this runs BEFORE the worker has an
-- account), so it only ever returns the domain string — never the
-- company name, id, or any other detail.
create or replace function get_invite_company_domain(p_invite_code text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  cname text;
begin
  select c.name into cname
  from company_invites ci
  join companies c on c.id = ci.company_id
  where ci.code = upper(trim(p_invite_code)) and ci.used = false;

  if cname is null then
    return null;
  end if;
  return company_slug(cname);
end;
$$;
grant execute on function get_invite_company_domain(text) to anon, authenticated;

-- ---------- Team directory: everyone in MY company ----------
-- Any signed-in member (owner or worker) can see the list; the
-- security-definer function only ever looks at the caller's own
-- company_id (via my_company_id()), so a company never sees
-- another company's emails.
create or replace function list_company_members()
returns table(id uuid, email text, role text)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
    select p.id, au.email::text, p.role
    from profiles p
    join auth.users au on au.id = p.id
    where p.company_id = my_company_id()
    order by (p.role = 'owner') desc, au.email;
end;
$$;
grant execute on function list_company_members() to authenticated;

-- ---------- Remove a worker: OWNER ONLY ----------
-- Removes someone from the company directory (they keep their login
-- but are no longer linked to any company, same as a fresh signup).
-- An owner can never remove themselves this way.
create or replace function remove_company_member(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if my_role() <> 'owner' then
    raise exception 'Only the owner can remove a teammate';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'The owner cannot remove their own account';
  end if;
  delete from profiles where id = p_user_id and company_id = my_company_id();
end;
$$;
grant execute on function remove_company_member(uuid) to authenticated;
