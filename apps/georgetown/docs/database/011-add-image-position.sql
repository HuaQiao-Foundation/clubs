-- Migration 011: Add Image Position Field
-- Purpose: Store focal point for image cropping (object-position CSS)
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- Add image_position column with default 'center'
ALTER TABLE service_projects
ADD COLUMN image_position TEXT DEFAULT 'center';

-- Verify column was added
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'service_projects'
  AND column_name = 'image_position';
