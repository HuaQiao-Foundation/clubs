-- Migration 019: Add Club President Photo and Manual Rotary Year Selection
-- Purpose:
--   1. Add official portrait field for club presidents
--   2. Allow manual Rotary year selection for service projects (fallback to auto-linking)
-- Date: 2025-10-13

-- =====================================================
-- 1. ADD CLUB PRESIDENT PHOTO TO ROTARY_YEARS
-- =====================================================
-- Stores Supabase Storage URL for president's official portrait

ALTER TABLE rotary_years
  ADD COLUMN IF NOT EXISTS club_president_photo_url TEXT;

COMMENT ON COLUMN rotary_years.club_president_photo_url IS
  'Supabase Storage URL for club president official portrait photo';

-- =====================================================
-- 2. NO CHANGES NEEDED TO SERVICE_PROJECTS
-- =====================================================
-- The rotary_year_id field already exists from migration 018
-- This serves as both:
--   - Auto-populated field (when completion_date is set)
--   - Manual selection field (can be set directly by users)
--
-- Users can manually select a Rotary year even without completion_date
-- This handles edge cases where:
--   - Project spans multiple years
--   - Completion date is unknown but year is known
--   - User wants to override auto-linking logic

-- =====================================================
-- 3. UPDATE EXISTING PROJECT (Christmas Orphan Care)
-- =====================================================
-- Link the existing "Christmas Orphan Care Project" to 2024-2025
-- Based on start_date: 2024-12-14 (falls in Rotary Year 2024-2025)

UPDATE service_projects
SET
  rotary_year_id = (
    SELECT id FROM rotary_years WHERE rotary_year = '2024-2025' LIMIT 1
  ),
  completion_date = '2024-12-14'  -- Assume completed same day (single-day event)
WHERE
  project_name = 'Christmas Orphan Care Project'
  AND rotary_year_id IS NULL;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- CEO: Run these after migration

-- Check president photo column added
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'rotary_years' AND column_name = 'club_president_photo_url';

-- Verify Christmas project linked to 2024-2025
-- SELECT
--   sp.project_name,
--   sp.start_date,
--   sp.completion_date,
--   ry.rotary_year
-- FROM service_projects sp
-- LEFT JOIN rotary_years ry ON sp.rotary_year_id = ry.id
-- WHERE sp.project_name = 'Christmas Orphan Care Project';

-- Check all projects with their Rotary year linkage
-- SELECT
--   sp.project_name,
--   sp.status,
--   sp.start_date,
--   sp.completion_date,
--   ry.rotary_year
-- FROM service_projects sp
-- LEFT JOIN rotary_years ry ON sp.rotary_year_id = ry.id
-- ORDER BY sp.start_date DESC;
