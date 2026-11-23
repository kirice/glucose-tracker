-- GlucoNote initial schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  diabetes_type text check (diabetes_type in ('type1','type2','other')),
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  preferred_unit text not null default 'mmol/L' check (preferred_unit in ('mmol/L','mg/dL')),
  timezone text not null default 'UTC',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.glucose_readings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  value_mmol numeric(8,3) not null check (value_mmol > 0 and value_mmol < 100),
  entered_value numeric(8,3) not null check (entered_value > 0 and entered_value < 1000),
  entered_unit text not null check (entered_unit in ('mmol/L','mg/dL')),
  context text not null default 'Другое',
  note text,
  measured_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists glucose_readings_user_measured_idx on public.glucose_readings(user_id, measured_at desc);

alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;
alter table public.glucose_readings enable row level security;

create policy "profiles_select_own" on public.profiles for select to authenticated using (id = (select auth.uid()));
create policy "profiles_insert_own" on public.profiles for insert to authenticated with check (id = (select auth.uid()));
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "settings_select_own" on public.user_settings for select to authenticated using (user_id = (select auth.uid()));
create policy "settings_insert_own" on public.user_settings for insert to authenticated with check (user_id = (select auth.uid()));
create policy "settings_update_own" on public.user_settings for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "readings_select_own" on public.glucose_readings for select to authenticated using (user_id = (select auth.uid()));
create policy "readings_insert_own" on public.glucose_readings for insert to authenticated with check (user_id = (select auth.uid()));
create policy "readings_update_own" on public.glucose_readings for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "readings_delete_own" on public.glucose_readings for delete to authenticated using (user_id = (select auth.uid()));

-- Create a profile/settings row for each newly registered user.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email, diabetes_type) values (new.id, new.email, nullif(new.raw_user_meta_data->>'diabetes_type',''))
  on conflict (id) do update set email = excluded.email, diabetes_type = excluded.diabetes_type;
  insert into public.user_settings (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Never expose the service_role key in the browser. RLS is mandatory.
