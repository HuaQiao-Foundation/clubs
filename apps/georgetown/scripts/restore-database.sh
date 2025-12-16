#!/bin/bash

# Georgetown Database Restore Script
# Restores database from a backup file

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Georgetown Database Restore${NC}"
echo "================================"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Navigate to the Georgetown app directory (parent of scripts/)
cd "$SCRIPT_DIR/.."

# Check if backup file argument provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo ""
    echo "Usage:"
    echo "  ./scripts/restore-database.sh <backup-file>"
    echo ""
    echo "Example:"
    echo "  ./scripts/restore-database.sh backups/georgetown_backup_2025-12-16.sql"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${RED}Error: .env.local file not found${NC}"
    echo "Please create .env.local with DATABASE_URL"
    exit 1
fi

# Extract connection details from DATABASE_URL in .env.local
# Uses PG* environment variables to avoid shell parsing issues with URL query parameters
DATABASE_URL_LINE=$(grep '^DATABASE_URL=' .env.local | cut -d'=' -f2-)

# Parse connection string (format: postgresql://user:pass@host:port/db?params)
export PGUSER=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*://\([^:]*\):.*|\1|p')
export PGPASSWORD=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p' | sed 's/%5E/^/g; s/%24/$/g; s/%25/%/g')
export PGHOST=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*@\([^:]*\):.*|\1|p')
export PGPORT=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
export PGDATABASE=$(echo "$DATABASE_URL_LINE" | sed -n 's|.*/\([^?]*\).*|\1|p')

# Check if all required variables are set
if [ -z "$PGHOST" ] || [ -z "$PGUSER" ] || [ -z "$PGPASSWORD" ]; then
    echo -e "${RED}Error: Could not parse DATABASE_URL from .env.local${NC}"
    exit 1
fi
fi

echo "Backup file: ${BACKUP_FILE}"
echo ""
echo -e "${RED}WARNING: This will overwrite the current database!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo ""
echo "Running psql restore..."

if psql "$DATABASE_URL" < "$BACKUP_FILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Restore completed successfully${NC}"
    echo ""
    echo "Database restored from: $BACKUP_FILE"
else
    echo -e "${RED}✗ Restore failed${NC}"
    echo "Check the backup file and DATABASE_URL"
    exit 1
fi
