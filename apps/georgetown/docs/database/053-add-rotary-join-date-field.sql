-- Migration: Add rotary_join_date field to members table
-- Purpose: Track when member originally joined Rotary (not just Georgetown Rotary)
-- Date: 2025-12-01

-- Add rotary_join_date column to members table
-- This field tracks when the member first joined ANY Rotary club (original join date)
-- The existing member_since field tracks when they joined Georgetown Rotary specifically
ALTER TABLE members
ADD COLUMN IF NOT EXISTS rotary_join_date DATE;

-- Add comment to clarify the field purpose
COMMENT ON COLUMN members.rotary_join_date IS 'Date when member originally joined their first Rotary club (may be different from Georgetown join date)';
COMMENT ON COLUMN members.member_since IS 'Date when member joined Georgetown Rotary Club specifically';

-- Note: Both fields are nullable as historical data may not be available for all members
-- Example usage:
--   - Member joined Rotary Club of Singapore in 2010 → rotary_join_date = '2010-01-15'
--   - Member transferred to Georgetown Rotary in 2020 → member_since = '2020-06-01'
