-- Migration 027: Add key_highlights field to rotary_years table
-- Purpose: Add markdown-formatted text field for key year highlights (separate from summary)
-- Date: 2025-10-14

-- Add key_highlights column to rotary_years table
ALTER TABLE public.rotary_years
ADD COLUMN IF NOT EXISTS key_highlights TEXT NULL;

COMMENT ON COLUMN public.rotary_years.key_highlights IS 'Markdown-formatted text for key highlights and achievements of the Rotary year. Displayed as a separate section from the year summary.';

-- Note: This is separate from the existing 'highlights' JSONB field
-- - key_highlights (TEXT): Markdown-formatted free text for display
-- - highlights (JSONB): Structured array for programmatic use (kept for future)
