# Scripts Directory

This directory contains reusable SQL queries and operational scripts for the Georgetown Rotary application.

## Database Backup & Restore

### Automated Backups (Recommended)

#### `backup-with-rotation.sh` ⭐

**Automated backup with intelligent rotation** following 2025 best practices.

**Retention Policy:**
- **Daily backups**: Keep 7 days (created every day)
- **Weekly backups**: Keep 4 weeks (created on Sundays)
- **Monthly backups**: Keep 6 months (created on 1st of month)

**Usage:**
```bash
cd apps/georgetown
./scripts/backup-with-rotation.sh
```

**Output:**
- Creates backups in `backups/daily/`, `backups/weekly/`, or `backups/monthly/`
- Automatically removes old backups based on retention policy
- Shows backup inventory and total storage used

#### `setup-automated-backups.sh`

**One-time setup for daily automated backups** via cron.

**Usage:**
```bash
cd apps/georgetown
./scripts/setup-automated-backups.sh
```

**What it does:**
- Installs cron job to run backups daily at 2:00 AM
- Logs output to `backups/backup.log`
- Prompts for confirmation before installing

**To verify:**
```bash
crontab -l | grep backup-with-rotation
```

**To view logs:**
```bash
tail -f apps/georgetown/backups/backup.log
```

---

### Manual Backups

#### `backup-database.sh`

Simple one-time backup script using `pg_dump`.

**Usage:**
```bash
cd apps/georgetown
./scripts/backup-database.sh
```

**Output:**
- Creates dated backup: `backups/georgetown_backup_YYYY-MM-DD.sql`
- Displays backup size and line count
- Exits with error if backup fails

**Requirements:**
- `pg_dump` installed (PostgreSQL client tools)
- `.env.local` file with `DATABASE_URL`

#### `restore-database.sh`

Restore database from a backup file.

**Usage:**
```bash
cd apps/georgetown
./scripts/restore-database.sh backups/daily/georgetown_2025-12-16.sql
```

**Warning:** This will overwrite the current database. Confirms before proceeding.

## Scripts Index

| Script | Type | Purpose | Added | Last Updated |
|--------|------|---------|-------|--------------|
| [backup-with-rotation.sh](backup-with-rotation.sh) ⭐ | Shell | Automated backup with 7/4/6 retention policy | 2025-12-16 | 2025-12-16 |
| [setup-automated-backups.sh](setup-automated-backups.sh) | Shell | Install cron job for daily automated backups | 2025-12-16 | 2025-12-16 |
| [backup-database.sh](backup-database.sh) | Shell | Simple one-time database backup | 2025-12-16 | 2025-12-16 |
| [restore-database.sh](restore-database.sh) | Shell | Restore database from backup file | 2025-12-16 | 2025-12-16 |
| [query-officers-and-chairs.sql](query-officers-and-chairs.sql) | SQL | Export all officer and committee chair roles | 2024-10-09 | 2024-10-09 |
| [update-schema-snapshot.sh](update-schema-snapshot.sh) | Shell | Update database schema snapshot | 2024-10-18 | 2024-10-18 |
| [sprint-status.sh](sprint-status.sh) | Shell | Generate sprint status report | 2024-09-29 | 2024-09-29 |
| [update-todo.sh](update-todo.sh) | Shell | Update TODO tracking | 2024-09-29 | 2024-09-29 |

## Script Types

### Database Operations
Backup, restore, and schema management scripts.

### SQL Queries
Reusable database queries for common reporting and data export tasks.

**Usage**:
1. Copy the SQL query content
2. Run in Supabase SQL Editor or via psql
3. Export results as needed

### Shell Scripts
Operational automation scripts for development workflows.

**Usage**:
1. Make executable: `chmod +x script-name.sh`
2. Run: `./script-name.sh`
3. Check output for results

## Environment Variables

Scripts read from `apps/georgetown/.env.local`:

```bash
DATABASE_URL="postgresql://postgres.PROJECT:PASSWORD@aws-1-REGION.pooler.supabase.com:6543/postgres?pgbouncer=true"
```

## Best Practices

1. **Set up automated backups:** Run `./scripts/setup-automated-backups.sh` once
2. **Before major changes:** Run manual backup with `./scripts/backup-database.sh`
3. **Test restores:** Periodically test restore process on local Supabase
4. **Monitor backup logs:** Check `backups/backup.log` regularly
5. **Secure backups:** Never commit backup files (they're gitignored)
6. **Production safety:** Test scripts on staging/local before running on production

## Backup Retention Policy (2025 Best Practices)

Based on industry standards for small organizations:

- **Daily backups**: 7 days retention (balances recovery needs with storage)
- **Weekly backups**: 4 weeks retention (captures weekly patterns)
- **Monthly backups**: 6 months retention (long-term recovery, compliance)

**Storage estimate**: ~3-5 MB per day for Georgetown database (current size: 430KB)
- Daily: ~3 MB (7 backups)
- Weekly: ~2 MB (4 backups)
- Monthly: ~3 MB (6 backups)
- **Total: ~8 MB** for full retention

**Sources:**
- [Backup Retention Policy Best Practices (TechTarget)](https://www.techtarget.com/searchdatabackup/answer/What-are-some-data-retention-policy-best-practices)
- [Data Retention Policies & Backups (Dataprise)](https://www.dataprise.com/resources/blog/data-retention-policies-and-backups/)
- [Backup Rotation Schemes (HandyBackup)](https://www.handybackup.net/backup-rotation-schedule.shtml)

## Output Locations

- **Automated backups**:
  - `backups/daily/` - Last 7 days
  - `backups/weekly/` - Last 4 weeks
  - `backups/monthly/` - Last 6 months
  - `backups/backup.log` - Automated backup logs
- **Manual backups**: `backups/` directory (gitignored)
- **Query results**: `/exports/` directory (gitignored)
- **Schema snapshots**: `docs/database/CURRENT-PRODUCTION-SCHEMA.sql`

## Adding New Scripts

When adding a new script:
1. Create the script file in this directory
2. Add comprehensive header comments explaining purpose and usage
3. Update the Scripts Index table above
4. Include example usage in script comments
5. Make executable if shell script: `chmod +x script-name.sh`
6. Commit with descriptive message: `chore(scripts): Add script-name`
