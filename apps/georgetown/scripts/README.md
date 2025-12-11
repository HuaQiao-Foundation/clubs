# Scripts Directory

This directory contains reusable SQL queries and operational scripts for the Georgetown Rotary application.

## Scripts Index

| Script | Type | Purpose | Added | Last Updated |
|--------|------|---------|-------|--------------|
| [query-officers-and-chairs.sql](query-officers-and-chairs.sql) | SQL | Export all officer and committee chair roles with assigned members | 2024-XX-XX | 2024-XX-XX |
| [update-schema-snapshot.sh](update-schema-snapshot.sh) | Shell | Update database schema snapshot | 2024-XX-XX | 2024-XX-XX |
| [sprint-status.sh](sprint-status.sh) | Shell | Generate sprint status report | 2024-XX-XX | 2024-XX-XX |
| [update-todo.sh](update-todo.sh) | Shell | Update TODO tracking | 2024-XX-XX | 2024-XX-XX |

## Script Types

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

## Output Location

Query results and exports should be saved to `/exports/` directory with timestamped filenames.

## Adding New Scripts

When adding a new script:
1. Create the script file in this directory
2. Add comprehensive header comments explaining purpose and usage
3. Update the Scripts Index table above
4. Include example usage in script comments
5. Commit with descriptive message
