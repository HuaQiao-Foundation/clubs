-- ============================================================
-- Migration: 004-fix-rls-policies.sql
-- Purpose: Fix RLS infinite recursion on member_profiles
-- Created: 2025-09-28
-- Deployed to Production: 2025-09-28
-- Prerequisites: 003-add-csv-fields.sql
-- ============================================================
-- FIX RLS INFINITE RECURSION ON MEMBER_PROFILES
-- Execute this in Supabase SQL Editor to fix the circular dependency

-- Drop the problematic policies
DROP POLICY IF EXISTS "Public profile access" ON member_profiles;
DROP POLICY IF EXISTS "Members can create profiles" ON member_profiles;
DROP POLICY IF EXISTS "Users update own profiles" ON member_profiles;

-- Create corrected policies without recursion
-- FIXED: Use privacy_settings table directly instead of joining member_profiles

-- Policy 1: Users can always see their own profile
CREATE POLICY "users_own_profile" ON member_profiles
FOR SELECT
USING (user_id = auth.uid());

-- Policy 2: Other users can see profiles based on privacy settings
-- This checks privacy_settings WITHOUT joining back to member_profiles
CREATE POLICY "users_view_others_profiles" ON member_profiles
FOR SELECT
USING (
    user_id != auth.uid() AND
    user_id IN (
        SELECT ps.user_id
        FROM privacy_settings ps
        WHERE ps.user_id = member_profiles.user_id
        AND (
            ps.show_photo = true OR
            ps.show_venture_info = true OR
            ps.show_expertise = true OR
            ps.show_bio = true
        )
    )
);

-- Policy 3: Allow profile creation (no recursion issue)
CREATE POLICY "members_create_profile" ON member_profiles
FOR INSERT
WITH CHECK (
    user_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

-- Policy 4: Allow profile updates (no recursion issue)
CREATE POLICY "members_update_own_profile" ON member_profiles
FOR UPDATE
USING (user_id = auth.uid());

-- ALSO FIX: Privacy settings policies for completeness
DROP POLICY IF EXISTS "User controls own privacy" ON privacy_settings;

CREATE POLICY "users_own_privacy_select" ON privacy_settings
FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "users_own_privacy_insert" ON privacy_settings
FOR INSERT
WITH CHECK (
    user_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "users_own_privacy_update" ON privacy_settings
FOR UPDATE
USING (user_id = auth.uid());

CREATE POLICY "users_own_privacy_delete" ON privacy_settings
FOR DELETE
USING (user_id = auth.uid());

-- Test query to verify no recursion
-- This should return results without infinite loop
SELECT
    mp.*,
    ps.show_photo,
    ps.show_venture_info
FROM member_profiles mp
LEFT JOIN privacy_settings ps ON mp.user_id = ps.user_id
LIMIT 5;

-- Schema fix complete!