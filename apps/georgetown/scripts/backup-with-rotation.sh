#!/bin/bash

# Georgetown Database Backup with Rotation
# Implements 7 daily, 4 weekly, 6 monthly retention policy
# Based on 2025 backup best practices

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Georgetown Database Backup with Rotation${NC}"
echo "================================================"

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

# Create backup directories if they don't exist
mkdir -p backups/daily
mkdir -p backups/weekly
mkdir -p backups/monthly

# Generate filenames with timestamps
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday
DAY_OF_MONTH=$(date +%d)

# Determine backup type based on date
BACKUP_TYPE="daily"
if [ "$DAY_OF_MONTH" = "01" ]; then
    BACKUP_TYPE="monthly"
elif [ "$DAY_OF_WEEK" = "7" ]; then  # Sunday
    BACKUP_TYPE="weekly"
fi

# Set backup path based on type
case $BACKUP_TYPE in
    "monthly")
        BACKUP_FILE="backups/monthly/georgetown_${DATE}.sql"
        RETENTION_DAYS=180  # 6 months
        ;;
    "weekly")
        BACKUP_FILE="backups/weekly/georgetown_${DATE}.sql"
        RETENTION_DAYS=28   # 4 weeks
        ;;
    *)
        BACKUP_FILE="backups/daily/georgetown_${DATE}.sql"
        RETENTION_DAYS=7
        ;;
esac

echo "Backup type: ${BACKUP_TYPE}"
echo "Backup file: ${BACKUP_FILE}"
echo ""

# Run pg_dump
echo "Running pg_dump..."
if pg_dump > "$BACKUP_FILE" 2>&1; then
    # Get file size and line count
    SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
    LINES=$(wc -l < "$BACKUP_FILE")

    echo -e "${GREEN}✓ Backup completed successfully${NC}"
    echo ""
    echo "Backup details:"
    echo "  Type: $BACKUP_TYPE"
    echo "  File: $BACKUP_FILE"
    echo "  Size: $SIZE"
    echo "  Lines: $LINES"
else
    echo -e "${RED}✗ Backup failed${NC}"
    rm -f "$BACKUP_FILE"  # Remove incomplete backup
    exit 1
fi

# Rotate old backups
echo ""
echo -e "${BLUE}Rotating old backups...${NC}"

# Remove daily backups older than 7 days
DAILY_REMOVED=$(find backups/daily -name "georgetown_*.sql" -type f -mtime +$RETENTION_DAYS 2>/dev/null | wc -l | tr -d ' ')
if [ "$DAILY_REMOVED" -gt 0 ]; then
    find backups/daily -name "georgetown_*.sql" -type f -mtime +7 -delete
    echo "  Removed $DAILY_REMOVED old daily backup(s)"
fi

# Remove weekly backups older than 28 days
WEEKLY_REMOVED=$(find backups/weekly -name "georgetown_*.sql" -type f -mtime +28 2>/dev/null | wc -l | tr -d ' ')
if [ "$WEEKLY_REMOVED" -gt 0 ]; then
    find backups/weekly -name "georgetown_*.sql" -type f -mtime +28 -delete
    echo "  Removed $WEEKLY_REMOVED old weekly backup(s)"
fi

# Remove monthly backups older than 180 days (6 months)
MONTHLY_REMOVED=$(find backups/monthly -name "georgetown_*.sql" -type f -mtime +180 2>/dev/null | wc -l | tr -d ' ')
if [ "$MONTHLY_REMOVED" -gt 0 ]; then
    find backups/monthly -name "georgetown_*.sql" -type f -mtime +180 -delete
    echo "  Removed $MONTHLY_REMOVED old monthly backup(s)"
fi

# Show current backup inventory
echo ""
echo -e "${BLUE}Current backup inventory:${NC}"
DAILY_COUNT=$(find backups/daily -name "georgetown_*.sql" -type f 2>/dev/null | wc -l | tr -d ' ')
WEEKLY_COUNT=$(find backups/weekly -name "georgetown_*.sql" -type f 2>/dev/null | wc -l | tr -d ' ')
MONTHLY_COUNT=$(find backups/monthly -name "georgetown_*.sql" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "  Daily backups:   $DAILY_COUNT (keep 7 days)"
echo "  Weekly backups:  $WEEKLY_COUNT (keep 4 weeks)"
echo "  Monthly backups: $MONTHLY_COUNT (keep 6 months)"

# Calculate total storage used
TOTAL_SIZE=$(du -sh backups 2>/dev/null | awk '{print $1}')
echo "  Total storage:   $TOTAL_SIZE"

echo ""
echo -e "${GREEN}✓ Backup rotation completed${NC}"
