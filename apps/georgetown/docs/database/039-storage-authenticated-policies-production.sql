-- Migration 039: Authenticated Storage Policies for Production
-- Purpose: Replace public trial policies with proper authentication-based security
-- Date: 2025-10-16 (for future execution)
-- Execute: CEO in Supabase SQL Editor AFTER authentication system is implemented
-- Prerequisites:
--   - Authentication system is implemented
--   - Users can log in and have JWT tokens
--   - members table has accurate roles data
--   - Migration 038 (trial policies) has been executed and tested
--
-- ⚠️  DO NOT EXECUTE THIS UNTIL AUTHENTICATION IS READY
-- ⚠️  Test authentication thoroughly before running this migration
-- ⚠️  Backup storage contents before executing
--
-- =====================================================
-- BACKGROUND
-- =====================================================
-- Migration 038 provided temporary public policies for trial phase.
-- This migration replaces them with production-ready authentication.
--
-- Security improvements:
-- 1. Member portraits: Self-service OR officer approval
-- 2. Speaker portraits: Officers/chairs only (quality control)
-- 3. Partner logos: Officers/chairs only (brand control)
-- 4. Project images: Officers/chairs only (project management)
-- 5. Club photos: Authenticated users upload, officers manage
-- 6. Rotary themes: Officers/chairs only (official branding)
--
-- =====================================================
-- PRE-MIGRATION CHECKLIST
-- =====================================================
-- [ ] Authentication system is implemented and tested
-- [ ] Users can successfully log in
-- [ ] JWT tokens are being generated
-- [ ] members table has all officers with correct roles
-- [ ] Tested that auth.jwt()->>'email' returns correct emails
-- [ ] Backup taken of all storage buckets
-- [ ] All stakeholders notified of upcoming security changes
--

-- =====================================================
-- STEP 1: DROP ALL TRIAL POLICIES
-- =====================================================

-- Member portraits
DROP POLICY IF EXISTS "trial_member_portraits_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_member_portraits_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_member_portraits_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_member_portraits_delete" ON storage.objects;

-- Speaker portraits
DROP POLICY IF EXISTS "trial_speaker_portraits_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_speaker_portraits_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_speaker_portraits_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_speaker_portraits_delete" ON storage.objects;

-- Partner logos
DROP POLICY IF EXISTS "trial_partner_logos_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_partner_logos_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_partner_logos_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_partner_logos_delete" ON storage.objects;

-- Project images
DROP POLICY IF EXISTS "trial_project_images_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_project_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_project_images_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_project_images_delete" ON storage.objects;

-- Club photos
DROP POLICY IF EXISTS "trial_club_photos_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_club_photos_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_club_photos_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_club_photos_delete" ON storage.objects;

-- Rotary themes
DROP POLICY IF EXISTS "trial_rotary_themes_select" ON storage.objects;
DROP POLICY IF EXISTS "trial_rotary_themes_insert" ON storage.objects;
DROP POLICY IF EXISTS "trial_rotary_themes_update" ON storage.objects;
DROP POLICY IF EXISTS "trial_rotary_themes_delete" ON storage.objects;

-- =====================================================
-- STEP 2: MEMBER PORTRAITS - Authenticated Policies
-- =====================================================
-- Self-service for members, officer override

CREATE POLICY "prod_member_portraits_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'member-portraits');

CREATE POLICY "prod_member_portraits_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'member-portraits' AND
  (
    -- Members can upload files named with their email prefix
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

CREATE POLICY "prod_member_portraits_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'member-portraits' AND
  (
    storage.filename(name) LIKE split_part(auth.jwt()->>'email', '@', 1) || '-%'
    OR
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

CREATE POLICY "prod_member_portraits_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'member-portraits' AND
  (
    storage.filename(name) LIKE split_part(auth.jwt()->>'email', '@', 1) || '-%'
    OR
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
-- STEP 3: SPEAKER PORTRAITS - Officers Only
-- =====================================================
-- Quality control for Speaker Bureau

CREATE POLICY "prod_speaker_portraits_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'speaker-portraits');

CREATE POLICY "prod_speaker_portraits_insert"
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

CREATE POLICY "prod_speaker_portraits_update"
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

CREATE POLICY "prod_speaker_portraits_delete"
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
-- STEP 4: PARTNER LOGOS - Officers Only
-- =====================================================
-- Brand control for partner relationships

CREATE POLICY "prod_partner_logos_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'partner-logos');

CREATE POLICY "prod_partner_logos_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'partner-logos' AND
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

CREATE POLICY "prod_partner_logos_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'partner-logos' AND
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

CREATE POLICY "prod_partner_logos_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'partner-logos' AND
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
-- STEP 5: PROJECT IMAGES - Officers Only
-- =====================================================
-- Project management control

CREATE POLICY "prod_project_images_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'project-images');

CREATE POLICY "prod_project_images_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'project-images' AND
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

CREATE POLICY "prod_project_images_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'project-images' AND
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

CREATE POLICY "prod_project_images_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'project-images' AND
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
-- STEP 6: CLUB PHOTOS - Authenticated Upload, Officers Manage
-- =====================================================
-- Members can upload event photos, officers curate

CREATE POLICY "prod_club_photos_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'club-photos');

CREATE POLICY "prod_club_photos_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'club-photos');

CREATE POLICY "prod_club_photos_update"
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

CREATE POLICY "prod_club_photos_delete"
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
-- STEP 7: ROTARY THEMES - Officers Only
-- =====================================================
-- Official Rotary International branding

CREATE POLICY "prod_rotary_themes_select"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rotary-themes');

CREATE POLICY "prod_rotary_themes_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'rotary-themes' AND
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

CREATE POLICY "prod_rotary_themes_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'rotary-themes' AND
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

CREATE POLICY "prod_rotary_themes_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'rotary-themes' AND
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

-- Verify all production policies are in place
SELECT
  policyname,
  cmd,
  roles,
  tablename
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE 'prod_%'
ORDER BY policyname;

-- Expected: 24 policies (4 per bucket × 6 buckets)
-- Each bucket should have: SELECT, INSERT, UPDATE, DELETE

-- Verify no trial policies remain
SELECT
  policyname
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE 'trial_%';

-- Expected: 0 rows (all trial policies should be dropped)

-- =====================================================
-- POST-MIGRATION TESTING
-- =====================================================
-- Test each scenario:
--
-- 1. Member self-service upload (member-portraits):
--    - Log in as regular member
--    - Upload portrait named with email prefix
--    - Verify success
--    - Try to upload portrait with different name (should fail)
--
-- 2. Officer upload (all buckets):
--    - Log in as officer/chair
--    - Upload to each bucket
--    - Verify success
--
-- 3. Public viewing (all buckets):
--    - Log out
--    - View member portraits (should work)
--    - View speaker portraits (should work)
--    - Try to upload (should fail)
--
-- 4. Non-authenticated upload (should all fail):
--    - Do NOT log in
--    - Try to upload to any bucket
--    - Verify rejection
--
-- =====================================================
-- ROLLBACK PROCEDURE (If Needed)
-- =====================================================
-- If production policies cause issues, rollback to trial:
--
-- 1. Execute migration 038 again (public policies)
-- 2. Notify users of temporary open access
-- 3. Debug authentication issues
-- 4. Re-execute this migration when fixed
--
-- ⚠️  Only rollback if absolutely necessary
-- ⚠️  Document the issue and resolution
-- ⚠️  Clean up any spam uploads after rollback
