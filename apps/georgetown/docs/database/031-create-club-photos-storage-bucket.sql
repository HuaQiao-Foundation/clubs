-- Migration 031: Create Club Photos Storage Bucket
-- Purpose: Create dedicated storage bucket for general club photo gallery
-- Date: 2025-10-15
-- Execute: CEO in Supabase Storage Dashboard or SQL Editor

-- =====================================================
-- STORAGE BUCKET CREATION
-- =====================================================
-- Note: Storage bucket creation may require Supabase Dashboard
-- Dashboard Steps:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "New Bucket"
-- 3. Name: 'club-photos'
-- 4. Set to Public bucket (for photo display)
-- 5. File size limit: 10 MB
-- 6. Allowed MIME types: image/jpeg, image/png, image/webp

-- Alternative: Execute via SQL (if Storage API is available)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'club-photos',
  'club-photos',
  true,
  10485760,  -- 10 MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Policy 1: Anyone can view club photos (public access)
CREATE POLICY "Club photos are publicly viewable"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'club-photos');

-- Policy 2: Authenticated users can upload club photos
CREATE POLICY "Authenticated users can upload club photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'club-photos' AND
  (storage.foldername(name))[1] IN ('events', 'fellowship', 'service', 'community', 'members', 'general')
);

-- Policy 3: Only officers and chairs can update club photos
CREATE POLICY "Officers and chairs can update club photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'club-photos' AND
  EXISTS (
    SELECT 1 FROM members
    WHERE members.email = auth.jwt()->>'email'
    AND members.roles && ARRAY[
      'President', 'President-Elect', 'Immediate Past President', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair', 'International Service Chair',
      'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

-- Policy 4: Only officers and chairs can delete club photos
CREATE POLICY "Officers and chairs can delete club photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'club-photos' AND
  EXISTS (
    SELECT 1 FROM members
    WHERE members.email = auth.jwt()->>'email'
    AND members.roles && ARRAY[
      'President', 'President-Elect', 'Immediate Past President', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair', 'International Service Chair',
      'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify bucket creation
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'club-photos';

-- Verify policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%club photos%'
ORDER BY cmd;

-- =====================================================
-- FOLDER STRUCTURE RECOMMENDATIONS
-- =====================================================
-- Organize photos in the bucket with this structure:
-- /events/YYYY/event-name-001.jpg
-- /fellowship/YYYY/meeting-MMDD-001.jpg
-- /service/project-name/activity-001.jpg
-- /community/YYYY/event-name-001.jpg
-- /members/YYYY/group-photo-001.jpg
-- /general/YYYY/description-001.jpg
