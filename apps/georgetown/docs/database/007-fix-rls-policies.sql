-- Migration 007: Fix RLS Policies for Public Access
-- Purpose: Allow unauthenticated users to access service projects and partners (for development/small club use)
-- Date: 2025-10-08
-- Execute: CEO in Supabase SQL Editor

-- =====================================================
-- UPDATE SERVICE PROJECTS RLS POLICIES
-- =====================================================

-- Drop old authenticated-only policy
DROP POLICY IF EXISTS "Service projects are viewable by authenticated users" ON service_projects;
DROP POLICY IF EXISTS "Service projects are manageable by authenticated users" ON service_projects;

-- Create new public policies
CREATE POLICY "Service projects are viewable by everyone"
  ON service_projects FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Service projects are manageable by everyone"
  ON service_projects FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- UPDATE PARTNERS RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Partners are viewable by authenticated users" ON partners;
DROP POLICY IF EXISTS "Partners are manageable by authenticated users" ON partners;

CREATE POLICY "Partners are viewable by everyone"
  ON partners FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Partners are manageable by everyone"
  ON partners FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- UPDATE PROJECT_PARTNERS RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Project partners are viewable by authenticated users" ON project_partners;
DROP POLICY IF EXISTS "Project partners are manageable by authenticated users" ON project_partners;

CREATE POLICY "Project partners are viewable by everyone"
  ON project_partners FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Project partners are manageable by everyone"
  ON project_partners FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);
