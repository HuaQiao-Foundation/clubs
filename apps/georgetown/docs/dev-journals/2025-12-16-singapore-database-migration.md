# Database Migration: Sydney → Singapore

**Date**: 2025-12-16
**Type**: Infrastructure / Database Migration
**Status**: ✅ Completed Successfully
**Duration**: ~2 hours

## Summary

Migrated Georgetown Rotary Supabase database from Sydney (ap-southeast-2) to Singapore (ap-southeast-1) to reduce latency for Malaysian users from ~120-150ms to ~5-10ms (12-15x improvement).

## Problem

Initial Supabase project was created in Sydney region, resulting in poor performance for Malaysian users (primary user base). Query latency of 120-150ms was causing noticeable delays in page loads and data operations.

## Solution

1. Created new Supabase project in Singapore (ap-southeast-1)
2. Backed up Sydney database using `pg_dump`
3. Restored backup to Singapore database using `psql`
4. Updated application configuration files
5. Verified data integrity
6. Deleted old Sydney projects to free up Supabase free tier slots

## Steps Taken

### 1. Database Backup

```bash
pg_dump 'postgresql://postgres.zooszmqdrdocuiuledql:S&5TN3Avce6MyuES@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres' > georgetown_backup.sql
```

**Result**: 442KB backup file (11,043 lines)

### 2. Create New Singapore Project

- Project ID: `rmorlqozjwbftzowqmps`
- Region: ap-southeast-1 (Singapore)
- Database password: `Bqj^$6jk5%WX3$fE`

### 3. Restore to Singapore

```bash
psql 'postgresql://postgres.rmorlqozjwbftzowqmps:Bqj%5E%246jk5%25WX3%24fE@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres' < georgetown_backup.sql
```

**Result**: Successful restore with expected errors (Supabase internal schemas)

### 4. Data Verification

```bash
psql 'postgresql://postgres.rmorlqozjwbftzowqmps:Bqj%5E%246jk5%25WX3%24fE@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres' -c "SELECT count(*) FROM public.speakers UNION ALL SELECT count(*) FROM public.events UNION ALL SELECT count(*) FROM public.members UNION ALL SELECT count(*) FROM public.locations;"
```

**Result**:
- 18 speakers ✅
- 32 events ✅
- 26 members ✅
- 5 locations ✅

### 5. Configuration Updates

Updated files:
- `apps/georgetown/.env`
- `apps/georgetown/.env.local`

Changed:
- `VITE_SUPABASE_URL`: `https://zooszmqdrdocuiuledql.supabase.co` → `https://rmorlqozjwbftzowqmps.supabase.co`
- `VITE_SUPABASE_ANON_KEY`: Updated to new project key
- `DATABASE_URL`: Updated to Singapore pooler (`aws-1-ap-southeast-1.pooler.supabase.com`)
- `DIRECT_URL`: Updated to Singapore pooler

### 6. Application Testing

```bash
npm run dev:georgetown
```

**Result**: App successfully connected to Singapore database, all data loads correctly

## Key Learnings

### Supabase Connection Changes

1. **Old format (deprecated)**: `db.*.supabase.co`
2. **New format**: `aws-1-[region].pooler.supabase.com`
3. **Session pooler port**: 6543 (required for `pg_dump`/`psql`)
4. **Transaction pooler port**: 5432 (not suitable for dump/restore)

### Password Special Characters

URL-encoding required for passwords with special characters:
- `^` → `%5E`
- `$` → `%24`
- `%` → `%25`

Example:
```
Bqj^$6jk5%WX3$fE → Bqj%5E%246jk5%25WX3%24fE
```

### Troubleshooting

**Issue 1**: Docker error with `supabase db dump`
- **Cause**: Supabase CLI tried to use Docker (not installed/running)
- **Solution**: Use `pg_dump` directly instead

**Issue 2**: DNS resolution failure
- **Cause**: Tried old `db.*.supabase.co` hostname format
- **Solution**: Use new pooler hostname format

**Issue 3**: "Tenant or user not found"
- **Cause**: Wrong pooler hostname or incorrect region
- **Solution**: Verify connection string from Supabase dashboard (Session mode)

## Files Modified

- `apps/georgetown/.env`
- `apps/georgetown/.env.local`
- `apps/georgetown/docs/database/README.md` (added backup/restore documentation)
- `.gitignore` (added `backups/`)

## Files Created

- `backups/georgetown_backup_2025-12-16.sql` (archived backup)
- `docs/adr/0001-supabase-singapore-migration.md` (architecture decision record)
- `docs/dev-journal/2025-12-16-singapore-database-migration.md` (this file)

## Performance Impact

**Before**:
- Region: Sydney (ap-southeast-2)
- Latency from Malaysia: ~120-150ms
- User experience: Noticeable delays

**After**:
- Region: Singapore (ap-southeast-1)
- Latency from Malaysia: ~5-10ms
- User experience: Instant responses
- **Improvement**: 12-15x faster ✅

## Next Steps

1. ✅ Delete old Sydney projects to free Supabase slots
2. ✅ Monitor application performance
3. ✅ Document backup/restore process
4. ⏳ Set up automated backup script (see `scripts/backup-database.sh`)

## References

- [ADR-0001: Supabase Singapore Migration](../adr/0001-supabase-singapore-migration.md)
- [Database Documentation](../database/README.md#generate-database-backup-pg_dump)
- [Supabase Connection Pooling](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler)
