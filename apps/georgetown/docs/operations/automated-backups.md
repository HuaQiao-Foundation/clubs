# Automated Database Backups

**Status**: Active
**Last Updated**: 2025-12-16
**Owner**: Georgetown Development Team

---

## Overview

Georgetown uses an automated backup system that creates daily backups with intelligent rotation following 2025 industry best practices. The system balances data protection, storage efficiency, and compliance requirements.

---

## Backup Strategy

### Retention Policy

Based on [2025 best practices for small organizations](https://www.techtarget.com/searchdatabackup/answer/What-are-some-data-retention-policy-best-practices):

| Type | Frequency | Retention | Created On | Storage |
|------|-----------|-----------|------------|---------|
| **Daily** | Every day | 7 days | Every day | ~3 MB |
| **Weekly** | Once per week | 4 weeks | Sundays | ~2 MB |
| **Monthly** | Once per month | 6 months | 1st of month | ~3 MB |
| **Total** | - | - | - | **~8 MB** |

### Why This Policy?

**Daily (7 days)**:
- Protects against recent errors or data corruption
- Balances recovery needs with storage costs
- Sufficient for most "oops, I need yesterday's data" scenarios

**Weekly (4 weeks)**:
- Captures weekly patterns in Rotary operations
- Provides recovery points for longer-term issues
- Aligns with typical sprint/meeting cycles

**Monthly (6 months)**:
- Long-term recovery capability
- Meets basic compliance requirements
- Historical reference for annual reporting

**Storage efficiency**:
- Current database size: 430KB
- Expected growth: Moderate (Rotary membership data)
- Total storage impact: Minimal (~8MB for all backups)

---

## Setup Instructions

### One-Time Setup

Run the automated backup setup script:

```bash
cd apps/georgetown
./scripts/setup-automated-backups.sh
```

**What this does**:
1. Verifies backup script exists and is executable
2. Shows proposed schedule (daily at 2:00 AM)
3. Checks for existing cron jobs
4. Prompts for confirmation
5. Installs cron job with logging

**Schedule**: Daily at 2:00 AM (off-peak hours)

**Log location**: `apps/georgetown/backups/backup.log`

---

## Verification

### Check if automated backups are installed

```bash
crontab -l | grep backup-with-rotation
```

**Expected output**:
```
0 2 * * * /path/to/backup-with-rotation.sh >> /path/to/backups/backup.log 2>&1
```

### View backup logs

```bash
cd apps/georgetown
tail -f backups/backup.log
```

### Check backup inventory

```bash
cd apps/georgetown
ls -lh backups/daily/
ls -lh backups/weekly/
ls -lh backups/monthly/
```

### Test backup manually

```bash
cd apps/georgetown
./scripts/backup-with-rotation.sh
```

---

## How It Works

### Backup Process

1. **Environment loading**: Reads `DATABASE_URL` from `.env.local`
2. **Connection setup**: Parses URL into PostgreSQL environment variables
3. **Type determination**: Checks date to determine backup type (daily/weekly/monthly)
4. **Backup creation**: Runs `pg_dump` to create SQL backup file
5. **Rotation**: Removes old backups based on retention policy
6. **Reporting**: Shows backup inventory and storage used

### File Organization

```
backups/
├── daily/
│   ├── georgetown_2025-12-16.sql
│   ├── georgetown_2025-12-15.sql
│   └── ... (up to 7 files)
├── weekly/
│   ├── georgetown_2025-12-15.sql  # Sunday
│   ├── georgetown_2025-12-08.sql  # Sunday
│   └── ... (up to 4 files)
├── monthly/
│   ├── georgetown_2025-12-01.sql  # 1st of month
│   ├── georgetown_2025-11-01.sql
│   └── ... (up to 6 files)
└── backup.log  # Automated backup logs
```

### Rotation Logic

**Daily backups**:
- Created every day
- Files older than 7 days are deleted
- Example: On Dec 17, backups from Dec 9 and earlier are removed

**Weekly backups**:
- Created only on Sundays
- Files older than 28 days are deleted
- Provides 4-week coverage

**Monthly backups**:
- Created only on 1st of each month
- Files older than 180 days (6 months) are deleted
- Long-term recovery capability

---

## Maintenance

### Monitor Backup Health

**Check recent backup status**:
```bash
tail -20 backups/backup.log
```

**Look for**:
- ✅ "Backup completed successfully"
- ❌ "Backup failed" errors
- File sizes (should be ~430KB currently)

**Set calendar reminder**: Check logs monthly

### Disk Space Monitoring

**Check total backup storage**:
```bash
du -sh backups/
```

**Expected**: ~8 MB for full retention (increases as database grows)

**Alert threshold**: If exceeds 50 MB, review retention policy or database size

### Test Restore Process

**Recommended**: Test restore quarterly

```bash
# 1. Create test backup
./scripts/backup-database.sh

# 2. Set up local Supabase instance (if available)
# 3. Restore to local instance
./scripts/restore-database.sh backups/georgetown_backup_2025-12-16.sql

# 4. Verify data integrity
# 5. Document results
```

---

## Troubleshooting

### Backup not running

**Check cron is installed**:
```bash
crontab -l
```

**Common issues**:
1. **Computer off at 2 AM**: Cron only runs when machine is on
   - Solution: Consider cloud-based cron (GitHub Actions, etc.)
2. **Permission errors**: Check script permissions
   - Solution: `chmod +x scripts/backup-with-rotation.sh`
3. **Environment variables not loaded**: Check `.env.local` exists
   - Solution: Verify file exists in `apps/georgetown/.env.local`

### Backup failed errors

**Check backup log**:
```bash
grep "Error\|failed" backups/backup.log
```

**Common causes**:
1. **Database connection failed**: Check Supabase credentials
2. **Disk full**: Check disk space with `df -h`
3. **Network issues**: Verify internet connection

**Resolution**: See [troubleshooting protocol](../protocols/troubleshooting-protocol.md)

### Storage growing too large

**Check largest backups**:
```bash
find backups -name "*.sql" -type f -exec ls -lh {} \; | sort -k5 -hr | head -10
```

**If backups are unexpectedly large**:
1. Check for data bloat in database
2. Consider compression (gzip)
3. Review retention policy

---

## Manual Operations

### Create backup on-demand

```bash
cd apps/georgetown
./scripts/backup-database.sh  # Simple backup
# OR
./scripts/backup-with-rotation.sh  # With rotation
```

### Restore from backup

```bash
cd apps/georgetown
./scripts/restore-database.sh backups/daily/georgetown_2025-12-16.sql
```

**Warning**: This overwrites the database. Always:
1. Create a backup before restoring
2. Verify the backup file is correct
3. Test on local/staging first if possible

### Disable automated backups

```bash
crontab -e
# Delete the line containing backup-with-rotation.sh
# Save and exit
```

### Change backup schedule

```bash
crontab -e
# Modify the time (currently: 0 2 * * * = 2:00 AM daily)
# Examples:
#   0 3 * * * = 3:00 AM daily
#   0 2 * * 0 = 2:00 AM Sundays only
#   0 */6 * * * = Every 6 hours
```

---

## Compliance & Legal

### Data Retention Compliance

**Georgetown Rotary** (Non-profit organization):
- No specific regulatory requirements for member data
- Retention policy follows best practices, not legal mandates
- Consider data privacy (member contact information)

**Best practices**:
- Backups stored locally (not cloud) = lower liability
- 6-month maximum retention = limited data exposure
- Regular rotation = automatic cleanup of old data

### Security Considerations

**Backup files contain**:
- Member names, emails, phone numbers
- Event attendance records
- Speaker contact information
- Committee assignments

**Protection measures**:
1. ✅ Backups gitignored (never committed to repository)
2. ✅ Stored locally on development machine
3. ✅ Automatic rotation (no indefinite storage)
4. ⚠️ Consider encryption for sensitive environments
5. ⚠️ Consider off-site storage for disaster recovery

**Recommendations**:
- Do not email backup files
- Do not store in public cloud without encryption
- Limit access to authorized developers only

---

## Migration Notes

### Moving to cloud-based backups

If/when moving to cloud automation (GitHub Actions, AWS, etc.):

**Advantages**:
- Runs even if local machine is off
- Centralized monitoring
- Off-site storage (disaster recovery)

**Considerations**:
- Must securely store `DATABASE_URL` (GitHub Secrets, AWS Secrets Manager)
- Network transfer time for backups
- Storage costs (though minimal at ~430KB/day)
- Compliance with data residency requirements

**Implementation**: See `docs/operations/cloudflare-deployment.md` for CI/CD patterns

---

## Sources

This backup strategy is based on 2025 industry best practices:

- [Backup Retention Policy Best Practices (TechTarget)](https://www.techtarget.com/searchdatabackup/answer/What-are-some-data-retention-policy-best-practices)
- [Data Retention Policies & Backups (Dataprise)](https://www.dataprise.com/resources/blog/data-retention-policies-and-backups/)
- [7 Data Retention Policy Best Practices (CrashPlan)](https://www.crashplan.com/blog/7-data-retention-policy-best-practices-for-your-business/)
- [Backup Rotation Schemes (HandyBackup)](https://www.handybackup.net/backup-rotation-schedule.shtml)
- [Scheduling Backups with Cron (Medium)](https://medium.com/@stark101/scheduling-backups-with-rsync-and-cron-in-bash-a-simple-guide-aa0e785ae79a)

---

## Related Documentation

- [scripts/README.md](../../scripts/README.md) - All backup scripts documentation
- [Troubleshooting Protocol](../protocols/troubleshooting-protocol.md) - If backups fail
- [Singapore Database Migration](../dev-journal/2025-12-16-singapore-database-migration.md) - Connection setup
- [Backup Script Troubleshooting](../dev-journal/2025-12-16-backup-script-troubleshooting.md) - How scripts were debugged

---

**Last Updated**: 2025-12-16
**Reviewed By**: Georgetown Development Team
**Next Review**: 2026-01-16 (monthly review recommended)
