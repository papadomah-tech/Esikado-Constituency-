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
  scope_branch_id   text,
  scope_branch_name text,
  is_branch_secretary boolean not null default false,
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
  {"title":"Chairman","levels":["region","ward"]},
  {"title":"First Vice Chairman","levels":["region"]},
  {"title":"Second Vice Chairman","levels":["region"]},
  {"title":"Vice Chairman","levels":["ward"]},
  {"title":"Secretary","levels":["region","ward"]},
  {"title":"Deputy Secretary","levels":["region","ward"]},
  {"title":"Treasurer","levels":["region","ward"]},
  {"title":"Deputy Treasurer","levels":["region"]},
  {"title":"Organizer","levels":["region","ward"]},
  {"title":"Deputy Organizer","levels":["region","ward"]},
  {"title":"Women''s Organizer","levels":["region","ward"]},
  {"title":"Deputy Women''s Organizer","levels":["region"]},
  {"title":"Youth Organizer","levels":["region","ward"]},
  {"title":"Deputy Youth Organizer","levels":["region"]},
  {"title":"Communications Officer","levels":["region","ward"]},
  {"title":"Nasara Coordinator","levels":["region","ward"]},
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
  code        text,
  ward_id     text not null references ndc_wards(id) on delete cascade,
  nominations_open boolean not null default false,
  election_cycle  integer not null default 1,
  election_status text not null default 'pending', -- pending | completed
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
-- 10. BRANCH REGISTER
--     Register of all registered party members at branch level,
--     compiled by the Branch Secretary. Each member gets an
--     auto-generated registry number (separate from the NDC member
--     ID below) used to verify identity when filing branch
--     nominations. This is effectively the branch's pre-executive
--     member profile: when a member wins a branch election, their
--     register entry becomes their executive record.
-- -----------------------------------------------------------------
create table if not exists ndc_branch_register (
  id           text primary key,
  branch_id    text not null references ndc_branches(id) on delete cascade,
  registry_no  text not null,
  full_name    text not null,
  member_id    text,
  phone        text,
  email        text,
  gender       text,
  dob          text,
  occupation   text,
  address      text,
  background   text,
  photo        text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  created_by   text,
  unique(branch_id, registry_no)
);

-- -----------------------------------------------------------------
-- 11. NOMINATIONS
--     Filed by registered members (verified by registry number against
--     the Branch Register) for a single branch position. Reviewed by
--     National Admin / Constituency Admin: pending -> cleared/rejected.
-- -----------------------------------------------------------------
create table if not exists ndc_nominations (
  id           text primary key,
  branch_id    text not null references ndc_branches(id) on delete cascade,
  registry_no  text not null,
  full_name    text not null,
  phone        text,
  gender       text,
  dob          text,
  position     text not null,
  status       text not null default 'pending', -- pending | cleared | rejected
  filed_at     timestamptz not null default now(),
  reviewed_at  timestamptz,
  reviewed_by  text,
  notified_at  timestamptz
);

