-- Diagnostic: Check current constraints on events table

-- 1. Check all constraints on events table
SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'events';

-- 2. Check CHECK constraints specifically
SELECT
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'events'
  AND con.contype = 'c';

-- 3. Check column details
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'events'
ORDER BY ordinal_position;
