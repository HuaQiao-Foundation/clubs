-- Migration 028: Drop key_highlights field from rotary_years table
-- Purpose: Remove key_highlights field - using narrative, highlights JSONB, and challenges instead
-- Date: 2025-10-14

-- Drop key_highlights column from rotary_years table
ALTER TABLE public.rotary_years
DROP COLUMN IF EXISTS key_highlights;

-- Note: Reverting migration 027
-- Timeline page will now show:
-- 1. Year Summary (summary TEXT)
-- 2. Narrative (narrative TEXT)
-- 3. Highlights (highlights JSONB)
-- 4. Challenges (challenges JSONB)
