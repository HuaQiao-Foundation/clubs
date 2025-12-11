-- Migration 018: Annual Rotary Year Timeline System
-- Purpose: Track Georgetown Rotary's institutional memory by Rotary year (July 1 - June 30)
-- Date: 2025-10-13
-- Execute: CEO in Supabase SQL Editor
--
-- Business Objective: Enable officers to review past accomplishments, understand multi-year
-- patterns, and create professional annual reports with minimal manual effort.
--
-- Georgetown Rotary Context:
--   - Club Number: 21331
--   - District: 3300
--   - Charter Date: October 4, 1983
--   - Current Rotary Year: 2025-2026

-- =====================================================
-- ROTARY YEARS TABLE
-- =====================================================
-- Captures club context and leadership themes at three levels:
-- 1. Rotary International President Theme
-- 2. District Governor Theme
-- 3. Club President Theme

CREATE TABLE IF NOT EXISTS rotary_years (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Rotary Year Identifier
  rotary_year TEXT NOT NULL UNIQUE,     -- "2024-2025" format
  start_date DATE NOT NULL,              -- July 1
  end_date DATE NOT NULL,                -- June 30

  -- Club Information (can change over time)
  club_name TEXT NOT NULL,               -- e.g., "Georgetown" (was "Bayan Baru")
  club_number INTEGER NOT NULL,          -- Permanent: 21331
  district_number INTEGER NOT NULL,      -- Current: 3300
  charter_date DATE NOT NULL,            -- October 4, 1983 (club founding)

  -- Club President Theme
  club_president_name TEXT NOT NULL,
  club_president_theme TEXT,
  club_president_theme_logo_url TEXT,    -- Supabase Storage URL

  -- Rotary International President Theme
  ri_president_name TEXT,
  ri_president_theme TEXT,
  ri_president_theme_logo_url TEXT,      -- Supabase Storage URL

  -- District Governor Theme
  dg_name TEXT,
  dg_theme TEXT,
  dg_theme_logo_url TEXT,                -- Supabase Storage URL

  -- Annual Documentation
  summary TEXT,                          -- Executive summary (1-2 paragraphs)
  narrative TEXT,                        -- Full year story (300-500 words)
  highlights JSONB DEFAULT '[]',         -- [{title: "", description: ""}]
  challenges JSONB DEFAULT '[]',         -- [{issue: "", resolution: ""}]
  stats JSONB DEFAULT '{}',              -- {meetings: 0, speakers: 0, projects: 0, volunteer_hours: 0}
  photos JSONB DEFAULT '[]',             -- [{url: "", caption: ""}]

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- EXTEND SERVICE_PROJECTS TABLE
-- =====================================================
-- Add timeline fields to existing service_projects structure

ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS rotary_year_id UUID REFERENCES rotary_years(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS completion_date DATE,
  ADD COLUMN IF NOT EXISTS lessons_learned TEXT,
  ADD COLUMN IF NOT EXISTS would_repeat TEXT CHECK (would_repeat IN ('yes', 'no', 'modified')),
  ADD COLUMN IF NOT EXISTS repeat_recommendations TEXT;

-- =====================================================
-- EXTEND SPEAKERS TABLE
-- =====================================================
-- Link speakers to Rotary years for annual reporting

ALTER TABLE speakers
  ADD COLUMN IF NOT EXISTS rotary_year_id UUID REFERENCES rotary_years(id) ON DELETE SET NULL;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_rotary_years_year ON rotary_years(rotary_year);
CREATE INDEX IF NOT EXISTS idx_rotary_years_club ON rotary_years(club_number);
CREATE INDEX IF NOT EXISTS idx_service_projects_rotary_year ON service_projects(rotary_year_id);
CREATE INDEX IF NOT EXISTS idx_speakers_rotary_year ON speakers(rotary_year_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE rotary_years ENABLE ROW LEVEL SECURITY;

-- Allow public read access to rotary years (club history is public knowledge)
CREATE POLICY "Rotary years are publicly viewable"
  ON rotary_years FOR SELECT
  USING (true);

-- Allow only club officers and committee chairs to modify rotary years
-- Officer roles: President, President-Elect, Immediate Past President, Vice President,
--                Secretary, Treasurer, Sergeant-at-Arms
-- Committee Chair roles: Club Service Chair, Foundation Chair, International Service Chair,
--                       Membership Chair, Public Image Chair, Service Projects Chair, Youth Service Chair
CREATE POLICY "Rotary years are manageable by officers and chairs"
  ON rotary_years FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM members
      WHERE members.email = auth.jwt()->>'email'
      AND members.roles && ARRAY[
        'President', 'President-Elect', 'Immediate Past President', 'Vice President',
        'Secretary', 'Treasurer', 'Sergeant-at-Arms',
        'Club Service Chair', 'Foundation Chair', 'International Service Chair',
        'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
      ]
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM members
      WHERE members.email = auth.jwt()->>'email'
      AND members.roles && ARRAY[
        'President', 'President-Elect', 'Immediate Past President', 'Vice President',
        'Secretary', 'Treasurer', 'Sergeant-at-Arms',
        'Club Service Chair', 'Foundation Chair', 'International Service Chair',
        'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
      ]
    )
  );

-- =====================================================
-- UPDATED_AT TRIGGER
-- =====================================================
-- Reuse existing update_updated_at_column function if it exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rotary_years_updated_at
  BEFORE UPDATE ON rotary_years
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SUPABASE STORAGE BUCKET FOR THEME LOGOS
-- =====================================================
-- Execute separately in Supabase Storage Dashboard:
-- 1. Create bucket named: 'rotary-themes'
-- 2. Set to Public bucket (for logo display)
-- 3. Configure RLS policies:
--    - SELECT: public (anyone can view)
--    - INSERT/UPDATE/DELETE: officers and chairs only

-- Alternative: Execute via SQL if Storage API is available
-- This is a placeholder - actual bucket creation may require dashboard or API
--
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('rotary-themes', 'rotary-themes', true)
-- ON CONFLICT DO NOTHING;
--
-- CREATE POLICY "Theme logos are publicly viewable"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'rotary-themes');
--
-- CREATE POLICY "Theme logos are manageable by officers and chairs"
--   ON storage.objects FOR ALL
--   USING (
--     bucket_id = 'rotary-themes' AND
--     EXISTS (
--       SELECT 1 FROM members
--       WHERE members.email = auth.jwt()->>'email'
--       AND members.roles && ARRAY[
--         'President', 'President-Elect', 'Immediate Past President', 'Vice President',
--         'Secretary', 'Treasurer', 'Sergeant-at-Arms',
--         'Club Service Chair', 'Foundation Chair', 'International Service Chair',
--         'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
--       ]
--     )
--   );

