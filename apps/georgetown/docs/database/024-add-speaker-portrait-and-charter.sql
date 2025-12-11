-- Migration 024: Add portrait_url to speakers table
-- Purpose: Support speaker portraits in Cards view
-- Date: 2025-10-13
-- Author: CTO (Claude Code)

-- Add portrait_url for speaker headshot photos
ALTER TABLE speakers
ADD COLUMN portrait_url TEXT;

-- Comments for documentation
COMMENT ON COLUMN speakers.portrait_url IS 'URL to speaker portrait photo in Supabase Storage. Optional field with graceful fallback to initials if null.';
