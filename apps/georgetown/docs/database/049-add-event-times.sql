-- Migration 049: Add start_time and end_time to events
-- Purpose: Allow events to specify specific times, not just dates
-- Date: 2025-10-18
-- Author: CTO

-- Add time columns to events table
ALTER TABLE events
  ADD COLUMN start_time TIME,
  ADD COLUMN end_time TIME;

-- Add comment for documentation
COMMENT ON COLUMN events.start_time IS 'Event start time (HH:MM format, 24-hour)';
COMMENT ON COLUMN events.end_time IS 'Event end time (HH:MM format, 24-hour)';

-- Verification query (run after migration to confirm)
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'events'
-- AND column_name IN ('start_time', 'end_time');
