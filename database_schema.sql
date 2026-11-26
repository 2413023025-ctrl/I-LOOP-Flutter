-- ==============================================================================
-- I'LOOP: Circular Economy & Reuse Marketplace
-- Supabase Database Schema with Complete Row Level Security (RLS) & Triggers
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUMS
DO $$ BEGIN
    CREATE TYPE listing_type_enum AS ENUM ('sell', 'swap', 'share');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE item_status_enum AS ENUM ('available', 'reserved', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE proposal_status_enum AS ENUM ('pending', 'accepted', 'rejected', 'completed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE proposal_type_enum AS ENUM ('swap', 'share');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'Pengguna I''LOOP',
    avatar_url TEXT,
    city TEXT DEFAULT 'Jakarta',
    campus_or_area TEXT,
    phone_number TEXT,
    items_saved_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: Otomatis buat Profile saat user Sign Up di Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, city)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pengguna I''LOOP'),
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_user_meta_data->>'city', 'Bandar Lampung')
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    city = COALESCE(EXCLUDED.city, public.profiles.city);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. ITEMS TABLE (Marketplace, Swap, Share)
CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    listing_type listing_type_enum NOT NULL DEFAULT 'sell',
    price NUMERIC(12, 2) DEFAULT 0,
    swap_wishlist TEXT,
    category TEXT NOT NULL,
    condition TEXT NOT NULL,
    status item_status_enum DEFAULT 'available',
    city TEXT NOT NULL DEFAULT 'Jakarta',
    area_notes TEXT,
    primary_image_url TEXT,
    view_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ITEM IMAGES TABLE (Multi-foto)
CREATE TABLE IF NOT EXISTS public.item_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. SWAP & SHARE PROPOSALS
CREATE TABLE IF NOT EXISTS public.swap_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_type proposal_type_enum NOT NULL DEFAULT 'swap',
    target_item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    offered_item_id UUID REFERENCES public.items(id) ON DELETE SET NULL,
    proposer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    note TEXT,
    status proposal_status_enum DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CHAT ROOMS & REALTIME MESSAGES
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID REFERENCES public.items(id) ON DELETE SET NULL,
    user_one UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_two UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    last_message TEXT,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_one, user_two, item_id)
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. REUSE & UPCYCLING COMMUNITY
CREATE TABLE IF NOT EXISTS public.upcycle_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content_materials TEXT NOT NULL,
    content_steps TEXT NOT NULL,
    cover_image_url TEXT NOT NULL,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.upcycle_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES public.upcycle_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.upcycle_likes (
    post_id UUID NOT NULL REFERENCES public.upcycle_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(post_id, user_id)
);

-- ==============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Aktifkan RLS di setiap tabel
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swap_proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upcycle_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upcycle_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upcycle_likes ENABLE ROW LEVEL SECURITY;

-- POLICIES: PROFILES
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Profiles are viewable by everyone" 
  ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" 
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" 
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- POLICIES: ITEMS
DROP POLICY IF EXISTS "Items are viewable by everyone" ON public.items;
CREATE POLICY "Items are viewable by everyone" 
  ON public.items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own items" ON public.items;
CREATE POLICY "Users can insert their own items" 
  ON public.items FOR INSERT WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can update their own items" ON public.items;
CREATE POLICY "Owners can update their own items" 
  ON public.items FOR UPDATE USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete their own items" ON public.items;
CREATE POLICY "Owners can delete their own items" 
  ON public.items FOR DELETE USING (auth.uid() = owner_id);

-- POLICIES: ITEM IMAGES
DROP POLICY IF EXISTS "Images are viewable by everyone" ON public.item_images;
CREATE POLICY "Images are viewable by everyone" 
  ON public.item_images FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert images for their items" ON public.item_images;
CREATE POLICY "Users can insert images for their items" 
  ON public.item_images FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.items 
      WHERE items.id = item_images.item_id AND items.owner_id = auth.uid()
    )
  );

