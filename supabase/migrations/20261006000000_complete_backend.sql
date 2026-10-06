-- =====================================================================
-- E-commerce app: missing tables, order function, triggers and security.
--
-- Run once in Supabase Dashboard -> SQL Editor -> New query -> Run.
-- It is safe to run again: everything is "if not exists" / "or replace".
--
-- Before this file the app referenced tables that did not exist
-- (orders, product_reviews, notifications), so placing an order,
-- reviews and notifications all failed.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Profiles: phone column, a row for every user, auto-create on sign-up
-- ---------------------------------------------------------------------
alter table public.profiles add column if not exists phone text;
alter table public.profiles add column if not exists avatar_url text;

-- Users who signed up before this trigger existed.
insert into public.profiles (id, email, name)
select u.id, coalesce(u.email, ''),
       coalesce(u.raw_user_meta_data ->> 'name',
                u.raw_user_meta_data ->> 'full_name',
                split_part(coalesce(u.email, ''), '@', 1))
  from auth.users u
on conflict (id) do nothing;


-- ---------------------------------------------------------------------
-- 2. Orders and their items
-- ---------------------------------------------------------------------
create table if not exists public.orders (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null default auth.uid()
                     references auth.users (id) on delete cascade,
  status           text not null default 'pending'
                     check (status in ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  subtotal         numeric(12, 2) not null default 0,
  discount         numeric(12, 2) not null default 0,
  delivery_fee     numeric(12, 2) not null default 0,
  tax              numeric(12, 2) not null default 0,
  total_amount     numeric(12, 2) not null default 0,
  coupon_code      text,
  payment_method   text not null default 'cash' check (payment_method in ('card', 'cash')),
  card_last4       text,
  address_id       bigint references public.shipping_addresses (id) on delete set null,
  -- Copy of the address at order time, so later edits don't change old orders.
  shipping_name    text,
  shipping_phone   text,
  shipping_address text,
  created_at       timestamptz not null default now()
);
create index if not exists orders_user_created_idx on public.orders (user_id, created_at desc);

create table if not exists public.order_items (
  id           bigint generated always as identity primary key,
  order_id     uuid not null references public.orders (id) on delete cascade,
  product_id   uuid references public.products (id) on delete set null,
  product_name text not null,
  image_url    text,
  unit_price   numeric(12, 2) not null,
  quantity     int not null check (quantity > 0)
);
create index if not exists order_items_order_idx on public.order_items (order_id);


-- ---------------------------------------------------------------------
-- 3. Coupons (sample code: WELCOME10 = 10% off)
-- ---------------------------------------------------------------------
create table if not exists public.coupons (
  code             text primary key check (code = upper(code)),
  discount_percent int not null check (discount_percent between 1 and 100),
  min_order        numeric(12, 2) not null default 0,
  active           boolean not null default true,
  expires_at       timestamptz
);
insert into public.coupons (code, discount_percent)
values ('WELCOME10', 10)
on conflict (code) do nothing;


-- ---------------------------------------------------------------------
-- 4. Product reviews (one per user and product) + rating on products
-- ---------------------------------------------------------------------
create table if not exists public.product_reviews (
  id         bigint generated always as identity primary key,
  product_id uuid not null references public.products (id) on delete cascade,
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  -- Copied from profiles on insert so other users' emails never need to be readable.
  user_name  text,
  rating     smallint not null check (rating between 1 and 5),
  comment    text not null default '' check (char_length(comment) <= 1000),
  created_at timestamptz not null default now(),
  unique (product_id, user_id)
);

create or replace function public.set_review_user_name()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  new.user_name := coalesce((select name from public.profiles where id = new.user_id), 'User');
  return new;
end;
$$;

drop trigger if exists product_reviews_set_user_name on public.product_reviews;
create trigger product_reviews_set_user_name
  before insert or update on public.product_reviews
  for each row execute function public.set_review_user_name();

-- Keeps products.rating / products.review_count equal to the real reviews.
create or replace function public.refresh_product_rating()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  pid uuid := coalesce(new.product_id, old.product_id);
begin
  update public.products p
     set rating = coalesce(
           (select round(avg(r.rating)::numeric, 1) from public.product_reviews r where r.product_id = pid),
           0),
         review_count = (select count(*) from public.product_reviews r where r.product_id = pid)
   where p.id = pid;
  return null;
end;
$$;

drop trigger if exists product_reviews_refresh_rating on public.product_reviews;
create trigger product_reviews_refresh_rating
  after insert or update or delete on public.product_reviews
  for each row execute function public.refresh_product_rating();


-- ---------------------------------------------------------------------
-- 5. Notifications (created automatically for orders and new accounts)
-- ---------------------------------------------------------------------
create table if not exists public.notifications (
  id              bigint generated always as identity primary key,
  user_id         uuid not null references auth.users (id) on delete cascade,
  title_key       text not null,
  description_key text not null,
  type            text not null default 'system' check (type in ('orders', 'system', 'promo')),
  order_id        uuid references public.orders (id) on delete cascade,
  is_read         boolean not null default false,
  created_at      timestamptz not null default now()
);
create index if not exists notifications_user_created_idx
  on public.notifications (user_id, created_at desc);

create or replace function public.notify_order_change()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.notifications (user_id, title_key, description_key, type, order_id)
    values (new.user_id, 'notif_order_pending_title', 'notif_order_pending_desc', 'orders', new.id);
  elsif new.status is distinct from old.status then
    insert into public.notifications (user_id, title_key, description_key, type, order_id)
    values (new.user_id,
            'notif_order_' || new.status || '_title',
            'notif_order_' || new.status || '_desc',
            'orders', new.id);
  end if;
  return new;
end;
$$;

drop trigger if exists orders_notify on public.orders;
create trigger orders_notify
  after insert or update of status on public.orders
  for each row execute function public.notify_order_change();

-- New account: create the profile row and a welcome notification.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id,
          coalesce(new.raw_user_meta_data ->> 'name',
                   new.raw_user_meta_data ->> 'full_name',
                   split_part(coalesce(new.email, ''), '@', 1)),
          coalesce(new.email, ''))
  on conflict (id) do nothing;

  insert into public.notifications (user_id, title_key, description_key, type)
  values (new.id, 'notif_welcome_title', 'notif_welcome_desc', 'system');
  return new;
