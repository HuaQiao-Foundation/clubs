-- Migration 048: Enable public photo inserts for development
-- Date: 2025-10-17
-- Description: Temporarily allow public INSERT on photos table during development phase
--              before authentication system is implemented
--              SECURITY NOTE: Disable this policy when implementing authentication

-- Drop existing public insert policy if it exists
DROP POLICY IF EXISTS "Public can insert photos (development)" ON public.photos;

-- Create temporary public INSERT policy for development
CREATE POLICY "Public can insert photos (development)"
ON public.photos FOR INSERT
TO public
WITH CHECK (true);

-- IMPORTANT SECURITY NOTE:
-- This policy allows unrestricted photo inserts during development.
-- When implementing authentication:
-- 1. DROP this public policy:
--    DROP POLICY "Public can insert photos (development)" ON public.photos;
-- 2. Keep the existing "Authenticated users can upload photos" policy
-- 3. Ensure proper auth checks are re-enabled in PhotoUploadModal.tsx
