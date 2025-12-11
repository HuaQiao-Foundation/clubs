# Georgetown Rotary Database Documentation

**Purpose**: Centralized database documentation and SQL migration management for Georgetown Rotary Club's speaker management system.

**Database**: Supabase (PostgreSQL)
**Last Updated**: 2025-10-15

---

## Directory Structure

```
docs/database/
├── README.md                              # This file - complete database documentation
├── 000-initial-schema.sql                 # Base database schema (foundation)
├── 001-locations-migration.sql            # Location tracking tables
├── 002-locations-extended-fields.sql      # Extended location metadata
├── 003-club-events-migration.sql          # Club events and calendar
├── 004-add-observance-event-type.sql      # Rotary observance event type
├── 005-add-deepavali-holiday.sql          # Deepavali observance event
├── ... (048 total migrations)             # All schema evolution history
└── schema-changes/                        # Schema evolution tracking
```

**Archived** (see `docs/archive/`):
- `database-protocol.md` - Merged into this README (2025-10-17)
- `database-migration.sql` - Legacy migration (superseded by numbered migrations)
- `supabase_migration.sql` - Legacy migration (superseded by numbered migrations)
- `EVENT_SYSTEM_STATUS.md` - Completed status report (event system now operational)
- `SUPABASE_LINKEDIN_MIGRATION.md` - Completed migration instructions (LinkedIn field added)
- `diagnose-events-constraints.sql` - One-time diagnostic query (issue resolved)

---

## SQL Migration System

### Naming Convention

**Sequential numbering**: `NNN-description.sql` where:
- `NNN` = Three-digit sequential number (001, 002, 003...)
- `description` = Kebab-case description of migration purpose

**Examples**:
- `001-locations-migration.sql` - Initial locations table
- `002-locations-extended-fields.sql` - Add metadata columns
- `003-club-events-migration.sql` - Club events schema

### File Header Standard

Every SQL migration file should include:

```sql
-- Migration: [Description]
-- Created: YYYY-MM-DD
-- Production Deploy: YYYY-MM-DD (or "Not deployed")
-- Prerequisites: [Required migrations or setup]
-- Purpose: [Business objective this migration serves]
```

### Idempotency

Use idempotent SQL patterns where possible:
- `CREATE TABLE IF NOT EXISTS`
- `CREATE OR REPLACE FUNCTION`
- `DROP POLICY IF EXISTS` before `CREATE POLICY`
- Check for existence before `ALTER TABLE ADD COLUMN`

---

## Workflow for Database Changes

### 1. Development

```bash
# Design SQL locally in editor
# Create new migration file: docs/database/NNN-description.sql
# Add proper header with metadata
```

### 2. Testing

```bash
# Open Supabase Dashboard → SQL Editor
# Paste SQL from migration file
# Execute and verify results
# Check for errors or constraint violations
```

### 3. Production Deployment

```bash
# Execute SQL in Supabase production environment
# Verify migration success
# Update migration file header with production deploy date
# Commit updated SQL file to git
```

### 4. Documentation

```bash
# Update this README.md if schema changes affect documentation
# Add diagnostic queries if needed
# Document any breaking changes or special procedures
# Commit documentation with migration
```

---

## Current Production Schema

**Last Verified**: 2025-10-18
**Source**: Supabase production database
**Schema File**: [CURRENT-PRODUCTION-SCHEMA.sql](./CURRENT-PRODUCTION-SCHEMA.sql) (auto-generated)
**Update Command**: `./scripts/update-schema-snapshot.sh [migration-number]`

### Schema Documentation System

Georgetown Rotary uses a **hybrid documentation approach**:

1. **Auto-Generated Snapshot** (`CURRENT-PRODUCTION-SCHEMA.sql`)
   - Complete CREATE TABLE statements, indexes, RLS policies
   - Generated via `supabase db dump --schema public`
   - Updated after each migration deployment
   - Machine-readable source of truth

2. **Migration History** (`000-*.sql` through `049-*.sql`)
   - Sequential evolution of database schema
   - Shows what changed and when
   - Required for new environment setup

3. **This README** (Human-readable overview)
   - Business context and table relationships
   - High-level architecture documentation

