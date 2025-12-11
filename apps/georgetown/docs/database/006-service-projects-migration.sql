-- Migration 006: Service Projects and Partners
-- Purpose: Add service projects tracking with partners, areas of focus, and image storage
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- =====================================================
-- PARTNERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS partners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Rotary Club', 'Foundation', 'NGO', 'Corporate', 'Government')),
  contact_info TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SERVICE PROJECTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS service_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_name TEXT NOT NULL,
  description TEXT,
  area_of_focus TEXT NOT NULL CHECK (area_of_focus IN ('Peace', 'Disease', 'Water', 'Maternal/Child', 'Education', 'Economy', 'Environment')),
  status TEXT NOT NULL DEFAULT 'Idea' CHECK (status IN ('Idea', 'Planning', 'Execution', 'Completed', 'Dropped')),
  type TEXT NOT NULL CHECK (type IN ('Global Grant', 'Club', 'Joint')),
  champion TEXT NOT NULL, -- Club member name (preserved even if member leaves)
  project_value_rm DECIMAL(12, 2), -- Malaysian Ringgit
  start_date DATE NOT NULL,
  end_date DATE,
  project_year INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM start_date)) STORED, -- Computed from start_date
  grant_number TEXT, -- TRF Global Grant tracking number
  beneficiary_count INTEGER, -- Number of people/communities served
  location TEXT, -- City/region served
  image_url TEXT, -- Supabase Storage public URL
  notes TEXT, -- Internal progress notes
  created_by TEXT, -- Club member who initiated
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PROJECT-PARTNERS JUNCTION TABLE (Many-to-Many)
-- =====================================================
CREATE TABLE IF NOT EXISTS project_partners (
  project_id UUID NOT NULL REFERENCES service_projects(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, partner_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_service_projects_status ON service_projects(status);
CREATE INDEX IF NOT EXISTS idx_service_projects_area_of_focus ON service_projects(area_of_focus);
CREATE INDEX IF NOT EXISTS idx_service_projects_year ON service_projects(project_year);
CREATE INDEX IF NOT EXISTS idx_project_partners_project ON project_partners(project_id);
CREATE INDEX IF NOT EXISTS idx_project_partners_partner ON project_partners(partner_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_partners ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all partners
CREATE POLICY "Partners are viewable by authenticated users"
  ON partners FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to manage partners
CREATE POLICY "Partners are manageable by authenticated users"
  ON partners FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read all service projects
CREATE POLICY "Service projects are viewable by authenticated users"
  ON service_projects FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to manage service projects
CREATE POLICY "Service projects are manageable by authenticated users"
  ON service_projects FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read all project-partner relationships
CREATE POLICY "Project partners are viewable by authenticated users"
  ON project_partners FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to manage project-partner relationships
CREATE POLICY "Project partners are manageable by authenticated users"
  ON project_partners FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- SAMPLE DATA (Optional - Remove if not needed)
-- =====================================================
-- Sample Partner
INSERT INTO partners (name, type, contact_info) VALUES
  ('Rotary Club of Shanghai', 'Rotary Club', 'shanghai@rotary.org'),
  ('HuaQiao Foundation', 'Foundation', 'info@huaqiao.org'),
  ('Roots of Peace', 'NGO', 'contact@rootsofpeace.org')
ON CONFLICT DO NOTHING;

-- Sample Service Project
INSERT INTO service_projects (
  project_name,
  description,
  area_of_focus,
  status,
  type,
  champion,
  project_value_rm,
  start_date,
  end_date,
  grant_number,
  beneficiary_count,
  location,
  created_by
) VALUES (
  'Christmas Orphan Care Project',
  'Annual Christmas celebration and gift distribution for local orphanage',
  'Maternal/Child',
  'Completed',
  'Club',
  'John Smith',
  5000.00,
  '2024-12-15',
  '2024-12-15',
  NULL,
  50,
  'Georgetown, Penang',
  'John Smith'
)
ON CONFLICT DO NOTHING;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- CEO: Run these after migration to verify success
-- SELECT COUNT(*) FROM partners;
-- SELECT COUNT(*) FROM service_projects;
-- SELECT * FROM service_projects LIMIT 1;
