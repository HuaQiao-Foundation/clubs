# Technical Briefing: Automated Database Backup Solution

**Document Type**: Technical Design Document (TDD)
**Project**: Georgetown Rotary (Reference Implementation)
**Intended Application**: Brandmine
**Date**: 2025-12-16
**Author**: Georgetown Development Team
**Status**: Production-Ready

---

## Executive Summary

This document describes a production-ready automated database backup solution implemented for Georgetown Rotary that can be replicated for Brandmine. The solution provides automated daily backups with intelligent rotation following 2025 industry best practices, requiring minimal maintenance and storage (~8MB for full retention).

**Key Benefits**:
- ✅ **Zero-maintenance**: Automated daily backups via cron
- ✅ **Industry-standard retention**: 7 daily / 4 weekly / 6 monthly
- ✅ **Minimal storage**: ~8MB total (scales with database size)
- ✅ **Production-tested**: Successfully deployed and operational
- ✅ **Security-conscious**: Local storage, automatic cleanup, no cloud dependencies

---

## Problem Statement

### Business Need

Small organizations (Rotary clubs, Brandmine) require reliable database backups but face:
1. **Manual backup burden**: Developers must remember to create backups
2. **Storage management**: Old backups accumulate, consuming disk space
3. **Recovery confidence**: Uncertainty about backup validity and availability
4. **Compliance requirements**: Need structured retention for potential audits

### Technical Constraints

- Limited budget for cloud backup services
- Small development teams (1-3 developers)
- Databases under 1GB in size
- PostgreSQL/Supabase infrastructure
- Local development workflow

---

## Solution Overview

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Cron Scheduler                        │
│              (Daily at 2:00 AM)                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│           backup-with-rotation.sh                        │
│                                                          │
│  1. Read DATABASE_URL from .env.local                   │
│  2. Parse into PG* environment variables                │
│  3. Determine backup type (daily/weekly/monthly)        │
│  4. Run pg_dump to create SQL backup                    │
│  5. Rotate old backups based on retention policy        │
│  6. Log results to backup.log                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Backup Storage (Local)                      │
│                                                          │
│  backups/                                               │
│  ├── daily/     (7 days retention)                      │
│  ├── weekly/    (4 weeks retention)                     │
│  ├── monthly/   (6 months retention)                    │
│  └── backup.log (Execution logs)                        │
└─────────────────────────────────────────────────────────┘
```

### Retention Policy

Based on [2025 industry best practices](https://www.techtarget.com/searchdatabackup/answer/What-are-some-data-retention-policy-best-practices):

| Backup Type | Frequency | Retention | Created On | Use Case |
|-------------|-----------|-----------|------------|----------|
| **Daily** | Every day | 7 days | Daily | Recent recovery ("I need yesterday's data") |
| **Weekly** | Once/week | 4 weeks | Sundays | Pattern capture, sprint cycles |
| **Monthly** | Once/month | 6 months | 1st of month | Long-term recovery, compliance |

**Rationale**:
- Balances data protection with storage costs
- Follows the 3-2-1 backup principle (multiple recovery points)
- Suitable for small organizations with no strict regulatory requirements
- Automatic cleanup prevents storage bloat

---

## Technical Implementation

### Core Components

#### 1. Main Backup Script (`backup-with-rotation.sh`)

**Purpose**: Create database backup and manage retention

**Key Features**:
- Parses `DATABASE_URL` into PostgreSQL environment variables
- Avoids shell parsing issues with URL query parameters
- Determines backup type based on current date
- Automatically removes expired backups
- Shows inventory and storage metrics

**Technical Approach**:
```bash
# Extract and parse DATABASE_URL
DATABASE_URL_LINE=$(grep '^DATABASE_URL=' .env.local | cut -d'=' -f2-)

