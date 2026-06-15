-- =================================================================
-- Ghana NDC Executive Registry — Supabase Schema
-- Run this entire file in your Supabase SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)
-- =================================================================

-- Enable UUID extension (already enabled by default on Supabase)
create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------
-- 1. USERS  (replaces local user:* keys)
-- -----------------------------------------------------------------
create table if not exists ndc_users (
  id            text primary key,          -- same as username, e.g. 'admin'
  username      text unique not null,
  password      text not null,
  full_name     text not null default '',
  role          text not null default 'viewer',
  scope_constituency_id   text,
  scope_constituency_name text,
  must_change_password    boolean not null default false,
  suspended     boolean not null default false,
  created_by    text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Seed the default National Admin (password must be changed on first login)
insert into ndc_users (id, username, password, full_name, role, must_change_password)
values ('admin', 'admin', 'ndc2024', 'National Administrator', 'national_admin', true)
on conflict (id) do nothing;

-- -----------------------------------------------------------------
-- 2. APP SETTINGS  (replaces settings key)
-- -----------------------------------------------------------------
create table if not exists ndc_settings (
  key   text primary key,
  value jsonb not null
);

insert into ndc_settings (key, value)
values ('positions', '[
  {"title":"Chairman","levels":["region","constituency","ward"]},
  {"title":"First Vice Chairman","levels":["region","constituency"]},
  {"title":"Second Vice Chairman","levels":["region","constituency"]},
  {"title":"Vice Chairman","levels":["ward"]},
  {"title":"Secretary","levels":["region","constituency","ward"]},
  {"title":"Deputy Secretary","levels":["region","constituency","ward"]},
  {"title":"Treasurer","levels":["region","constituency","ward"]},
  {"title":"Deputy Treasurer","levels":["region","constituency"]},
  {"title":"Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Organizer","levels":["region","constituency","ward"]},
  {"title":"Women''s Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Women''s Organizer","levels":["region","constituency"]},
  {"title":"Youth Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Youth Organizer","levels":["region","constituency"]},
  {"title":"Communications Officer","levels":["region","constituency","ward"]},
  {"title":"Nasara Coordinator","levels":["region","constituency","ward"]},
  {"title":"Zonal Coordinator","levels":["ward"]},
  {"title":"Chairman","levels":["branch"]},
  {"title":"Secretary","levels":["branch"]},
  {"title":"Organizer","levels":["branch"]},
  {"title":"Youth Organizer","levels":["branch"]},
  {"title":"Women''s Organizer","levels":["branch"]},
  {"title":"Communications Officer","levels":["branch"]},
  {"title":"Treasurer","levels":["branch"]},
  {"title":"Executive Member 1","levels":["branch"]},
  {"title":"Executive Member 2","levels":["branch"]}
]'::jsonb)
on conflict (key) do nothing;

-- -----------------------------------------------------------------
-- 3. SEQUENCE COUNTERS  (replaces seq:* keys)
-- -----------------------------------------------------------------
create table if not exists ndc_sequences (
  prefix  text primary key,
  current integer not null default 0
);

-- -----------------------------------------------------------------
-- 4. WARDS
-- -----------------------------------------------------------------
create table if not exists ndc_wards (
  id               text primary key,
  name             text not null,
  constituency_id  text not null,
  code             text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  created_by       text
);

-- -----------------------------------------------------------------
-- 5. BRANCHES
-- -----------------------------------------------------------------
create table if not exists ndc_branches (
  id          text primary key,
  name        text not null,
  ward_id     text not null references ndc_wards(id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  created_by  text
);

-- -----------------------------------------------------------------
-- 6. UNITS
-- -----------------------------------------------------------------
create table if not exists ndc_units (
  id          text primary key,
  name        text not null,
  branch_id   text not null references ndc_branches(id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  created_by  text
);

-- -----------------------------------------------------------------
-- 7. EXECUTIVES
-- -----------------------------------------------------------------
create table if not exists ndc_executives (
  id               text primary key,
  level            text not null,          -- region | constituency | ward | branch | unit
  region_id        text,
  constituency_id  text,
  ward_id          text references ndc_wards(id) on delete set null,
  branch_id        text references ndc_branches(id) on delete set null,
  unit_id          text references ndc_units(id) on delete set null,
  full_name        text not null,
  member_id        text,                   -- NDC party membership ID number
  position         text not null,
  gender           text,
  phone            text,
  email            text,
  dob              text,
  occupation       text,
  address          text,
  background       text,
  photo            text,                   -- base64 data-URL
  reg_no           text,
  status           text not null default 'active',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  created_by       text
);

-- -----------------------------------------------------------------
-- 8. AUDIT LOG
-- -----------------------------------------------------------------
create table if not exists ndc_audit (
  id           text primary key,
  ts           timestamptz not null default now(),
  username     text,
  role         text,
  action       text,
  entity_type  text,
  entity_id    text,
  detail       text
);

-- -----------------------------------------------------------------
-- 9. Row Level Security — anon key can do everything (app-enforces access)
--    For a production hardening pass, replace these with role-based policies.
-- -----------------------------------------------------------------
alter table ndc_users       enable row level security;
alter table ndc_settings    enable row level security;
alter table ndc_sequences   enable row level security;
alter table ndc_wards       enable row level security;
alter table ndc_branches    enable row level security;
alter table ndc_units       enable row level security;
alter table ndc_executives  enable row level security;
alter table ndc_audit       enable row level security;

-- Allow anon role full access (the app handles its own auth)
create policy "anon_all" on ndc_users      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_settings   for all to anon using (true) with check (true);
create policy "anon_all" on ndc_sequences  for all to anon using (true) with check (true);
create policy "anon_all" on ndc_wards      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_branches   for all to anon using (true) with check (true);
create policy "anon_all" on ndc_units      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_executives for all to anon using (true) with check (true);
create policy "anon_all" on ndc_audit      for all to anon using (true) with check (true);

-- -----------------------------------------------------------------
-- Helpful indexes
-- -----------------------------------------------------------------
create index if not exists idx_exec_level            on ndc_executives(level);
create index if not exists idx_exec_constituency     on ndc_executives(constituency_id);
create index if not exists idx_exec_region           on ndc_executives(region_id);
create index if not exists idx_wards_constituency    on ndc_wards(constituency_id);
create index if not exists idx_branches_ward         on ndc_branches(ward_id);
create index if not exists idx_units_branch          on ndc_units(branch_id);
create index if not exists idx_audit_ts              on ndc_audit(ts desc);

-- -----------------------------------------------------------------
-- Migration for existing deployments: add member_id if this schema
-- was applied before this column existed. Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_executives add column if not exists member_id text;

-- -----------------------------------------------------------------
-- Migration for existing deployments: add suspended flag and creator
-- tracking to ndc_users. Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_users add column if not exists suspended boolean not null default false;
alter table ndc_users add column if not exists created_by text;

-- -----------------------------------------------------------------
-- Migration for existing deployments: refresh the positions slate to
-- the v5.0 structure (Ward renamed to Zonal/Electoral Area with a
-- single Zonal Coordinator position, Unit level retired, and a new
-- nine-position Branch slate). Safe to re-run; this overwrites any
-- previous positions customisation with the standard slate below.
-- -----------------------------------------------------------------
update ndc_settings set value = '[
  {"title":"Chairman","levels":["region","constituency","ward"]},
  {"title":"First Vice Chairman","levels":["region","constituency"]},
  {"title":"Second Vice Chairman","levels":["region","constituency"]},
  {"title":"Vice Chairman","levels":["ward"]},
  {"title":"Secretary","levels":["region","constituency","ward"]},
  {"title":"Deputy Secretary","levels":["region","constituency","ward"]},
  {"title":"Treasurer","levels":["region","constituency","ward"]},
  {"title":"Deputy Treasurer","levels":["region","constituency"]},
  {"title":"Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Organizer","levels":["region","constituency","ward"]},
  {"title":"Women''s Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Women''s Organizer","levels":["region","constituency"]},
  {"title":"Youth Organizer","levels":["region","constituency","ward"]},
  {"title":"Deputy Youth Organizer","levels":["region","constituency"]},
  {"title":"Communications Officer","levels":["region","constituency","ward"]},
  {"title":"Nasara Coordinator","levels":["region","constituency","ward"]},
  {"title":"Zonal Coordinator","levels":["ward"]},
  {"title":"Chairman","levels":["branch"]},
  {"title":"Secretary","levels":["branch"]},
  {"title":"Organizer","levels":["branch"]},
  {"title":"Youth Organizer","levels":["branch"]},
  {"title":"Women''s Organizer","levels":["branch"]},
  {"title":"Communications Officer","levels":["branch"]},
  {"title":"Treasurer","levels":["branch"]},
  {"title":"Executive Member 1","levels":["branch"]},
  {"title":"Executive Member 2","levels":["branch"]}
]'::jsonb
where key = 'positions';

notify pgrst, 'reload schema';
