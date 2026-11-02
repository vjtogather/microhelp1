create table if not exists public.services (
  id uuid primary key default gen_random_uuid(), title text not null, slug text not null unique,
  summary text not null default '', description text not null default '', icon text,
  is_published boolean not null default false, sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.blog_posts (
  id uuid primary key default gen_random_uuid(), title text not null, slug text not null unique,
  excerpt text not null default '', body text not null default '', cover_image text,
  category text, tags text[] not null default '{}', is_published boolean not null default false,
  published_at timestamptz, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.site_settings (
  key text primary key, value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.services enable row level security;
alter table public.blog_posts enable row level security;
alter table public.site_settings enable row level security;

create policy "Public read published services" on public.services for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins manage services" on public.services for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public read published blog posts" on public.blog_posts for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins manage blog posts" on public.blog_posts for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public read site settings" on public.site_settings for select to anon, authenticated
  using (true);
create policy "Admins manage site settings" on public.site_settings for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create trigger services_set_updated_at before update on public.services
  for each row execute function public.set_updated_at();
create trigger blog_posts_set_updated_at before update on public.blog_posts
  for each row execute function public.set_updated_at();
create trigger site_settings_set_updated_at before update on public.site_settings
  for each row execute function public.set_updated_at();
