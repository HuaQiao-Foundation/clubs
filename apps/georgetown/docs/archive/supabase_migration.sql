-- Georgetown Rotary Speaker System - Database Schema Update
-- This migration adds marketing and networking fields to the speakers table

-- Add job_title column
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS job_title TEXT;

-- Add description column for marketing materials
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add primary_url column for website/LinkedIn
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS primary_url TEXT;

-- Add additional_urls column as array for multiple links
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS additional_urls TEXT[];

-- Add is_rotarian column to track Rotary members
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS is_rotarian BOOLEAN DEFAULT FALSE;

-- Add rotary_club column for Rotarian's club name
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS rotary_club TEXT;

-- Add comment to document the schema
COMMENT ON COLUMN speakers.job_title IS 'Speaker professional title';
COMMENT ON COLUMN speakers.description IS 'Speaker background and expertise for marketing materials';
COMMENT ON COLUMN speakers.primary_url IS 'Main website or LinkedIn profile';
COMMENT ON COLUMN speakers.additional_urls IS 'Additional professional links';
COMMENT ON COLUMN speakers.is_rotarian IS 'Whether speaker is a Rotarian';
COMMENT ON COLUMN speakers.rotary_club IS 'Name of Rotary club if speaker is a Rotarian';