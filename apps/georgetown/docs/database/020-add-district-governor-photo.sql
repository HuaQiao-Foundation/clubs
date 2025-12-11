-- Migration 020: Add District Governor Photo Field
-- Date: 2025-10-13
-- Purpose: Add official portrait photo field for District Governors to match Club President display

-- Add district governor photo field to rotary_years table
ALTER TABLE rotary_years
  ADD COLUMN IF NOT EXISTS district_governor_photo_url TEXT;

COMMENT ON COLUMN rotary_years.district_governor_photo_url IS 'URL to District Governor official portrait photo in Supabase Storage';

-- Example: Update existing year with DG photo (replace with actual Supabase Storage URL)
-- UPDATE rotary_years
-- SET district_governor_photo_url = 'https://[project-id].supabase.co/storage/v1/object/public/rotary-photos/dg-arvind-kumar-2024-2025.jpg'
-- WHERE rotary_year = '2024-2025';

-- Verification Query
-- SELECT
--   rotary_year,
--   district_governor_name,
--   district_governor_photo_url
-- FROM rotary_years
-- ORDER BY start_date DESC;
