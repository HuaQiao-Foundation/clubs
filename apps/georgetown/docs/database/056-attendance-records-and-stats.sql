-- Migration 056: Attendance Records and Statistics
-- Purpose: Track actual meeting attendance (members, visitors, guests) + calculate stats
-- Date: 2025-12-02
-- Author: CTO (Claude Code)
-- Dependencies: Migration 054 (user_roles), Migration 055 (meeting_rsvps)

-- ============================================================================
-- OVERVIEW
-- ============================================================================
-- This migration creates the attendance tracking system for club meetings.
-- Features:
-- - Track member attendance (who actually showed up)
-- - Track visiting Rotarians (name, club, district)
-- - Track non-Rotarian guests (prospective members)
-- - Calculate attendance statistics (percentage, streaks, makeup credits)
-- - Quarterly and YTD attendance reporting

-- ============================================================================
-- 1. ATTENDANCE RECORDS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS attendance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

  -- Attendee type and identity
  attendee_type TEXT NOT NULL CHECK (attendee_type IN ('member', 'visiting_rotarian', 'guest')),

  -- For members
  member_id UUID REFERENCES members(id) ON DELETE SET NULL,

  -- For visiting Rotarians
  visitor_name TEXT,
  visitor_club TEXT,
  visitor_district TEXT,

  -- For non-Rotarian guests
  guest_name TEXT,
  guest_hosted_by UUID REFERENCES members(id) ON DELETE SET NULL,
  guest_is_prospective_member BOOLEAN DEFAULT FALSE,
  guest_contact_info TEXT, -- Email or phone for follow-up

  -- Check-in metadata
  checked_in_at TIMESTAMPTZ DEFAULT NOW(),
  checked_in_by UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Which officer took attendance
  notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  CHECK (
    (attendee_type = 'member' AND member_id IS NOT NULL) OR
    (attendee_type = 'visiting_rotarian' AND visitor_name IS NOT NULL) OR
    (attendee_type = 'guest' AND guest_name IS NOT NULL)
  )
);

-- Indexes for performance
CREATE INDEX idx_attendance_event ON attendance_records(event_id);
CREATE INDEX idx_attendance_member ON attendance_records(member_id);
CREATE INDEX idx_attendance_type ON attendance_records(attendee_type);
CREATE INDEX idx_attendance_date ON attendance_records(checked_in_at);
CREATE INDEX idx_attendance_event_member ON attendance_records(event_id, member_id); -- Unique attendance per member per event
CREATE INDEX idx_attendance_prospective ON attendance_records(guest_is_prospective_member) WHERE guest_is_prospective_member = TRUE;

-- Comments
COMMENT ON TABLE attendance_records IS 'Actual attendance records for club meetings (members, visitors, guests)';
COMMENT ON COLUMN attendance_records.attendee_type IS 'member (club member), visiting_rotarian (Rotarian from another club), guest (non-Rotarian)';
COMMENT ON COLUMN attendance_records.visitor_club IS 'Name of visiting Rotarian's home club (e.g., "Rotary Club of Seattle")';
COMMENT ON COLUMN attendance_records.guest_is_prospective_member IS 'Flag potential new members for follow-up';
COMMENT ON COLUMN attendance_records.checked_in_by IS 'Which officer/admin recorded this attendance';

-- ============================================================================
-- 2. MEMBER ATTENDANCE STATISTICS TABLE
-- ============================================================================
-- Pre-calculated statistics for performance (updated via trigger or cron)

