#!/bin/bash
# Georgetown Rotary - Schema Snapshot Updater
# Purpose: Generate current production schema after CEO deploys migrations
# Usage: ./scripts/update-schema-snapshot.sh [migration-number]
#
# Requirements:
# - Supabase CLI installed (brew install supabase/tap/supabase)
# - Project linked (supabase link --project-ref [id])

set -e  # Exit on error

SCHEMA_FILE="docs/database/CURRENT-PRODUCTION-SCHEMA.sql"
MIGRATION_NUM=${1:-"unknown"}

echo "📸 Generating schema snapshot from Supabase production..."
echo ""

# Generate schema-only dump (no data)
supabase db dump --schema public --data-only=false > "$SCHEMA_FILE"

echo "✅ Schema snapshot saved to $SCHEMA_FILE"
echo ""

# Display summary statistics
echo "📊 Schema Summary:"
echo "=================="
TABLE_COUNT=$(grep -c "CREATE TABLE" "$SCHEMA_FILE" || echo "0")
INDEX_COUNT=$(grep -c "CREATE INDEX" "$SCHEMA_FILE" || echo "0")
POLICY_COUNT=$(grep -c "CREATE POLICY" "$SCHEMA_FILE" || echo "0")

echo "Tables:       $TABLE_COUNT"
echo "Indexes:      $INDEX_COUNT"
echo "RLS Policies: $POLICY_COUNT"
echo ""

# Show table names
echo "📋 Tables in Production:"
echo "========================"
grep "CREATE TABLE" "$SCHEMA_FILE" | sed 's/CREATE TABLE public\.\([^ ]*\).*/  - \1/' || echo "  (none found)"
echo ""

# Next steps
echo "🎯 Next Steps:"
echo "=============="
echo "1. Review $SCHEMA_FILE for accuracy"
echo "2. git add $SCHEMA_FILE"
echo "3. git commit -m 'docs(db): schema snapshot after migration $MIGRATION_NUM'"
if [ "$MIGRATION_NUM" != "unknown" ]; then
    echo "4. Update docs/database/${MIGRATION_NUM}-*.sql header with deploy date"
fi
echo ""
echo "✨ Schema documentation updated successfully!"
