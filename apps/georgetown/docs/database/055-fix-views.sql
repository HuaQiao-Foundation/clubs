-- Fix Migration 055: Correct views and functions for actual schema
-- Events table has 'type' column (not 'event_type') and 'location_id' (not 'location')
-- Members table has 'active' boolean (not 'status' text)

-- Drop existing broken function
DROP FUNCTION IF EXISTS send_rsvp_reminder(UUID);

-- ============================================================================
-- 2. RSVP SUMMARY VIEW (FOR ADMIN DASHBOARD) - FIXED
-- ============================================================================

CREATE OR REPLACE VIEW meeting_rsvp_summary AS
SELECT
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,
  e.location_id AS event_location_id,

  -- RSVP counts
  COUNT(*) FILTER (WHERE r.status = 'attending') AS attending_count,
  COUNT(*) FILTER (WHERE r.status = 'not_attending') AS not_attending_count,
  COUNT(*) FILTER (WHERE r.status = 'maybe') AS maybe_count,
  COUNT(*) FILTER (WHERE r.status = 'no_response') AS no_response_count,

  -- Total members
  (SELECT COUNT(*) FROM members WHERE active = true) AS total_active_members,

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
WHERE e.type = 'club_meeting' -- Fixed: 'type' not 'event_type'
GROUP BY e.id, e.title, e.date, e.location_id
ORDER BY e.date ASC;

COMMENT ON VIEW meeting_rsvp_summary IS 'Real-time RSVP summary per meeting (headcount for meal planning)';

-- ============================================================================
-- 3. MEMBER RSVP HISTORY VIEW - FIXED
-- ============================================================================

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
WHERE e.type = 'club_meeting' -- Fixed: 'type' not 'event_type'
ORDER BY m.name, e.date DESC;

COMMENT ON VIEW member_rsvp_history IS 'Member RSVP history across all meetings (for reliability analysis)';

-- ============================================================================
-- 4. FIXED FUNCTION: Send RSVP reminder
-- ============================================================================

CREATE OR REPLACE FUNCTION send_rsvp_reminder(event_uuid UUID)
RETURNS TABLE(member_id UUID, member_name TEXT, member_email TEXT) AS $$
  SELECT m.id, m.name, m.email
  FROM members m
  INNER JOIN meeting_rsvps r ON m.id = r.member_id
  WHERE r.event_id = event_uuid
    AND r.status = 'no_response'
    AND m.active = true  -- Fixed: 'active' boolean not 'status' text
    AND m.email IS NOT NULL
  ORDER BY m.name;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION send_rsvp_reminder IS 'Get list of members who have not responded to RSVP (for email reminders)';

-- ============================================================================
-- 5. FIX AUTO-CREATE FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION create_rsvps_for_new_meeting()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create RSVPs for club meetings
  IF NEW.type = 'club_meeting' THEN  -- Fixed: 'type' not 'event_type'
    INSERT INTO meeting_rsvps (event_id, member_id, status)
    SELECT NEW.id, m.id, 'no_response'
    FROM members m
    WHERE m.active = true  -- Fixed: 'active' boolean not 'status' text
    ON CONFLICT (event_id, member_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_rsvps_for_new_meeting IS 'Auto-create RSVP records for all active members when new club meeting is created';
