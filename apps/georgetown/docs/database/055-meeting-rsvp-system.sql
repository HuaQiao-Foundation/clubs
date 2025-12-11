-- Migration 055: Meeting RSVP System
-- Purpose: Enable members to RSVP for club meetings (meal planning, venue setup)
-- Date: 2025-12-02
-- Author: CTO (Claude Code)
-- Dependencies: Migration 054 (user_roles), events table

-- ============================================================================
-- OVERVIEW
-- ============================================================================
-- This migration creates the RSVP system for club meetings.
-- Features:
-- - Members RSVP: Attending / Not Attending / Maybe / No Response
-- - Guest count tracking (for meal planning)
-- - Dietary restrictions/notes
-- - Real-time updates via Supabase subscriptions
-- - Admin dashboard showing who's coming

-- ============================================================================
-- 1. MEETING RSVPS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS meeting_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,

  -- RSVP status
  status TEXT NOT NULL DEFAULT 'no_response'
    CHECK (status IN ('attending', 'not_attending', 'maybe', 'no_response')),

  -- Guest information
  guest_count INTEGER DEFAULT 0 CHECK (guest_count >= 0 AND guest_count <= 10),
  guest_names TEXT[], -- Array of guest names (optional)

  -- Dietary restrictions
  dietary_notes TEXT,

  -- Special requests
  special_requests TEXT, -- "Need vegetarian meal", "Wheelchair accessible seating", etc.

  -- Metadata
  responded_at TIMESTAMPTZ, -- When they first responded (not no_response)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  UNIQUE(event_id, member_id) -- One RSVP per member per event
);

-- Indexes for performance
CREATE INDEX idx_meeting_rsvps_event ON meeting_rsvps(event_id);
CREATE INDEX idx_meeting_rsvps_member ON meeting_rsvps(member_id);
CREATE INDEX idx_meeting_rsvps_status ON meeting_rsvps(status);
CREATE INDEX idx_meeting_rsvps_event_status ON meeting_rsvps(event_id, status); -- For "Who's attending this meeting?"

-- Comments
COMMENT ON TABLE meeting_rsvps IS 'Member RSVPs for club meetings (meal planning, headcount)';
COMMENT ON COLUMN meeting_rsvps.status IS 'attending (confirmed yes), not_attending (confirmed no), maybe (tentative), no_response (not yet responded)';
COMMENT ON COLUMN meeting_rsvps.guest_count IS 'Number of non-member guests attending (max 10 per member)';
COMMENT ON COLUMN meeting_rsvps.guest_names IS 'Optional array of guest names for nametags/registration';
COMMENT ON COLUMN meeting_rsvps.dietary_notes IS 'Dietary restrictions: vegetarian, vegan, gluten-free, allergies, etc.';
COMMENT ON COLUMN meeting_rsvps.responded_at IS 'Timestamp when member first responded (changed from no_response)';

-- ============================================================================
-- 2. RSVP SUMMARY VIEW (FOR ADMIN DASHBOARD)
-- ============================================================================
-- Real-time view of RSVP counts per event

CREATE OR REPLACE VIEW meeting_rsvp_summary AS
SELECT
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,
  e.location AS event_location,

  -- RSVP counts
  COUNT(*) FILTER (WHERE r.status = 'attending') AS attending_count,
  COUNT(*) FILTER (WHERE r.status = 'not_attending') AS not_attending_count,
  COUNT(*) FILTER (WHERE r.status = 'maybe') AS maybe_count,
  COUNT(*) FILTER (WHERE r.status = 'no_response') AS no_response_count,

  -- Total members
  (SELECT COUNT(*) FROM members WHERE status = 'active') AS total_active_members,

  -- Guest count
  COALESCE(SUM(r.guest_count) FILTER (WHERE r.status = 'attending'), 0) AS total_guests,

  -- Total headcount (attending members + guests)
  COUNT(*) FILTER (WHERE r.status = 'attending') +
    COALESCE(SUM(r.guest_count) FILTER (WHERE r.status = 'attending'), 0) AS total_headcount,

  -- Response rate
  ROUND(
    (COUNT(*) FILTER (WHERE r.status != 'no_response')::DECIMAL /
    NULLIF(COUNT(*), 0) * 100),
    1
  ) AS response_rate_pct,

  -- Dietary restrictions count
  COUNT(*) FILTER (WHERE r.dietary_notes IS NOT NULL AND r.dietary_notes != '') AS dietary_restrictions_count

