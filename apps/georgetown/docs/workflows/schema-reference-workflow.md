# Schema Reference Workflow (Simplified)

**Purpose**: CTO has accurate schema reference to prevent table name errors
**Owner**: CTO maintains, CEO provides one-time export
**Time**: 0 minutes ongoing (CEO), 2 minutes per schema-changing migration (CTO)

---

## What We Built

**File**: [docs/database/CURRENT-PRODUCTION-SCHEMA.sql](../database/CURRENT-PRODUCTION-SCHEMA.sql)

**Purpose**:
- Single file showing all production table structures
- CTO references before writing migrations
- Prevents errors like `club_events` vs `events` confusion

---

## CEO Involvement: ZERO (After Initial Export)

✅ **Already done**: You ran the schema export query (2025-10-18)
✅ **Ongoing**: Nothing - you're done with schema documentation

---

## CTO Workflow

### Before Writing Migration
1. Open `docs/database/CURRENT-PRODUCTION-SCHEMA.sql`
2. Find table name and verify structure
3. Write migration using correct names

### After Schema-Changing Migration
1. CEO executes migration (existing workflow - no change)
2. CTO updates `CURRENT-PRODUCTION-SCHEMA.sql` to reflect changes
3. Commit both migration file and schema file together

**Example**:
```bash
# After CEO executes migration 050
git add docs/database/050-add-speaker-bio.sql
git add docs/database/CURRENT-PRODUCTION-SCHEMA.sql
git commit -m "feat(db): migration 050 - add speaker bio field"
```

---

## When CTO Needs Fresh Schema

**Rare scenario**: CTO suspects schema file is outdated

**Solution**: CTO asks CEO to run query (30 seconds):
```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

CEO pastes result → CTO updates schema file → Done

**Frequency**: Maybe once per quarter, if ever

---

## Comparison: Old vs New Approach

### ❌ Before (What Caused the Problem)
- CTO had no schema reference
- CTO reconstructed schema from 48+ migration files
- CTO made error: used `club_events` instead of `events`
- CEO corrected: "We don't have a `club_events` table"

### ✅ After (Current System)
- CTO has `CURRENT-PRODUCTION-SCHEMA.sql`
- CTO looks up table name before writing migration
- CTO uses correct name: `events`
- No CEO involvement

---

## What We Discarded

**Option 1**: Supabase CLI automation ❌
- Pro: Automated schema snapshots
- Con: CEO runs script after every migration (5 min overhead)
- **Rejected**: Too much CEO busywork

**Option 2**: Ad-hoc queries ❌
- Pro: Simple, no automation
- Con: CTO asks CEO for schema info frequently
- **Rejected**: Interrupts CEO workflow

**Option 3**: One-time export, CTO maintains ✅ **CHOSEN**
- Pro: Zero ongoing CEO time
- Pro: CTO owns technical documentation
- Pro: Simple, low overhead
- Con: CTO must update schema file after migrations (2 min)

---

## Files in This System

| File | Owner | Purpose | Frequency |
|------|-------|---------|-----------|
| `CURRENT-PRODUCTION-SCHEMA.sql` | CTO | Schema reference | Updated after schema migrations |
| `NNN-description.sql` | CTO writes, CEO executes | Actual migrations | As needed |
| `README.md` | CTO | High-level docs | Updated rarely |

---

## Success Criteria

✅ **CTO never uses wrong table names** (has reference file)
✅ **CEO never maintains schema docs** (zero ongoing time)
✅ **Schema file stays current** (CTO updates with migrations)
✅ **Low overhead** (2 min per schema migration)

---

## Example: How It Works

**Scenario**: CTO needs to add `bio` field to speakers table

**Step 1**: CTO checks schema
```bash
# Open docs/database/CURRENT-PRODUCTION-SCHEMA.sql
# Search for "speakers"
# Verify table name and current columns
```

**Step 2**: CTO writes migration
```sql
-- Migration 050: Add speaker bio
ALTER TABLE speakers ADD COLUMN bio TEXT;  -- ✅ Correct table name
```

**Step 3**: CEO executes migration
```bash
# Open Supabase SQL Editor
# Paste migration SQL
# Execute
```

**Step 4**: CTO updates schema file
```sql
-- In CURRENT-PRODUCTION-SCHEMA.sql, add:
bio TEXT  -- to speakers table column list
```

**Step 5**: Commit together
```bash
git add docs/database/050-add-speaker-bio.sql
git add docs/database/CURRENT-PRODUCTION-SCHEMA.sql
git commit -m "feat(db): add speaker bio field"
```

---

## Related Files

- **Schema Reference**: [docs/database/CURRENT-PRODUCTION-SCHEMA.sql](../database/CURRENT-PRODUCTION-SCHEMA.sql)
- **Database README**: [docs/database/README.md](../database/README.md)
- **Migration Template**: [docs/database/MIGRATION-TEMPLATE.sql](../database/MIGRATION-TEMPLATE.sql)

---

**Last Updated**: 2025-10-18
**Maintained By**: CTO
**CEO Time Required**: 0 minutes ongoing (one-time export complete)
