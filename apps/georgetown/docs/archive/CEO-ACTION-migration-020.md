# CEO ACTION REQUIRED: Migration 020 - District Governor Photo Field

## Overview
Add District Governor official portrait photo field to timeline system for visual consistency across all three leadership levels (Club President, DG, RI President).

## Migration SQL to Execute

**File**: `docs/database/020-add-district-governor-photo.sql`

### Copy and execute this SQL in Supabase SQL Editor:

```sql
-- Migration 020: Add District Governor Photo Field
-- Purpose: Add official portrait photo field for District Governors

ALTER TABLE rotary_years
  ADD COLUMN IF NOT EXISTS district_governor_photo_url TEXT;

COMMENT ON COLUMN rotary_years.district_governor_photo_url IS 'URL to District Governor official portrait photo in Supabase Storage';
```

## Verification Queries

### 1. Verify column was added:
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'rotary_years'
  AND column_name = 'district_governor_photo_url';
```

**Expected Result**: One row showing the new column

### 2. View current DG data:
```sql
SELECT
  rotary_year,
  dg_name,
  district_governor_photo_url
FROM rotary_years
ORDER BY start_date DESC;
```

**Expected Result**: All years with NULL district_governor_photo_url (until photos are uploaded)

## How to Upload District Governor Photos

### Step 1: Prepare Photos
- Recommended size: 512x512px or larger square images
- Format: JPG or PNG
- File naming convention: `dg-[name]-[year].jpg` (e.g., `dg-arvind-kumar-2024-2025.jpg`)

### Step 2: Upload to Supabase Storage

1. Go to Supabase Dashboard → Storage → `rotary-themes` bucket
2. Upload DG portrait photos to the existing `rotary-themes` bucket
   - **Rationale**: DG portraits are year-specific like club president photos and theme logos
   - All annual Rotary year assets in one centralized location
3. Copy the public URL for each photo

### Step 3: Update Database with Photo URLs

```sql
-- Example: Add DG photo for 2024-2025
UPDATE rotary_years
SET district_governor_photo_url = 'https://[your-project-id].supabase.co/storage/v1/object/public/rotary-themes/dg-arvind-kumar-2024-2025.jpg'
WHERE rotary_year = '2024-2025';

-- Example: Add DG photo for 2025-2026
UPDATE rotary_years
SET district_governor_photo_url = 'https://[your-project-id].supabase.co/storage/v1/object/public/rotary-themes/dg-edward-khoo-2025-2026.jpg'
WHERE rotary_year = '2025-2026';
```

## What This Enables

**Timeline Display Enhancement:**
- District Governor portraits now display as circular photos (128x128px) with blue border
- Matches the Club President portrait display style
- Provides visual consistency across all three leadership levels
- Photos appear above the DG theme section when URL is provided

**Visual Hierarchy:**
1. **Club President**: Name + Portrait + Theme + Theme Logo
2. **District Governor**: Name + Portrait + Theme + Theme Logo
3. **RI President**: Name + Theme + Theme Logo (no portrait - international figure)

## Frontend Changes Already Deployed

- ✅ TypeScript types updated with `district_governor_photo_url` field
- ✅ YearOverview component passes DG photo to ThemeDisplay
- ✅ ThemeDisplay component renders circular portrait for DG level
- ✅ Styling matches Club President portrait display

## Next Steps After Migration

1. Execute migration SQL above
2. Run verification queries to confirm field exists
3. Upload DG portrait photos to Supabase Storage (optional - can be done anytime)
4. Update records with photo URLs when ready
5. View timeline to see DG portraits display alongside Club President portraits

## Support

If you encounter any issues:
- Check that the Storage bucket is public
- Verify photo URLs are publicly accessible
- Ensure photo files are optimized (< 500KB recommended)
- Contact CTO if photos don't display after migration
