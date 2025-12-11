-- Migration 047: Fix storage bucket policy names
-- Date: 2025-10-17
-- Description: Correct bucket names from migration 046 to match actual Supabase buckets
--              Drop old policies with incorrect bucket names, create new ones with correct names

-- Drop ALL existing public storage policies (both old and new)
DROP POLICY IF EXISTS "Public upload member portraits" ON storage.objects;
DROP POLICY IF EXISTS "Public delete member portraits" ON storage.objects;
DROP POLICY IF EXISTS "Public upload speaker portraits" ON storage.objects;
DROP POLICY IF EXISTS "Public delete speaker portraits" ON storage.objects;
DROP POLICY IF EXISTS "Public upload partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Public delete partner logos" ON storage.objects;
DROP POLICY IF EXISTS "Public upload theme logos" ON storage.objects;
DROP POLICY IF EXISTS "Public delete theme logos" ON storage.objects;
DROP POLICY IF EXISTS "Public upload rotary themes" ON storage.objects;
DROP POLICY IF EXISTS "Public delete rotary themes" ON storage.objects;
DROP POLICY IF EXISTS "Public upload club photos" ON storage.objects;
DROP POLICY IF EXISTS "Public delete club photos" ON storage.objects;
DROP POLICY IF EXISTS "Public upload project images" ON storage.objects;
DROP POLICY IF EXISTS "Public delete project images" ON storage.objects;

-- Create corrected policies with actual bucket names

-- Member portraits bucket policies
CREATE POLICY "Public upload member portraits"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'member-portraits');

CREATE POLICY "Public delete member portraits"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'member-portraits');

-- Speaker portraits bucket policies
CREATE POLICY "Public upload speaker portraits"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'speaker-portraits');

CREATE POLICY "Public delete speaker portraits"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'speaker-portraits');

-- Partner logos bucket policies
CREATE POLICY "Public upload partner logos"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'partner-logos');

CREATE POLICY "Public delete partner logos"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'partner-logos');

-- Rotary themes bucket policies
CREATE POLICY "Public upload rotary themes"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'rotary-themes');

CREATE POLICY "Public delete rotary themes"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'rotary-themes');

-- Club photos bucket policies
CREATE POLICY "Public upload club photos"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'club-photos');

CREATE POLICY "Public delete club photos"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'club-photos');

-- Project images bucket policies
CREATE POLICY "Public upload project images"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'project-images');

CREATE POLICY "Public delete project images"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'project-images');

-- IMPORTANT SECURITY NOTE:
-- These policies allow unrestricted uploads during development.
-- When implementing authentication:
-- 1. DROP these public policies
-- 2. CREATE new policies using auth.uid() checks
-- 3. Example authenticated policy:
--    CREATE POLICY "Authenticated uploads" ON storage.objects
--    FOR INSERT TO authenticated
--    WITH CHECK (bucket_id = 'member-portraits' AND auth.role() = 'authenticated');
