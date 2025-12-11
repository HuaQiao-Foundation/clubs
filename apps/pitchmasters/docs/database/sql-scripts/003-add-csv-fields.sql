-- ============================================================
-- Migration: 003-add-csv-fields.sql
-- Purpose: Add CSV import fields to member_profiles table
-- Created: 2025-09-28
-- Deployed to Production: 2025-09-28
-- Prerequisites: 002-member-profiles-extension.sql
-- ============================================================
-- Add missing fields from CSV data to member_profiles table
-- These fields capture additional member information not in current schema

ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS city VARCHAR(100);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS country VARCHAR(100);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS citizenship VARCHAR(100);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS tm_member_number VARCHAR(50);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS member_type VARCHAR(20) CHECK (member_type IN ('New', 'Dual', 'Transfer', 'Reinstated'));
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS officer_role VARCHAR(100);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS team VARCHAR(100);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS level VARCHAR(20);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS completed_pathways TEXT[] DEFAULT '{}';
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS dtm BOOLEAN DEFAULT false;
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS organization VARCHAR(200);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS job_title VARCHAR(200);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS is_founder BOOLEAN DEFAULT false;
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS is_rotarian BOOLEAN DEFAULT false;
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS joining_date DATE;
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS birthday_month VARCHAR(20);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS birthday_day INTEGER CHECK (birthday_day BETWEEN 1 AND 31);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS age_bracket VARCHAR(20);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS introducer VARCHAR(200);
ALTER TABLE member_profiles ADD COLUMN IF NOT EXISTS mentor VARCHAR(200);

-- Add indexes for new searchable fields
CREATE INDEX IF NOT EXISTS idx_member_profiles_city ON member_profiles(city);
CREATE INDEX IF NOT EXISTS idx_member_profiles_country ON member_profiles(country);
CREATE INDEX IF NOT EXISTS idx_member_profiles_tm_member_number ON member_profiles(tm_member_number);
CREATE INDEX IF NOT EXISTS idx_member_profiles_member_type ON member_profiles(member_type);
CREATE INDEX IF NOT EXISTS idx_member_profiles_officer_role ON member_profiles(officer_role);
CREATE INDEX IF NOT EXISTS idx_member_profiles_is_founder ON member_profiles(is_founder);
CREATE INDEX IF NOT EXISTS idx_member_profiles_organization ON member_profiles(organization);

-- Update composite search index to include new fields
DROP INDEX IF EXISTS idx_member_profiles_search;
CREATE INDEX idx_member_profiles_search ON member_profiles(club_id, industry, venture_stage, path_level, city, country, is_founder, member_type);