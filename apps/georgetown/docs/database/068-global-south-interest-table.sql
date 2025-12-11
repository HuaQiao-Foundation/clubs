-- Migration 068: Create Global South Interest Table
-- Purpose: Store expressions of interest from Rotary clubs in the Global South
-- Author: CTO
-- Date: 2025-12-02

-- Create global_south_interest table
CREATE TABLE IF NOT EXISTS global_south_interest (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  club_name TEXT NOT NULL,
  club_location TEXT NOT NULL,
  country TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  message TEXT,
  submitted_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_global_south_interest_country ON global_south_interest(country);
CREATE INDEX IF NOT EXISTS idx_global_south_interest_submitted_at ON global_south_interest(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_global_south_interest_email ON global_south_interest(email);

-- Enable Row Level Security
ALTER TABLE global_south_interest ENABLE ROW LEVEL SECURITY;

-- Policy: Public inserts (form submissions)
CREATE POLICY "Allow public inserts"
  ON global_south_interest
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Policy: Officers and chairs can view all submissions
CREATE POLICY "Officers and chairs can view submissions"
  ON global_south_interest
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role IN ('officer', 'chair')
    )
  );

-- Add table comment
COMMENT ON TABLE global_south_interest IS 'Stores expressions of interest from Rotary clubs in the Global South who want to use the Georgetown club management platform';
COMMENT ON COLUMN global_south_interest.name IS 'Contact person name';
COMMENT ON COLUMN global_south_interest.club_name IS 'Name of the Rotary club';
COMMENT ON COLUMN global_south_interest.club_location IS 'City/region where club is located';
COMMENT ON COLUMN global_south_interest.country IS 'Country where club is located';
COMMENT ON COLUMN global_south_interest.email IS 'Contact email address';
COMMENT ON COLUMN global_south_interest.phone IS 'Contact phone number (optional)';
COMMENT ON COLUMN global_south_interest.message IS 'Additional message from submitter (optional)';
COMMENT ON COLUMN global_south_interest.submitted_at IS 'Timestamp when form was submitted';
COMMENT ON COLUMN global_south_interest.created_at IS 'Timestamp when record was created';
