-- Migration 040: Rename "Service Projects" to "Projects"
-- Purpose: Simplify terminology for club members - rename service_projects table and all references to just "projects"
-- Date: 2025-10-17
-- Execute: CEO in Supabase SQL Editor
-- Branch: feature/rename-service-projects-to-projects
-- IMPORTANT: This is a breaking change - coordinate with CTO code changes

-- =====================================================
-- BACKUP VERIFICATION (Run First!)
-- =====================================================
-- CEO: Before running this migration, verify you have:
-- 1. Recent database backup
-- 2. CTO ready with code changes on new branch
-- 3. Confirmed all services are using latest code

-- Check current data counts
SELECT
  (SELECT COUNT(*) FROM service_projects) as project_count,
  (SELECT COUNT(*) FROM project_partners) as partnership_count;

-- =====================================================
-- STEP 1: RENAME MAIN TABLE
-- =====================================================
ALTER TABLE service_projects RENAME TO projects;

-- =====================================================
-- STEP 2: UPDATE FOREIGN KEY CONSTRAINT
-- =====================================================
-- The project_partners junction table references service_projects
-- Update the foreign key constraint to reference new table name
ALTER TABLE project_partners
  DROP CONSTRAINT IF EXISTS project_partners_project_id_fkey;

ALTER TABLE project_partners
  ADD CONSTRAINT project_partners_project_id_fkey
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

-- =====================================================
-- STEP 3: RENAME INDEXES
-- =====================================================
ALTER INDEX IF EXISTS idx_service_projects_status
  RENAME TO idx_projects_status;

ALTER INDEX IF EXISTS idx_service_projects_area_of_focus
  RENAME TO idx_projects_area_of_focus;

ALTER INDEX IF EXISTS idx_service_projects_year
  RENAME TO idx_projects_year;

-- =====================================================
-- STEP 4: UPDATE RLS POLICIES
-- =====================================================
-- Drop old policies (they reference old table name)
DROP POLICY IF EXISTS "Service projects are viewable by authenticated users" ON projects;
DROP POLICY IF EXISTS "Service projects are manageable by authenticated users" ON projects;

-- Create new policies with updated names
CREATE POLICY "Projects are viewable by authenticated users"
  ON projects FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Projects are manageable by authenticated users"
  ON projects FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- STEP 5: VERIFICATION QUERIES
-- =====================================================
-- CEO: Run these after migration to verify success

-- Verify table exists and data is intact
SELECT COUNT(*) as total_projects FROM projects;

-- Verify indexes exist
SELECT indexname
FROM pg_indexes
WHERE tablename = 'projects'
ORDER BY indexname;

-- Verify RLS policies exist
SELECT policyname
FROM pg_policies
WHERE tablename = 'projects'
ORDER BY policyname;

-- Verify foreign key constraint
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'project_partners'
  AND tc.constraint_type = 'FOREIGN KEY';

-- Verify project-partner relationships intact
SELECT
  p.project_name,
  COUNT(pp.partner_id) as partner_count
FROM projects p
LEFT JOIN project_partners pp ON p.id = pp.project_id
GROUP BY p.id, p.project_name
ORDER BY p.project_name
LIMIT 5;

-- =====================================================
-- ROLLBACK PROCEDURE (If needed)
-- =====================================================
-- If something goes wrong, execute these in reverse order:
/*
-- 1. Drop new policies
DROP POLICY IF EXISTS "Projects are viewable by authenticated users" ON projects;
DROP POLICY IF EXISTS "Projects are manageable by authenticated users" ON projects;

-- 2. Recreate old policies
CREATE POLICY "Service projects are viewable by authenticated users"
  ON projects FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service projects are manageable by authenticated users"
  ON projects FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 3. Rename indexes back
ALTER INDEX IF EXISTS idx_projects_status RENAME TO idx_service_projects_status;
ALTER INDEX IF EXISTS idx_projects_area_of_focus RENAME TO idx_service_projects_area_of_focus;
ALTER INDEX IF EXISTS idx_projects_year RENAME TO idx_service_projects_year;

-- 4. Update foreign key back
ALTER TABLE project_partners DROP CONSTRAINT IF EXISTS project_partners_project_id_fkey;
ALTER TABLE project_partners
  ADD CONSTRAINT project_partners_project_id_fkey
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

-- 5. Rename table back
ALTER TABLE projects RENAME TO service_projects;
*/

-- =====================================================
-- POST-MIGRATION NOTES FOR CEO
-- =====================================================
-- After successful migration:
-- 1. Confirm all verification queries return expected results
-- 2. Notify CTO to deploy code changes
-- 3. Test project creation/editing in application
-- 4. Monitor for any errors in application logs
-- 5. Archive this file in docs/database/
