# Database Migration Workflow

**Purpose**: Standard process for creating and deploying database schema changes to Georgetown Rotary's Supabase instance.

**Participants**: CTO (SQL development), CEO (Supabase execution), COO (quality review)

**Key Constraint**: Only CEO has Supabase dashboard access. CTO writes SQL, CEO executes it.

---

## Process Overview

1. **Requirements Gathering** - Understand business need
2. **SQL Development** - CTO writes migration file
3. **CEO Execution** - CEO runs SQL in Supabase SQL Editor
4. **Verification** - CTO tests in application
5. **Documentation** - CTO updates docs and commits to git

---

## Step-by-Step Process

### 1. Requirements Gathering

**CEO provides business requirement:**
```
"We need to track speaker presentation dates"
"Add location capacity field"
"Create new event type for Rotary observances"
```

**CTO clarifies:**
- Required fields and data types
- Business rules and constraints
- Impact on existing features
- UI/UX implications

---

### 2. SQL Development

**CTO creates new migration file:**

```bash
# Determine next sequential number
cd docs/database
ls -1 *.sql | grep "^[0-9]" | tail -1
# If last is 005-*, create 006-*

# Create new migration file
touch 006-speaker-presentation-dates.sql
```

**Add file header:**

```sql
-- Migration: Add presentation_date to speakers table
-- Created: 2025-10-08
-- Production Deploy: Not deployed
-- Prerequisites: speakers table exists (initial-schema.sql)
-- Purpose: Track when speakers presented to enable follow-up scheduling
```

**Write idempotent SQL:**

```sql
-- Add presentation_date column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'speakers'
        AND column_name = 'presentation_date'
    ) THEN
        ALTER TABLE speakers
        ADD COLUMN presentation_date DATE;
    END IF;
END $$;

-- Add index for date queries
CREATE INDEX IF NOT EXISTS idx_speakers_presentation_date
ON speakers(presentation_date);
```

---

### 3. CEO Execution in Supabase

**CTO provides migration to CEO:**

```markdown
**Ready for deployment**: docs/database/006-speaker-presentation-dates.sql

Please execute this SQL in Supabase SQL Editor:
1. Navigate to https://supabase.com/dashboard
2. Select Georgetown Rotary project
3. Click "SQL Editor" in left sidebar
4. Click "New query"
5. Copy SQL from docs/database/006-speaker-presentation-dates.sql
6. Paste into SQL Editor
7. Click "Run" button
8. Confirm success message
```

**CEO executes SQL:**
1. Opens Supabase dashboard
2. Navigates to SQL Editor
3. Runs the migration SQL
4. Verifies success message
5. Confirms to CTO: "Migration deployed successfully"

**CEO verification queries** (optional):

```sql
-- Check column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'speakers'
AND column_name = 'presentation_date';

-- Check index exists
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'speakers'
AND indexname = 'idx_speakers_presentation_date';
```

---

### 4. CTO Verification

**After CEO confirms deployment, CTO tests in application:**

```bash
# Run development server
npm run dev

# Test the new feature:
# - Check that new field appears in forms
# - Verify data saves correctly
# - Test any UI that displays the new field
# - Confirm data persists after refresh
```

**CTO updates migration file header:**

```sql
-- Migration: Add presentation_date to speakers table
-- Created: 2025-10-08
-- Production Deploy: 2025-10-08  ← Update with CEO's deployment date
-- Prerequisites: speakers table exists (initial-schema.sql)
-- Purpose: Track when speakers presented to enable follow-up scheduling
```

---

### 5. Documentation

**Update docs/database/README.md:**

Add entry to migration history table:

```markdown
| File | Purpose | Status | Deploy Date |
|------|---------|--------|-------------|
| `006-speaker-presentation-dates.sql` | Track presentation dates | ✅ Production | 2025-10-08 |
```

**Update database-protocol.md if needed:**
- Document new field in schema reference
- Add business rules for field usage
- Note any UI/UX implications

**Commit to git:**

```bash
git add docs/database/006-speaker-presentation-dates.sql
git add docs/database/README.md
git commit -m "feat(db): add presentation_date field to speakers table

Enables tracking when speakers presented for follow-up scheduling.
Migration tested and deployed to production.

See docs/database/006-speaker-presentation-dates.sql"
```

---

## Quality Checklist

Before marking migration complete, verify:

- ✅ **CTO**: SQL uses idempotent patterns (IF NOT EXISTS, CREATE OR REPLACE)
- ✅ **CTO**: File header includes all metadata (created, deployed, prerequisites, purpose)
- ✅ **CTO**: Migration file created in docs/database/ with sequential numbering
- ✅ **CTO**: Provides clear deployment instructions to CEO
- ✅ **CEO**: Executes SQL in Supabase SQL Editor
- ✅ **CEO**: Confirms successful deployment to CTO
- ✅ **CTO**: Verifies functionality in application (npm run dev)
- ✅ **CTO**: Updates production deploy date in file header
- ✅ **CTO**: Updates migration history in docs/database/README.md
- ✅ **CTO**: Updates related documentation (database-protocol.md, etc.)
- ✅ **CTO**: Commits changes to git with descriptive message

---

## Special Cases

### Adding RLS Policies

```sql
-- Drop existing policy if it exists
DROP POLICY IF EXISTS "speakers_select_policy" ON speakers;

-- Create new policy
CREATE POLICY "speakers_select_policy"
ON speakers FOR SELECT
TO authenticated
USING (true);
```

### Modifying Existing Columns

```sql
-- Use ALTER COLUMN with care (may require data migration)
ALTER TABLE speakers
ALTER COLUMN email TYPE VARCHAR(255);

-- Add NOT NULL constraint safely
UPDATE speakers SET email = '' WHERE email IS NULL;
ALTER TABLE speakers
ALTER COLUMN email SET NOT NULL;
```

### Data Migration Scripts

```sql
-- Migrate data when changing structure
UPDATE speakers
SET presentation_date = created_at::DATE
WHERE status = 'spoken'
AND presentation_date IS NULL;
```

---

## Rollback Procedures

**If migration causes issues:**

1. **Write rollback SQL:**
   ```sql
   -- Rollback for 006-speaker-presentation-dates.sql
   DROP INDEX IF EXISTS idx_speakers_presentation_date;
   ALTER TABLE speakers DROP COLUMN IF EXISTS presentation_date;
   ```

2. **Test rollback locally first**

3. **Execute in production if needed**

4. **Document rollback in migration file:**
   ```sql
   -- Production Deploy: 2025-10-08
   -- Rolled Back: 2025-10-09 (reason: conflicted with existing feature)
   ```

---

## Common Issues

**"Column already exists"**
- Use idempotent SQL with existence checks
- Verify migration hasn't already been run

**"Permission denied"**
- Check RLS policies
- Verify service role credentials

**"Foreign key constraint violation"**
- Ensure referenced tables/columns exist
- Check data integrity before adding constraints

**"Type mismatch"**
- Verify data types match business requirements
- Use explicit type casts when needed

---

## Best Practices

✅ **DO**:
- Always test in SQL Editor before considering deployed
- Use sequential numbering for clear migration order
- Write idempotent SQL (safe to run multiple times)
- Document business purpose in file header
- Update migration history immediately after deploy
- Commit SQL and docs together

❌ **DON'T**:
- Modify migration files after production deployment
- Skip sequential numbers in file naming
- Deploy without testing
- Forget to update production deploy date
- Mix multiple unrelated changes in one migration
- Commit without descriptive message

---

**Workflow Owner**: CTO
**Review Frequency**: Update as process evolves
**Last Updated**: 2025-10-08
