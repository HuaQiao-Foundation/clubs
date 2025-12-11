-- Migration 033: Fix project_partners RLS Policy Error
-- Purpose: Resolve "new row violates row-level security policy" error when saving projects with partners
-- Date: 2025-10-15
-- Execute: CEO in Supabase SQL Editor
-- Issue: Users getting RLS error when inserting partner relationships

-- =====================================================
-- DIAGNOSTIC: Check current RLS policies
-- =====================================================
-- Run this first to see what policies exist:
/*
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'project_partners'
ORDER BY policyname;
*/

-- =====================================================
-- FIX: Drop and recreate project_partners RLS policies
-- =====================================================

-- Drop ALL existing policies on project_partners
DROP POLICY IF EXISTS "Project partners are viewable by authenticated users" ON project_partners;
DROP POLICY IF EXISTS "Project partners are manageable by authenticated users" ON project_partners;
DROP POLICY IF EXISTS "Project partners are viewable by everyone" ON project_partners;
DROP POLICY IF EXISTS "Project partners are manageable by everyone" ON project_partners;

-- Create comprehensive public policies (for development/small club use)
-- NOTE: For production with authentication, change TO public → TO authenticated

-- Policy 1: Everyone can view project-partner relationships
CREATE POLICY "Allow public read access to project_partners"
  ON project_partners FOR SELECT
  TO public
  USING (true);

-- Policy 2: Everyone can insert project-partner relationships
CREATE POLICY "Allow public insert to project_partners"
  ON project_partners FOR INSERT
  TO public
  WITH CHECK (true);

-- Policy 3: Everyone can update project-partner relationships
CREATE POLICY "Allow public update to project_partners"
  ON project_partners FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

-- Policy 4: Everyone can delete project-partner relationships
CREATE POLICY "Allow public delete from project_partners"
  ON project_partners FOR DELETE
  TO public
  USING (true);

-- =====================================================
-- VERIFICATION
-- =====================================================

-- 1. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'project_partners' AND schemaname = 'public';
-- Expected: rowsecurity = true

-- 2. Verify all policies are created
SELECT
  policyname,
  cmd,
  roles::text[],
  CASE
    WHEN qual IS NOT NULL THEN 'Has USING clause'
    ELSE 'No USING clause'
  END as using_clause,
  CASE
    WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause'
    ELSE 'No WITH CHECK clause'
  END as with_check_clause
FROM pg_policies
WHERE tablename = 'project_partners' AND schemaname = 'public'
ORDER BY policyname;
-- Expected: 4 policies (SELECT, INSERT, UPDATE, DELETE)

-- 3. Test INSERT permission (this should succeed without error)
/*
DO $$
DECLARE
  test_project_id UUID;
  test_partner_id UUID;
BEGIN
  -- Get a sample project and partner ID
  SELECT id INTO test_project_id FROM service_projects LIMIT 1;
  SELECT id INTO test_partner_id FROM partners LIMIT 1;

  -- Try to insert (will rollback at end)
  IF test_project_id IS NOT NULL AND test_partner_id IS NOT NULL THEN
    INSERT INTO project_partners (project_id, partner_id)
    VALUES (test_project_id, test_partner_id)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'SUCCESS: INSERT permission verified for project_partners';

    -- Cleanup test data
    DELETE FROM project_partners
    WHERE project_id = test_project_id AND partner_id = test_partner_id;
  ELSE
    RAISE NOTICE 'SKIPPED: No test data available (need at least 1 project and 1 partner)';
  END IF;
END $$;
*/

-- =====================================================
-- NOTES FOR CEO
-- =====================================================
-- 1. This migration drops ALL existing RLS policies and recreates them with public access
-- 2. Current Georgetown setup uses public access (no auth) for small club use
-- 3. If you plan to add authentication later, change "TO public" to "TO authenticated"
-- 4. The error was likely caused by:
--    - Missing INSERT policy
--    - Policy with overly restrictive WITH CHECK clause
--    - Migration 007 not being executed in production
-- 5. After running this migration, test by creating a new project with partners
-- 6. Verify the error is resolved by checking the console logs

-- =====================================================
-- PRODUCTION AUTHENTICATION VERSION (FUTURE USE)
-- =====================================================
-- When authentication is implemented, use these policies instead:
/*
DROP POLICY IF EXISTS "Allow public read access to project_partners" ON project_partners;
DROP POLICY IF EXISTS "Allow public insert to project_partners" ON project_partners;
DROP POLICY IF EXISTS "Allow public update to project_partners" ON project_partners;
DROP POLICY IF EXISTS "Allow public delete from project_partners" ON project_partners;

CREATE POLICY "Authenticated users can read project_partners"
  ON project_partners FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert project_partners"
  ON project_partners FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update project_partners"
  ON project_partners FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete project_partners"
  ON project_partners FOR DELETE
  TO authenticated
  USING (true);
*/
