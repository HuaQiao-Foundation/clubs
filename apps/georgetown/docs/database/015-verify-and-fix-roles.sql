-- Migration 015 Verification and Fix
-- Description: Verify roles array is populated correctly and fix if needed

-- Step 1: Check current state - see what we have
SELECT
    id,
    name,
    roles,
    ARRAY_LENGTH(roles, 1) as num_roles
FROM members
ORDER BY name
LIMIT 10;

-- Step 2: Count members with empty or null roles arrays
SELECT
    COUNT(*) as total_members,
    COUNT(CASE WHEN roles IS NULL OR ARRAY_LENGTH(roles, 1) IS NULL THEN 1 END) as members_without_roles,
    COUNT(CASE WHEN roles IS NOT NULL AND ARRAY_LENGTH(roles, 1) > 0 THEN 1 END) as members_with_roles
FROM members;

-- Step 3: If many members are missing roles, they all need at least 'Member' role
-- Run this ONLY if Step 2 shows many members without roles:
-- UPDATE members
-- SET roles = ARRAY['Member']
-- WHERE roles IS NULL OR ARRAY_LENGTH(roles, 1) IS NULL;

-- Step 4: Verification - check specific officer roles exist
SELECT
    name,
    roles
FROM members
WHERE roles && ARRAY['President', 'President-Elect', 'Immediate Past President', 'Vice President', 'Secretary', 'Treasurer', 'Sergeant-at-Arms']
ORDER BY name;

-- Step 5: Count how many officers we have
SELECT
    COUNT(*) as officer_count
FROM members
WHERE roles && ARRAY['President', 'President-Elect', 'Immediate Past President', 'Vice President', 'Secretary', 'Treasurer', 'Sergeant-at-Arms'];
