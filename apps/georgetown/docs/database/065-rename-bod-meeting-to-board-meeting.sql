-- Migration: 065-rename-bod-meeting-to-board-meeting.sql
-- Purpose: Rename event type from 'bod_meeting' to 'board_meeting' for consistency
-- Date: 2025-12-02
-- Author: CTO (RSVP Feature Enhancement)
-- Issue: Standardize naming convention - 'board_meeting' matches 'club_meeting', 'committee_meeting' pattern

-- Step 1: Drop existing check constraint
ALTER TABLE events DROP CONSTRAINT events_type_check;

-- Step 2: Add new check constraint with 'board_meeting' instead of 'bod_meeting'
ALTER TABLE events ADD CONSTRAINT events_type_check
CHECK (type = ANY (ARRAY[
  'club_meeting'::text,
  'club_assembly'::text,
  'board_meeting'::text,
  'committee_meeting'::text,
  'club_event'::text,
  'service_project'::text,
  'holiday'::text,
  'observance'::text
]));

-- Step 3: Update all existing 'bod_meeting' records to 'board_meeting'
UPDATE events
SET type = 'board_meeting'
WHERE type = 'bod_meeting';

-- Verify: Check all board meetings
SELECT id, title, type, date
FROM events
WHERE type = 'board_meeting'
ORDER BY date DESC
LIMIT 5;
