-- Migration: 062-fix-rsvp-summary-all-types.sql
-- Purpose: Update meeting_rsvp_summary view to include ALL meeting types with RSVPs
-- Date: 2025-12-02
-- Author: CTO (Phase 3 RSVP & Attendance Bug Fix)
-- Issue: View was filtering to club_meeting only, excluding club_assembly, board_meeting, etc.

-- Drop existing view
DROP VIEW IF EXISTS meeting_rsvp_summary;

-- Recreate view with all RSVP-enabled event types
CREATE VIEW meeting_rsvp_summary AS
SELECT
  e.id AS event_id,
  e.title AS event_title,
  e.date AS event_date,
  e.location_id AS event_location_id,
  COUNT(*) FILTER (WHERE r.status = 'attending') AS attending_count,
  COUNT(*) FILTER (WHERE r.status = 'not_attending') AS not_attending_count,
  COUNT(*) FILTER (WHERE r.status = 'maybe') AS maybe_count,
  COUNT(*) FILTER (WHERE r.status = 'no_response') AS no_response_count,
  (SELECT COUNT(*) FROM members WHERE active = true) AS total_active_members,
  COALESCE(SUM(r.guest_count) FILTER (WHERE r.status = 'attending'), 0) AS total_guests,
  COUNT(*) FILTER (WHERE r.status = 'attending') + COALESCE(SUM(r.guest_count) FILTER (WHERE r.status = 'attending'), 0) AS total_headcount,
  ROUND(
    COUNT(*) FILTER (WHERE r.status != 'no_response')::NUMERIC /
    NULLIF(COUNT(*), 0)::NUMERIC * 100,
    1
  ) AS response_rate_pct,
  COUNT(*) FILTER (WHERE r.dietary_notes IS NOT NULL AND r.dietary_notes != '') AS dietary_restrictions_count
FROM events e
LEFT JOIN meeting_rsvps r ON e.id = r.event_id
WHERE e.type IN (
  'club_meeting',
  'club_assembly',
  'board_meeting',
  'committee_meeting',
  'club_event',
  'service_project'
)
GROUP BY e.id, e.title, e.date, e.location_id
ORDER BY e.date;

-- Verify: Check AGM 2025 now shows RSVP data
SELECT
  event_title,
  attending_count,
  total_headcount
FROM meeting_rsvp_summary
WHERE event_title = 'AGM 2025';