FROM events e
LEFT JOIN meeting_rsvps r ON e.id = r.event_id
WHERE e.event_type = 'club_meeting' -- Only for club meetings
GROUP BY e.id, e.title, e.date, e.location
ORDER BY e.date ASC;

COMMENT ON VIEW meeting_rsvp_summary IS 'Real-time RSVP summary per meeting (headcount for meal planning)';

-- ============================================================================
-- 3. MEMBER RSVP HISTORY VIEW
-- ============================================================================
-- View member's RSVP history (for attendance tracking correlation)

CREATE OR REPLACE VIEW member_rsvp_history AS
SELECT
  m.id AS member_id,
  m.name AS member_name,
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,
  r.status AS rsvp_status,
  r.guest_count,
  r.responded_at,

  -- Did they attend? (will join with attendance_records in migration 056)
  NULL::BOOLEAN AS actually_attended -- Placeholder for future join

FROM members m
CROSS JOIN events e
LEFT JOIN meeting_rsvps r ON m.id = r.member_id AND e.id = r.event_id
WHERE e.event_type = 'club_meeting'
ORDER BY m.name, e.date DESC;

COMMENT ON VIEW member_rsvp_history IS 'Member RSVP history across all meetings (for reliability analysis)';

-- ============================================================================
-- 4. FUNCTIONS FOR RSVP MANAGEMENT
-- ============================================================================

-- Function: Auto-create RSVPs for new meetings
CREATE OR REPLACE FUNCTION create_rsvps_for_new_meeting()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create RSVPs for club meetings
  IF NEW.event_type = 'club_meeting' THEN
    INSERT INTO meeting_rsvps (event_id, member_id, status)
    SELECT NEW.id, m.id, 'no_response'
    FROM members m
    WHERE m.status = 'active'
    ON CONFLICT (event_id, member_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_rsvps_for_new_meeting IS 'Auto-create RSVP records for all active members when new club meeting is created';

-- Trigger: Create RSVPs when new club meeting added
CREATE TRIGGER trigger_create_rsvps_for_meeting
  AFTER INSERT ON events
  FOR EACH ROW
  EXECUTE FUNCTION create_rsvps_for_new_meeting();

-- Function: Update responded_at timestamp
CREATE OR REPLACE FUNCTION update_rsvp_responded_at()
RETURNS TRIGGER AS $$
BEGIN
  -- If status changed from 'no_response' to anything else, set responded_at
  IF OLD.status = 'no_response' AND NEW.status != 'no_response' AND NEW.responded_at IS NULL THEN
    NEW.responded_at = NOW();
  END IF;

  -- If status changed back to 'no_response', clear responded_at
  IF NEW.status = 'no_response' THEN
    NEW.responded_at = NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_rsvp_responded_at IS 'Set responded_at timestamp when member first responds to RSVP';

-- Trigger: Update responded_at on status change
CREATE TRIGGER trigger_update_rsvp_responded_at
  BEFORE UPDATE ON meeting_rsvps
  FOR EACH ROW
  EXECUTE FUNCTION update_rsvp_responded_at();

-- Function: Send RSVP reminder (placeholder for future email integration)
CREATE OR REPLACE FUNCTION send_rsvp_reminder(event_uuid UUID)
RETURNS TABLE(member_id UUID, member_name TEXT, member_email TEXT) AS $$
  SELECT m.id, m.name, m.email
  FROM members m
  INNER JOIN meeting_rsvps r ON m.id = r.member_id
  WHERE r.event_id = event_uuid
    AND r.status = 'no_response'
    AND m.status = 'active'
    AND m.email IS NOT NULL
  ORDER BY m.name;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION send_rsvp_reminder IS 'Get list of members who have not responded to RSVP (for email reminders)';

-- ============================================================================
-- 5. ROW LEVEL SECURITY POLICIES
-- ============================================================================

ALTER TABLE meeting_rsvps ENABLE ROW LEVEL SECURITY;

-- Policy: Members can view all RSVPs (to see who else is coming)
CREATE POLICY "Members can view all RSVPs"
  ON meeting_rsvps FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('member', 'chair', 'officer', 'admin')
    )
  );