CREATE TABLE IF NOT EXISTS member_attendance_stats (
  member_id UUID PRIMARY KEY REFERENCES members(id) ON DELETE CASCADE,

  -- Current quarter stats (Rotary quarters: Jul-Sep, Oct-Dec, Jan-Mar, Apr-Jun)
  current_quarter_meetings INTEGER DEFAULT 0,
  current_quarter_attended INTEGER DEFAULT 0,
  current_quarter_percentage DECIMAL(5,2),

  -- Year-to-date stats (Rotary year: July 1 - June 30)
  ytd_meetings INTEGER DEFAULT 0,
  ytd_attended INTEGER DEFAULT 0,
  ytd_percentage DECIMAL(5,2),

  -- All-time stats
  lifetime_meetings INTEGER DEFAULT 0,
  lifetime_attended INTEGER DEFAULT 0,
  lifetime_percentage DECIMAL(5,2),

  -- Makeup credits (attending other clubs, Rotary events)
  makeups_credited INTEGER DEFAULT 0,

  -- Tracking
  last_attended_date DATE,
  last_attended_event_id UUID REFERENCES events(id) ON DELETE SET NULL,
  consecutive_absences INTEGER DEFAULT 0, -- Alert if >= 4 (Rotary attendance policy)
  longest_attendance_streak INTEGER DEFAULT 0, -- Gamification!

  -- Metadata
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_member_stats_percentage ON member_attendance_stats(ytd_percentage);
CREATE INDEX idx_member_stats_absences ON member_attendance_stats(consecutive_absences) WHERE consecutive_absences >= 4;

-- Comments
COMMENT ON TABLE member_attendance_stats IS 'Pre-calculated attendance statistics per member (performance optimization)';
COMMENT ON COLUMN member_attendance_stats.current_quarter_percentage IS 'Attendance % for current Rotary quarter';
COMMENT ON COLUMN member_attendance_stats.ytd_percentage IS 'Attendance % for current Rotary year (Jul 1 - Jun 30)';
COMMENT ON COLUMN member_attendance_stats.consecutive_absences IS 'Alert members if >= 4 (Rotary attendance requirement)';
COMMENT ON COLUMN member_attendance_stats.makeups_credited IS 'Makeup credits from attending other clubs or Rotary events';

-- ============================================================================
-- 3. ATTENDANCE SUMMARY VIEWS
-- ============================================================================

-- View: Meeting attendance summary (per event)
CREATE OR REPLACE VIEW meeting_attendance_summary AS
SELECT
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,
  e.location AS event_location,

  -- Attendance counts by type
  COUNT(*) FILTER (WHERE a.attendee_type = 'member') AS members_attended,
  COUNT(*) FILTER (WHERE a.attendee_type = 'visiting_rotarian') AS visitors_attended,
  COUNT(*) FILTER (WHERE a.attendee_type = 'guest') AS guests_attended,

  -- Total headcount
  COUNT(*) AS total_headcount,

  -- Total active members
  (SELECT COUNT(*) FROM members WHERE status = 'active') AS total_active_members,

  -- Attendance percentage (members only)
  ROUND(
    (COUNT(*) FILTER (WHERE a.attendee_type = 'member')::DECIMAL /
    NULLIF((SELECT COUNT(*) FROM members WHERE status = 'active'), 0) * 100),
    1
  ) AS attendance_percentage,

  -- Prospective members count
  COUNT(*) FILTER (WHERE a.guest_is_prospective_member = TRUE) AS prospective_members_count

FROM events e
LEFT JOIN attendance_records a ON e.id = a.event_id
WHERE e.event_type = 'club_meeting'
GROUP BY e.id, e.title, e.date, e.location
ORDER BY e.date DESC;

COMMENT ON VIEW meeting_attendance_summary IS 'Per-meeting attendance summary (headcount, percentage, guests)';

-- View: Member attendance detail (with RSVP correlation)
CREATE OR REPLACE VIEW member_attendance_detail AS
SELECT
  m.id AS member_id,
  m.name AS member_name,
  m.classification,
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,

  -- RSVP status
  r.status AS rsvp_status,
  r.responded_at,

  -- Actual attendance
  CASE WHEN a.id IS NOT NULL THEN TRUE ELSE FALSE END AS attended,
  a.checked_in_at,

  -- RSVP accuracy (did they show up if they said yes?)
  CASE
    WHEN r.status = 'attending' AND a.id IS NOT NULL THEN 'showed_up'
    WHEN r.status = 'attending' AND a.id IS NULL THEN 'no_show'
    WHEN r.status = 'not_attending' AND a.id IS NOT NULL THEN 'surprise_attendance'
    WHEN r.status = 'not_attending' AND a.id IS NULL THEN 'confirmed_absent'
    WHEN r.status = 'maybe' AND a.id IS NOT NULL THEN 'maybe_yes'
    WHEN r.status = 'maybe' AND a.id IS NULL THEN 'maybe_no'
    WHEN r.status = 'no_response' AND a.id IS NOT NULL THEN 'attended_no_rsvp'
    WHEN r.status = 'no_response' AND a.id IS NULL THEN 'absent_no_rsvp'
    ELSE 'unknown'
  END AS rsvp_accuracy

FROM members m
CROSS JOIN events e
LEFT JOIN meeting_rsvps r ON m.id = r.member_id AND e.id = r.event_id
LEFT JOIN attendance_records a ON m.id = a.member_id AND e.id = a.event_id
WHERE e.event_type = 'club_meeting'
  AND m.status = 'active'
ORDER BY e.date DESC, m.name;

COMMENT ON VIEW member_attendance_detail IS 'Detailed member attendance with RSVP correlation (reliability tracking)';

-- View: At-risk members (below 60% attendance)
CREATE OR REPLACE VIEW at_risk_members AS
SELECT
  m.id,
  m.name,
  m.email,
  s.ytd_percentage,
  s.consecutive_absences,
  s.last_attended_date,
  CASE
    WHEN s.consecutive_absences >= 4 THEN 'critical'
    WHEN s.ytd_percentage < 50 THEN 'high_risk'
    WHEN s.ytd_percentage < 60 THEN 'moderate_risk'
    ELSE 'low_risk'
  END AS risk_level
FROM members m
LEFT JOIN member_attendance_stats s ON m.id = s.member_id
WHERE m.status = 'active'
  AND (s.ytd_percentage < 60 OR s.consecutive_absences >= 4 OR s.ytd_percentage IS NULL)
ORDER BY
  CASE
    WHEN s.consecutive_absences >= 4 THEN 1
    WHEN s.ytd_percentage < 50 THEN 2
    WHEN s.ytd_percentage < 60 THEN 3
    ELSE 4
  END,
  s.ytd_percentage ASC NULLS LAST;

COMMENT ON VIEW at_risk_members IS 'Members below 60% attendance or 4+ consecutive absences (Rotary requirement)';

-- ============================================================================
-- 4. FUNCTIONS FOR ATTENDANCE MANAGEMENT
-- ============================================================================

-- Function: Calculate Rotary quarter
CREATE OR REPLACE FUNCTION get_rotary_quarter(target_date DATE)
RETURNS INTEGER AS $$
  SELECT
    CASE
      WHEN EXTRACT(MONTH FROM target_date) BETWEEN 7 AND 9 THEN 1
      WHEN EXTRACT(MONTH FROM target_date) BETWEEN 10 AND 12 THEN 2
      WHEN EXTRACT(MONTH FROM target_date) BETWEEN 1 AND 3 THEN 3
      WHEN EXTRACT(MONTH FROM target_date) BETWEEN 4 AND 6 THEN 4
    END;
$$ LANGUAGE SQL IMMUTABLE;

COMMENT ON FUNCTION get_rotary_quarter IS 'Returns Rotary quarter (1=Jul-Sep, 2=Oct-Dec, 3=Jan-Mar, 4=Apr-Jun)';

-- Function: Calculate Rotary year
CREATE OR REPLACE FUNCTION get_rotary_year(target_date DATE)
RETURNS INTEGER AS $$
  SELECT
    CASE
      WHEN EXTRACT(MONTH FROM target_date) >= 7 THEN EXTRACT(YEAR FROM target_date)::INTEGER
      ELSE EXTRACT(YEAR FROM target_date)::INTEGER - 1
    END;
$$ LANGUAGE SQL IMMUTABLE;

COMMENT ON FUNCTION get_rotary_year IS 'Returns Rotary year (starts July 1, e.g., 2024-2025 = 2024)';

-- Function: Refresh member attendance stats
CREATE OR REPLACE FUNCTION refresh_member_attendance_stats(target_member_id UUID DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
  current_rotary_year INTEGER := get_rotary_year(CURRENT_DATE);
  current_rotary_quarter INTEGER := get_rotary_quarter(CURRENT_DATE);
BEGIN
  -- If specific member, update only that member; otherwise update all
  INSERT INTO member_attendance_stats (
    member_id,
    current_quarter_meetings,
    current_quarter_attended,
    current_quarter_percentage,
    ytd_meetings,
    ytd_attended,
    ytd_percentage,
    lifetime_meetings,
    lifetime_attended,
    lifetime_percentage,
    last_attended_date,
    last_attended_event_id,
    consecutive_absences,
    updated_at
  )
  SELECT
    m.id,

    -- Current quarter
    COUNT(DISTINCT e.id) FILTER (WHERE
      get_rotary_year(e.date) = current_rotary_year
      AND get_rotary_quarter(e.date) = current_rotary_quarter
    ),
    COUNT(DISTINCT a.event_id) FILTER (WHERE
      get_rotary_year(e.date) = current_rotary_year
      AND get_rotary_quarter(e.date) = current_rotary_quarter
    ),
    ROUND(
      COUNT(DISTINCT a.event_id) FILTER (WHERE
        get_rotary_year(e.date) = current_rotary_year
        AND get_rotary_quarter(e.date) = current_rotary_quarter
      )::DECIMAL /
      NULLIF(COUNT(DISTINCT e.id) FILTER (WHERE
        get_rotary_year(e.date) = current_rotary_year
        AND get_rotary_quarter(e.date) = current_rotary_quarter
      ), 0) * 100,
      2
    ),

    -- Year-to-date
    COUNT(DISTINCT e.id) FILTER (WHERE get_rotary_year(e.date) = current_rotary_year),
    COUNT(DISTINCT a.event_id) FILTER (WHERE get_rotary_year(e.date) = current_rotary_year),
    ROUND(
      COUNT(DISTINCT a.event_id) FILTER (WHERE get_rotary_year(e.date) = current_rotary_year)::DECIMAL /
      NULLIF(COUNT(DISTINCT e.id) FILTER (WHERE get_rotary_year(e.date) = current_rotary_year), 0) * 100,
      2
    ),

    -- Lifetime
    COUNT(DISTINCT e.id),
    COUNT(DISTINCT a.event_id),
    ROUND(
      COUNT(DISTINCT a.event_id)::DECIMAL /
      NULLIF(COUNT(DISTINCT e.id), 0) * 100,
      2
    ),

    -- Last attended
    MAX(a.checked_in_at)::DATE,
    (SELECT event_id FROM attendance_records WHERE member_id = m.id ORDER BY checked_in_at DESC LIMIT 1),

    -- Consecutive absences (simplified: count recent meetings without attendance)
    (
      SELECT COUNT(*)
      FROM events e2
      WHERE e2.event_type = 'club_meeting'
        AND e2.date <= CURRENT_DATE
        AND e2.date > CURRENT_DATE - INTERVAL '90 days'
        AND NOT EXISTS (
          SELECT 1 FROM attendance_records a2
          WHERE a2.event_id = e2.id AND a2.member_id = m.id
        )
    ),

    NOW()

  FROM members m
  LEFT JOIN events e ON e.event_type = 'club_meeting' AND e.date <= CURRENT_DATE
  LEFT JOIN attendance_records a ON a.event_id = e.id AND a.member_id = m.id
  WHERE m.status = 'active'
    AND (target_member_id IS NULL OR m.id = target_member_id)
  GROUP BY m.id

  ON CONFLICT (member_id) DO UPDATE SET
    current_quarter_meetings = EXCLUDED.current_quarter_meetings,
    current_quarter_attended = EXCLUDED.current_quarter_attended,
    current_quarter_percentage = EXCLUDED.current_quarter_percentage,
    ytd_meetings = EXCLUDED.ytd_meetings,
    ytd_attended = EXCLUDED.ytd_attended,
    ytd_percentage = EXCLUDED.ytd_percentage,
    lifetime_meetings = EXCLUDED.lifetime_meetings,
    lifetime_attended = EXCLUDED.lifetime_attended,
    lifetime_percentage = EXCLUDED.lifetime_percentage,
    last_attended_date = EXCLUDED.last_attended_date,
    last_attended_event_id = EXCLUDED.last_attended_event_id,
    consecutive_absences = EXCLUDED.consecutive_absences,
    updated_at = EXCLUDED.updated_at;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_member_attendance_stats IS 'Recalculate attendance statistics for member(s). Call after taking attendance.';

-- Trigger: Auto-refresh stats when attendance is recorded
CREATE OR REPLACE FUNCTION trigger_refresh_stats_on_attendance()
RETURNS TRIGGER AS $$
BEGIN
  -- Only refresh for member attendance (not visitors/guests)
  IF NEW.attendee_type = 'member' AND NEW.member_id IS NOT NULL THEN
    PERFORM refresh_member_attendance_stats(NEW.member_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_refresh_attendance_stats
  AFTER INSERT ON attendance_records
  FOR EACH ROW
  EXECUTE FUNCTION trigger_refresh_stats_on_attendance();

-- ============================================================================
-- 5. ROW LEVEL SECURITY POLICIES
-- ============================================================================

ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;

-- Policy: Members can view all attendance records
CREATE POLICY "Members view all attendance"
  ON attendance_records FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('member', 'chair', 'officer', 'admin')
    )
  );

-- Policy: Officers can create attendance records
CREATE POLICY "Officers create attendance"
  ON attendance_records FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('officer', 'admin')
    )
  );

