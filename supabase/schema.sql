create extension if not exists pgcrypto;

create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 kode_produk text not null unique,
 kategori text not null check (kategori in ('akun_ff','id_cantik','rental')),
 judul text not null,
 harga bigint, harga_coret bigint, harga_per_jam bigint, harga_per_hari bigint, harga_per_minggu bigint,
 status text not null default 'ready' check (status in ('ready','terjual','disewa','booked','maintenance')),
 level text, rank_cs text, rank_br text, nomor_id_ff text, jumlah_digit text, nickname text,
 total_bundle text, total_evo text, total_emote text, total_pet text, bind_akun text, keamanan_data text,
 syarat_sewa text, deskripsi text, foto_utama_url text,
 is_titipan boolean not null default false, nama_pemilik_titipan text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.product_images (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
 image_url text not null, urutan int not null default 0
);
create table if not exists public.titip_jual_requests (
 id uuid primary key default gen_random_uuid(), nama_buyer text not null, wa_buyer text not null,
 nama_akun text not null, level text, harga_mau bigint not null, deskripsi text, foto_url text,
 status text not null default 'menunggu' check(status in ('menunggu','diterima','ditolak','terjual')),
 created_at timestamptz not null default now()
);
create table if not exists public.banners (
 id uuid primary key default gen_random_uuid(), title text, subtitle text, image_url text, is_active boolean default true,
 created_at timestamptz default now()
);
create table if not exists public.testimonials (
 id uuid primary key default gen_random_uuid(), buyer_name text not null, message text not null,
 is_active boolean default true, created_at timestamptz default now()
);
create table if not exists public.settings (
 id int primary key default 1 check(id=1), store_name text not null default 'KIEE STURR',
 admin_whatsapp text not null default '', instagram_url text, tiktok_url text,
 warranty_text text, service_fee text, service_terms text, logo_url text
);
insert into public.settings(id,store_name) values(1,'KIEE STURR') on conflict(id) do nothing;

-- Auth users with this metadata role=admin are administrators.
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade,
 email text not null unique, created_at timestamptz default now()
);

alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.titip_jual_requests enable row level security;
alter table public.banners enable row level security;
alter table public.testimonials enable row level security;
alter table public.settings enable row level security;
alter table public.admins enable row level security;

create or replace function public.is_store_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.admins where user_id=auth.uid()); $$;

-- Public storefront reads; only authenticated admins can change catalog.
create policy "products public read" on public.products for select using (true);
create policy "products admin insert" on public.products for insert to authenticated with check (public.is_store_admin());
create policy "products admin update" on public.products for update to authenticated using (public.is_store_admin()) with check (public.is_store_admin());
create policy "products admin delete" on public.products for delete to authenticated using (public.is_store_admin());
create policy "images public read" on public.product_images for select using (true);
create policy "images admin all" on public.product_images for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

-- Public can submit a titip request; only admins can read/manage it.
create policy "titip public submit" on public.titip_jual_requests for insert to anon,authenticated with check (status='menunggu');
create policy "titip admin read" on public.titip_jual_requests for select to authenticated using (public.is_store_admin());
create policy "titip admin update" on public.titip_jual_requests for update to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

create policy "settings public read" on public.settings for select using (true);
create policy "settings admin update" on public.settings for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());
create policy "reviews public read" on public.testimonials for select using (is_active=true);
create policy "reviews admin all" on public.testimonials for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());
create policy "banners public read" on public.banners for select using (is_active=true);
create policy "banners admin all" on public.banners for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());
create policy "admins self read" on public.admins for select to authenticated using (user_id=auth.uid());

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('store-media','store-media',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "public view store media" on storage.objects for select using (bucket_id='store-media');
create policy "admin upload store media" on storage.objects for insert to authenticated with check (bucket_id='store-media' and public.is_store_admin());
create policy "admin update store media" on storage.objects for update to authenticated using (bucket_id='store-media' and public.is_store_admin()) with check (bucket_id='store-media' and public.is_store_admin());
create policy "admin delete store media" on storage.objects for delete to authenticated using (bucket_id='store-media' and public.is_store_admin());

-- Register admin row after creating the auth user (replace UUID/email).
-- insert into public.admins(user_id,email) values('AUTH_USER_UUID','admin@email.com');
