-- Migration: Add 'observance' event type for Rotary International observances
-- Date: 2025-10-08
-- Purpose: Support World Polio Day, Rotary Anniversary, and Club Anniversary events
-- Version 2: Works regardless of existing constraint name

-- First, drop ALL check constraints on the events table
DO $$
DECLARE
    constraint_record RECORD;
BEGIN
    FOR constraint_record IN
        SELECT con.conname
        FROM pg_constraint con
        JOIN pg_class rel ON rel.oid = con.conrelid
        WHERE rel.relname = 'events' AND con.contype = 'c'
    LOOP
        EXECUTE format('ALTER TABLE events DROP CONSTRAINT IF EXISTS %I', constraint_record.conname);
    END LOOP;
END $$;

-- Add new constraint including 'observance'
ALTER TABLE events
ADD CONSTRAINT events_type_check
CHECK (type IN ('club_meeting', 'club_event', 'service_project', 'observance', 'holiday'));

-- Verify the change
SELECT
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'events'
  AND con.contype = 'c';
