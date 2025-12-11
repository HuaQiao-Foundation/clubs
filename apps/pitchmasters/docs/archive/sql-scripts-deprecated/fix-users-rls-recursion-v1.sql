-- FIX RLS INFINITE RECURSION ON USERS TABLE
-- Execute this in Supabase SQL Editor

-- Step 1: Create a security definer function to get current user's club_id
-- This bypasses RLS and breaks the recursion
CREATE OR REPLACE FUNCTION auth.get_user_club_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT club_id FROM users WHERE id = auth.uid() LIMIT 1;
$$;

-- Step 2: Drop the problematic recursive policy on users table
DROP POLICY IF EXISTS "Users can view own club members" ON users;

-- Step 3: Create non-recursive policy using the security definer function
CREATE POLICY "users_view_same_club" ON users
FOR SELECT
USING (club_id = auth.get_user_club_id());

-- Step 4: Also fix the clubs policy which has similar recursion
DROP POLICY IF EXISTS "Users can view own club" ON clubs;

CREATE POLICY "clubs_view_own" ON clubs
FOR SELECT
USING (id = auth.get_user_club_id());

-- Test query to verify no recursion (should return users without error)
SELECT id, full_name, email, role, club_id
FROM users
LIMIT 5;