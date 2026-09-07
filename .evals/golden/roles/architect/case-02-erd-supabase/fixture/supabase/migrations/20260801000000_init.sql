create table employers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id),
  name text not null,
  city text not null
);
create table jobs (
  id uuid primary key default gen_random_uuid(),
  employer_id uuid not null references employers(id),
  title text not null,
  city text not null,
  created_at timestamptz not null default now()
);
create table applicants (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references jobs(id),
  name text not null,
  email text not null,
  phone text,
  applied_at timestamptz not null default now()
);
alter table employers enable row level security;
alter table jobs enable row level security;
create policy employers_own on employers for all using (auth.uid() = owner_id);
create policy jobs_by_owner on jobs for all using (
  exists (select 1 from employers e where e.id = jobs.employer_id and e.owner_id = auth.uid())
);
