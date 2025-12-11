-- Migration 014: Rename 'Alumni' to 'Former Member' in members table
-- This aligns with proper Rotary terminology where "Alumni" refers to
-- former program participants (Youth Exchange, Scholarships, etc.),
-- not former club members.

-- Update any existing 'Alumni' records to 'Former Member'
UPDATE members
SET type = 'Former Member'
WHERE type = 'Alumni';

-- Note: No schema changes needed as the 'type' field is already TEXT
-- and can accommodate the new value
