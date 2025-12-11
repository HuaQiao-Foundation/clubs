-- Migration 038: Public Storage Policies for Trial Phase (No Authentication)
-- Purpose: Enable public uploads for trial/development phase before auth is implemented
-- Date: 2025-10-16
-- Execute: CEO in Supabase SQL Editor
-- Prerequisites: Storage buckets exist (member-portraits, speaker-portraits, partner-logos, project-images)
--
-- IMPORTANT: This is a TEMPORARY migration for trial phase
-- When authentication is implemented, execute migration 039 to add proper security
--
-- =====================================================
-- BACKGROUND
-- =====================================================
-- Current situation:
-- - No authentication system built yet
-- - Need to trial upload functionality
-- - Current policies require auth.jwt() which doesn't exist
-- - All uploads are failing
--
-- This migration:
-- 1. DROPS all existing restrictive policies
-- 2. ADDS permissive public policies for trial
-- 3. Documents security risks
-- 4. Provides clear path to proper security (migration 039)
--
-- =====================================================
-- SECURITY WARNING
-- =====================================================
-- ⚠️  THESE POLICIES ARE NOT PRODUCTION-READY
-- ⚠️  Anyone can upload/modify/delete files
-- ⚠️  Use only for trial/development phase
-- ⚠️  Execute migration 039 before production launch
--
-- Risks during trial phase:
-- - Spam uploads
-- - Storage quota exhaustion
-- - Inappropriate content
-- - Accidental deletions
--
-- Mitigations in place:
-- - File size limits (5 MB per file)
-- - MIME type restrictions (images only)
-- - Bucket-level organization
-- - Easy cleanup via Supabase Dashboard
--

-- =====================================================
-- STEP 1: DROP ALL EXISTING RESTRICTIVE POLICIES
-- =====================================================

-- Drop member-portraits policies
DROP POLICY IF EXISTS "Member portraits are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload member portraits" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own member portraits" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own member portraits" ON storage.objects;

-- Drop speaker-portraits policies
DROP POLICY IF EXISTS "Speaker portraits are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Officers and chairs can upload speaker portraits" ON storage.objects;
DROP POLICY IF EXISTS "Officers and chairs can update speaker portraits" ON storage.objects;
DROP POLICY IF EXISTS "Officers and chairs can delete speaker portraits" ON storage.objects;

-- Drop partner-logos policies (if any exist)
DROP POLICY IF EXISTS "Public can view partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Public can upload partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Public can update partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Public can delete partner logos" ON storage.objects;

-- Drop club-photos policies (if any exist)
DROP POLICY IF EXISTS "Club photos are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload club photos" ON storage.objects;
DROP POLICY IF EXISTS "Officers and chairs can delete club photos" ON storage.objects;
DROP POLICY IF EXISTS "Officers and chairs can update club photos" ON storage.objects;

-- Drop project-images policies (if any exist)
DROP POLICY IF EXISTS "Project images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can upload project images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update project images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete project images" ON storage.objects;

-- =====================================================
-- STEP 2: CREATE PUBLIC TRIAL POLICIES
-- =====================================================

-- =====================================================
-- MEMBER PORTRAITS - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_member_portraits_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'member-portraits');

CREATE POLICY "trial_member_portraits_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'member-portraits' AND
  -- File size check is enforced at bucket level (5 MB)
  -- MIME type check is enforced at bucket level (images only)
  -- File name must start with 'member-' for organization
  storage.filename(name) LIKE 'member-%'
);

CREATE POLICY "trial_member_portraits_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'member-portraits');

CREATE POLICY "trial_member_portraits_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'member-portraits');

-- =====================================================
-- SPEAKER PORTRAITS - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_speaker_portraits_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'speaker-portraits');

CREATE POLICY "trial_speaker_portraits_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'speaker-portraits' AND
  storage.filename(name) LIKE 'speaker-%'
);