**Best Practice**: Reference `CURRENT-PRODUCTION-SCHEMA.sql` for accurate table structures when writing code.

---

### Table Quick Reference

**IMPORTANT**: Always verify table names in `CURRENT-PRODUCTION-SCHEMA.sql` before writing migrations.

| Table Name | Primary Key | Purpose | Key Relationships |
|------------|-------------|---------|-------------------|
| **speakers** | id (UUID) | Speaker pipeline (kanban board) | None |
| **events** | id (UUID) | Club calendar and meetings | → locations |
| **locations** | id (UUID) | Meeting venues | ← events |
| **members** | id (UUID) | Club membership roster | None |
| **rotary_years** | id (UUID) | Annual Rotary year records | None |
| **projects** | id (UUID) | Service projects | → partners (via project_partners) |
| **partners** | id (UUID) | Community partner organizations | ← projects |
| **photos** | id (UUID) | Photo gallery system | → rotary_years |
| **global_south_interest** | id (UUID) | Expression of interest forms from Global South clubs | None |

---

### Table Details (High-Level)

**speakers**
- Core speaker data (name, company, title, topic)
- Contact information (phone, email, website)
- Metadata (Rotary affiliation, kanban status)
- Timestamps (created_at, updated_at)

**locations**
- Meeting venues and event locations
- Extended metadata (capacity, parking, accessibility)
- Status tracking (active/inactive)

**events**
- Club calendar events
- Event types: meeting, social, service, observance
- Date/time tracking (date, start_time, end_time)
- Location relationships

**members**
- Club membership roster
- Contact and classification data
- LinkedIn profile integration
- Proposer tracking for new members

**rotary_years**
- Annual Rotary year records (July 1 - June 30)
- Leadership themes (RI President, District Governor, Club President)
- Official portraits and theme logos
- Year narratives, highlights, and challenges
- Auto-calculated statistics (meetings, speakers, projects, beneficiaries, project value)
- Photo galleries for year history

**photos** (formerly club_photos)
- Photo gallery system with comprehensive metadata
- Event categorization (meeting, service, social, observance, fellowship)
- Searchable tags (JSONB array)
- Auto-linking to Rotary years via photo_date
- Storage in Supabase "club-photos" bucket (public, 10MB max)

**global_south_interest**
- Expression of interest forms from Rotary clubs in the Global South
- Contact information (name, email, phone)
- Club details (club_name, club_location, country)
- Optional message field
- Public insert access (form submissions), officer/chair read access

### Row Level Security (RLS)

All tables use RLS policies:
- Public read access for authenticated users
- Restricted write access (service role only)
- No anonymous access

---

### Common Schema Queries

**List all tables in production:**
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Verify table structure:**
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'events'  -- Replace with your table name
ORDER BY ordinal_position;
```

**Check RLS policies:**
```sql
SELECT tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**View table relationships (foreign keys):**
```sql
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;
```

---

## Environment Variables

**Required for Supabase Access**:

