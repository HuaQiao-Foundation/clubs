-- Migration: Add 'club_assembly' to events.type constraint
-- Description: Adds Club Assembly as a new event type option
-- Date: 2025-11-19
-- Requested by: CEO
--
-- EXECUTION REQUIRED: This migration must be executed by CEO in Supabase SQL Editor
-- See docs/workflows/database-migration-workflow.md for execution process

-- Drop the existing CHECK constraint
ALTER TABLE events DROP CONSTRAINT IF EXISTS events_type_check;

-- Add new CHECK constraint with 'club_assembly' included
ALTER TABLE events ADD CONSTRAINT events_type_check
  CHECK (type IN ('club_meeting', 'club_assembly', 'club_event', 'service_project', 'holiday', 'observance'));

-- Verification query (run after executing above)
-- SELECT conname, pg_get_constraintdef(oid)
-- FROM pg_constraint
-- WHERE conrelid = 'events'::regclass AND conname = 'events_type_check';
