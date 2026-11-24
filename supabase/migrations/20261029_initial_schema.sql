-- =============================================================================
-- MIGRATION: NONGKI MOBILE APP INITIAL SCHEMA
-- Tanggal: 2026-10-29
-- =============================================================================

-- 1. PROFILES TABLE (Terkoneksi dengan auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'kasir', 'admin', 'owner')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security (RLS) Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pengguna dapat melihat profil miliknya sendiri"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Pengguna dapat memperbarui profil miliknya sendiri"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Pendaftaran baru hanya dapat membuat akun role customer"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id AND role = 'customer');

-- Trigger auto insert profile saat user register via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name, phone, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone',
        'customer'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- 2. PLACES TABLE (Tempat Nongkrong)
CREATE TABLE IF NOT EXISTS public.places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Kafe', 'Outdoor', 'Working Space', 'Restoran', 'Kedai')),
    description TEXT,
    address TEXT,
    image_url TEXT,
    image_urls TEXT[] DEFAULT '{}',
    rating NUMERIC(2,1) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    price_min INT NOT NULL DEFAULT 0,
    price_max INT NOT NULL DEFAULT 0,
    opening_hours TEXT,
    is_open BOOLEAN DEFAULT TRUE,
    facilities TEXT[] DEFAULT '{}',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accepts_order BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Places: Publik dapat membaca data tempat nongkrong
ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Publik dapat melihat data tempat nongkrong"
    ON public.places FOR SELECT
    TO PUBLIC
    USING (true);


-- 3. MENU ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price INT NOT NULL,
    image_url TEXT,
    category TEXT NOT NULL DEFAULT 'Kopi' CHECK (category IN ('Kopi', 'Non-Kopi', 'Makanan', 'Camilan')),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Publik dapat melihat daftar menu"
    ON public.menu_items FOR SELECT
    TO PUBLIC
    USING (true);


-- 4. FAVORITES TABLE
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, place_id)
);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pengguna dapat melihat daftar favorit miliknya"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menambah favorit miliknya"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus favorit miliknya"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);


-- 5. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    place_id UUID NOT NULL REFERENCES public.places(id),
    place_name TEXT NOT NULL,
    place_address TEXT,
    subtotal INT NOT NULL,
    service_fee INT NOT NULL DEFAULT 2000,
    total INT NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    payment_status TEXT NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'paid', 'cancelled')),
    status TEXT NOT NULL DEFAULT 'processing' CHECK (status IN ('pending_payment', 'processing', 'ready', 'completed', 'cancelled', 'failed')),
    dining_option TEXT NOT NULL DEFAULT 'dine_in' CHECK (dining_option IN ('dine_in', 'takeaway')),
    table_number TEXT,
    notes TEXT,
    has_reviewed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pengguna dapat melihat pesanan miliknya"
    ON public.orders FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat pesanan baru"
    ON public.orders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membatalkan pesanan yang belum diproses"
    ON public.orders FOR UPDATE
    USING (auth.uid() = user_id AND status = 'processing')
    WITH CHECK (status = 'cancelled' AND payment_status = 'cancelled');


-- 6. ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES public.menu_items(id),
    name TEXT NOT NULL,
    price INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal INT NOT NULL,
    note TEXT
);

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pengguna dapat melihat rincian item pesanannya"
    ON public.order_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Pengguna dapat memasukkan rincian item pesanannya"
    ON public.order_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );


-- 7. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT,
    order_id UUID REFERENCES public.orders(id),
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Publik dapat membaca ulasan tempat nongkrong"
    ON public.reviews FOR SELECT
    TO PUBLIC
    USING (true);

CREATE POLICY "Pengguna terdaftar dapat mengirim ulasan"
    ON public.reviews FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- INDEXES UNTUK PERFORMA QUERY
CREATE INDEX IF NOT EXISTS idx_places_category ON public.places(category);
CREATE INDEX IF NOT EXISTS idx_places_price ON public.places(price_min, price_max);
CREATE INDEX IF NOT EXISTS idx_menu_items_place_id ON public.menu_items(place_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_place_id ON public.reviews(place_id);