-- -----------------------------------------------------------------
-- 12. ELECTION RESULTS
--     Vote counts entered by the Branch Secretary for each cleared
--     candidate, for one election cycle per branch at a time. The
--     branch's cycle number and status are tracked on ndc_branches
--     (election_cycle, election_status). Recording results with
--     status 'completed' creates/updates the winner's executive
--     record for that position (see app logic).
-- -----------------------------------------------------------------
create table if not exists ndc_election_results (
  id            text primary key,
  branch_id     text not null references ndc_branches(id) on delete cascade,
  cycle         integer not null default 1,
  nomination_id text not null references ndc_nominations(id) on delete cascade,
  position      text not null,
  votes         integer not null default 0,
  is_winner     boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique(branch_id, cycle, nomination_id)
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
alter table ndc_branch_register enable row level security;
alter table ndc_nominations enable row level security;
alter table ndc_election_results enable row level security;

-- Allow anon role full access (the app handles its own auth)
drop policy if exists "anon_all" on ndc_users;
drop policy if exists "anon_all" on ndc_settings;
drop policy if exists "anon_all" on ndc_sequences;
drop policy if exists "anon_all" on ndc_wards;
drop policy if exists "anon_all" on ndc_branches;
drop policy if exists "anon_all" on ndc_units;
drop policy if exists "anon_all" on ndc_executives;
drop policy if exists "anon_all" on ndc_audit;
drop policy if exists "anon_all" on ndc_branch_register;
drop policy if exists "anon_all" on ndc_nominations;
drop policy if exists "anon_all" on ndc_election_results;
create policy "anon_all" on ndc_users      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_settings   for all to anon using (true) with check (true);
create policy "anon_all" on ndc_sequences  for all to anon using (true) with check (true);
create policy "anon_all" on ndc_wards      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_branches   for all to anon using (true) with check (true);
create policy "anon_all" on ndc_units      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_executives for all to anon using (true) with check (true);
create policy "anon_all" on ndc_audit      for all to anon using (true) with check (true);
create policy "anon_all" on ndc_branch_register for all to anon using (true) with check (true);
create policy "anon_all" on ndc_nominations for all to anon using (true) with check (true);
create policy "anon_all" on ndc_election_results for all to anon using (true) with check (true);

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
create index if not exists idx_branch_register_branch on ndc_branch_register(branch_id);
create index if not exists idx_nominations_branch    on ndc_nominations(branch_id);
create index if not exists idx_nominations_status    on ndc_nominations(status);
create index if not exists idx_election_results_branch on ndc_election_results(branch_id, cycle);

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
  {"title":"Chairman","levels":["region","ward"]},
  {"title":"First Vice Chairman","levels":["region"]},
  {"title":"Second Vice Chairman","levels":["region"]},
  {"title":"Vice Chairman","levels":["ward"]},
  {"title":"Secretary","levels":["region","ward"]},
  {"title":"Deputy Secretary","levels":["region","ward"]},
  {"title":"Treasurer","levels":["region","ward"]},
  {"title":"Deputy Treasurer","levels":["region"]},
  {"title":"Organizer","levels":["region","ward"]},
  {"title":"Deputy Organizer","levels":["region","ward"]},
  {"title":"Women''s Organizer","levels":["region","ward"]},
  {"title":"Deputy Women''s Organizer","levels":["region"]},
  {"title":"Youth Organizer","levels":["region","ward"]},
  {"title":"Deputy Youth Organizer","levels":["region"]},
  {"title":"Communications Officer","levels":["region","ward"]},
  {"title":"Nasara Coordinator","levels":["region","ward"]},
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

-- -----------------------------------------------------------------
-- Migration for existing deployments: add Branch Secretary scoping to
-- ndc_users and create the Branch Register table if this schema was
-- applied before they existed. Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_users add column if not exists scope_branch_id text;
alter table ndc_users add column if not exists scope_branch_name text;
alter table ndc_users add column if not exists is_branch_secretary boolean not null default false;

create table if not exists ndc_branch_register (
  id           text primary key,
  branch_id    text not null references ndc_branches(id) on delete cascade,
  registry_no  text not null,
  full_name    text not null,
  phone        text,
  gender       text,
  dob          text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  created_by   text,
  unique(branch_id, registry_no)
);
alter table ndc_branch_register enable row level security;
drop policy if exists "anon_all" on ndc_branch_register;
create policy "anon_all" on ndc_branch_register for all to anon using (true) with check (true);
create index if not exists idx_branch_register_branch on ndc_branch_register(branch_id);

-- -----------------------------------------------------------------
-- Migration for existing deployments: expand the Branch Register to a
-- full member profile (the v5.1 "members become executives on
-- election" model). Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_branch_register add column if not exists member_id  text;
alter table ndc_branch_register add column if not exists email      text;
alter table ndc_branch_register add column if not exists occupation text;
alter table ndc_branch_register add column if not exists address    text;
alter table ndc_branch_register add column if not exists background text;
alter table ndc_branch_register add column if not exists photo      text;

-- -----------------------------------------------------------------
-- Migration for existing deployments: add the nominations window flag
-- to ndc_branches and create the nominations table if this schema was
-- applied before they existed. Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_branches add column if not exists nominations_open boolean not null default false;

create table if not exists ndc_nominations (
  id           text primary key,
  branch_id    text not null references ndc_branches(id) on delete cascade,
  registry_no  text not null,
  full_name    text not null,
  phone        text,
  gender       text,
  dob          text,
  position     text not null,
  status       text not null default 'pending',
  filed_at     timestamptz not null default now(),
  reviewed_at  timestamptz,
  reviewed_by  text,
  notified_at  timestamptz
);
alter table ndc_nominations enable row level security;
drop policy if exists "anon_all" on ndc_nominations;
create policy "anon_all" on ndc_nominations for all to anon using (true) with check (true);
create index if not exists idx_nominations_branch on ndc_nominations(branch_id);
create index if not exists idx_nominations_status on ndc_nominations(status);

-- -----------------------------------------------------------------
-- Migration for existing deployments: add election cycle tracking to
-- ndc_branches and create the election results table if this schema
-- was applied before they existed. Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_branches add column if not exists election_cycle integer not null default 1;
alter table ndc_branches add column if not exists election_status text not null default 'pending';

create table if not exists ndc_election_results (
  id            text primary key,
  branch_id     text not null references ndc_branches(id) on delete cascade,
  cycle         integer not null default 1,
  nomination_id text not null references ndc_nominations(id) on delete cascade,
  position      text not null,
  votes         integer not null default 0,
  is_winner     boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique(branch_id, cycle, nomination_id)
);
alter table ndc_election_results enable row level security;
drop policy if exists "anon_all" on ndc_election_results;
create policy "anon_all" on ndc_election_results for all to anon using (true) with check (true);
create index if not exists idx_election_results_branch on ndc_election_results(branch_id, cycle);

-- -----------------------------------------------------------------
-- Migration: add branch code column (used as registry number prefix).
-- Safe to re-run.
-- -----------------------------------------------------------------
alter table ndc_branches add column if not exists code text;

-- -----------------------------------------------------------------
-- Migration: remove constituency level from positions slate (v5.2).
-- Executives are now tracked at Region and Zonal/Electoral Area
-- level only. Existing constituency-level executive records remain
-- in the database but are excluded from all views.
-- -----------------------------------------------------------------
update ndc_settings set value = '[
  {"title":"Chairman","levels":["region","ward"]},
  {"title":"First Vice Chairman","levels":["region"]},
  {"title":"Second Vice Chairman","levels":["region"]},
  {"title":"Vice Chairman","levels":["ward"]},
  {"title":"Secretary","levels":["region","ward"]},
  {"title":"Deputy Secretary","levels":["region","ward"]},
  {"title":"Treasurer","levels":["region","ward"]},
  {"title":"Deputy Treasurer","levels":["region"]},
  {"title":"Organizer","levels":["region","ward"]},
  {"title":"Deputy Organizer","levels":["region","ward"]},
  {"title":"Women''s Organizer","levels":["region","ward"]},
  {"title":"Deputy Women''s Organizer","levels":["region"]},
  {"title":"Youth Organizer","levels":["region","ward"]},
  {"title":"Deputy Youth Organizer","levels":["region"]},
  {"title":"Communications Officer","levels":["region","ward"]},
  {"title":"Nasara Coordinator","levels":["region","ward"]},
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
