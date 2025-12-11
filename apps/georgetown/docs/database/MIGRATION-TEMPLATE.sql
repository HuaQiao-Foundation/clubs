-- Migration NNN: [Brief description of what this migration does]
-- Created: YYYY-MM-DD
-- Production Deploy: [CEO fills this in after deployment - YYYY-MM-DD or "Not deployed"]
-- Deployed By: [CEO name]
-- Verified: [YES/NO - CEO confirms verification queries passed]
-- Prerequisites: [Required tables, columns, or prior migrations that must exist]
-- Purpose: [Business objective this migration serves - why are we making this change?]
-- Breaking Changes: [YES - describe what breaks OR NONE]
-- Rollback Plan: [SQL commands to undo this migration if needed]

-- =====================================================
-- MIGRATION SQL
-- =====================================================

-- Example: Add new column to existing table
ALTER TABLE table_name
  ADD COLUMN IF NOT EXISTS column_name DATA_TYPE;

-- Example: Create new table
CREATE TABLE IF NOT EXISTS new_table (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add database comments for self-documentation
-- (These appear in Supabase Table Editor and in schema dumps)
COMMENT ON COLUMN table_name.column_name IS 'Description of what this field stores, format requirements, and how it is used in the application.';
COMMENT ON TABLE new_table IS 'Description of table purpose and relationship to other tables.';

-- Add indexes for performance (if querying on these columns)
CREATE INDEX IF NOT EXISTS idx_table_name_column_name
  ON table_name(column_name);

-- Add RLS policies if new table created
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users to read" ON new_table;
CREATE POLICY "Allow authenticated users to read"
  ON new_table FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Allow service role full access" ON new_table;
CREATE POLICY "Allow service role full access"
  ON new_table FOR ALL
  TO service_role
  USING (true);

-- =====================================================
-- VERIFICATION QUERIES (CEO: Run these after deployment)
-- =====================================================

-- 1. Verify table exists (if creating new table)
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_schema = 'public'
  AND table_name = 'new_table'
);
-- Expected: true

-- 2. Verify columns added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'table_name'
  AND column_name = 'column_name'
ORDER BY ordinal_position;
-- Expected: Column appears with correct data type

-- 3. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'table_name'
  AND indexname = 'idx_table_name_column_name';
-- Expected: Index appears

-- 4. Verify RLS policies (if applicable)
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'new_table'
ORDER BY policyname;
-- Expected: Policies listed

-- 5. Test basic query to ensure table accessible
SELECT COUNT(*) FROM table_name;
-- Expected: Returns count without errors

-- =====================================================
-- NOTES FOR FUTURE REFERENCE
-- =====================================================
-- [Any special considerations, data migration notes, or follow-up tasks]
-- [Known limitations or edge cases]
-- [Related migrations or dependencies]
