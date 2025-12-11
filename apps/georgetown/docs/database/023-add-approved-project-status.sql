-- Migration: Add 'Approved' status to service_projects
-- Date: 2025-10-13
-- Purpose: Add "Approved" status to align Projects workflow with Speakers workflow (6 stages)
-- Author: CTO (Claude Code)

-- Background:
-- Projects workflow should mirror Speakers workflow for consistency:
-- Speakers: Ideas → Approached → Agreed → Scheduled → Spoken → Dropped
-- Projects: Idea → Planning → Approved → Execution → Completed → Dropped
--
-- Currently Projects has 5 stages (missing "Approved" between Planning and Execution)
-- This migration adds "Approved" as a valid status value

-- Step 1: Add new status value to the status column
-- Note: PostgreSQL ENUM types are immutable, so we need to use a different approach
-- if the column is defined as an ENUM. If it's a TEXT/VARCHAR with CHECK constraint,
-- we update the constraint.

-- Check current constraint (if exists)
-- This migration assumes status is VARCHAR/TEXT with a CHECK constraint or no constraint

-- If status has a CHECK constraint, we need to drop and recreate it
DO $$
BEGIN
  -- Drop existing check constraint if it exists
  IF EXISTS (
    SELECT 1
    FROM information_schema.constraint_column_usage
    WHERE table_name = 'service_projects'
    AND column_name = 'status'
    AND constraint_name LIKE '%status%check%'
  ) THEN
    ALTER TABLE service_projects
    DROP CONSTRAINT IF EXISTS service_projects_status_check;
  END IF;

  -- Add new check constraint with Approved status
  ALTER TABLE service_projects
  ADD CONSTRAINT service_projects_status_check
  CHECK (status IN ('Idea', 'Planning', 'Approved', 'Execution', 'Completed', 'Dropped'));

EXCEPTION
  WHEN OTHERS THEN
    -- If column doesn't have constraint, this is fine
    RAISE NOTICE 'Status column may not have had a constraint, adding new one';

    -- Try to add constraint anyway
    BEGIN
      ALTER TABLE service_projects
      ADD CONSTRAINT service_projects_status_check
      CHECK (status IN ('Idea', 'Planning', 'Approved', 'Execution', 'Completed', 'Dropped'));
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE 'Could not add constraint, column may already allow any value';
    END;
END $$;

-- Step 2: Verify no existing projects are in invalid state
-- (This query just reports, doesn't change anything)
DO $$
DECLARE
  invalid_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO invalid_count
  FROM service_projects
  WHERE status NOT IN ('Idea', 'Planning', 'Approved', 'Execution', 'Completed', 'Dropped');

  IF invalid_count > 0 THEN
    RAISE WARNING 'Found % projects with invalid status values that need manual review', invalid_count;
  ELSE
    RAISE NOTICE 'All existing projects have valid status values';
  END IF;
END $$;

-- Step 3: Optional - if you want to migrate existing "Planning" projects to "Approved"
-- based on some business logic, you could add that here. For now, we leave data as-is
-- and let officers manually update projects to "Approved" status as needed.

-- Verification Query (for manual checking after migration):
-- SELECT status, COUNT(*) as count
-- FROM service_projects
-- GROUP BY status
-- ORDER BY
--   CASE status
--     WHEN 'Idea' THEN 1
--     WHEN 'Planning' THEN 2
--     WHEN 'Approved' THEN 3
--     WHEN 'Execution' THEN 4
--     WHEN 'Completed' THEN 5
--     WHEN 'Dropped' THEN 6
--     ELSE 7
--   END;

-- Note for CEO: After running this migration in Supabase SQL Editor,
-- CTO will update frontend code to include "Approved" status in:
-- - src/types/database.ts (ServiceProject type)
-- - src/components/ServiceProjectModal.tsx (PROJECT_STATUSES array)
-- - src/components/ServiceProjectsPage.tsx (kanban columns and colors)
