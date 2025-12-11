-- Migration 013: Add rotary_id field to members table
-- Description: Add Rotary ID Number field for tracking member Rotary International identification

-- Add rotary_id field (text to allow alphanumeric IDs)
ALTER TABLE members
ADD COLUMN rotary_id TEXT;

-- Verification query
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'members'
  AND column_name = 'rotary_id'
ORDER BY ordinal_position;