exception when others then
  -- Never block a sign-up because of this bookkeeping.
  raise warning 'handle_new_user failed for %: %', new.id, sqlerrm;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ---------------------------------------------------------------------
-- 6. place_order(): one atomic step that prices the cart on the server,
--    applies the coupon, saves the order + items and empties the cart.
--    The app never sends prices, so totals cannot be tampered with.
-- ---------------------------------------------------------------------
create or replace function public.place_order(
  p_address_id     bigint,
  p_payment_method text,
  p_card_last4     text default null,
  p_coupon_code    text default null
)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  v_user     uuid := auth.uid();
  v_address  public.shipping_addresses%rowtype;
  v_subtotal numeric(12, 2);
  v_percent  int;
  v_discount numeric(12, 2) := 0;
  v_delivery numeric(12, 2) := 12;    -- keep in sync with CartViewModel.deliveryFee
  v_tax      numeric(12, 2);          -- 5%, keep in sync with CartViewModel.taxRate
  v_coupon   text := nullif(upper(trim(coalesce(p_coupon_code, ''))), '');
  v_order    uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_payment_method not in ('card', 'cash') then
    raise exception 'invalid_payment_method';
  end if;

  select * into v_address
    from public.shipping_addresses
   where id = p_address_id and user_id = v_user;
  if not found then
    raise exception 'address_not_found';
  end if;

  select coalesce(sum(p.price * c.quantity), 0) into v_subtotal
    from public.cart_items c
    join public.products p on p.id = c.product_id
   where c.user_id = v_user;
  if v_subtotal = 0 then
    raise exception 'cart_empty';
  end if;

  if v_coupon is not null then
    select discount_percent into v_percent
      from public.coupons
     where code = v_coupon
       and active
       and (expires_at is null or expires_at > now())
       and min_order <= v_subtotal;
    if not found then
      raise exception 'invalid_coupon';
    end if;
    v_discount := round(v_subtotal * v_percent / 100.0, 2);
  end if;

  v_tax := round((v_subtotal - v_discount) * 0.05, 2);

  insert into public.orders (
    user_id, subtotal, discount, delivery_fee, tax, total_amount, coupon_code,
    payment_method, card_last4, address_id,
    shipping_name, shipping_phone, shipping_address)
  values (
    v_user, v_subtotal, v_discount, v_delivery, v_tax,
    v_subtotal - v_discount + v_delivery + v_tax, v_coupon,
    p_payment_method,
    case when p_payment_method = 'card' then right(p_card_last4, 4) end,
    v_address.id, v_address.full_name, v_address.phone_number,
    concat_ws(', ', v_address.street_address, v_address.city,
              v_address.postal_code, v_address.country))
  returning id into v_order;

  insert into public.order_items (order_id, product_id, product_name, image_url, unit_price, quantity)
  select v_order, p.id, p.name, p.images[1], p.price, c.quantity
    from public.cart_items c
    join public.products p on p.id = c.product_id
   where c.user_id = v_user;

  delete from public.cart_items where user_id = v_user;

  return v_order;
