-- ============================================================
-- Migration: 005-add-public-read-policy.sql
-- Purpose: Enable public read access for visible member profiles
-- Created: 2025-09-28
-- Deployed to Production: 2025-09-28
-- Prerequisites: 004-fix-rls-policies.sql
-- ============================================================
-- ADD PUBLIC READ ACCESS FOR USERS WITH VISIBLE PROFILES
-- This allows unauthenticated visitors to see basic member directory
-- Execute this in Supabase SQL Editor

-- Step 1: Allow public read access to privacy_settings (read-only, no PII)
-- This is needed so anonymous users can check visibility flags
CREATE POLICY "privacy_settings_public_read" ON privacy_settings
FOR SELECT
USING (true);  -- Anyone can read privacy flags (no sensitive data in this table)

-- Step 2: Add policy to allow public to see users who have opted into profile visibility
CREATE POLICY "users_public_with_visible_profiles" ON users
FOR SELECT
USING (
  -- Allow if user has a profile with at least one public field enabled
  id IN (
    SELECT mp.user_id
    FROM member_profiles mp
    JOIN privacy_settings ps ON mp.user_id = ps.user_id
    WHERE ps.show_photo = true
       OR ps.show_venture_info = true
       OR ps.show_expertise = true
       OR ps.show_bio = true
  )
);

-- Test query (should now return users with visible profiles)
SELECT u.id, u.full_name, u.email, u.role
FROM users u
JOIN member_profiles mp ON u.id = mp.user_id
JOIN privacy_settings ps ON u.id = ps.user_id
WHERE ps.show_photo = true OR ps.show_venture_info = true
LIMIT 5;