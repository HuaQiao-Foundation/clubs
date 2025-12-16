#!/bin/bash

# Georgetown Automated Backup Setup
# Configures cron job for daily automated backups with rotation

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Georgetown Automated Backup Setup${NC}"
echo "===================================="
echo ""

# Get the absolute path to the backup script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-with-rotation.sh"

# Verify backup script exists
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo -e "${RED}Error: Backup script not found at $BACKUP_SCRIPT${NC}"
    exit 1
fi

# Check if script is executable
if [ ! -x "$BACKUP_SCRIPT" ]; then
    echo -e "${YELLOW}Making backup script executable...${NC}"
    chmod +x "$BACKUP_SCRIPT"
fi

# Proposed cron schedule: 2:00 AM daily
CRON_TIME="0 2 * * *"  # Every day at 2:00 AM
CRON_JOB="$CRON_TIME $BACKUP_SCRIPT >> $SCRIPT_DIR/../backups/backup.log 2>&1"

echo "This will set up a daily automated backup with the following schedule:"
echo ""
echo -e "${BLUE}Schedule:${NC} Every day at 2:00 AM"
echo -e "${BLUE}Script:${NC} $BACKUP_SCRIPT"
echo -e "${BLUE}Log file:${NC} $SCRIPT_DIR/../backups/backup.log"
echo ""
echo -e "${BLUE}Retention policy:${NC}"
echo "  • Daily backups: Keep 7 days"
echo "  • Weekly backups: Keep 4 weeks (created on Sundays)"
echo "  • Monthly backups: Keep 6 months (created on 1st of month)"
echo ""

# Check if cron job already exists
EXISTING_CRON=$(crontab -l 2>/dev/null | grep -F "$BACKUP_SCRIPT" || true)

if [ -n "$EXISTING_CRON" ]; then
    echo -e "${YELLOW}Warning: A cron job for this backup script already exists:${NC}"
    echo "$EXISTING_CRON"
    echo ""
    read -p "Do you want to replace it? (yes/no): " REPLACE
    if [ "$REPLACE" != "yes" ]; then
        echo "Setup cancelled"
        exit 0
    fi
    # Remove existing cron job
    crontab -l 2>/dev/null | grep -v -F "$BACKUP_SCRIPT" | crontab -
    echo -e "${GREEN}Removed existing cron job${NC}"
fi

# Confirm installation
read -p "Do you want to install this automated backup? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Install cron job
(crontab -l 2>/dev/null || true; echo "$CRON_JOB") | crontab -

echo ""
echo -e "${GREEN}✓ Automated backup installed successfully!${NC}"
echo ""
echo "Backup will run daily at 2:00 AM"
echo ""
echo "To verify installation:"
echo "  crontab -l | grep backup-with-rotation"
echo ""
echo "To view backup logs:"
echo "  tail -f $SCRIPT_DIR/../backups/backup.log"
echo ""
echo "To test backup manually:"
echo "  $BACKUP_SCRIPT"
echo ""
echo "To remove automated backups:"
echo "  crontab -e"
echo "  (delete the line containing backup-with-rotation.sh)"
