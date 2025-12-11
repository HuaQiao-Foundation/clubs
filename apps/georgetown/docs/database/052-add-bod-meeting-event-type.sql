-- Migration 052: Add BOD Meeting and Committee Meeting event types
-- Purpose: Add 'bod_meeting' and 'committee_meeting' to events.type enum
-- Requires: CEO execution in Supabase SQL Editor
-- Date: 2025-11-20

-- Drop existing CHECK constraint
ALTER TABLE events DROP CONSTRAINT IF EXISTS events_type_check;

-- Add new CHECK constraint with bod_meeting and committee_meeting
ALTER TABLE events ADD CONSTRAINT events_type_check
  CHECK (type IN ('club_meeting', 'club_assembly', 'bod_meeting', 'committee_meeting', 'club_event', 'service_project', 'holiday', 'observance'));

-- Add comment
COMMENT ON CONSTRAINT events_type_check ON events IS
  'Valid event types: club_meeting (weekly meetings), club_assembly (business/voting), bod_meeting (board of directors), committee_meeting (committee meetings), club_event (social/fellowship), service_project (community service), holiday (club closed), observance (special recognition)';
