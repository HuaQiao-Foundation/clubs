-- Georgetown Rotary Club - Production Database Schema
-- Generated: 2025-10-18
-- Source: Supabase production database (CEO export)
-- Purpose: CTO reference for accurate table structures
--
-- DO NOT EXECUTE THIS FILE - It is documentation only
-- For migrations, use numbered files: docs/database/NNN-description.sql

-- =====================================================
-- TABLE: events
-- =====================================================
CREATE TABLE events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('club_meeting', 'club_event', 'service_project', 'holiday', 'observance')),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by TEXT NOT NULL,
  updated_by TEXT NOT NULL,
  location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
  start_time TIME,  -- Event start time (HH:MM format)
  end_time TIME     -- Event end time (HH:MM format)
);

-- =====================================================
-- TABLE: locations
-- =====================================================
CREATE TABLE locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  phone TEXT,
  email TEXT,
  whatsapp TEXT,
  website TEXT,
  facebook TEXT,
  instagram TEXT,
  youtube TEXT,
  key_contact TEXT
);

-- =====================================================
-- TABLE: members
-- =====================================================
CREATE TABLE members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prefix TEXT,
  name TEXT NOT NULL,
  gender TEXT,
  rotary_profile_url TEXT,
  type TEXT,
  member_since TEXT,
  email TEXT,
  mobile TEXT,
  phf TEXT,
  classification TEXT,
  linkedin TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  company_name TEXT,
  company_url TEXT,
  job_title TEXT,
  birth_month INTEGER,
  birth_day INTEGER,
  rotary_resume TEXT,
  charter_member BOOLEAN DEFAULT false,
  citizenship TEXT,
  rotary_id TEXT,
  roles TEXT[],
  portrait_url TEXT,
  social_media_links JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- TABLE: partners
-- =====================================================
CREATE TABLE partners (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  contact_info TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  contact_name TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  website TEXT,
  status TEXT DEFAULT 'Active',
  relationship_since DATE,
  logo_url TEXT,
  description TEXT,
  primary_contact_rotarian_id UUID REFERENCES members(id),
  collaboration_areas TEXT[],
  contact_title TEXT,
  next_review_date DATE,
  mou_signed_date DATE,
  partnership_value_rm NUMERIC,
  city TEXT,
  country TEXT,
  social_media_links JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- TABLE: photos
-- =====================================================
CREATE TABLE photos (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  url TEXT NOT NULL,
  storage_path TEXT,
  thumbnail_url TEXT,
  title TEXT,
  caption TEXT,
  photo_date DATE,
  photographer_name TEXT,
  location TEXT,
  rotary_year_id UUID REFERENCES rotary_years(id),
  event_id UUID REFERENCES events(id),
  project_id UUID REFERENCES service_projects(id),
  category TEXT DEFAULT 'general',
  tags TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  visibility TEXT DEFAULT 'public',
  approval_status TEXT DEFAULT 'approved',
  approval_notes TEXT,
  width INTEGER,
  height INTEGER,
  file_size INTEGER,
  mime_type TEXT,
  uploaded_by UUID REFERENCES members(id),
  approved_by UUID REFERENCES members(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- TABLE: project_partners
-- =====================================================
CREATE TABLE project_partners (
  project_id UUID NOT NULL REFERENCES service_projects(id),
  partner_id UUID NOT NULL REFERENCES partners(id),
  PRIMARY KEY (project_id, partner_id)
);

-- =====================================================
-- TABLE: rotary_years
-- =====================================================
CREATE TABLE rotary_years (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  rotary_year TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  club_name TEXT NOT NULL,
  club_number INTEGER NOT NULL,
  district_number INTEGER NOT NULL,
  charter_date DATE NOT NULL,
  club_president_name TEXT NOT NULL,
  club_president_theme TEXT,
  club_president_theme_logo_url TEXT,
  ri_president_name TEXT,
  ri_president_theme TEXT,
  ri_president_theme_logo_url TEXT,
  dg_name TEXT,
  dg_theme TEXT,
  dg_theme_logo_url TEXT,
  summary TEXT,
  narrative TEXT,
  highlights JSONB DEFAULT '[]'::jsonb,
  challenges JSONB DEFAULT '[]'::jsonb,
  stats JSONB DEFAULT '{}'::jsonb,
  photos JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  club_president_photo_url TEXT,
  district_governor_photo_url TEXT,
  member_count_year_end INTEGER
);

-- =====================================================
-- TABLE: service_projects
-- =====================================================
CREATE TABLE service_projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_name TEXT NOT NULL,
  description TEXT,
  area_of_focus TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Idea',
  type TEXT NOT NULL,
  champion TEXT NOT NULL,
  project_value_rm NUMERIC,
  start_date DATE NOT NULL,
  end_date DATE,
  project_year INTEGER,
  grant_number TEXT,
  beneficiary_count INTEGER,
  location TEXT,
  image_url TEXT,
  notes TEXT,
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  impact TEXT,
  image_position TEXT DEFAULT 'center',
  rotary_year_id UUID REFERENCES rotary_years(id),
  completion_date DATE,
  lessons_learned TEXT,
  would_repeat TEXT,
  repeat_recommendations TEXT,
  volunteer_hours INTEGER,
  funding_source TEXT,
  district_grant_number TEXT,
  matching_grant_value_rm NUMERIC,
  project_committee_members TEXT[],
  sustainability_plan TEXT,
  publicity_urls TEXT[],
  collaboration_type TEXT,
  beneficiary_demographics JSONB,
  rotary_citation_eligible BOOLEAN DEFAULT false,
  follow_up_date DATE,
  risk_assessment TEXT
);

-- =====================================================
-- TABLE: speakers
-- =====================================================
CREATE TABLE speakers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  organization TEXT,
  topic TEXT NOT NULL,
  notes TEXT,
  status TEXT NOT NULL,
  scheduled_date DATE,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by TEXT NOT NULL,
  updated_by TEXT NOT NULL,
  job_title TEXT,
  description TEXT,
  primary_url TEXT,
  additional_urls TEXT[],
  is_rotarian BOOLEAN DEFAULT false,
  rotary_club TEXT,
  linkedin_url TEXT,
  recommend BOOLEAN DEFAULT false,
  recommendation_date TIMESTAMP,
  recommendation_notes TEXT,
  proposer_id UUID REFERENCES members(id),
  rotary_year_id UUID REFERENCES rotary_years(id),
  portrait_url TEXT,
  charter_member BOOLEAN DEFAULT false,
  social_media_links JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- SCHEMA SUMMARY
-- =====================================================
-- Total Tables: 9
--
-- Tables: events, locations, members, partners, photos,
--         project_partners, rotary_years, service_projects, speakers
--
-- Key Relationships:
-- - events.location_id ’ locations.id
-- - photos ’ rotary_years, events, service_projects
-- - partners.primary_contact_rotarian_id ’ members.id
-- - project_partners links service_projects ” partners
-- - speakers ’ members (proposer), rotary_years
--
-- =====================================================
-- MAINTENANCE
-- =====================================================
-- CTO updates this file after schema-changing migrations
-- Last updated: 2025-10-18 (Migration 049: event times)