CREATE POLICY "trial_speaker_portraits_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'speaker-portraits');

CREATE POLICY "trial_speaker_portraits_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'speaker-portraits');

-- =====================================================
-- PARTNER LOGOS - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_partner_logos_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'partner-logos');

CREATE POLICY "trial_partner_logos_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'partner-logos' AND
  storage.filename(name) LIKE 'partner-%'
);

CREATE POLICY "trial_partner_logos_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'partner-logos');

CREATE POLICY "trial_partner_logos_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'partner-logos');

-- =====================================================
-- PROJECT IMAGES - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_project_images_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'project-images');

CREATE POLICY "trial_project_images_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'project-images');

CREATE POLICY "trial_project_images_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'project-images');

CREATE POLICY "trial_project_images_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'project-images');

-- =====================================================
-- CLUB PHOTOS - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_club_photos_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'club-photos');

CREATE POLICY "trial_club_photos_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'club-photos');

CREATE POLICY "trial_club_photos_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'club-photos');

CREATE POLICY "trial_club_photos_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'club-photos');

-- =====================================================
-- ROTARY THEMES - Public Trial Policies
-- =====================================================

CREATE POLICY "trial_rotary_themes_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rotary-themes');

CREATE POLICY "trial_rotary_themes_insert"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'rotary-themes');

CREATE POLICY "trial_rotary_themes_update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'rotary-themes');

CREATE POLICY "trial_rotary_themes_delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'rotary-themes');

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify all trial policies are in place
SELECT
  policyname,
  cmd,
  qual,
  with_check,
  tablename
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE 'trial_%'
ORDER BY policyname;

-- Expected: 24 policies (4 per bucket × 6 buckets)
-- Each bucket should have: SELECT, INSERT, UPDATE, DELETE

-- Verify bucket settings remain correct
SELECT
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
WHERE id IN (
  'member-portraits',
  'speaker-portraits',
  'partner-logos',
  'project-images',
  'club-photos',
  'rotary-themes'
)
ORDER BY id;

-- =====================================================
-- FILE NAMING CONVENTIONS (Trial Phase)
-- =====================================================
-- Even in trial phase, use consistent naming:
--
-- member-portraits:   member-{name}-{timestamp}.jpg
-- speaker-portraits:  speaker-{name}-{timestamp}.jpg
-- partner-logos:      partner-{name}-{timestamp}.jpg
-- project-images:     {project-id}-{timestamp}.jpg
-- club-photos:        {category}-{year}-{title}-{timestamp}.jpg
-- rotary-themes:      theme-{year}-{type}.{ext}
--
-- This maintains organization and prepares for migration 039

-- =====================================================
-- TRIAL PHASE CLEANUP TIPS
-- =====================================================
-- During trial, you may need to clean up test uploads:
--
-- View all files in a bucket:
-- SELECT name, created_at, metadata->>'size' as size_bytes
-- FROM storage.objects
-- WHERE bucket_id = 'member-portraits'
-- ORDER BY created_at DESC;
--
-- Delete all files in a bucket (use carefully):
-- DELETE FROM storage.objects WHERE bucket_id = 'member-portraits';
--
-- Or use Supabase Dashboard: Storage > [bucket] > Select files > Delete

-- =====================================================
-- NEXT STEPS
-- =====================================================
-- 1. Test uploads in all sections (Members, Speakers, Partners, Projects)
-- 2. Verify compression is working (files should be ~100-200 KB)
-- 3. Test on mobile devices (file picker should work)
-- 4. Monitor storage usage in Supabase Dashboard
-- 5. When authentication is ready, execute migration 039
--
-- BEFORE PRODUCTION LAUNCH:
-- ⚠️  Execute migration 039 to add proper authentication-based security
-- ⚠️  Verify all officers have correct roles in members table
-- ⚠️  Test authenticated upload/update/delete flows
-- ⚠️  Review and clean up any test/spam uploads from trial phase
