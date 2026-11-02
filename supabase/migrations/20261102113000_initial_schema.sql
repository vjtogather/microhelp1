create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.admin_users au where au.user_id = auth.uid()); $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(), title text not null, slug text not null unique,
  summary text not null default '', description text not null default '', cover_image text,
  demo_url text, source_url text, price_inr integer not null default 0 check (price_inr >= 0),
  is_featured boolean not null default false, is_published boolean not null default false,
  sort_order integer not null default 0, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(), title text not null, slug text not null unique,
  summary text not null default '', description text not null default '', cover_image text,
  price_inr integer not null default 0 check (price_inr >= 0), is_published boolean not null default false,
  sort_order integer not null default 0, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.gallery_items (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null default '',
  image_url text not null, alt_text text not null default '', sort_order integer not null default 0,
  is_published boolean not null default false, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(), name text not null, email text not null,
  phone text, subject text, message text not null,
  status text not null default 'new' check (status in ('new','in_progress','closed')),
  created_at timestamptz not null default now()
);
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(), customer_name text not null, customer_email text not null,
  customer_phone text, item_type text not null check (item_type in ('project','course')),
  item_id uuid not null, item_title text not null, amount_inr integer not null check (amount_inr > 0),
  currency text not null default 'INR' check (currency = 'INR'),
  status text not null default 'pending' check (status in ('pending','paid','failed','refunded')),
  razorpay_order_id text unique, razorpay_payment_id text unique, paid_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create index if not exists projects_public_sort_idx on public.projects (is_published, sort_order);
create index if not exists courses_public_sort_idx on public.courses (is_published, sort_order);
create index if not exists gallery_public_sort_idx on public.gallery_items (is_published, sort_order);
create index if not exists enquiries_created_idx on public.enquiries (created_at desc);
create index if not exists orders_created_idx on public.orders (created_at desc);

alter table public.admin_users enable row level security;
alter table public.projects enable row level security;
alter table public.courses enable row level security;
alter table public.gallery_items enable row level security;
alter table public.enquiries enable row level security;
alter table public.orders enable row level security;

create policy "Admins manage admin users" on public.admin_users for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public read published projects" on public.projects for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins manage projects" on public.projects for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public read published courses" on public.courses for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins manage courses" on public.courses for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public read published gallery" on public.gallery_items for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins manage gallery" on public.gallery_items for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Public submit enquiries" on public.enquiries for insert to anon, authenticated
  with check (length(trim(name)) between 1 and 120 and length(trim(email)) between 3 and 254
    and length(trim(message)) between 1 and 10000);
create policy "Admins read and manage enquiries" on public.enquiries for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage orders" on public.orders for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

insert into storage.buckets (id, name, public) values ('portfolio-media', 'portfolio-media', true)
on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('course-files', 'course-files', false)
on conflict (id) do nothing;
create policy "Public read portfolio media" on storage.objects for select to anon, authenticated
  using (bucket_id = 'portfolio-media');
create policy "Admins upload media" on storage.objects for insert to authenticated
  with check (bucket_id in ('portfolio-media','course-files') and public.is_admin());
create policy "Admins update media" on storage.objects for update to authenticated
  using (bucket_id in ('portfolio-media','course-files') and public.is_admin())
  with check (bucket_id in ('portfolio-media','course-files') and public.is_admin());
create policy "Admins delete media" on storage.objects for delete to authenticated
  using (bucket_id in ('portfolio-media','course-files') and public.is_admin());

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = ''
as $$ begin new.updated_at = now(); return new; end; $$;
create trigger projects_set_updated_at before update on public.projects
  for each row execute function public.set_updated_at();
create trigger courses_set_updated_at before update on public.courses
  for each row execute function public.set_updated_at();
create trigger gallery_set_updated_at before update on public.gallery_items
  for each row execute function public.set_updated_at();
create trigger orders_set_updated_at before update on public.orders
  for each row execute function public.set_updated_at();
