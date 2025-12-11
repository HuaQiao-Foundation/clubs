-- Migration 012: Add citizenship field to members table
-- Description: Add citizenship field for member demographics (gender already exists)

-- Add citizenship field (free text for country name)
ALTER TABLE members
ADD COLUMN citizenship TEXT;

-- Check what gender values currently exist
SELECT DISTINCT gender FROM members WHERE gender IS NOT NULL;

-- Note: If you see values other than 'Female' or 'Male', update them first before adding constraint
-- Example: UPDATE members SET gender = NULL WHERE gender NOT IN ('Female', 'Male');
-- Then you can add the constraint:
-- ALTER TABLE members ADD CONSTRAINT members_gender_check CHECK (gender IN ('Female', 'Male'));

-- Verification query
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'members'
  AND column_name IN ('gender', 'citizenship')
ORDER BY ordinal_position;
