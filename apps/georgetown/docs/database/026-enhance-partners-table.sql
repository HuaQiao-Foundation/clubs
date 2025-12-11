-- Migration 026: Enhance partners table with detailed fields
-- Purpose: Add comprehensive partner contact and relationship tracking
-- Date: 2025-01-14
-- Production Deploy: Not deployed (POST-MVP ENHANCEMENT)
-- Prerequisites: partners table exists (created in migration 006)
-- Author: CTO (Claude Code)
-- Status: OPTIONAL - Phase 3 requirements already met without these fields

-- =====================================================
-- BUSINESS CONTEXT
-- =====================================================
-- Current partners table is minimal (name, type, contact_info)
-- This migration adds structured contact fields, status tracking,
-- relationship history, and logo support for more professional
-- partner management in List and Table views.

-- =====================================================
-- NEW COLUMNS
-- =====================================================

-- Structured contact information (replace freeform contact_info)
ALTER TABLE partners
ADD COLUMN IF NOT EXISTS contact_name TEXT,
ADD COLUMN IF NOT EXISTS contact_email TEXT,
ADD COLUMN IF NOT EXISTS contact_phone TEXT,
ADD COLUMN IF NOT EXISTS website TEXT;

-- Partner status tracking
ALTER TABLE partners
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive'));

-- Relationship tracking
ALTER TABLE partners
ADD COLUMN IF NOT EXISTS relationship_since DATE;

-- Partner logo support
ALTER TABLE partners
ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- =====================================================
-- COMMENTS FOR DOCUMENTATION
-- =====================================================
COMMENT ON COLUMN partners.contact_name IS 'Primary contact person name at partner organization';
COMMENT ON COLUMN partners.contact_email IS 'Primary contact email address';
COMMENT ON COLUMN partners.contact_phone IS 'Primary contact phone number';
COMMENT ON COLUMN partners.website IS 'Partner organization website URL';
COMMENT ON COLUMN partners.status IS 'Partner relationship status: Active or Inactive';
COMMENT ON COLUMN partners.relationship_since IS 'Date when partnership relationship began';
COMMENT ON COLUMN partners.logo_url IS 'URL to partner logo image in Supabase Storage';

-- =====================================================
-- OPTIONAL: DATA MIGRATION
-- =====================================================
-- If you have existing partners with freeform contact_info,
-- you may want to manually parse and migrate that data to
-- the new structured fields. Example:
--
-- UPDATE partners
-- SET contact_email = 'extracted@email.com',
--     contact_name = 'Extracted Name'
-- WHERE id = 'partner-uuid-here';

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================
-- CEO: Run this after migration to verify success
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'partners'
  AND column_name IN ('contact_name', 'contact_email', 'contact_phone', 'website', 'status', 'relationship_since', 'logo_url')
ORDER BY column_name;

-- Expected result: 7 new columns with proper types

-- =====================================================
-- NOTES FOR CEO
-- =====================================================
-- 1. This migration is OPTIONAL for Phase 3 completion
-- 2. Current PartnersList component works fine with minimal schema
-- 3. These fields enable more professional partner management post-MVP
-- 4. All new columns are OPTIONAL (nullable) except status (defaults to Active)
-- 5. Existing partners will retain their data, new fields will be NULL
-- 6. After migration, CTO can enhance PartnersPage to use structured fields
-- 7. Recommended to execute this during low-traffic period (optional optimization)

-- =====================================================
-- TYPESCRIPT TYPE UPDATE NEEDED AFTER MIGRATION
-- =====================================================
-- CTO will update src/types/database.ts Partner type to include:
-- export type Partner = {
--   id: string
--   name: string
--   type: 'Rotary Club' | 'Foundation' | 'NGO' | 'Corporate' | 'Government'
--   contact_info?: string          // Legacy field (keep for backward compatibility)
--   contact_name?: string           // NEW
--   contact_email?: string          // NEW
--   contact_phone?: string          // NEW
--   website?: string                // NEW
--   status?: 'Active' | 'Inactive'  // NEW
--   relationship_since?: string     // NEW (ISO date string)
--   logo_url?: string               // NEW
--   created_at: string
--   updated_at: string
-- }
