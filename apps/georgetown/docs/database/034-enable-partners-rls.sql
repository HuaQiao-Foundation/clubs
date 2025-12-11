-- Migration 034: Enable RLS on Partners Table and Create Storage Bucket
-- Purpose: Ensure Row Level Security is enabled on partners table and create partner-logos storage
-- Date: 2025-10-15
-- Execute: CEO in Supabase SQL Editor
-- Context: Partners table showing as "Unrestricted" and logo uploads failing with RLS error

-- =====================================================
-- PART 1: ENABLE RLS ON PARTNERS TABLE
-- =====================================================

-- Enable RLS (if not already enabled)
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (if any)
DROP POLICY IF EXISTS "Partners are viewable by everyone" ON partners;
DROP POLICY IF EXISTS "Partners are manageable by everyone" ON partners;

-- Create public read policy
CREATE POLICY "Partners are viewable by everyone"
  ON partners FOR SELECT
  TO public
  USING (true);

-- Create public write policy (INSERT, UPDATE, DELETE)
CREATE POLICY "Partners are manageable by everyone"
  ON partners FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- PART 2: CREATE PARTNER-LOGOS STORAGE BUCKET
-- =====================================================

-- Create storage bucket for partner logos (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'partner-logos',
  'partner-logos',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- PART 3: CREATE STORAGE POLICIES
-- =====================================================

-- Drop existing storage policies (if any)
DROP POLICY IF EXISTS "Partner logos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can upload partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete partner logos" ON storage.objects;

-- Public read access for partner logos
CREATE POLICY "Partner logos are publicly accessible"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'partner-logos');

-- Public upload access
CREATE POLICY "Anyone can upload partner logos"
  ON storage.objects FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'partner-logos');

-- Public update access
CREATE POLICY "Anyone can update partner logos"
  ON storage.objects FOR UPDATE
  TO public
  USING (bucket_id = 'partner-logos');

-- Public delete access
CREATE POLICY "Anyone can delete partner logos"
  ON storage.objects FOR DELETE
  TO public
  USING (bucket_id = 'partner-logos');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify RLS is enabled on partners table:
-- SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'partners';
-- Expected: rowsecurity = true

-- Check partners table policies:
-- SELECT * FROM pg_policies WHERE tablename = 'partners';
-- Expected: Two policies shown above

-- Check storage bucket exists:
-- SELECT * FROM storage.buckets WHERE id = 'partner-logos';
-- Expected: One row with public = true

-- Check storage policies:
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%partner%';
-- Expected: Four policies for SELECT, INSERT, UPDATE, DELETE
