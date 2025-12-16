#!/bin/bash

# Georgetown Database Backup Script
# Creates a timestamped backup of the Supabase database

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Georgetown Database Backup${NC}"
echo "================================"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Navigate to the Georgetown app directory (parent of scripts/)
cd "$SCRIPT_DIR/.."

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

# Create backups directory if it doesn't exist
mkdir -p backups

# Generate backup filename with date
DATE=$(date +%Y-%m-%d)
BACKUP_FILE="backups/georgetown_backup_${DATE}.sql"

echo "Backup file: ${BACKUP_FILE}"
echo ""

# Run pg_dump
echo "Running pg_dump..."
if pg_dump "$DATABASE_URL" > "$BACKUP_FILE" 2>&1; then
    # Get file size and line count
    SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
    LINES=$(wc -l < "$BACKUP_FILE")

    echo -e "${GREEN}✓ Backup completed successfully${NC}"
    echo ""
    echo "Backup details:"
    echo "  File: $BACKUP_FILE"
    echo "  Size: $SIZE"
    echo "  Lines: $LINES"
    echo ""
    echo "To restore this backup:"
    echo "  ./scripts/restore-database.sh $BACKUP_FILE"
else
    echo -e "${RED}✗ Backup failed${NC}"
    rm -f "$BACKUP_FILE"  # Remove incomplete backup
    exit 1
fi
