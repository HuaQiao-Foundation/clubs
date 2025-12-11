-- Migration: 064-standardize-club-meeting-titles.sql
-- Purpose: Standardize all club meeting titles to "Club Meeting"
-- Date: 2025-12-02
-- Author: CTO (RSVP Feature Enhancement)
-- Issue: Remove custom titles like "Business Meeting", "Speaker Meeting" - just use "Club Meeting"

-- Update all club_meeting events to have standardized title
UPDATE events
SET title = 'Club Meeting'
WHERE type = 'club_meeting'
  AND title IN ('Business Meeting', 'Speaker Meeting', 'Regular Club Meeting');

-- Verify: Check all club meeting titles
SELECT id, title, type, date
FROM events
WHERE type = 'club_meeting'
ORDER BY date DESC
LIMIT 10;
