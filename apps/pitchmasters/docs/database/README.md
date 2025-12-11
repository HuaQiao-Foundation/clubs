# Pitchmasters Database Documentation

**Purpose**: Centralized database documentation and SQL management
**Database**: Supabase PostgreSQL with Row Level Security
**Last Updated**: 2025-10-08

---

## Quick Navigation

### Core Documentation

**[database-protocol.md](database-protocol.md)** - Architecture Standards
- Multi-club tenant isolation principles
- Row Level Security design
- Performance optimization strategies
- Migration strategy for phases 1-3

**[schema-design.md](schema-design.md)** - Complete Schema Reference
- All table definitions with fields
- RLS policies and security model
- Indexes and performance targets
- Migration history (001-007)

### SQL Scripts

**[sql-scripts/](sql-scripts/)** - Executable Migration Files
- Sequential numbered migrations (001-007)
- Reusable analytical queries
- Migration headers with metadata
- Ready for Supabase SQL Editor

### Setup Guides

**[guides/setup-guide.md](guides/setup-guide.md)** - Step-by-Step Setup
- Supabase project creation
- Running migrations in order
- Environment variable configuration
- Verification and troubleshooting

---

## SQL Migration System

### Naming Convention

**Pattern**: `NNN-description.sql` (three-digit sequential)

```
001-initial-schema.sql          → Foundation tables
002-member-profiles-extension.sql → Privacy-controlled profiles
003-add-csv-fields.sql          → Additional member fields
004-fix-rls-policies.sql        → RLS recursion fixes
005-add-public-read-policy.sql  → Public profile access
006-fix-users-rls-recursion.sql → Security definer function
007-rebuild-schema.sql          → Complete rebuild
queries.sql                     → Reusable queries (not a migration)
```

### Migration Headers

Every migration includes standardized header:

```sql
-- ============================================================
-- Migration: NNN-description.sql
-- Purpose: Brief description of what this migration does
-- Created: YYYY-MM-DD
-- Deployed to Production: YYYY-MM-DD
-- Prerequisites: Previous migration number or "None"
-- ============================================================
```

### Running Migrations

**Sequential Execution** (recommended for fresh setup):
1. Open Supabase Dashboard → SQL Editor
2. Run migrations in order: 001 → 002 → 003 → 004 → 005 → 006
3. Verify each migration before proceeding to next
4. Check for error messages in SQL Editor output

**Full Rebuild** (for complete reset):
1. Use `007-rebuild-schema.sql`
2. WARNING: Drops all existing tables
3. Only use for fresh starts or development environments

**Detailed Instructions**: See [guides/setup-guide.md](guides/setup-guide.md)

---

## Current Schema Status

### Production Tables (7 tables)

**Core Tables**:
- `clubs` - Tenant root table
- `users` - Club members with roles
- `meetings` - Meeting scheduling
- `speeches` - Speech tracking
- `meeting_roles` - Functional role assignments

**Extended Tables**:
- `member_profiles` - Extended member data with privacy controls
- `privacy_settings` - Granular visibility controls

### Security Functions

- `update_updated_at_column()` - Automatic timestamp updates
- `get_current_user_club_id()` - RLS recursion prevention

### Row Level Security

**Status**: Fully implemented and tested
- All tables have RLS enabled
- Policies enforce club-level isolation
- Privacy controls respect user settings
- No recursion issues (fixed in migrations 004, 006)

---

## Reusable Queries

### queries.sql Contents

**[sql-scripts/queries.sql](sql-scripts/queries.sql)** contains ready-to-use queries for:

**Member Queries**:
- Get all club members
- Search by expertise/industry
- Founders list
- Birthday reports

**Meeting Queries**:
- Upcoming meetings
- Meeting roles and assignments
- Speech counts per meeting
- Unfilled roles (for reminders)

**Speech Queries**:
- Member speech history
- Speech count leaderboard
- Pathways progress tracking
- Recent speeches across club

**Analytics Queries**:
- Club activity summary
- Member engagement metrics
- Monthly attendance trends
- Role distribution

**Administrative Queries**:
- Officers list
- Members without profiles
- Privacy settings audit
- Data cleanup utilities

**Usage**: Copy query from `queries.sql`, replace placeholders `{club_id}`, `{user_id}`, `{meeting_id}` with actual UUIDs, run in SQL Editor.

---

## Database Architecture

### Multi-Tenant Design

**Tenant Boundary**: `club_id` foreign key
**Isolation Method**: Row Level Security (RLS)
**Scalability**: UUID primary keys, indexed foreign keys

**Data Flow**:
```
clubs (root)
  ↓
users (club members)
  ↓
meetings (club meetings)
  ↓
speeches, meeting_roles (meeting data)
  ↓
member_profiles, privacy_settings (extended data)
```

### Access Control Tiers

**Public Tier**: Visible to anyone if privacy settings allow
- Photo, venture info, expertise, bio

**Member-Only Tier**: Authenticated club members only
- Contact info, networking interests, progress stats

**Private Tier**: Individual + officers only
- Personal goals, officer notes, sensitive data

**See**: [schema-design.md](schema-design.md) for complete RLS policy details

---

## Development Workflow

### Making Schema Changes

**1. Draft SQL Locally**:
```sql
-- Example: Add new field to member_profiles
ALTER TABLE member_profiles
ADD COLUMN linkedin_verified BOOLEAN DEFAULT false;
```

