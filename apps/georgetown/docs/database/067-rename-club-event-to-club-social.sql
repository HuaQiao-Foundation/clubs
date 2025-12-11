-- Migration: Rename club_event to club_social
-- Date: 2025-12-02
-- Description: Rename event type from 'club_event' to 'club_social' for better clarity

-- Step 1: Drop the existing check constraint
ALTER TABLE events DROP CONSTRAINT IF EXISTS events_type_check;

-- Step 2: Add new check constraint with both old and new values (for transition)
ALTER TABLE events ADD CONSTRAINT events_type_check
CHECK (type = ANY (ARRAY[
  'club_meeting'::text,
  'club_assembly'::text,
  'board_meeting'::text,
  'committee_meeting'::text,
  'club_event'::text,
  'club_social'::text,
  'service_project'::text,
  'holiday'::text,
  'observance'::text
]));

-- Step 3: Update all existing 'club_event' records to 'club_social'
UPDATE events
SET type = 'club_social'
WHERE type = 'club_event';

-- Step 4: Drop and recreate constraint without 'club_event' (clean up)
ALTER TABLE events DROP CONSTRAINT events_type_check;

ALTER TABLE events ADD CONSTRAINT events_type_check
CHECK (type = ANY (ARRAY[
  'club_meeting'::text,
  'club_assembly'::text,
  'board_meeting'::text,
  'committee_meeting'::text,
  'club_social'::text,
  'service_project'::text,
  'holiday'::text,
  'observance'::text
]));

-- Add comment for documentation
COMMENT ON COLUMN events.type IS 'Event type: club_meeting, club_assembly, board_meeting, committee_meeting, club_social (formerly club_event), service_project, holiday, observance';
