-- Migration 060: Create mock authentication user for testing
-- Purpose: Enable RSVP testing with mock auth by linking fixed UUID to first active member
-- Date: 2025-12-02
-- Author: CTO

-- Create mock auth.users entry with fixed UUID
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000001',  -- Fixed UUID for mock auth
  'authenticated',
  'authenticated',
  'mock@georgetown-rotary.org',
  crypt('MockPassword123!', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"name": "Mock User"}',
  false
)
ON CONFLICT (id) DO NOTHING;

-- Link mock user to first active member in user_roles
-- NOTE: This updates the existing user_roles entry for the first active member
UPDATE user_roles
SET user_id = '00000000-0000-0000-0000-000000000001'
WHERE member_id = (SELECT id FROM members WHERE active = true ORDER BY created_at LIMIT 1);

-- Verification query
SELECT
  u.id as user_id,
  u.email,
  ur.member_id,
  m.name as member_name,
  ur.role
FROM auth.users u
JOIN user_roles ur ON ur.user_id = u.id
JOIN members m ON m.id = ur.member_id
WHERE u.id = '00000000-0000-0000-0000-000000000001';

-- TODO: Before production deployment:
-- 1. Remove this mock user from auth.users
-- 2. Implement proper Supabase Auth signup/login flow
-- 3. Update useAuth.ts to remove mock auth fallback
-- 4. Restore proper RLS policies on meeting_rsvps (from migration 055)
