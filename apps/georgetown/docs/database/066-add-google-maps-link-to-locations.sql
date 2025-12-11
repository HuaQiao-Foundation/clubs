-- Migration: Add Google Maps link to locations
-- Date: 2025-12-02
-- Description: Add google_maps_link field to locations table for direct map integration

-- Add google_maps_link column to locations table
ALTER TABLE locations
ADD COLUMN google_maps_link TEXT;

-- Add comment for documentation
COMMENT ON COLUMN locations.google_maps_link IS 'Google Maps link or embed URL for the location';
