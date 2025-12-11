-- Migration 010: Fix Storage Policies for Public Access
-- Purpose: Change storage policies from authenticated to public access
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- Drop existing authenticated policies
DROP POLICY IF EXISTS "Authenticated users can delete project images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload project images" ON storage.objects;

-- Create public policies for all operations
CREATE POLICY "Anyone can upload project images"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'project-images');

CREATE POLICY "Anyone can update project images"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'project-images');

CREATE POLICY "Anyone can delete project images"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'project-images');

-- Note: "Project images are publicly accessible" (SELECT) already exists as public

-- Verify all policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%project images%'
ORDER BY cmd;
