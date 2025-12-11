-- Migration 016: Populate missing roles arrays
-- Description: Fix members who lost their role data during migration 015

-- This migration assumes you need to manually identify and update officer roles
-- Since the old 'role' column no longer exists, you'll need to identify officers by name

-- OPTION 1: If you have a backup or know the officer names, update them individually
-- Example format (uncomment and update with actual names and roles):

-- UPDATE members SET roles = ARRAY['President'] WHERE name = 'John Doe';
-- UPDATE members SET roles = ARRAY['Vice President'] WHERE name = 'Jane Smith';
-- UPDATE members SET roles = ARRAY['Secretary'] WHERE name = 'Bob Johnson';
-- UPDATE members SET roles = ARRAY['Treasurer'] WHERE name = 'Alice Williams';
-- UPDATE members SET roles = ARRAY['President-Elect'] WHERE name = 'Charlie Brown';
-- UPDATE members SET roles = ARRAY['Immediate Past President'] WHERE name = 'David Lee';
-- UPDATE members SET roles = ARRAY['Sergeant-at-Arms'] WHERE name = 'Emma Davis';

-- For members with multiple roles, use this format:
-- UPDATE members SET roles = ARRAY['Immediate Past President', 'Club Service Projects Chair'] WHERE name = 'Wilson Lim';

-- OPTION 2: Set all members without roles to 'Member' role
UPDATE members
SET roles = ARRAY['Member']
WHERE roles IS NULL OR ARRAY_LENGTH(roles, 1) IS NULL OR ARRAY_LENGTH(roles, 1) = 0;

-- Verification: Check the update
SELECT
    name,
    roles,
    type
FROM members
ORDER BY name;
