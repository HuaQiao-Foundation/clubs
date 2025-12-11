-- Migration 009: Add Impact Field to Service Projects
-- Purpose: Separate qualitative impact description from internal notes
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- Add impact column
ALTER TABLE service_projects
ADD COLUMN impact TEXT;

-- Verify column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'service_projects'
  AND column_name = 'impact';
