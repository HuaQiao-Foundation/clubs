# Supabase Migration Instructions: LinkedIn URL Field
## Georgetown Rotary Speaker Management System

### IMPORTANT: Read Completely Before Starting
These instructions add a new `linkedin_url` field to your speakers table while preserving all existing data.

---

## Step 1: Access Supabase Dashboard
1. Open your browser and go to https://supabase.com
2. Sign in to your account
3. Select the Georgetown Rotary project from your dashboard

## Step 2: Navigate to SQL Editor
1. In the left sidebar, click on **"SQL Editor"**
2. Click the **"+ New query"** button to create a new SQL query tab

## Step 3: Add LinkedIn URL Field

### Copy and paste this EXACT SQL command:
```sql
-- Add linkedin_url field to speakers table
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS linkedin_url TEXT;

-- Add a comment to document the field
COMMENT ON COLUMN speakers.linkedin_url IS 'LinkedIn profile URL for the speaker';
```

### Execute the migration:
1. Click the **"Run"** button (or press Ctrl+Enter / Cmd+Enter)
2. You should see a success message: "Success. No rows returned"
3. If you see any error, STOP and do not proceed

## Step 4: Verify the Migration

### Run this verification query:
```sql
-- Check that the new column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'speakers'
AND column_name = 'linkedin_url';
```

### Expected result:
You should see one row returned:
- column_name: `linkedin_url`
- data_type: `text`
- is_nullable: `YES`

## Step 5: Test the New Field

### Run this test to ensure the field works:
```sql
-- Test updating a speaker with a LinkedIn URL (using a test record)
UPDATE speakers
SET linkedin_url = 'https://www.linkedin.com/in/test-profile/'
WHERE id = (SELECT id FROM speakers LIMIT 1);

-- Verify the update worked
SELECT name, linkedin_url
FROM speakers
WHERE linkedin_url IS NOT NULL;
```

### Then clean up the test:
```sql
-- Remove the test LinkedIn URL
UPDATE speakers
SET linkedin_url = NULL
WHERE linkedin_url = 'https://www.linkedin.com/in/test-profile/';
```

## Step 6: Update RLS Policies (If Applicable)

If you have Row Level Security enabled, run:
```sql
-- Check if RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'speakers';
```

If `rowsecurity` is `true`, your existing policies should already cover the new field since they likely use `*` selection.

## Step 7: Final Verification

### Run this comprehensive check:
```sql
-- Final verification query
SELECT
    COUNT(*) as total_speakers,
    COUNT(primary_url) as speakers_with_primary_url,
    COUNT(additional_urls) as speakers_with_additional_urls,
    COUNT(linkedin_url) as speakers_with_linkedin
FROM speakers;
```

This shows that existing URL fields are preserved and the new LinkedIn field is ready.

---

## Rollback Instructions (If Needed)

**Only use if something goes wrong:**

```sql
-- Remove the linkedin_url column
ALTER TABLE speakers
DROP COLUMN IF EXISTS linkedin_url;
```

---

## What This Migration Does

✅ **ADDS**: New `linkedin_url` field to speakers table
✅ **PRESERVES**: All existing data and fields
✅ **KEEPS**: primary_url, additional_urls unchanged
✅ **ALLOWS**: NULL values (speakers don't require LinkedIn)

## What This Migration Does NOT Do

❌ Does NOT remove any existing fields
❌ Does NOT modify any existing data
❌ Does NOT require LinkedIn URLs for speakers
❌ Does NOT affect any other tables

---

## Success Criteria

After completing these steps, you should be able to:
1. See the new `linkedin_url` column in your speakers table
2. Add LinkedIn URLs to speakers through the application
3. Still use all existing URL fields exactly as before
4. Have zero data loss or modification

---

## Support

If you encounter any issues:
1. Do NOT proceed with partial changes
2. Run the rollback command if needed
3. Contact your developer with the exact error message

---

**Migration prepared**: September 25, 2025
**Estimated time**: 5 minutes
**Risk level**: Low (additive change only)