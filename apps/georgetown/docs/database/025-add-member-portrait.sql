-- Migration 025: Add portrait_url to members table
-- Purpose: Support member portraits in List view and Cards view
-- Date: 2025-01-14
-- Production Deploy: Not deployed
-- Prerequisites: members table exists (created in initial schema)
-- Author: CTO (Claude Code)

-- Add portrait_url for member headshot photos
ALTER TABLE members
ADD COLUMN IF NOT EXISTS portrait_url TEXT;

-- Comments for documentation
COMMENT ON COLUMN members.portrait_url IS 'URL to member portrait photo in Supabase Storage. Optional field with graceful fallback to initials if null.';

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================
-- CEO: Run this after migration to verify success
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'members' AND column_name = 'portrait_url';

-- Expected result:
-- column_name   | data_type | is_nullable
-- portrait_url  | text      | YES

-- =====================================================
-- NOTES FOR CEO
-- =====================================================
-- 1. This column is OPTIONAL - all existing members will have NULL values
-- 2. The UI components already handle NULL gracefully (show initials)
-- 3. No data migration needed - portraits can be added gradually
-- 4. Portrait URLs should point to Supabase Storage paths
-- 5. Recommended image specs: 200x200px minimum, square aspect ratio, JPG/PNG format
