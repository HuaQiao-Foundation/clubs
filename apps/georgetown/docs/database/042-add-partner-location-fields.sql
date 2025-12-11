-- Migration 042: Add Location Fields to Partners Table
-- Date: 2025-10-17
-- Purpose: Add city and country fields to partners table for better location tracking and Rotary reporting

-- Business Context:
-- Partners are located globally and tracking their location is important for:
-- 1. Rotary reporting and district-level partnership analysis
-- 2. Geographic diversity tracking in partnership portfolio
-- 3. International collaboration opportunities
-- 4. Partnership mapping and visualization

-- Add city field (optional, text)
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS city TEXT;

-- Add country field (optional, text)
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS country TEXT;

-- Add comments for documentation
COMMENT ON COLUMN partners.city IS 'City where partner organization is based';
COMMENT ON COLUMN partners.country IS 'Country where partner organization is based';

-- Verification Query (Run after migration)
-- SELECT id, name, city, country, website FROM partners ORDER BY name;
