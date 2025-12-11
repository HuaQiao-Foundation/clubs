-- ============================================================
-- Migration: 006-fix-users-rls-recursion.sql
-- Purpose: Fix RLS infinite recursion on users table (revised)
-- Created: 2025-09-28
-- Deployed to Production: 2025-09-28
-- Prerequisites: 005-add-public-read-policy.sql
-- ============================================================
-- FIX RLS INFINITE RECURSION ON USERS TABLE (Revised)
-- Execute this in Supabase SQL Editor

-- Step 1: Create a security definer function in PUBLIC schema to get current user's club_id
-- This bypasses RLS and breaks the recursion
CREATE OR REPLACE FUNCTION public.get_current_user_club_id()
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
USING (club_id = public.get_current_user_club_id());

-- Step 4: Also fix the clubs policy which has similar recursion
DROP POLICY IF EXISTS "Users can view own club" ON clubs;

CREATE POLICY "clubs_view_own" ON clubs
FOR SELECT
USING (id = public.get_current_user_club_id());

-- Test query to verify no recursion (should return users without error)
SELECT id, full_name, email, role, club_id
FROM users
LIMIT 5;