-- =====================================================
-- CAR HOUSE DATABASE SCHEMA & SETUP
-- Consolidated Database Script
-- =====================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLES

-- PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'customer',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT,
  icon TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  title TEXT,
  description TEXT,
  price DECIMAL(12,2) DEFAULT 0.0,
  compare_price DECIMAL(12,2),
  stock INTEGER DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0.0,
  image_url TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  brand TEXT,
  car_model TEXT,
  tags TEXT[],
  meta JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PRODUCT IMAGES
CREATE TABLE IF NOT EXISTS public.product_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  alt TEXT,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CARTS
CREATE TABLE IF NOT EXISTS public.carts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CART ITEMS
CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id UUID REFERENCES public.carts(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(cart_id, product_id)
);

-- ORDERS
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending',
  total_amount DECIMAL(12,2) DEFAULT 0.0,
  total DECIMAL(12,2), -- Alias or specific field used in code
  payment_method TEXT,
  shipping_address JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  title TEXT,
  unit_price DECIMAL(12,2) DEFAULT 0.0,
  quantity INTEGER DEFAULT 1,
  subtotal DECIMAL(12,2) DEFAULT 0.0,
  price DECIMAL(12,2), -- Alias or specific field used in code
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- FAVORITES
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- SERVICE TYPES
CREATE TABLE IF NOT EXISTS public.service_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  estimated_duration INTEGER, -- in minutes
  base_price DECIMAL(12,2),
  icon TEXT,
  is_active BOOLEAN DEFAULT true,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SERVICE TYPE PRODUCTS (SPARE PARTS FOR SERVICES)
CREATE TABLE IF NOT EXISTS public.service_type_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_type_id UUID REFERENCES public.service_types(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(service_type_id, product_id)
);

-- WORKSHOP BOOKINGS
CREATE TABLE IF NOT EXISTS public.workshop_bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  service_type_id UUID REFERENCES public.service_types(id) ON DELETE SET NULL,
  service_type TEXT NOT NULL,
  vehicle_info JSONB DEFAULT '{}',
  scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'scheduled',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. STORAGE SETUP
-- Create 'users' and 'avatars' buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('users', 'users', true) ON CONFLICT (id) DO UPDATE SET public = true;
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT (id) DO UPDATE SET public = true;

-- 4. RLS POLICIES

-- PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);
CREATE POLICY "Public profiles are viewable" ON public.profiles FOR SELECT TO public USING (true);

-- ORDERS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT TO authenticated USING ( auth.uid() = user_id );
CREATE POLICY "Users can create orders" ON public.orders FOR INSERT TO authenticated WITH CHECK ( auth.uid() = user_id );

-- ORDER ITEMS
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own order items" ON public.order_items FOR SELECT TO authenticated USING ( EXISTS ( SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid() ) );
CREATE POLICY "Users can create order items" ON public.order_items FOR INSERT TO authenticated WITH CHECK ( EXISTS ( SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid() ) );

-- STORAGE (Users Bucket)
CREATE POLICY "Public Access to Users Bucket" ON storage.objects FOR SELECT TO public USING ( bucket_id = 'users' );
CREATE POLICY "Users can upload avatars" ON storage.objects FOR INSERT TO authenticated WITH CHECK ( bucket_id = 'users' AND (storage.foldername(name))[1] = auth.uid()::text );
CREATE POLICY "Users can update avatars" ON storage.objects FOR UPDATE TO authenticated USING ( bucket_id = 'users' AND (storage.foldername(name))[1] = auth.uid()::text );
CREATE POLICY "Users can delete avatars" ON storage.objects FOR DELETE TO authenticated USING ( bucket_id = 'users' AND (storage.foldername(name))[1] = auth.uid()::text );

-- SERVICE PRODUCTS
ALTER TABLE public.service_type_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "service_products_select_all" ON public.service_type_products FOR SELECT USING (true);
