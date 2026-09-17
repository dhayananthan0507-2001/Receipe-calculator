-- ============================================================
-- LEARNING HUB — curated YouTube tutorials, shared across every
-- company (not per-tenant data). Only an app-level admin (you)
-- can add/edit videos; any signed-in user can watch them.
-- ============================================================

-- A global admin flag, separate from the per-company owner/worker role.
alter table profiles add column if not exists is_app_admin boolean not null default false;

create or replace function is_app_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select p.is_app_admin from profiles p where p.id = auth.uid()), false);
$$;
grant execute on function is_app_admin() to authenticated;

-- ---------- videos ----------
create table videos (
  id                uuid primary key default gen_random_uuid(),
  title             text not null,
  description       text,
  video_provider    text not null default 'youtube',
  youtube_url       text not null,
  youtube_video_id  text not null,
  thumbnail_url     text,
  category          text not null default 'Tutorials',
  difficulty        text not null default 'Beginner' check (difficulty in ('Beginner','Intermediate','Advanced')),
  duration_seconds  integer,
  tags              text[] default '{}',
  why_watch         text,
  related_feature   text,       -- one of: dashboard | products | calculator | prices | cost
  is_featured       boolean not null default false,
  is_published      boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
alter table videos enable row level security;

create policy "anyone can read published videos" on videos
  for select using (is_published = true or is_app_admin());
create policy "admin can insert videos" on videos
  for insert with check (is_app_admin());
create policy "admin can update videos" on videos
  for update using (is_app_admin());
create policy "admin can delete videos" on videos
  for delete using (is_app_admin());

-- ---------- video_progress ----------
create table video_progress (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  video_id          uuid not null references videos(id) on delete cascade,
  progress_seconds  integer not null default 0,
  completed         boolean not null default false,
  updated_at        timestamptz not null default now(),
  unique(user_id, video_id)
);
alter table video_progress enable row level security;

create policy "user manages own progress" on video_progress
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- saved_videos ----------
create table saved_videos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  video_id    uuid not null references videos(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique(user_id, video_id)
);
alter table saved_videos enable row level security;

create policy "user manages own saved videos" on saved_videos
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- run this once, after you've signed up, to make YOUR account the app admin ----------
-- update profiles set is_app_admin = true where id = (select id from auth.users where email = 'dhayananthan0507@gmail.com');
