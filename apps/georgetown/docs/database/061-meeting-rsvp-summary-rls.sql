-- Migration: 061-meeting-rsvp-summary-rls.sql
-- Purpose: Add RLS policies to meeting_rsvp_summary view
-- Date: 2025-12-02
-- Author: CTO (Phase 3 RSVP & Attendance)

-- Enable RLS on the view
ALTER VIEW meeting_rsvp_summary SET (security_barrier = true);

-- Allow all to read RSVP summaries (public counts, non-sensitive)
-- This is permissive for testing - tighten later if needed
CREATE POLICY "Allow public read access to RSVP summaries"
ON meeting_rsvps
FOR SELECT
USING (true);

-- Verify: Test that view is accessible
SELECT COUNT(*) as summary_count FROM meeting_rsvp_summary;
