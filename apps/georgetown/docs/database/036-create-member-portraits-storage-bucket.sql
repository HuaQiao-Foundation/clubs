-- Migration 036: Create Member Portraits Storage Bucket
-- Purpose: Create dedicated storage bucket for member portrait photos
-- Date: 2025-10-16
-- Execute: CEO in Supabase Storage Dashboard or SQL Editor
-- Prerequisites: members table exists with portrait_url column (migration 025)

-- =====================================================
-- STORAGE BUCKET CREATION
-- =====================================================
-- Note: Storage bucket creation may require Supabase Dashboard
-- Dashboard Steps:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "New Bucket"
-- 3. Name: 'member-portraits'
-- 4. Set to Public bucket (for portrait display)
-- 5. File size limit: 5 MB
-- 6. Allowed MIME types: image/jpeg, image/png, image/webp

-- Alternative: Execute via SQL (if Storage API is available)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'member-portraits',
  'member-portraits',
  true,
  5242880,  -- 5 MB in bytes (portraits don't need 10MB)
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Policy 1: Anyone can view member portraits (public access)
CREATE POLICY "Member portraits are publicly viewable"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'member-portraits');

-- Policy 2: Authenticated users can upload member portraits
-- This allows members to upload their own portraits
CREATE POLICY "Authenticated users can upload member portraits"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'member-portraits' AND
  (
    -- Members can upload files named with their email prefix
    -- Example: john.doe@example.com can upload john.doe-*.jpg
    storage.filename(name) LIKE split_part(auth.jwt()->>'email', '@', 1) || '-%'
    OR
    -- Officers and chairs can upload any member portraits
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
  )
);

-- Policy 3: Users can update their own portraits, officers can update any
CREATE POLICY "Users can update their own member portraits"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'member-portraits' AND
  (
    -- Members can update files named with their email prefix
    storage.filename(name) LIKE split_part(auth.jwt()->>'email', '@', 1) || '-%'
    OR
    -- Officers and chairs can update any member portraits
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
  )
);

-- Policy 4: Users can delete their own portraits, officers can delete any
CREATE POLICY "Users can delete their own member portraits"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'member-portraits' AND
  (
    -- Members can delete files named with their email prefix
    storage.filename(name) LIKE split_part(auth.jwt()->>'email', '@', 1) || '-%'
    OR
    -- Officers and chairs can delete any member portraits
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
  )
);

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify bucket creation
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'member-portraits';

-- Expected result:
-- id               | name             | public | file_size_limit | allowed_mime_types
-- member-portraits | member-portraits | true   | 5242880         | {image/jpeg,image/png,image/webp,image/jpg}

-- Verify policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%member portrait%'
ORDER BY cmd;

-- Expected result: 4 policies
-- 1. SELECT (view) - public access
-- 2. INSERT (upload) - authenticated with self/officer check
-- 3. UPDATE (modify) - authenticated with self/officer check
-- 4. DELETE (remove) - authenticated with self/officer check

-- =====================================================
-- FILE NAMING CONVENTIONS
-- =====================================================
-- Recommended naming pattern: email-prefix-timestamp.jpg
-- Examples:
-- john.doe-1697123456.jpg
-- jane.smith-1697123456.png
-- president-2024.jpg (for official portraits)
--
-- This allows:
-- 1. Easy identification of portrait owner
-- 2. Version control (timestamp or year)
-- 3. Self-service uploads by members
-- 4. Officer override for any portrait

-- =====================================================
-- INTEGRATION WITH MEMBERS TABLE
-- =====================================================
-- After uploading portrait to storage, update member record:
-- UPDATE members
-- SET portrait_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/member-portraits/john.doe-1697123456.jpg'
-- WHERE email = 'john.doe@example.com';
--
-- The UI components already handle NULL portrait_url gracefully
-- by showing initials in a gradient circle.

-- =====================================================
-- RECOMMENDED IMAGE SPECIFICATIONS
-- =====================================================
-- Size: 200x200px minimum, 800x800px maximum
-- Format: JPEG (best compression), PNG (transparency), WebP (modern browsers)
-- Aspect Ratio: 1:1 (square)
-- File Size: < 500 KB recommended (5 MB max enforced)
-- Quality: 80-90% JPEG quality is sufficient
-- Background: Neutral or transparent preferred
