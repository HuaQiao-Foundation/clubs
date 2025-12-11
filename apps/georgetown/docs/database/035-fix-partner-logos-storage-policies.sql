-- Migration 035: Fix Partner Logos Storage Policies
-- Purpose: Correct the storage policies for partner-logos bucket
-- Date: 2025-10-15
-- Execute: CEO in Supabase SQL Editor
-- Context: Logo upload still failing - policies were created incorrectly in migration 034

-- =====================================================
-- DROP INCORRECTLY CREATED POLICIES FROM MIGRATION 034
-- =====================================================

-- These were created on the wrong location - drop them
DROP POLICY IF EXISTS "Partner logos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can upload partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete partner logos" ON storage.objects;

-- =====================================================
-- CREATE STORAGE POLICIES WITH CORRECT NAMES
-- =====================================================

-- Policy names must be unique across ALL buckets, so we need unique names

-- Public read access for partner logos
CREATE POLICY "Public can view partner logos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'partner-logos');

-- Public upload access
CREATE POLICY "Public can upload partner logos"
  ON storage.objects FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'partner-logos');

-- Public update access
CREATE POLICY "Public can update partner logos"
  ON storage.objects FOR UPDATE
  TO public
  USING (bucket_id = 'partner-logos');

-- Public delete access
CREATE POLICY "Public can delete partner logos"
  ON storage.objects FOR DELETE
  TO public
  USING (bucket_id = 'partner-logos');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check storage bucket exists:
-- SELECT id, name, public FROM storage.buckets WHERE id = 'partner-logos';
-- Expected: One row with public = true

-- Check storage policies exist and are unique:
-- SELECT policyname, cmd FROM pg_policies
-- WHERE schemaname = 'storage' AND tablename = 'objects'
-- AND policyname LIKE '%partner logo%'
-- ORDER BY cmd;
-- Expected: Four policies (DELETE, INSERT, SELECT, UPDATE)