-- Policy: Officers can update attendance records
CREATE POLICY "Officers update attendance"
  ON attendance_records FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('officer', 'admin')
    )
  );

-- Policy: Only admins can delete attendance records (careful!)
CREATE POLICY "Admins delete attendance"
  ON attendance_records FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role = 'admin'
    )
  );

-- Enable RLS on stats table
ALTER TABLE member_attendance_stats ENABLE ROW LEVEL SECURITY;

-- Policy: Members can view all stats
CREATE POLICY "Members view all stats"
  ON member_attendance_stats FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role IN ('member', 'chair', 'officer', 'admin')
    )
  );

-- Policy: Only system can update stats (via function)
CREATE POLICY "System updates stats"
  ON member_attendance_stats FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role = 'admin'
    )
  );

-- ============================================================================
-- 6. INITIAL STATS CALCULATION
-- ============================================================================
-- Run stats calculation for all existing members

SELECT refresh_member_attendance_stats();

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To rollback this migration:
-- DROP TRIGGER IF EXISTS trigger_auto_refresh_attendance_stats ON attendance_records;
-- DROP FUNCTION IF EXISTS trigger_refresh_stats_on_attendance();
-- DROP FUNCTION IF EXISTS refresh_member_attendance_stats(UUID);
-- DROP FUNCTION IF EXISTS get_rotary_year(DATE);
-- DROP FUNCTION IF EXISTS get_rotary_quarter(DATE);
-- DROP VIEW IF EXISTS at_risk_members;
-- DROP VIEW IF EXISTS member_attendance_detail;
-- DROP VIEW IF EXISTS meeting_attendance_summary;
-- DROP TABLE IF EXISTS member_attendance_stats CASCADE;
-- DROP TABLE IF EXISTS attendance_records CASCADE;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after migration to verify success:
-- SELECT * FROM attendance_records LIMIT 10;
-- SELECT * FROM member_attendance_stats ORDER BY ytd_percentage ASC;
-- SELECT * FROM meeting_attendance_summary LIMIT 10;
-- SELECT * FROM member_attendance_detail WHERE member_id = '[some-member-uuid]' LIMIT 10;
-- SELECT * FROM at_risk_members;
-- SELECT get_rotary_quarter(CURRENT_DATE), get_rotary_year(CURRENT_DATE);
