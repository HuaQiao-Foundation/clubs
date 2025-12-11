-- Migration 057: Rename bod_meeting to board_meeting
-- Purpose: Update event type naming for clarity and consistency
-- Date: 2025-12-02
-- Author: CTO

-- Update existing events with type 'bod_meeting' to 'board_meeting'
UPDATE events
SET type = 'board_meeting'
WHERE type = 'bod_meeting';

-- Note: No table structure changes required
-- The 'type' column is already text and accepts any value
-- This migration only updates existing data values

-- Verification query (run after migration):
-- SELECT DISTINCT type FROM events ORDER BY type;
-- Expected to see: board_meeting, club_assembly, club_event, club_meeting, holiday, observance, service_project