# Set individual PG* variables (avoids URL parsing issues)
export PGUSER=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*://\([^:]*\):.*|\1|p')
export PGPASSWORD=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p' | sed 's/%5E/^/g; s/%24/$/g; s/%25/%/g')
export PGHOST=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*@\([^:]*\):.*|\1|p')
export PGPORT=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
export PGDATABASE=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*/\([^?]*\).*|\1|p')

# Run backup
pg_dump > "$BACKUP_FILE"

# Rotate old backups
find backups/daily -name "*.sql" -type f -mtime +7 -delete
```

**Why This Approach**:
- PostgreSQL environment variables more reliable than full URL strings
- Handles URL-encoded passwords automatically
- No dependencies on external libraries
- Works with Supabase connection pooling (`?pgbouncer=true`)

#### 2. Setup Script (`setup-automated-backups.sh`)

**Purpose**: One-time installation of automated backups

**Functionality**:
- Verifies backup script exists and is executable
- Shows proposed schedule for user review
- Checks for existing cron jobs (prevents duplicates)
- Installs cron job with logging
- Provides verification commands

**Cron Configuration**:
```bash
# Daily at 2:00 AM (off-peak hours)
0 2 * * * /absolute/path/to/backup-with-rotation.sh >> /path/to/backups/backup.log 2>&1
```

#### 3. Manual Backup Scripts

- `backup-database.sh`: Simple one-time backup
- `restore-database.sh`: Restore from backup file (with confirmation)

---

## Security Considerations

### Data Protection

**What's in the backups**:
- Database schema (tables, indexes, constraints)
- All application data (users, content, relationships)
- Potentially sensitive information (emails, phone numbers, etc.)

**Security measures**:
1. ✅ **Local storage only** - Backups never leave developer machine
2. ✅ **Gitignored** - Backup files excluded from version control
3. ✅ **Automatic rotation** - Old data automatically deleted
4. ✅ **Access control** - Limited to developers with file system access
5. ⚠️ **Not encrypted** - Backups stored in plain text SQL format

**Recommendations**:
- For production: Consider encrypting backups with `gpg`
- For sensitive data: Implement off-site encrypted storage
- For compliance: Document backup access logs

### Connection Security

**Database credentials**:
- Read from `.env.local` (gitignored, not committed)
- Password URL-encoded for special characters
- Credentials only in memory during backup execution
- No credentials logged to backup.log

---

## Storage & Performance

### Storage Requirements

**Georgetown Database** (Reference):
- Current size: 430KB
- Backup file size: 430KB (SQL text format)
- Full retention: ~8MB total

**Scaling Estimates**:

| Database Size | Daily (7d) | Weekly (4w) | Monthly (6m) | Total |
|---------------|------------|-------------|--------------|-------|
| 500KB | 3.5 MB | 2 MB | 3 MB | 8.5 MB |
| 5 MB | 35 MB | 20 MB | 30 MB | 85 MB |
| 50 MB | 350 MB | 200 MB | 300 MB | 850 MB |
| 500 MB | 3.5 GB | 2 GB | 3 GB | 8.5 GB |

**Brandmine Estimate**:
- Assuming 10-50MB database: ~85-850MB total storage
- Storage cost: Negligible (local disk)

### Performance

**Backup Duration**:
- 430KB database: ~2-5 seconds
- 50MB database: ~30-60 seconds (estimated)
- Runs at 2:00 AM (off-peak)

**System Impact**:
- Minimal CPU usage (pg_dump is efficient)
- Network: Depends on connection to Supabase (typically <1 minute)
- No impact on running application

---

## Operational Requirements

### Prerequisites

**Software**:
- `pg_dump` (PostgreSQL client tools)
  - macOS: `brew install libpq` (already installed for Georgetown)
  - Linux: `apt-get install postgresql-client`
- `bash` shell (standard on macOS/Linux)
- `cron` (standard on macOS/Linux)

**Configuration**:
- `.env.local` file with `DATABASE_URL`
- Supabase connection string (session pooler, port 6543)
- File system write access to backup directory

### Deployment Steps

1. **Copy scripts to project**:
   ```bash
   cp apps/georgetown/scripts/backup-with-rotation.sh apps/brandmine/scripts/
   cp apps/georgetown/scripts/setup-automated-backups.sh apps/brandmine/scripts/
   chmod +x apps/brandmine/scripts/*.sh
   ```

2. **Verify DATABASE_URL format**:
   ```bash
   # Must be unquoted in .env.local
   DATABASE_URL=postgresql://user:pass@host:port/db?pgbouncer=true
   ```

3. **Test backup manually**:
   ```bash
   cd apps/brandmine
   ./scripts/backup-with-rotation.sh
   ```

4. **Install automated backups**:
   ```bash
   cd apps/brandmine
   ./scripts/setup-automated-backups.sh
   ```

5. **Verify installation**:
   ```bash
   crontab -l | grep backup-with-rotation
   ```

**Time to deploy**: ~10 minutes

### Maintenance

**Monthly** (5 minutes):
- Check `backups/backup.log` for errors
- Verify backups are being created
- Check disk space usage

**Quarterly** (30 minutes):
- Test restore process to verify backup integrity
- Review retention policy (adjust if needed)

**Annual** (1 hour):
- Review backup strategy
- Update documentation
- Consider off-site storage for disaster recovery

---

## Troubleshooting

### Common Issues

#### 1. Backup Not Running

**Symptoms**: No new backups in `backups/daily/`

**Causes**:
- Computer off at 2:00 AM (cron only runs when machine is on)
- Cron job not installed correctly
- Script permissions incorrect

**Resolution**:
```bash
# Verify cron job
crontab -l | grep backup-with-rotation

# Check script is executable
ls -l scripts/backup-with-rotation.sh

# Test manually
./scripts/backup-with-rotation.sh
```

#### 2. Connection Errors

**Symptoms**: "Could not connect to database" errors in log

**Causes**:
- Supabase credentials changed
- Network connectivity issues
- Database URL format incorrect

**Resolution**:
```bash
# Test connection manually
psql "$DATABASE_URL" -c "SELECT version();"

# Verify URL format (no quotes)
grep DATABASE_URL .env.local
```

#### 3. Storage Growing Too Large

**Symptoms**: Backup directory exceeds expected size

**Causes**:
- Database growing rapidly
- Rotation not removing old backups
- Many large backups accumulated

**Resolution**:
```bash
# Check backup sizes
du -sh backups/*

# Verify rotation is working
./scripts/backup-with-rotation.sh
# (should show old backups being removed)

# Consider shorter retention if needed
```

**Full troubleshooting protocol**: See [docs/protocols/troubleshooting-protocol.md](../protocols/troubleshooting-protocol.md)

---

## Lessons Learned (Georgetown Implementation)

### Technical Challenges

**Challenge 1: Environment Variable Loading**

**Problem**: URL query parameters (`?pgbouncer=true`) broke bash `source` command

**Solution**: Parse URL into individual PostgreSQL environment variables

**Time to resolve**: 45 minutes with systematic troubleshooting

**Documentation**: [Backup Script Troubleshooting Log](../georgetown/docs/dev-journal/2025-12-16-backup-script-troubleshooting.md)

**Key Learning**: PostgreSQL `PG*` environment variables more reliable than full connection URLs in bash scripts

---

### Process Insights

**What worked well**:
1. Systematic troubleshooting protocol (prevented circular debugging)
2. Research after 3 failed attempts (found better approach)
3. Real-time documentation (captured lessons for future)

**What to replicate for Brandmine**:
1. Test connection string manually before scripting
2. Use troubleshooting protocol if issues arise
3. Document any customizations needed

---

## Migration to Brandmine

### Compatibility Assessment

**Georgetown → Brandmine Differences**:

| Aspect | Georgetown | Brandmine | Compatibility |
|--------|-----------|-----------|---------------|
| Database | PostgreSQL (Supabase) | PostgreSQL (Supabase) | ✅ Direct |
| Connection | Session pooler (6543) | TBD | ✅ Same approach |
| Environment | .env.local | .env.local | ✅ Same format |
| OS | macOS | macOS/Linux | ✅ Bash compatible |
| Monorepo | Yes (clubs/) | Yes | ✅ Same structure |

**Expected compatibility**: 100% (no modifications needed)

### Customization Points

**May need adjustment**:

1. **Retention policy**: Adjust based on Brandmine's needs
   ```bash
   # In backup-with-rotation.sh
   RETENTION_DAYS=7  # Daily backups (change if needed)
   ```

2. **Backup schedule**: Change cron timing if 2:00 AM doesn't work
   ```bash
   # In setup-automated-backups.sh
   CRON_TIME="0 2 * * *"  # Adjust time
   ```

3. **Storage location**: If prefer different backup directory
   ```bash
   # In backup-with-rotation.sh
   mkdir -p backups/daily  # Change path if needed
   ```

### Migration Steps

1. **Copy scripts** (5 min)
2. **Test manually** (5 min)
3. **Install cron** (2 min)
4. **Monitor first week** (5 min/day)
5. **Document any customizations** (10 min)

**Total time**: ~30 minutes + 1 week monitoring

---

## Alternative Approaches Considered

### Cloud-Based Backups (GitHub Actions, AWS)

**Pros**:
- Runs even if local machine is off
- Off-site storage (disaster recovery)
- Centralized monitoring

**Cons**:
- Must securely store credentials in cloud
- Network transfer time for backups
- Minimal storage costs (but adds complexity)
- Compliance concerns with data residency

**Recommendation**: Start with local backups, migrate to cloud if needed

### Compressed Backups (gzip)

**Pros**:
- Reduces storage by ~70-80%
- Same reliability

**Cons**:
- Slightly longer backup time
- Must decompress to restore
- Adds complexity

**Recommendation**: Implement if storage becomes issue (>1GB retention)

### Real-Time Replication

**Pros**:
- Continuous protection
- Near-zero data loss

**Cons**:
- Complex to set up
- Higher costs (second database)
- Overkill for small organizations

**Recommendation**: Not needed for Brandmine's scale

---

## Cost-Benefit Analysis

### Costs

**Development Time**:
- Georgetown implementation: ~3 hours (including troubleshooting)
- Brandmine migration: ~30 minutes (scripts already built)

**Storage**:
- Local disk: Free (8MB - 850MB depending on database size)
- No cloud costs

**Maintenance**:
- Monthly: 5 minutes
- Quarterly: 30 minutes
- Annual: 1 hour

**Total Annual Cost**: ~3-4 hours developer time

### Benefits

**Risk Mitigation**:
- Prevents data loss from developer errors
- Quick recovery from bad migrations
- Protection against database corruption

**Compliance**:
- Structured retention policy
- Documented backup process
- Audit trail via backup.log

**Developer Productivity**:
- Zero mental overhead (automated)
- Confidence to make database changes
- No manual backup management

**Business Value**:
- Data protection for critical business assets
- Peace of mind for stakeholders
- Professional backup practices

**ROI**: High (minimal cost, significant risk reduction)

---

## Recommendations

### For Brandmine Deployment

**Immediate Actions** (Week 1):
1. ✅ Copy scripts from Georgetown
2. ✅ Test manual backup
3. ✅ Install automated backups
4. ✅ Monitor first week of backups

**Short-term** (Month 1):
1. ✅ Test restore process
2. ✅ Document any Brandmine-specific customizations
3. ✅ Add backup verification to monthly review

**Long-term** (Year 1):
1. ⚠️ Consider off-site storage for disaster recovery
2. ⚠️ Evaluate cloud migration if team grows
3. ⚠️ Review retention policy based on actual needs

### Future Enhancements

**If needed**:
1. Compression (gzip) for larger databases
2. Encryption for sensitive data
3. Off-site storage (S3, BackBlaze)
4. Notification system (email/Slack on failure)
5. Backup verification tests (automatic restore to staging)

**Not recommended unless needed**:
- Real-time replication (overkill)
- Complex retention policies (current policy sufficient)
- Third-party backup services (adds cost and complexity)

---

## References

### Industry Best Practices

**Retention Policies**:
- [Backup Retention Policy Best Practices (TechTarget)](https://www.techtarget.com/searchdatabackup/answer/What-are-some-data-retention-policy-best-practices)
- [Data Retention Policies & Backups (Dataprise)](https://www.dataprise.com/resources/blog/data-retention-policies-and-backups/)
- [7 Data Retention Policy Best Practices (CrashPlan)](https://www.crashplan.com/blog/7-data-retention-policy-best-practices-for-your-business/)

**Automation & Rotation**:
- [Backup Rotation Schemes (HandyBackup)](https://www.handybackup.net/backup-rotation-schedule.shtml)
- [Scheduling Backups with Cron (Medium)](https://medium.com/@stark101/scheduling-backups-with-rsync-and-cron-in-bash-a-simple-guide-aa0e785ae79a)

**PostgreSQL Specific**:
- [PostgreSQL Documentation: pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
- [PostgreSQL Environment Variables](https://www.postgresql.org/docs/current/libpq-envars.html)
- [Special characters in PostgreSQL URLs](https://copyprogramming.com/howto/in-postgresql-url-i-can-t-use-a-password-containing-special-characters)

### Georgetown Documentation

**Implementation Details**:
- [scripts/README.md](apps/georgetown/scripts/README.md) - All backup scripts
- [docs/operations/automated-backups.md](apps/georgetown/docs/operations/automated-backups.md) - Complete operations guide
- [docs/dev-journal/2025-12-16-backup-script-troubleshooting.md](apps/georgetown/docs/dev-journal/2025-12-16-backup-script-troubleshooting.md) - Troubleshooting log

**Related**:
- [docs/protocols/troubleshooting-protocol.md](apps/georgetown/docs/protocols/troubleshooting-protocol.md) - Systematic debugging
- [docs/adr/0001-supabase-singapore-migration.md](apps/georgetown/docs/adr/0001-supabase-singapore-migration.md) - Connection setup

---

## Appendix A: Script Inventory

| Script | Lines | Purpose | Dependencies |
|--------|-------|---------|--------------|
| backup-with-rotation.sh | ~150 | Main backup with rotation | pg_dump, bash, find |
| setup-automated-backups.sh | ~80 | Cron installation | crontab, bash |
| backup-database.sh | ~65 | Simple one-time backup | pg_dump, bash |
| restore-database.sh | ~75 | Restore from backup | psql, bash |

**Total codebase**: ~370 lines (fully commented)

---

## Appendix B: Test Results

**Georgetown Production** (2025-12-16):

```bash
$ ./scripts/backup-with-rotation.sh

Georgetown Database Backup with Rotation
================================================
Backup type: daily
Backup file: backups/daily/georgetown_2025-12-16.sql

Running pg_dump...
✓ Backup completed successfully

Backup details:
  Type: daily
  File: backups/daily/georgetown_2025-12-16.sql
  Size: 430K
  Lines: 11104

Rotating old backups...

Current backup inventory:
  Daily backups:   1 (keep 7 days)
  Weekly backups:  0 (keep 4 weeks)
  Monthly backups: 0 (keep 6 months)
  Total storage:   896K

✓ Backup rotation completed
```

**Status**: ✅ Production-ready

---

## Contact & Support

**Primary Contact**: Georgetown Development Team
**Documentation**: apps/georgetown/docs/operations/automated-backups.md
**Issue Tracking**: See troubleshooting protocol

**For Brandmine Implementation**:
- Review this document
- Test on Brandmine staging environment
- Document any customizations needed
- Share lessons learned with team

---

**Document Version**: 1.0
**Last Updated**: 2025-12-16
**Next Review**: 2026-01-16
**Status**: Approved for Brandmine Migration