```bash
VITE_SUPABASE_URL=https://[project].supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

**Local Development**:
```bash
# .env.local file in project root
# Loaded automatically by Vite
npm run dev
```

**Production**:
```bash
# Set in Cloudflare Pages environment variables
# Automatically injected during build
```

---

## Key Documentation Files

**README.md** (this file)
- Complete database documentation
- Implementation standards and protocol
- Schema design patterns
- Quality assurance requirements
- Full-stack verification checklist
- Migration history and conventions

**000-initial-schema.sql**
- Base database schema
- Core tables and relationships
- Essential RLS policies

**Migration Files (NNN-*.sql)**
- Executable SQL for schema changes
- Sequential evolution of database
- Production-ready with headers

---

## Database Implementation Protocol

### Full-Stack Implementation Requirements

**Never implement frontend features without corresponding database changes.** This is a fundamental violation of professional system architecture.

### Mandatory Implementation Sequence

**1. Database Schema First**
```sql
-- REQUIRED: Create/modify database schema BEFORE frontend
ALTER TABLE speakers ADD COLUMN job_title TEXT;
ALTER TABLE speakers ADD COLUMN description TEXT;
```

**2. Backend API Updates**
- Update database queries to handle new fields
- Modify insert/update operations
- Test database operations independently

**3. Frontend Implementation**
- Add TypeScript types (only after database confirmed)
- Implement UI components
- Connect to verified backend functionality

**4. Full-Stack Integration Testing**
- Test complete data flow: UI → API → Database → UI
- Verify all CRUD operations work end-to-end
- Confirm data persistence and retrieval

### Quality Verification Checklist

**Database Verification (MANDATORY)**
- [ ] Schema changes deployed to Supabase
- [ ] Database accepts new field values
- [ ] Existing data preserved during schema changes
- [ ] SQL queries updated for new fields
- [ ] Foreign key relationships maintained

**API Verification (MANDATORY)**
- [ ] Insert operations work with new fields
- [ ] Update operations handle all fields
- [ ] Select queries return new data
- [ ] Delete operations work correctly
- [ ] Error handling for invalid data

**Frontend Verification (MANDATORY)**
- [ ] UI displays database-stored values
- [ ] Forms submit successfully to database
- [ ] Validation works with actual constraints
- [ ] User actions result in database changes
- [ ] Real-time updates reflect database state

**Integration Verification (MANDATORY)**
- [ ] Complete user workflows function end-to-end
- [ ] Data survives browser refresh (database persistence)
- [ ] Multiple users see consistent data
- [ ] Mobile and desktop both work with real data
- [ ] Error messages reflect actual system state

---

## Best Practices

### Schema Changes

✅ **DO**:
- Create new migration file for each logical change
- Test locally before production deployment
- Document business purpose in file header
- Use sequential numbering for clear history
- Make migrations idempotent where possible
- Complete database changes BEFORE frontend implementation

❌ **DON'T**:
- Modify existing migration files after production deploy
- Skip sequential numbers
- Deploy without testing
- Forget to update production deploy date in header
- Mix multiple unrelated changes in one migration
- Implement frontend-only features without database backend

### SQL Style

- Use lowercase for SQL keywords (`select`, `create table`, not `SELECT`)
- Indent nested queries and clauses
- Add comments for complex logic
- Use meaningful constraint names
- Organize policies by operation (SELECT, INSERT, UPDATE, DELETE)

### Commit Messages

```bash
# Good commit message examples:
git commit -m "feat(db): add observance event type for Rotary celebrations"
git commit -m "fix(db): correct timezone handling in events table"
git commit -m "docs(db): document RLS policy structure"
```

---

## Migration History

| File | Purpose | Status | Deploy Date |
|------|---------|--------|-------------|
| `000-initial-schema.sql` | Base speakers table schema | ✅ Production | 2025-09-23 |
| `001-locations-migration.sql` | Location tracking | ✅ Production | 2025-09-24 |
| `002-locations-extended-fields.sql` | Location metadata | ✅ Production | 2025-09-25 |
| `003-club-events-migration.sql` | Events calendar | ✅ Production | 2025-09-26 |
| `004-add-observance-event-type.sql` | Observance events | ✅ Production | 2025-10-08 |
| `005-add-deepavali-holiday.sql` | Deepavali event | ✅ Production | 2025-10-08 |
| `025-add-member-portrait.sql` | Member portrait URLs | ✅ Production | 2025-01-14 |
| `026-enhance-partners-table.sql` | Enhanced partner fields | ✅ Production | 2025-01-14 |
| `031-create-club-photos-storage-bucket.sql` | Photo storage bucket | ⏳ Pending CEO | Not deployed |
| `032-create-photos-table.sql` | Photo gallery table | ⏳ Pending CEO | Not deployed |

---

## Common Operations

### View All Tables

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

### Check RLS Policies

```sql
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### View Table Structure

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'speakers'
ORDER BY ordinal_position;
```

---

## Questions or Issues?

- **Schema Design**: Review "Database Implementation Protocol" section above
- **Migration Errors**: Check Supabase logs in Dashboard
- **RLS Issues**: Verify policies with diagnostic queries
- **Performance**: Add indexes for frequently queried columns

---

**Maintained by**: CTO (Claude Code)
**Review Frequency**: Updated with each schema change
**Next Review**: As needed with new migrations
