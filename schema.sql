-- Execute no SQL Editor do Supabase.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'member' check (role in ('admin','member')),
  created_at timestamptz not null default now()
);

create table if not exists public.demandas (
  id uuid primary key default gen_random_uuid(),
  demanda text not null,
  solicitante text,
  contato text,
  canal text,
  categoria text,
  prioridade text not null default 'Média' check (prioridade in ('Baixa','Média','Alta','Urgente')),
  prazo date,
  status text not null default 'Não iniciado' check (status in ('Não iniciado','Em andamento','Concluído','Cancelado')),
  last_note text,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

insert into public.settings(key,value) values
('canais','["WhatsApp","Telefone","Rua","Instagram"]'::jsonb),
('categorias','["Atendimento","Cadastro","Agendamento","Documento"]'::jsonb)
on conflict(key) do nothing;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id,full_name,role) values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), 'member') on conflict(id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

alter table public.profiles enable row level security;
alter table public.demandas enable row level security;
alter table public.settings enable row level security;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated" on public.profiles for select to authenticated using (true);
drop policy if exists "profiles_admin_update" on public.profiles;
create policy "profiles_admin_update" on public.profiles for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "demandas_select_authenticated" on public.demandas;
create policy "demandas_select_authenticated" on public.demandas for select to authenticated using (true);
drop policy if exists "demandas_insert_authenticated" on public.demandas;
create policy "demandas_insert_authenticated" on public.demandas for insert to authenticated with check (created_by=auth.uid());
drop policy if exists "demandas_update_authenticated" on public.demandas;
create policy "demandas_update_authenticated" on public.demandas for update to authenticated using (true) with check (true);
drop policy if exists "demandas_delete_admin" on public.demandas;
create policy "demandas_delete_admin" on public.demandas for delete to authenticated using (public.is_admin());

drop policy if exists "settings_select_authenticated" on public.settings;
create policy "settings_select_authenticated" on public.settings for select to authenticated using (true);
drop policy if exists "settings_admin_write" on public.settings;
create policy "settings_admin_write" on public.settings for all to authenticated using (public.is_admin()) with check (public.is_admin());

create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists demandas_updated_at on public.demandas;
create trigger demandas_updated_at before update on public.demandas for each row execute procedure public.set_updated_at();

-- Depois de criar sua primeira conta, torne-a administradora executando:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='SEU_EMAIL');
