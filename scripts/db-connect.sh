#!/bin/bash
# =============================================================================
# Database Connection Helper for Clubs Monorepo
# =============================================================================
# Simplifies direct database access using psql for Georgetown and Pitchmasters
#
# Usage:
#   ./scripts/db-connect.sh georgetown -c "SELECT COUNT(*) FROM speakers;"
#   ./scripts/db-connect.sh georgetown -f apps/georgetown/docs/database/001-migration.sql
#   ./scripts/db-connect.sh georgetown  # Interactive session
#
#   ./scripts/db-connect.sh pitchmasters -c "SELECT COUNT(*) FROM clubs;"
#
# Prerequisites:
#   - PostgreSQL client tools installed (brew install libpq)
#   - .env.local exists in apps/georgetown/ or apps/pitchmasters/
#   - DIRECT_URL defined in .env.local
# =============================================================================

set -euo pipefail

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <app> [psql arguments]"
  echo ""
  echo "Examples:"
  echo "  $0 georgetown -c \"SELECT COUNT(*) FROM speakers;\""
  echo "  $0 georgetown -f apps/georgetown/docs/database/001-migration.sql"
  echo "  $0 georgetown  # Interactive session"
  echo ""
  echo "  $0 pitchmasters -c \"SELECT COUNT(*) FROM clubs;\""
  exit 1
fi

APP=$1
shift

# Determine env file path
case $APP in
  georgetown)
    ENV_FILE="apps/georgetown/.env.local"
    ;;
  pitchmasters)
    ENV_FILE="apps/pitchmasters/.env.local"
    ;;
  *)
    echo "Error: Unknown app '$APP'. Use 'georgetown' or 'pitchmasters'."
    exit 1
    ;;
esac

# Check env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found"
  echo "Please create it from the .env.example file"
  exit 1
fi

# Source env file and extract DIRECT_URL
source "$ENV_FILE"

if [ -z "${DIRECT_URL:-}" ]; then
  echo "Error: DIRECT_URL not found in $ENV_FILE"
  exit 1
fi

# Parse DIRECT_URL into PostgreSQL environment variables
# Format: postgresql://user:password@host:port/database
export PGUSER=$(echo "$DIRECT_URL" | sed -n 's|.*://\([^:]*\):.*|\1|p')

# Extract password and URL-decode it
RAW_PASSWORD=$(echo "$DIRECT_URL" | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p')
export PGPASSWORD=$(printf '%b' "${RAW_PASSWORD//%/\\x}")

export PGHOST=$(echo "$DIRECT_URL" | sed -n 's|.*@\([^:]*\):.*|\1|p')
export PGPORT=$(echo "$DIRECT_URL" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
export PGDATABASE=$(echo "$DIRECT_URL" | sed -n 's|.*/\([^?]*\).*|\1|p')

# Execute psql with provided arguments
psql "$@"
