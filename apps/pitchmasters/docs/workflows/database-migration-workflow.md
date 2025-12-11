# Database Migration Workflow

**Purpose**: Standard process for creating and deploying database schema changes to Pitchmasters' Supabase instance.

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
"We need to track founder pitch practice sessions"
"Add club capacity field for venue planning"
"Create new event type for startup demo days"
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
touch 006-pitch-practice-sessions.sql
```

**Add file header:**

```sql
-- Migration: Add pitch_practice_sessions table
-- Created: 2025-10-08
-- Production Deploy: Not deployed
-- Prerequisites: members table exists (initial-schema.sql)
-- Purpose: Track founder pitch practice sessions for skill development tracking
```

**Write idempotent SQL:**

```sql
-- Create pitch_practice_sessions table if it doesn't exist
CREATE TABLE IF NOT EXISTS pitch_practice_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id) ON DELETE CASCADE,
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    session_date TIMESTAMP WITH TIME ZONE NOT NULL,
    pitch_title VARCHAR(255) NOT NULL,
    duration_seconds INTEGER,
    feedback_score INTEGER CHECK (feedback_score >= 1 AND feedback_score <= 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index for queries by member
CREATE INDEX IF NOT EXISTS idx_pitch_sessions_member_id
ON pitch_practice_sessions(member_id);

-- Add index for queries by club
CREATE INDEX IF NOT EXISTS idx_pitch_sessions_club_id
ON pitch_practice_sessions(club_id);

-- Add RLS policy
ALTER TABLE pitch_practice_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pitch_sessions_select_policy" ON pitch_practice_sessions;
CREATE POLICY "pitch_sessions_select_policy"
ON pitch_practice_sessions FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "pitch_sessions_insert_policy" ON pitch_practice_sessions;
CREATE POLICY "pitch_sessions_insert_policy"
ON pitch_practice_sessions FOR INSERT
TO authenticated
WITH CHECK (true);
```

---

### 3. CEO Execution in Supabase

**CTO provides migration to CEO:**

```markdown
**Ready for deployment**: docs/database/006-pitch-practice-sessions.sql

Please execute this SQL in Supabase SQL Editor:
1. Navigate to https://supabase.com/dashboard
2. Select Pitchmasters project
3. Click "SQL Editor" in left sidebar
4. Click "New query"
5. Copy SQL from docs/database/006-pitch-practice-sessions.sql
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
-- Check table exists
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'pitch_practice_sessions'
ORDER BY ordinal_position;

-- Check indexes exist
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'pitch_practice_sessions';

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'pitch_practice_sessions';
```

---

### 4. CTO Verification

**After CEO confirms deployment, CTO tests in application:**

```bash
# Run development server
npm run dev

# Test the new feature:
# - Check that new table appears in Supabase queries
# - Verify data saves correctly
# - Test any UI that displays the new data
# - Confirm data persists after refresh
# - Verify RLS policies work as expected
```

**CTO updates migration file header:**

```sql
-- Migration: Add pitch_practice_sessions table
-- Created: 2025-10-08
-- Production Deploy: 2025-10-08  ← Update with CEO's deployment date
-- Prerequisites: members table exists (initial-schema.sql)
-- Purpose: Track founder pitch practice sessions for skill development tracking
```

---

### 5. Documentation

**Update docs/database/README.md:**

Add entry to migration history table:

```markdown
| File | Purpose | Status | Deploy Date |
|------|---------|--------|-------------|
| `006-pitch-practice-sessions.sql` | Track pitch practice sessions | ✅ Production | 2025-10-08 |
```

**Update database-protocol.md if needed:**
- Document new table in schema reference
- Add business rules for table usage
- Note any UI/UX implications

**Commit to git:**

```bash
git add docs/database/006-pitch-practice-sessions.sql
git add docs/database/README.md
git commit -m "feat(db): add pitch_practice_sessions table

Enables tracking founder pitch practice sessions for skill development.
Migration tested and deployed to production.

See docs/database/006-pitch-practice-sessions.sql"
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
-- Enable RLS on table
ALTER TABLE pitch_practice_sessions ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "pitch_sessions_select_policy" ON pitch_practice_sessions;

-- Create new policy
CREATE POLICY "pitch_sessions_select_policy"
ON pitch_practice_sessions FOR SELECT
TO authenticated
USING (true);
```

### Modifying Existing Columns

```sql
-- Use ALTER COLUMN with care (may require data migration)
ALTER TABLE members
ALTER COLUMN email TYPE VARCHAR(255);

-- Add NOT NULL constraint safely
UPDATE members SET email = '' WHERE email IS NULL;
ALTER TABLE members
ALTER COLUMN email SET NOT NULL;
```

### Data Migration Scripts

```sql
-- Migrate data when changing structure
UPDATE members
SET club_id = (SELECT id FROM clubs WHERE name = 'Pitchmasters' LIMIT 1)
WHERE club_id IS NULL;
```

---

## Rollback Procedures

**If migration causes issues:**

1. **Write rollback SQL:**
   ```sql
   -- Rollback for 006-pitch-practice-sessions.sql
   DROP TABLE IF EXISTS pitch_practice_sessions CASCADE;
   ```

2. **Test rollback locally first** (if possible)

3. **Execute in production if needed** (CEO runs in Supabase)

4. **Document rollback in migration file:**
   ```sql
   -- Production Deploy: 2025-10-08
   -- Rolled Back: 2025-10-09 (reason: conflicted with existing feature)
   ```

---

## Common Issues

**"Table already exists"**
- Use idempotent SQL with existence checks (CREATE TABLE IF NOT EXISTS)
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
