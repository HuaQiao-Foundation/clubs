-- Migration 037: Add Storage Policies for Speaker Portraits Bucket
-- Purpose: Add missing security policies to existing speaker-portraits bucket
-- Date: 2025-10-16
-- Execute: CEO in Supabase SQL Editor
-- Prerequisites:
--   - speakers table exists with portrait_url column (migration 024)
--   - speaker-portraits bucket already exists in Supabase Storage
-- CRITICAL: Bucket exists but has NO POLICIES - adding proper security

-- =====================================================
-- BACKGROUND
-- =====================================================
-- The portrait_url column was added in migration 024, and the
-- speaker-portraits storage bucket was created in Supabase Dashboard,
-- but NO POLICIES were ever added. This creates a security gap.
-- This migration adds the missing policies.

-- =====================================================
-- VERIFY BUCKET EXISTS
-- =====================================================
-- This should return a row if bucket exists
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'speaker-portraits';

-- CURRENT BUCKET SETTINGS (as of 2025-10-16):
-- - Public: Yes
-- - File size limit: 1 MB (1048576 bytes)
-- - MIME types: image/jpeg, image/jpg, image/png, image/webp
-- - Policies: NONE (this migration adds them)

-- RECOMMENDATION: Increase file size limit to 5 MB via Supabase Dashboard
-- 1 MB is sufficient for 400x400px portraits (~100-200 KB)
-- but may be too small for high-quality 800x800px portraits (~500 KB)

-- Verify bucket exists and check current settings
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'speaker-portraits';

-- Update file size limit to 5 MB (optional but recommended)
-- Run this BEFORE adding policies if you want to increase the limit
UPDATE storage.buckets
SET file_size_limit = 5242880  -- 5 MB in bytes
WHERE id = 'speaker-portraits';

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Policy 1: Anyone can view speaker portraits (public access)
-- Speakers Bureau is public-facing, so portraits must be viewable
CREATE POLICY "Speaker portraits are publicly viewable"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'speaker-portraits');

-- Policy 2: Officers and chairs can upload speaker portraits
-- Program committee manages speakers, so they need upload access
CREATE POLICY "Officers and chairs can upload speaker portraits"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'speaker-portraits' AND
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

-- Policy 3: Officers and chairs can update speaker portraits
CREATE POLICY "Officers and chairs can update speaker portraits"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'speaker-portraits' AND
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

-- Policy 4: Officers and chairs can delete speaker portraits
CREATE POLICY "Officers and chairs can delete speaker portraits"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'speaker-portraits' AND
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
WHERE id = 'speaker-portraits';

-- Expected result:
-- id                | name              | public | file_size_limit | allowed_mime_types
-- speaker-portraits | speaker-portraits | true   | 5242880         | {image/jpeg,image/png,image/webp,image/jpg}

-- Verify policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%speaker portrait%'
ORDER BY cmd;

-- Expected result: 4 policies
-- 1. SELECT (view) - public access
-- 2. INSERT (upload) - officers/chairs only
-- 3. UPDATE (modify) - officers/chairs only
-- 4. DELETE (remove) - officers/chairs only

-- =====================================================
-- FILE NAMING CONVENTIONS
-- =====================================================
-- Recommended naming pattern: speaker-name-slug-timestamp.jpg
-- Examples:
-- john-doe-1697123456.jpg
-- jane-smith-speaker-1697123456.png
-- chong-seng-lim-2024.jpg
--
-- This allows:
-- 1. Easy identification of speaker
-- 2. Version control (timestamp or year)
-- 3. SEO-friendly names for Speaker Bureau
-- 4. Professional appearance in URLs

-- =====================================================
-- INTEGRATION WITH SPEAKERS TABLE
-- =====================================================
-- After uploading portrait to storage, update speaker record:
-- UPDATE speakers
-- SET portrait_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/speaker-portraits/john-doe-1697123456.jpg'
-- WHERE id = 'speaker-uuid';
--
-- The UI components already handle NULL portrait_url gracefully
-- by showing initials in a gradient circle.

-- =====================================================
-- RECOMMENDED IMAGE SPECIFICATIONS
-- =====================================================
-- Size: 400x400px recommended (200px min, 800px max)
-- Format: JPEG (best compression), PNG (transparency), WebP (modern browsers)
-- Aspect Ratio: 1:1 (square)
-- File Size: < 500 KB recommended (5 MB max enforced)
-- Quality: 80-90% JPEG quality is sufficient
-- Background: Professional headshot, neutral background preferred
--
-- WHY 400x400px?
-- - Retina-ready (displays at 200px CSS, looks sharp on high-DPI)
-- - Small file size (~50-150 KB)
-- - Fast loading on mobile networks
-- - Future-proof (can scale down, not up)
-- - Industry standard for profile photos

-- =====================================================
-- SECURITY NOTES
-- =====================================================
-- Unlike member-portraits, speaker-portraits do NOT allow
-- self-service uploads. This is intentional:
--
-- 1. Speakers are external (not members)
-- 2. Program committee manages speaker data
-- 3. Quality control needed for Speaker Bureau
-- 4. Professional presentation required
--
-- Officers/chairs act as gatekeepers for speaker portrait quality.

-- =====================================================
-- SPEAKER BUREAU USAGE
-- =====================================================
-- The Speakers Bureau (/speakers-bureau) displays recommended
-- speakers with their portraits. This is a public-facing page
-- potentially shared with other Rotary clubs and District 7620.
--
-- Portrait quality directly impacts Georgetown Rotary's
-- professional image and speaker recommendations.