-- =====================================================
-- SAMPLE DATA - Current Rotary Year (2025-2026)
-- =====================================================
-- Insert current year as baseline
INSERT INTO rotary_years (
  rotary_year,
  start_date,
  end_date,
  club_name,
  club_number,
  district_number,
  charter_date,
  club_president_name,
  club_president_theme,
  ri_president_name,
  ri_president_theme,
  summary
) VALUES (
  '2025-2026',
  '2025-07-01',
  '2026-06-30',
  'Georgetown',
  21331,
  3300,
  '1983-10-04',
  'TBD',  -- CEO to update with actual president name
  NULL,   -- CEO to update with club theme
  'TBD',  -- CEO to update with RI President name
  NULL,   -- CEO to update with RI theme
  'Rotary Year 2025-2026 for Georgetown Rotary Club.'
)
ON CONFLICT (rotary_year) DO NOTHING;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- CEO: Run these after migration to verify success

-- Check rotary_years table created
-- SELECT * FROM rotary_years ORDER BY rotary_year DESC;

-- Verify timeline fields added to service_projects
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'service_projects'
-- AND column_name IN ('rotary_year_id', 'completion_date', 'lessons_learned', 'would_repeat', 'repeat_recommendations');

-- Verify rotary_year_id added to speakers
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'speakers'
-- AND column_name = 'rotary_year_id';

-- Check indexes created
-- SELECT indexname, tablename FROM pg_indexes WHERE tablename IN ('rotary_years', 'service_projects', 'speakers');

-- Verify RLS policies
-- SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'rotary_years';
