-- Migration: Add agenda field to events table
-- Description: Adds optional agenda field for structured meeting agendas (Club Meeting and Club Assembly)
-- Date: 2025-11-19
-- Requested by: CEO
--
-- EXECUTION REQUIRED: This migration must be executed by CEO in Supabase SQL Editor
-- See docs/workflows/database-migration-workflow.md for execution process

-- Add agenda column to events table
ALTER TABLE events ADD COLUMN agenda TEXT;

-- Add comment to document field purpose
COMMENT ON COLUMN events.agenda IS 'Structured meeting agenda for Club Meeting and Club Assembly events. Supports multi-line formatted content (markdown, numbered lists, bullet points).';

-- Verification query (run after executing above)
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'events' AND column_name = 'agenda';
