-- Migration 008: Ensure UPDATE/INSERT/DELETE Policies Exist
-- Purpose: Add missing management policies for service_projects
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- Drop the old policy if it exists, then recreate it
DROP POLICY IF EXISTS "Service projects are manageable by everyone" ON service_projects;

-- Create comprehensive management policy
CREATE POLICY "Service projects are manageable by everyone"
  ON service_projects FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Verify policies are active
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'service_projects'
ORDER BY policyname;
