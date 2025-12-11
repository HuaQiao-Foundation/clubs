# Schema Documentation Workflow

**Purpose**: Maintain accurate database schema documentation using automated snapshots
**Owner**: CEO (executes), CTO (references)
**Setup Time**: 10 minutes (one-time)
**Maintenance**: 5 minutes per migration

---

## One-Time Setup (CEO)

### Step 1: Install Supabase CLI
```bash
brew install supabase/tap/supabase
```

### Step 2: Link Georgetown Project
```bash
cd /Users/randaleastman/dev/georgetown
supabase init
supabase link --project-ref <your-project-id>
```

**Find your project ID**:
- Open Supabase Dashboard
- Project Settings → General → Reference ID

### Step 3: Generate Initial Schema Snapshot
```bash
./scripts/update-schema-snapshot.sh baseline
```

This creates `docs/database/CURRENT-PRODUCTION-SCHEMA.sql` with complete production schema.

### Step 4: Commit Baseline
```bash
git add docs/database/CURRENT-PRODUCTION-SCHEMA.sql
git commit -m "docs(db): establish schema snapshot baseline"
```

---

## After Each Migration Deployment

### CEO Workflow

**1. Deploy Migration** (existing process)
```bash
# Open Supabase Dashboard → SQL Editor
# Paste migration SQL from docs/database/NNN-description.sql
# Execute
# Run verification queries
```

**2. Update Schema Snapshot** (NEW - 2 minutes)
```bash
cd /Users/randaleastman/dev/georgetown
./scripts/update-schema-snapshot.sh 049  # Use actual migration number
```

**Output Example:**
```
📸 Generating schema snapshot from Supabase production...
✅ Schema snapshot saved to docs/database/CURRENT-PRODUCTION-SCHEMA.sql

📊 Schema Summary:
==================
Tables:       9
Indexes:      23
RLS Policies: 18

📋 Tables in Production:
========================
  - events
  - locations
  - members
  - partners
  - photos
  - projects
  - rotary_years
  - service_projects
  - speakers

🎯 Next Steps:
==============
1. Review docs/database/CURRENT-PRODUCTION-SCHEMA.sql for accuracy
2. git add docs/database/CURRENT-PRODUCTION-SCHEMA.sql
3. git commit -m 'docs(db): schema snapshot after migration 049'
4. Update docs/database/049-*.sql header with deploy date
```

**3. Commit Schema Snapshot**
```bash
git add docs/database/CURRENT-PRODUCTION-SCHEMA.sql
git commit -m "docs(db): schema snapshot after migration 049"
```

**4. Update Migration File Header** (optional but recommended)
```bash
# Edit docs/database/049-add-event-times.sql
# Change line: "Production Deploy: Not deployed"
# To: "Production Deploy: 2025-10-18"
# Commit change
```

---

## CTO Workflow (Using Schema Snapshot)

### Before Writing New Migration

**1. Check Current Schema**
```bash
# Open docs/database/CURRENT-PRODUCTION-SCHEMA.sql
# Search for table name to verify correct structure
```

**2. Write Migration Using Accurate Table Names**
```sql
-- Migration 050: Add speaker bio
-- (Use MIGRATION-TEMPLATE.sql as starting point)

-- ✅ CORRECT (verified in CURRENT-PRODUCTION-SCHEMA.sql)
ALTER TABLE events ADD COLUMN start_time TIME;

-- ❌ WRONG (table doesn't exist)
ALTER TABLE club_events ADD COLUMN start_time TIME;
```

**3. Test Migration Locally** (if Supabase local dev setup)
```bash
supabase db reset  # Reset local database
supabase db push   # Apply all migrations
```

**4. Provide Migration to CEO**
```bash
git add docs/database/050-add-speaker-bio.sql
git commit -m "feat(db): migration 050 - add speaker bio field"
# CEO will execute in production
```

---

## Detecting Schema Drift

### CEO: Check for Drift Before Migrations

**Problem**: Production schema doesn't match migration expectations

**Solution**: Compare production to migration files
```bash
cd /Users/randaleastman/dev/georgetown
supabase db diff
```

**Output if drift detected:**
```sql
-- Changes detected in production that aren't in migrations:
ALTER TABLE events ADD COLUMN unexpected_field TEXT;
```

**Action**: Investigate why production differs from migrations, create corrective migration if needed.

---

## Schema Reference Quick Guide

### For CTO: Finding Table Information

**Q: What's the exact name of the events table?**
```bash
# Open docs/database/CURRENT-PRODUCTION-SCHEMA.sql
# Search for "CREATE TABLE"
# Find: CREATE TABLE public.events (...)
```

**Q: What columns does the events table have?**
```bash
# Open docs/database/CURRENT-PRODUCTION-SCHEMA.sql
# Search for "CREATE TABLE public.events"
# Read column definitions
```

**Q: What are the foreign key relationships?**
```bash
# Open docs/database/CURRENT-PRODUCTION-SCHEMA.sql
# Search for "FOREIGN KEY" or "REFERENCES"
```

### For CEO: Verifying Production Schema

**Run these queries in Supabase SQL Editor:**

**List all tables:**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY table_name;
```

**Check table structure:**
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'events'
ORDER BY ordinal_position;
```

---

## Troubleshooting

### Problem: "supabase: command not found"

**Solution**: Install Supabase CLI
```bash
brew install supabase/tap/supabase
```

### Problem: "Project not linked"

**Solution**: Link project
```bash
cd /Users/randaleastman/dev/georgetown
supabase link --project-ref <your-project-id>
```

### Problem: Schema snapshot shows unexpected tables

**Cause**: Production has tables not created by migrations (manual changes)

**Solution**:
1. Review CURRENT-PRODUCTION-SCHEMA.sql to identify unexpected changes
2. Create migration to document the change
3. Or remove manual changes if they were mistakes

### Problem: Migration references wrong table name

**Cause**: CTO didn't check CURRENT-PRODUCTION-SCHEMA.sql before writing migration

**Solution**:
1. CEO: Don't deploy the migration
2. CTO: Review CURRENT-PRODUCTION-SCHEMA.sql for correct table name
3. CTO: Fix migration file
4. CEO: Deploy corrected migration

---

## Benefits of This System

✅ **Prevents errors**: CTO references single file (CURRENT-PRODUCTION-SCHEMA.sql) for accurate table names
✅ **Low maintenance**: 5 minutes per migration (automated script)
✅ **Always accurate**: Generated from production, can't be stale
✅ **Drift detection**: `supabase db diff` catches discrepancies automatically
✅ **Professional**: Industry-standard approach used by modern teams
✅ **Version controlled**: Schema snapshots tracked in git history

---

## Related Documentation

- [Database README](../database/README.md) - Complete database documentation
- [Database Migration Workflow](./database-migration-workflow.md) - Existing migration process
- [Migration Template](../database/MIGRATION-TEMPLATE.sql) - Standardized migration format
- Schema Snapshot Script: `/scripts/update-schema-snapshot.sh`
- Current Schema: `/docs/database/CURRENT-PRODUCTION-SCHEMA.sql`

---

**Maintained by**: CTO (Claude Code)
**Updated**: 2025-10-18
**Next Review**: After adopting workflow for 3 migrations