**2. Create Migration File**:
- Name: `008-add-linkedin-verification.sql` (next sequential number)
- Add standard header with purpose, date, prerequisites
- Include rollback instructions in comments if applicable

**3. Test in Development**:
- Run in Supabase SQL Editor (development project)
- Verify table structure in Database → Tables
- Test with sample queries
- Check RLS policies still work

**4. Document in schema-design.md**:
- Update table schema section
- Add to migration history
- Note any RLS policy changes

**5. Deploy to Production**:
- Run migration in production Supabase project
- Update migration header with production deployment date
- Commit migration file to git

**6. Update README.md**:
- Add to migration list above
- Update "Current Schema Status" if needed

---

## Conventions & Best Practices

### SQL Standards

**Idempotent Operations**: Use when possible
```sql
-- Good: Can run multiple times safely
ALTER TABLE member_profiles
ADD COLUMN IF NOT EXISTS new_field VARCHAR(100);

-- Avoid: Fails on second run
ALTER TABLE member_profiles
ADD COLUMN new_field VARCHAR(100);
```

**Clear Comments**: Explain non-obvious logic
```sql
-- Check privacy settings WITHOUT joining member_profiles (avoids recursion)
WHERE user_id IN (SELECT user_id FROM privacy_settings WHERE ...)
```

**Consistent Naming**:
- Tables: `snake_case`, plural (users, member_profiles)
- Columns: `snake_case` (full_name, club_id)
- Indexes: `idx_tablename_columnname`
- Policies: `descriptive_action` (users_view_same_club)

### Migration Best Practices

✅ **Do**:
- Number migrations sequentially (001, 002, 003...)
- Include purpose and prerequisites in header
- Note production deployment date
- Test in development before production
- Keep migrations focused (one logical change)

❌ **Don't**:
- Skip migration numbers
- Modify existing migration files after deployment
- Include multiple unrelated changes in one migration
- Forget to update schema-design.md

---

## Troubleshooting

### Common Issues

**"Infinite recursion detected in policy"**
→ See migration 006 for security definer function solution

**"Permission denied for table"**
→ Check RLS policies are created for new tables

**"Migration fails with foreign key constraint"**
→ Ensure prerequisite tables exist, run migrations in order

**"Can't connect from application"**
→ Verify `.env.local` has correct Supabase credentials

**Detailed Solutions**: See [guides/setup-guide.md#troubleshooting](guides/setup-guide.md#troubleshooting)

---

## Related Documentation

### Project Documentation

- **[PDD.md](../PDD.md)** - Business requirements and success criteria
- **[TIS.md](../TIS.md)** - Technical architecture overview
- **[governance/tech-constraints.md](../governance/tech-constraints.md)** - Technology stability rules

### External Resources

- **Supabase Docs**: [supabase.com/docs/guides/database](https://supabase.com/docs/guides/database)
- **PostgreSQL RLS**: [PostgreSQL Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- **Supabase Auth**: [supabase.com/docs/guides/auth](https://supabase.com/docs/guides/auth)

---

## Quick Reference

### File Organization

```
docs/database/
├── README.md                    # This file - overview and conventions
├── database-protocol.md         # Architecture principles
├── schema-design.md             # Complete schema reference
├── sql-scripts/                 # Executable SQL files
│   ├── 001-initial-schema.sql
│   ├── 002-member-profiles-extension.sql
│   ├── 003-add-csv-fields.sql
│   ├── 004-fix-rls-policies.sql
│   ├── 005-add-public-read-policy.sql
│   ├── 006-fix-users-rls-recursion.sql
│   ├── 007-rebuild-schema.sql
│   └── queries.sql
└── guides/
    └── setup-guide.md           # Step-by-step Supabase setup
```

### Decision Tree

**"Where do I find..."**

1. **How to set up database from scratch?**
   → [guides/setup-guide.md](guides/setup-guide.md)

2. **Complete table definitions and fields?**
   → [schema-design.md](schema-design.md)

3. **Architecture principles and RLS design?**
   → [database-protocol.md](database-protocol.md)

4. **SQL to create specific table?**
   → [sql-scripts/001-initial-schema.sql](sql-scripts/001-initial-schema.sql) or [007-rebuild-schema.sql](sql-scripts/007-rebuild-schema.sql)

5. **Queries for reports and analytics?**
   → [sql-scripts/queries.sql](sql-scripts/queries.sql)

6. **Migration history and order?**
   → This README (above) or [schema-design.md#migration-history](schema-design.md#migration-history)

---

## Metrics

**Current Database Documentation**:
- Migration files: 7 (numbered) + 1 (queries)
- Documentation files: 5 (README, protocol, schema, setup guide, deprecated README)
- Total SQL lines: ~2000+ across migrations
- Reusable queries: 30+ in queries.sql

**Schema Complexity**:
- Tables: 7 core + extended
- RLS policies: 15+ across tables
- Indexes: 12+ performance indexes
- Functions: 2 helper functions

**Organization Health**:
- ✅ Sequential migration numbering
- ✅ Migration headers with metadata
- ✅ Comprehensive documentation
- ✅ Reusable queries separated
- ✅ Setup guide for new developers
- ✅ Clear naming conventions

---

**Maintained by**: Claude Code (CTO)
**Pattern Source**: Georgetown/Brandmine database documentation best practices
**Last Schema Update**: Migration 007 (2025-09-28)
**Next Review**: After Phase 2 planning
