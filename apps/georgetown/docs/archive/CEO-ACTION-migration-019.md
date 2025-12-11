# CEO Action Required: Migration 019 - President Photo & Project Fix

**Date**: 2025-10-13
**Priority**: High (Fixes Christmas project issue you identified)
**Estimated Time**: 5 minutes

---

## What This Fixes

1. **Christmas Orphan Care Project** - Will appear in 2024-2025 timeline (currently shows "FY 2024" but should be in Rotary Year 2024-2025)
2. **Club President Official Portrait** - Adds photo field for presidential portraits in annual records

---

## Execute in Supabase SQL Editor

Copy and paste this entire SQL block:

```sql
-- Migration 019: Add Club President Photo and Fix Christmas Project

-- 1. Add club president photo field
ALTER TABLE rotary_years
  ADD COLUMN IF NOT EXISTS club_president_photo_url TEXT;

-- 2. Link Christmas Orphan Care Project to 2024-2025
UPDATE service_projects
SET
  rotary_year_id = (
    SELECT id FROM rotary_years WHERE rotary_year = '2024-2025' LIMIT 1
  ),
  completion_date = '2024-12-14'
WHERE
  project_name = 'Christmas Orphan Care Project'
  AND rotary_year_id IS NULL;
```

---

## Verification Queries

Run these after the migration to confirm success:

### 1. Check president photo field added
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'rotary_years' AND column_name = 'club_president_photo_url';
```

**Expected**: 1 row showing `club_president_photo_url | text`

### 2. Verify Christmas project linked to 2024-2025
```sql
SELECT
  sp.project_name,
  sp.start_date,
  sp.completion_date,
  sp.status,
  ry.rotary_year
FROM service_projects sp
LEFT JOIN rotary_years ry ON sp.rotary_year_id = ry.id
WHERE sp.project_name = 'Christmas Orphan Care Project';
```

**Expected**:
```
project_name: Christmas Orphan Care Project
start_date: 2024-12-14
completion_date: 2024-12-14
status: Completed
rotary_year: 2024-2025
```

### 3. Manually trigger statistics update for 2024-2025

The auto-calculation didn't run yet. Execute this to calculate stats:

```sql
-- Update 2024-2025 statistics based on linked projects
UPDATE rotary_years
SET stats = jsonb_build_object(
  'meetings', 0,
  'speakers', 0,
  'projects', (
    SELECT COUNT(*)::int
    FROM service_projects
    WHERE rotary_year_id = rotary_years.id
    AND status = 'Completed'
  ),
  'beneficiaries', (
    SELECT COALESCE(SUM(beneficiary_count), 0)::int
    FROM service_projects
    WHERE rotary_year_id = rotary_years.id
    AND status = 'Completed'
  ),
  'project_value_rm', (
    SELECT COALESCE(SUM(project_value_rm), 0)::numeric
    FROM service_projects
    WHERE rotary_year_id = rotary_years.id
    AND status = 'Completed'
  )
)
WHERE rotary_year = '2024-2025';
```

**Then verify**:
```sql
SELECT rotary_year, stats FROM rotary_years WHERE rotary_year = '2024-2025';
```

**Expected**:
```json
{
  "meetings": 0,
  "speakers": 0,
  "projects": 1,
  "beneficiaries": 20,
  "project_value_rm": 4999.00
}
```

---

## After Migration

1. **Refresh timeline page** in the app: `http://localhost:5173/timeline`
2. **Select "2024-2025"** from year dropdown
3. **Verify Christmas project appears** in the "Completed Service Projects" section

---

## What Changed in the App

- Completion Date is now **optional** (not required) for Completed projects
- Auto-linking still works when completion_date is set
- Christmas project will now show in correct Rotary year

---

## Adding Club President Official Portraits

The `club_president_photo_url` field is now available. This is **separate from the club theme logo**.

**Purpose**: Store president's official portrait photo for annual records

**Display**: Shows as circular portrait with blue border above the club theme

**To add a president photo:**

1. Upload portrait to Supabase Storage `rotary-themes` bucket (square image recommended, will be cropped to circle)
2. Get the public URL
3. Update rotary_years record:

```sql
UPDATE rotary_years
SET club_president_photo_url = 'https://[your-supabase-url].supabase.co/storage/v1/object/public/rotary-themes/president-howard-roscoe-2025-2026.jpg'
WHERE rotary_year = '2025-2026';
```

**Note**: This is different from `club_president_theme_logo_url` which is the club's annual theme logo/artwork.

---

## Confirmation

After executing, please reply:
- [ ] Migration executed successfully
- [ ] Christmas project now shows in 2024-2025 timeline
- [ ] Any errors encountered

**CTO will verify in app after your confirmation.**
