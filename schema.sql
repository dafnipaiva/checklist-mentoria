-- ============================================================
-- CHECKLIST MENTORIA — Schema Supabase
-- Cole este SQL inteiro no Supabase > SQL Editor > Run
-- ============================================================

-- 1. Perfis (estende o auth.users do Supabase)
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  nome text not null,
  role text not null check (role in ('mentora', 'mentorada')),
  created_at timestamptz default now()
);

-- 2. Fases (criadas pela mentorada)
create table public.fases (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  titulo text not null,
  ordem int not null default 0,
  created_at timestamptz default now()
);

-- 3. Itens de cada fase
create table public.itens (
  id uuid default gen_random_uuid() primary key,
  fase_id uuid references public.fases(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  texto text not null,
  concluido boolean default false,
  evidencia_url text,
  ordem int not null default 0,
  updated_at timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.fases enable row level security;
alter table public.itens enable row level security;

-- Profiles: cada um vê só o próprio, mentora vê todos
create policy "proprio perfil" on public.profiles
  for all using (auth.uid() = id);

create policy "mentora ve todos perfis" on public.profiles
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'mentora'
    )
  );

-- Fases: mentorada gerencia as próprias, mentora lê todas
create policy "mentorada gerencia proprias fases" on public.fases
  for all using (auth.uid() = user_id);

create policy "mentora le todas fases" on public.fases
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'mentora'
    )
  );

-- Itens: mentorada gerencia os próprios, mentora lê todos
create policy "mentorada gerencia proprios itens" on public.itens
  for all using (auth.uid() = user_id);

create policy "mentora le todos itens" on public.itens
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'mentora'
    )
  );

-- ============================================================
-- TRIGGER: cria perfil automaticamente ao registrar usuário
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nome, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'role', 'mentorada')
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
