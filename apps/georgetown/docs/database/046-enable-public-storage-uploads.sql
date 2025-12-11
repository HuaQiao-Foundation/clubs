-- Migration 046: Enable public uploads to storage buckets (development mode)
-- Date: 2025-10-17
-- Description: Allow public uploads and deletes for portrait/logo storage buckets
--              during development phase before authentication system is implemented
--              SECURITY NOTE: Disable these policies when implementing authentication

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

-- Rotary themes bucket policies (for Rotary year themes)
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
