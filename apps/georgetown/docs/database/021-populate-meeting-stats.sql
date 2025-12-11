-- Migration 021: Populate Meeting Statistics from Calendar Events
-- Date: 2025-10-13
-- Purpose: Calculate and update meeting counts in rotary_years.stats based on calendar events
--
-- IMPORTANT: For current year, only count meetings up to TODAY (progress-aware)
--            For past years, count all meetings (historical accuracy)

-- Update meeting counts for all Rotary years
-- Current year: Count only meetings that have occurred (date <= CURRENT_DATE)
-- Past years: Count all meetings in the year period
UPDATE rotary_years
SET stats = jsonb_set(
  COALESCE(stats, '{}'::jsonb),
  '{meetings}',
  to_jsonb((
    SELECT COUNT(*)::int
    FROM events
    WHERE type = 'club_meeting'
      AND date >= rotary_years.start_date
      AND date <= LEAST(
        rotary_years.end_date,
        CASE
          WHEN CURRENT_DATE BETWEEN rotary_years.start_date AND rotary_years.end_date
          THEN CURRENT_DATE
          ELSE rotary_years.end_date
        END
      )
  ))
);

-- Verification: Check meeting counts for all years
SELECT
  rotary_year,
  start_date,
  end_date,
  CASE
    WHEN CURRENT_DATE BETWEEN start_date AND end_date THEN 'CURRENT'
    WHEN CURRENT_DATE > end_date THEN 'PAST'
    ELSE 'FUTURE'
  END as year_status,
  stats->'meetings' as meeting_count,
  (
    SELECT COUNT(*)
    FROM events
    WHERE type = 'club_meeting'
      AND date >= rotary_years.start_date
      AND date <= LEAST(
        rotary_years.end_date,
        CASE
          WHEN CURRENT_DATE BETWEEN rotary_years.start_date AND rotary_years.end_date
          THEN CURRENT_DATE
          ELSE rotary_years.end_date
        END
      )
  ) as actual_meetings_held_to_date
FROM rotary_years
ORDER BY start_date DESC;
