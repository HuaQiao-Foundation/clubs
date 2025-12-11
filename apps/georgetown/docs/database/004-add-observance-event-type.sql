-- Migration: Add 'observance' event type for Rotary International observances
-- Date: 2025-10-07
-- Purpose: Support World Polio Day, Rotary Anniversary, and Club Anniversary events

-- Drop existing constraint
ALTER TABLE events
DROP CONSTRAINT IF EXISTS events_type_check;

-- Add new constraint including 'observance'
ALTER TABLE events
ADD CONSTRAINT events_type_check
CHECK (type IN ('club_meeting', 'club_event', 'service_project', 'observance', 'holiday'));

-- Verify the change
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'events_type_check';