end;
$$;

revoke all on function public.place_order(bigint, text, text, text) from public, anon;
grant execute on function public.place_order(bigint, text, text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 7. One cart line / wishlist entry per product (skipped if duplicates
--    already exist; clean them up and run again).
-- ---------------------------------------------------------------------
do $$
begin
  alter table public.cart_items add constraint cart_items_user_product_key unique (user_id, product_id);
exception when duplicate_table or duplicate_object then null;
          when others then raise notice 'cart_items unique constraint skipped: %', sqlerrm;
end $$;

do $$
begin
  alter table public.wishlist add constraint wishlist_user_product_key unique (user_id, product_id);
exception when duplicate_table or duplicate_object then null;
          when others then raise notice 'wishlist unique constraint skipped: %', sqlerrm;
end $$;

-- Fill categories from the products if the table is empty.
do $$
begin
  insert into public.categories (name)
  select distinct p.category_name
    from public.products p
   where p.category_name is not null
     and not exists (select 1 from public.categories c where c.name = p.category_name);
exception when others then
  raise notice 'categories not seeded: %', sqlerrm;
end $$;


-- ---------------------------------------------------------------------
-- 8. Row Level Security: every user sees and changes only their own rows.
--    Existing policies on these tables are dropped first so that no older,
--    more permissive policy stays active (at the time of writing the
--    profiles table - names and emails - was readable with the public key).
-- ---------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename, policyname
      from pg_policies
     where schemaname = 'public'
       and tablename in ('profiles', 'cart_items', 'wishlist', 'shipping_addresses',
                         'orders', 'order_items', 'product_reviews', 'notifications',
                         'coupons', 'products', 'categories')
  loop
    execute format('drop policy %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end $$;

alter table public.products           enable row level security;
alter table public.categories         enable row level security;
alter table public.profiles           enable row level security;
alter table public.cart_items         enable row level security;
alter table public.wishlist           enable row level security;
alter table public.shipping_addresses enable row level security;
alter table public.orders             enable row level security;
alter table public.order_items        enable row level security;
alter table public.product_reviews    enable row level security;
alter table public.notifications      enable row level security;
alter table public.coupons            enable row level security;

-- Catalog: readable by everyone, changed only from the dashboard.
create policy "products: read" on public.products
  for select to anon, authenticated using (true);
create policy "categories: read" on public.categories
  for select to anon, authenticated using (true);

create policy "profiles: own row" on public.profiles
  for all to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy "cart_items: own rows" on public.cart_items
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "wishlist: own rows" on public.wishlist
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "shipping_addresses: own rows" on public.shipping_addresses
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Orders are created only through place_order(); users can read their own.
create policy "orders: read own" on public.orders
  for select to authenticated using (user_id = auth.uid());

create policy "order_items: read own" on public.order_items
  for select to authenticated
  using (exists (select 1 from public.orders o
                  where o.id = order_items.order_id and o.user_id = auth.uid()));

create policy "product_reviews: read" on public.product_reviews
  for select to anon, authenticated using (true);
create policy "product_reviews: write own" on public.product_reviews
  for insert to authenticated with check (user_id = auth.uid());
create policy "product_reviews: update own" on public.product_reviews
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "product_reviews: delete own" on public.product_reviews
  for delete to authenticated using (user_id = auth.uid());

create policy "notifications: read own" on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy "notifications: mark own read" on public.notifications
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "coupons: read active" on public.coupons
  for select to authenticated using (active);


-- ---------------------------------------------------------------------
-- 9. Storage bucket for profile photos: avatars/<user id>/avatar.jpg
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars: public read" on storage.objects;
create policy "avatars: public read" on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists "avatars: owner insert" on storage.objects;
create policy "avatars: owner insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars: owner update" on storage.objects;
create policy "avatars: owner update" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars: owner delete" on storage.objects;
create policy "avatars: owner delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
