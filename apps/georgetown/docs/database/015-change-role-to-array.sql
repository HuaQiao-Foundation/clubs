-- Migration 015: Change role field from TEXT to TEXT[] to support multiple roles
-- This allows members to hold multiple positions simultaneously
-- (e.g., "Immediate Past President" + "Club Service Projects Chair")

-- Step 1: Add new column for multiple roles
ALTER TABLE members
ADD COLUMN roles TEXT[];

-- Step 2: Migrate existing single role data to array
UPDATE members
SET roles = ARRAY[role]
WHERE role IS NOT NULL AND role != '';

-- Step 3: For members with no role or empty role, set to array with 'Member'
UPDATE members
SET roles = ARRAY['Member']
WHERE role IS NULL OR role = '';

-- Step 4: Drop the old single role column
ALTER TABLE members
DROP COLUMN role;

-- Step 5: Rename new column to 'role' (or keep as 'roles' - your choice)
-- Note: Keeping as 'roles' (plural) makes it clearer it's an array
-- ALTER TABLE members RENAME COLUMN roles TO role;

-- Note: The column will be named 'roles' (plural) to indicate it contains multiple values