-- POLICIES: SWAP PROPOSALS
DROP POLICY IF EXISTS "Proposals viewable by participants" ON public.swap_proposals;
CREATE POLICY "Proposals viewable by participants" 
  ON public.swap_proposals FOR SELECT 
  USING (auth.uid() = proposer_id OR auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can create proposals" ON public.swap_proposals;
CREATE POLICY "Users can create proposals" 
  ON public.swap_proposals FOR INSERT WITH CHECK (auth.uid() = proposer_id);

DROP POLICY IF EXISTS "Participants can update proposal status" ON public.swap_proposals;
CREATE POLICY "Participants can update proposal status" 
  ON public.swap_proposals FOR UPDATE 
  USING (auth.uid() = proposer_id OR auth.uid() = owner_id);

-- POLICIES: CHAT ROOMS
DROP POLICY IF EXISTS "Chat rooms viewable by participants" ON public.chat_rooms;
CREATE POLICY "Chat rooms viewable by participants" 
  ON public.chat_rooms FOR SELECT 
  USING (auth.uid() = user_one OR auth.uid() = user_two);

DROP POLICY IF EXISTS "Users can start a chat room" ON public.chat_rooms;
CREATE POLICY "Users can start a chat room" 
  ON public.chat_rooms FOR INSERT 
  WITH CHECK (auth.uid() = user_one OR auth.uid() = user_two);

-- POLICIES: MESSAGES
DROP POLICY IF EXISTS "Messages viewable by chat participants" ON public.messages;
CREATE POLICY "Messages viewable by chat participants" 
  ON public.messages FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM public.chat_rooms 
      WHERE chat_rooms.id = messages.chat_room_id 
        AND (chat_rooms.user_one = auth.uid() OR chat_rooms.user_two = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Participants can insert messages" ON public.messages;
CREATE POLICY "Participants can insert messages" 
  ON public.messages FOR INSERT 
  WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.chat_rooms 
      WHERE chat_rooms.id = messages.chat_room_id 
        AND (chat_rooms.user_one = auth.uid() OR chat_rooms.user_two = auth.uid())
    )
  );

-- POLICIES: UPCYCLE POSTS
DROP POLICY IF EXISTS "Upcycle posts viewable by everyone" ON public.upcycle_posts;
CREATE POLICY "Upcycle posts viewable by everyone" 
  ON public.upcycle_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can create upcycle posts" ON public.upcycle_posts;
CREATE POLICY "Authenticated users can create upcycle posts" 
  ON public.upcycle_posts FOR INSERT WITH CHECK (auth.uid() = author_id);

DROP POLICY IF EXISTS "Authors can update upcycle posts" ON public.upcycle_posts;
CREATE POLICY "Authors can update upcycle posts" 
  ON public.upcycle_posts FOR UPDATE USING (auth.uid() = author_id);

-- POLICIES: UPCYCLE COMMENTS
DROP POLICY IF EXISTS "Comments viewable by everyone" ON public.upcycle_comments;
CREATE POLICY "Comments viewable by everyone" 
  ON public.upcycle_comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can comment" ON public.upcycle_comments;
CREATE POLICY "Authenticated users can comment" 
  ON public.upcycle_comments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- POLICIES: UPCYCLE LIKES
DROP POLICY IF EXISTS "Likes viewable by everyone" ON public.upcycle_likes;
CREATE POLICY "Likes viewable by everyone" 
  ON public.upcycle_likes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can toggle likes" ON public.upcycle_likes;
CREATE POLICY "Users can toggle likes" 
  ON public.upcycle_likes FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can remove their like" ON public.upcycle_likes;
CREATE POLICY "Users can remove their like" 
  ON public.upcycle_likes FOR DELETE USING (auth.uid() = user_id);

-- ==============================================================================
-- 10. REALTIME CONFIGURATION & RPC
-- ==============================================================================
-- Fungsi RPC untuk menambah penghitung dampak sirkular pengguna
CREATE OR REPLACE FUNCTION public.increment_items_saved(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.profiles
  SET items_saved_count = items_saved_count + 1
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fungsi RPC untuk menambah/mengurangi likes artikel upcycle
CREATE OR REPLACE FUNCTION public.increment_upcycle_likes(target_post_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.upcycle_posts
  SET likes_count = likes_count + 1
  WHERE id = target_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.decrement_upcycle_likes(target_post_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.upcycle_posts
  SET likes_count = GREATEST(0, likes_count - 1)
  WHERE id = target_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aktifkan streaming realtime untuk tabel obrolan dan proposal
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.swap_proposals;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