-- Policy: Members can update their own RSVP
CREATE POLICY "Members can update own RSVP"
  ON meeting_rsvps FOR UPDATE
  USING (
    member_id IN (
      SELECT member_id FROM user_roles WHERE user_id = auth.uid()
    )
  );

-- Policy: Members can create their own RSVP (if auto-creation didn't happen)
CREATE POLICY "Members can create own RSVP"
  ON meeting_rsvps FOR INSERT
  WITH CHECK (
    member_id IN (
      SELECT member_id FROM user_roles WHERE user_id = auth.uid()
    )
  );

-- Policy: Officers/Admins can create/update/delete any RSVP
CREATE POLICY "Officers can manage all RSVPs"
  ON meeting_rsvps FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('officer', 'admin')
    )
  );

-- ============================================================================
-- 6. TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE TRIGGER update_meeting_rsvps_updated_at
  BEFORE UPDATE ON meeting_rsvps
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. SAMPLE DATA (FOR TESTING)
-- ============================================================================
-- Uncomment to insert sample RSVPs for testing

-- INSERT INTO meeting_rsvps (event_id, member_id, status, guest_count, dietary_notes)
-- SELECT
--   e.id,
--   m.id,
--   CASE (random() * 10)::INT
--     WHEN 0, 1, 2, 3, 4, 5, 6, 7 THEN 'attending'
--     WHEN 8 THEN 'not_attending'
--     WHEN 9 THEN 'maybe'
--     ELSE 'no_response'
--   END,
--   CASE WHEN random() < 0.2 THEN (random() * 2)::INT ELSE 0 END,
--   CASE WHEN random() < 0.1 THEN 'Vegetarian' ELSE NULL END
-- FROM events e
-- CROSS JOIN members m
-- WHERE e.event_type = 'club_meeting'
--   AND m.status = 'active'
-- ON CONFLICT (event_id, member_id) DO NOTHING;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To rollback this migration:
-- DROP TRIGGER IF EXISTS update_meeting_rsvps_updated_at ON meeting_rsvps;
-- DROP TRIGGER IF EXISTS trigger_update_rsvp_responded_at ON meeting_rsvps;
-- DROP TRIGGER IF EXISTS trigger_create_rsvps_for_meeting ON events;
-- DROP FUNCTION IF EXISTS send_rsvp_reminder(UUID);
-- DROP FUNCTION IF EXISTS update_rsvp_responded_at();
-- DROP FUNCTION IF EXISTS create_rsvps_for_new_meeting();
-- DROP VIEW IF EXISTS member_rsvp_history;
-- DROP VIEW IF EXISTS meeting_rsvp_summary;
-- DROP TABLE IF EXISTS meeting_rsvps CASCADE;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after migration to verify success:
-- SELECT * FROM meeting_rsvps LIMIT 10;
-- SELECT * FROM meeting_rsvp_summary;
-- SELECT * FROM member_rsvp_history WHERE member_id = '[some-member-uuid]' LIMIT 10;
-- SELECT * FROM send_rsvp_reminder('[some-event-uuid]');
