# CEO ACTION REQUIRED: Migration 021 - Populate Meeting Statistics

## Overview
Populate meeting counts in Rotary year statistics by counting `club_meeting` events from the calendar system.

**Progress-Aware Logic:**
- **Current year** (2025-2026): Count only meetings that have occurred up to TODAY
- **Past years**: Count all meetings during the year period (historical accuracy)

## Issue Identified
- 2025-2026 timeline shows 0 meetings even though several club meetings have been held
- Original approach would count all 20 scheduled meetings (including future ones) which is misleading
- Club members need to see **actual progress year-to-date**, not planned future meetings

## Migration SQL to Execute

**File**: `docs/database/021-populate-meeting-stats.sql`

### Copy and execute this SQL in Supabase SQL Editor:

```sql
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
```

## Verification Query

### Check meeting counts for all years:
```sql
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
```

**Expected Result for Current Year (2025-2026):**
- `year_status`: "CURRENT"
- `meeting_count`: Should match number of meetings held from July 1, 2025 to TODAY (not all 20 scheduled)
- Example: If today is October 13, 2025, might show ~15 meetings (July-Oct only)

**Expected Result for Past Years:**
- `year_status`: "PAST"
- `meeting_count`: Shows total meetings held during entire year period

## What This Fixes

**Before:**
- 2025-2026 showed 0 meetings despite having club_meeting events in calendar
- Would show all 20 scheduled meetings (misleading - includes future meetings not yet held)
- Stats were not auto-calculating from existing calendar data

**After:**
- **Current year (2025-2026)**: Shows only meetings held up to today (realistic progress metric)
- **Past years**: Show complete meeting counts (historical accuracy)
- Statistics display: **Meetings** as separate metric from **Speakers**

**User Experience Benefits:**
- Club members see realistic year-to-date progress for current year
- No confusion about whether 20 meetings have actually happened
- Historical years maintain accurate complete records

## Frontend Changes Already Deployed

- ✅ YearOverview now displays 5 separate stat cards (was 4):
  1. **Meetings** - Total held (Calendar icon)
  2. **Speakers** - Presented (Users icon)
  3. **Projects** - Completed (Award icon)
  4. **People Served** - Beneficiaries (Users icon)
  5. **Project Value** - Total value (Award icon)

- ✅ Grid layout changed from `md:grid-cols-4` to `md:grid-cols-5`
- ✅ Meetings and Speakers are now distinct metrics (not combined)

## Going Forward

**Monthly Updates Recommended:**
- Run the UPDATE query monthly to refresh current year meeting count
- As time progresses, more past meetings will be counted automatically
- Example: Today shows 15 meetings (July-Oct), next month will show ~19 (July-Nov)

**Manual Update Anytime:**
```sql
-- Quick refresh of all meeting counts
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
        CASE WHEN CURRENT_DATE BETWEEN rotary_years.start_date AND rotary_years.end_date
        THEN CURRENT_DATE ELSE rotary_years.end_date END
      )
  ))
);
```

## Next Steps After Migration

1. Execute migration SQL above
2. Run verification query to confirm counts are correct
3. View 2025-2026 timeline - should show actual meeting count
4. Verify all other years show correct meeting counts

## Support

If meeting counts don't match expectations:
- Verify events table has correct `type = 'club_meeting'` entries
- Check event dates fall within Rotary year start/end dates
- Contact CTO if discrepancies persist
