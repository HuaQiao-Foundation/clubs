# ADR-0001: Migrate Supabase Database to Singapore Region

**Status**: Accepted
**Date**: 2025-12-16
**Deciders**: Randal Eastman (CEO), Claude Code (CTO)
**Technical Story**: Initial Georgetown database was hosted in Sydney (ap-southeast-2), causing high latency for Malaysian users.

## Context and Problem Statement

The Georgetown Rotary application's Supabase database was initially provisioned in Sydney, Australia (ap-southeast-2 region). With the primary user base located in Malaysia, this resulted in ~120-150ms database query latency, negatively impacting user experience.

How can we optimize database performance for Malaysian users while maintaining data integrity during migration?

## Decision Drivers

* **Performance**: Reduce query latency from Malaysia (primary user location)
* **Cost**: Free tier limit of 2 Supabase projects requires careful region selection
* **Data Integrity**: Must migrate existing data without loss
* **Simplicity**: Minimize operational complexity during migration

## Considered Options

1. Keep Sydney database (ap-southeast-2)
2. Migrate to Singapore (ap-southeast-1)
3. Migrate to a different region closer to Malaysia

## Decision Outcome

Chosen option: "Migrate to Singapore (ap-southeast-1)", because it provides the best balance of proximity to Malaysia (~5-10ms latency), AWS region stability, and straightforward migration path.

### Positive Consequences

* **12-15x latency improvement**: From ~120-150ms to ~5-10ms for Malaysian users
* **Better user experience**: Faster page loads and data updates
* **Proven region**: Singapore is AWS's primary ASEAN region with excellent uptime
* **Successful migration**: All data (18 speakers, 32 events, 26 members, 5 locations) migrated successfully

### Negative Consequences

* **One-time migration effort**: Required ~2 hours to backup, restore, and update configurations
* **Project limit reached**: Used both free tier Supabase projects, deleted old Sydney instances to free slots

## Pros and Cons of the Options

### Keep Sydney (ap-southeast-2)

* Good, because no migration effort required
* Good, because database already set up and working
* Bad, because ~120-150ms latency from Malaysia
* Bad, because poor user experience with slow queries

### Migrate to Singapore (ap-southeast-1)

* Good, because ~5-10ms latency from Malaysia (12-15x faster)
* Good, because established AWS region with excellent connectivity to ASEAN
* Good, because straightforward migration via `pg_dump`/`psql`
* Good, because proven region used by many production applications
* Bad, because requires one-time migration effort
* Bad, because uses up second free tier project slot

### Other Regions (Tokyo, Mumbai, etc.)

* Bad, because higher latency than Singapore
* Bad, because less established connectivity to Malaysia
* Bad, because no clear advantage over Singapore

## Implementation Details

### Migration Process

1. **Backup from Sydney database**:
   ```bash
   pg_dump 'postgresql://postgres.zooszmqdrdocuiuledql:PASSWORD@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres' > georgetown_backup.sql
   ```

2. **Create new Singapore project**:
   - Project ID: `rmorlqozjwbftzowqmps`
   - Region: ap-southeast-1 (Singapore)

3. **Restore to Singapore database**:
   ```bash
   psql 'postgresql://postgres.rmorlqozjwbftzowqmps:PASSWORD@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres' < georgetown_backup.sql
   ```

4. **Update configuration**:
   - `apps/georgetown/.env`
   - `apps/georgetown/.env.local`
   - Verified data integrity: 18 speakers, 32 events, 26 members, 5 locations

5. **Document process**:
   - Updated `docs/database/README.md` with backup/restore commands
   - Created backup automation scripts

### Key Learnings

* **Supabase connection strings changed**: No longer support `db.*.supabase.co`, must use pooler URLs
* **Session pooler required**: Port 6543 (not 5432) for `pg_dump`/`psql` operations
* **Password special characters**: Must URL-encode in connection strings (`^` = `%5E`, `$` = `%24`, `%` = `%25`)
* **Backup location**: Stored in `backups/` directory (gitignored)

## Links

* Documented in: [docs/database/README.md](../database/README.md#generate-database-backup-pg_dump)
* Related: [Dev Journal Entry 2025-12-16](../dev-journal/2025-12-16-singapore-database-migration.md)
