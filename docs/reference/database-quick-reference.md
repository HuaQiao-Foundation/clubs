# Database Quick Reference

Quick reference for direct database access in the Clubs monorepo.

For complete documentation, see [direct-database-access.md](direct-database-access.md).

## Quick Start

### Connect to Georgetown Database

```bash
# Run a query
./scripts/db-connect.sh georgetown -c "SELECT COUNT(*) FROM speakers;"

# Interactive session
./scripts/db-connect.sh georgetown

# Apply migration
./scripts/db-connect.sh georgetown -f apps/georgetown/docs/database/001-migration.sql

# List all tables
./scripts/db-connect.sh georgetown -c "\dt"

# Describe a table
./scripts/db-connect.sh georgetown -c "\d speakers"
```

### Connect to Pitchmasters Database

```bash
# Run a query
./scripts/db-connect.sh pitchmasters -c "SELECT COUNT(*) FROM clubs;"

# Interactive session
./scripts/db-connect.sh pitchmasters

# Apply migration
./scripts/db-connect.sh pitchmasters -f apps/pitchmasters/docs/database/001-migration.sql
```

## Common Commands

### Inspection Commands

```bash
# List all tables
\dt

# Describe table structure
\d table_name

# List all indexes
\di

# List all views
\dv

# Show table constraints
\d+ table_name

# Quit
\q
```

### Georgetown Tables

- `speakers` - Speaker management (18 records)
- `members` - Club members
- `events` - Rotary events
- `attendance_records` - Meeting attendance
- `service_projects` - Service projects
- `locations` - Meeting locations
- `photos` - Event photos
- `partners` - Project partners

### Pitchmasters Tables

(To be populated when Pitchmasters database is ready)

## Environment Files

### Georgetown

**File**: `apps/georgetown/.env.local`

Contains:
- `VITE_SUPABASE_URL` - Frontend API URL
- `VITE_SUPABASE_ANON_KEY` - Public API key
- `DATABASE_URL` - Pooled connection (port 6543)
- `DIRECT_URL` - Direct connection (port 5432)

### Pitchmasters

**File**: `apps/pitchmasters/.env.local`

(To be created when database is ready)

## Tips

1. **Always run from repo root**: `./scripts/db-connect.sh`
2. **Use DIRECT_URL for migrations**: Already configured in helper script
3. **URL-encoded passwords**: Helper script handles decoding automatically
4. **Interactive mode**: Best for exploration and ad-hoc queries
5. **Script mode** (`-c` or `-f`): Best for automation and migrations

## Troubleshooting

### Connection Failed

```bash
# Test connectivity
ping aws-1-ap-southeast-1.pooler.supabase.com

# Verify credentials
grep DIRECT_URL apps/georgetown/.env.local
```

### Authentication Failed

- Check password hasn't changed in Supabase dashboard
- Verify `.env.local` is up to date
- Ensure helper script has URL decoding (line 73)

### Wrong Database

```bash
# Verify which database you're connected to
./scripts/db-connect.sh georgetown -c "SELECT current_database();"
./scripts/db-connect.sh pitchmasters -c "SELECT current_database();"
```

## See Also

- [direct-database-access.md](direct-database-access.md) - Complete documentation
- [scripts/db-connect.sh](../scripts/db-connect.sh) - Helper script source
- [apps/georgetown/docs/database/](../apps/georgetown/docs/database/) - Georgetown migrations
- [apps/pitchmasters/docs/database/](../apps/pitchmasters/docs/database/) - Pitchmasters migrations
