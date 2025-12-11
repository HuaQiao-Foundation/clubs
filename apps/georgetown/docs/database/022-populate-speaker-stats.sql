-- Migration 022: Populate Speaker Statistics from Speakers Table
-- Date: 2025-10-13
-- Purpose: Calculate and update speaker counts in rotary_years.stats based on speakers with status='spoken'
--
-- IMPORTANT: For current year, only count speakers who have spoken up to TODAY (progress-aware)
--            For past years, count all speakers who spoke during the year (historical accuracy)

-- Update speaker counts for all Rotary years
-- Current year: Count only speakers where scheduled_date <= CURRENT_DATE
-- Past years: Count all speakers who spoke during the year period
UPDATE rotary_years
SET stats = jsonb_set(
  COALESCE(stats, '{}'::jsonb),
  '{speakers}',
  to_jsonb((
    SELECT COUNT(*)::int
    FROM speakers
    WHERE status = 'spoken'
      AND scheduled_date IS NOT NULL
      AND scheduled_date >= rotary_years.start_date
      AND scheduled_date <= LEAST(
        rotary_years.end_date,
        CASE
          WHEN CURRENT_DATE BETWEEN rotary_years.start_date AND rotary_years.end_date
          THEN CURRENT_DATE
          ELSE rotary_years.end_date
        END
      )
  ))
);

-- Verification: Check speaker counts for all years
SELECT
  rotary_year,
  start_date,
  end_date,
  CASE
    WHEN CURRENT_DATE BETWEEN start_date AND end_date THEN 'CURRENT'
    WHEN CURRENT_DATE > end_date THEN 'PAST'
    ELSE 'FUTURE'
  END as year_status,
  stats->'speakers' as speaker_count,
  (
    SELECT COUNT(*)
    FROM speakers
    WHERE status = 'spoken'
      AND scheduled_date IS NOT NULL
      AND scheduled_date >= rotary_years.start_date
      AND scheduled_date <= LEAST(
        rotary_years.end_date,
        CASE
          WHEN CURRENT_DATE BETWEEN rotary_years.start_date AND rotary_years.end_date
          THEN CURRENT_DATE
          ELSE rotary_years.end_date
        END
      )
  ) as actual_speakers_to_date
FROM rotary_years
ORDER BY start_date DESC;

-- Additional verification: List speakers for current year
SELECT
  name,
  topic,
  scheduled_date,
  status
FROM speakers
WHERE status = 'spoken'
  AND scheduled_date >= (SELECT start_date FROM rotary_years WHERE rotary_year = '2025-2026')
  AND scheduled_date <= CURRENT_DATE
ORDER BY scheduled_date DESC;
