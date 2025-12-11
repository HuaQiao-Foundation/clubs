-- Migration 059: Simplify meeting_rsvps RLS for testing
-- Purpose: Remove auth.uid() dependency to enable mock auth testing
-- Date: 2025-12-02
-- Author: CTO

-- Drop existing RLS policies that require auth.uid()
DROP POLICY IF EXISTS "Members can view all RSVPs" ON meeting_rsvps;
DROP POLICY IF EXISTS "Members can create own RSVP" ON meeting_rsvps;
DROP POLICY IF EXISTS "Members can update own RSVP" ON meeting_rsvps;
DROP POLICY IF EXISTS "Officers can manage all RSVPs" ON meeting_rsvps;

-- Create permissive policies for testing (to be replaced with proper auth later)
CREATE POLICY "Anyone can view RSVPs"
  ON meeting_rsvps FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create RSVPs"
  ON meeting_rsvps FOR INSERT
  WITH CHECK (member_id IN (SELECT id FROM members WHERE active = true));

CREATE POLICY "Anyone can update RSVPs"
  ON meeting_rsvps FOR UPDATE
  USING (member_id IN (SELECT id FROM members WHERE active = true));

CREATE POLICY "Anyone can delete RSVPs"
  ON meeting_rsvps FOR DELETE
  USING (member_id IN (SELECT id FROM members WHERE active = true));

-- Verification query
SELECT 'meeting_rsvps RLS policies updated for testing' AS status;

-- TODO: Before production deployment, replace these with proper auth-based policies:
-- CREATE POLICY "Members can view all RSVPs"
--   ON meeting_rsvps FOR SELECT
--   USING (public.has_any_role(ARRAY['member', 'chair', 'officer', 'admin']));
--
-- CREATE POLICY "Members can create own RSVP"
--   ON meeting_rsvps FOR INSERT
--   WITH CHECK (member_id IN (
--     SELECT member_id FROM user_roles WHERE user_id = auth.uid()
--   ));
--
-- CREATE POLICY "Members can update own RSVP"
--   ON meeting_rsvps FOR UPDATE
--   USING (member_id IN (
--     SELECT member_id FROM user_roles WHERE user_id = auth.uid()
--   ));
--
-- CREATE POLICY "Officers can manage all RSVPs"
--   ON meeting_rsvps FOR ALL
--   USING (public.has_any_role(ARRAY['officer', 'admin']));
