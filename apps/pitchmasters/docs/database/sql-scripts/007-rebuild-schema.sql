-- ============================================================
-- Migration: 007-rebuild-schema.sql
-- Purpose: Complete schema rebuild with Sprint 1 requirements
-- Created: 2025-09-28
-- Deployed to Production: 2025-09-28
-- Prerequisites: Fresh database or all previous migrations
-- WARNING: This drops all tables - use for complete rebuild only
-- ============================================================
-- DROP INCORRECT TABLES AND REBUILD WITH CORRECT SPRINT 1 SCHEMA
-- Execute this in Supabase SQL Editor to fix table structures

-- Drop all tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS partner_reviews CASCADE;
DROP TABLE IF EXISTS ecosystem_partners CASCADE;
DROP TABLE IF EXISTS pathways_progress CASCADE;
DROP TABLE IF EXISTS speech_evaluations CASCADE;
DROP TABLE IF EXISTS privacy_settings CASCADE;
DROP TABLE IF EXISTS member_profiles CASCADE;
DROP TABLE IF EXISTS meeting_roles CASCADE;
DROP TABLE IF EXISTS speeches CASCADE;
DROP TABLE IF EXISTS meetings CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS clubs CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =====================================================
-- CORE TABLES (from original schema.sql)
-- =====================================================

-- Clubs table (top-level tenant isolation)
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    charter_number VARCHAR(50) UNIQUE,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users table (scoped to clubs)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('member', 'officer', 'admin')) DEFAULT 'member',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(email, club_id)
);

-- Meetings table
CREATE TABLE meetings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    meeting_type VARCHAR(20) CHECK (meeting_type IN ('regular', 'special', 'demo')) DEFAULT 'regular',
    status VARCHAR(20) CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')) DEFAULT 'scheduled',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Speeches table
CREATE TABLE speeches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    manual VARCHAR(100) NOT NULL,
    project_number INTEGER NOT NULL,
    objectives TEXT[] DEFAULT '{}',
    duration_minutes INTEGER DEFAULT 7,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Meeting roles table
CREATE TABLE meeting_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    role_type VARCHAR(30) CHECK (role_type IN ('toastmaster', 'evaluator', 'timer', 'grammarian', 'ah_counter', 'table_topics_master')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(meeting_id, role_type)
);

-- =====================================================
-- SPRINT 1 EXTENDED TABLES (multi-tier privacy)
-- =====================================================

-- Member profiles with multi-tier data structure
CREATE TABLE member_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    -- Public tier data
    photo_url VARCHAR(500),
    path_level VARCHAR(50) DEFAULT 'Level 1',
    current_path VARCHAR(100) DEFAULT 'Dynamic Leadership',
    venture_name VARCHAR(200),
    venture_description TEXT,
    venture_stage VARCHAR(50) CHECK (venture_stage IN ('idea', 'mvp', 'growth', 'scale', 'exit')),
    industry VARCHAR(100),
    expertise_areas TEXT[] DEFAULT '{}',
    bio TEXT,

    -- Member-only tier data
    phone VARCHAR(30),
    linkedin_url VARCHAR(500),
    website_url VARCHAR(500),
    networking_interests TEXT[] DEFAULT '{}',
    looking_for TEXT[] DEFAULT '{}',
    offering TEXT[] DEFAULT '{}',
    speech_count INTEGER DEFAULT 0,
    evaluation_count INTEGER DEFAULT 0,
    leadership_roles TEXT[] DEFAULT '{}',

    -- Private tier data
    personal_goals TEXT,
    communication_goals TEXT,
    leadership_goals TEXT,
    next_speech_plan TEXT,
    feedback_preferences JSONB DEFAULT '{}',
    officer_notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Privacy settings table (granular visibility controls)
CREATE TABLE privacy_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    -- Public tier visibility controls
    show_photo BOOLEAN DEFAULT true,
    show_venture_info BOOLEAN DEFAULT true,
    show_expertise BOOLEAN DEFAULT true,
    show_bio BOOLEAN DEFAULT true,

    -- Member-only tier visibility controls
    show_contact_info BOOLEAN DEFAULT true,
    show_social_links BOOLEAN DEFAULT true,
    show_networking_interests BOOLEAN DEFAULT true,
    show_speech_progress BOOLEAN DEFAULT true,
    show_looking_for BOOLEAN DEFAULT true,
    show_offering BOOLEAN DEFAULT true,

    -- Private tier controls
    allow_officer_notes BOOLEAN DEFAULT true,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Speech evaluations with privacy controls
CREATE TABLE speech_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    speech_id UUID NOT NULL REFERENCES speeches(id) ON DELETE CASCADE,
    evaluator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    -- Public evaluation data
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5),
    public_feedback TEXT,

    -- Private evaluation data
    detailed_feedback TEXT,
    strengths TEXT[] DEFAULT '{}',
    improvement_areas TEXT[] DEFAULT '{}',
    specific_recommendations TEXT,

    -- Evaluation settings
    is_public BOOLEAN DEFAULT false,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(speech_id, evaluator_id)
);

-- Pathways progress tracking
CREATE TABLE pathways_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    path_name VARCHAR(100) NOT NULL,
    level_number INTEGER NOT NULL CHECK (level_number BETWEEN 1 AND 5),
    project_number INTEGER NOT NULL CHECK (project_number BETWEEN 1 AND 11),
    project_title VARCHAR(200) NOT NULL,
    completion_date DATE,
    speech_id UUID REFERENCES speeches(id) ON DELETE SET NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, path_name, level_number, project_number)
);

-- Ecosystem partners (member-only access)
CREATE TABLE ecosystem_partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Partner company information
    company_name VARCHAR(200) NOT NULL,
    company_description TEXT,
    company_website VARCHAR(500),
    industry VARCHAR(100) NOT NULL,
    company_size VARCHAR(50) CHECK (company_size IN ('startup', 'small', 'medium', 'large', 'enterprise')),

    -- Contact information
    contact_name VARCHAR(200),
    contact_title VARCHAR(100),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(30),

    -- Partnership details
    partnership_type VARCHAR(50) CHECK (partnership_type IN ('investor', 'accelerator', 'service_provider', 'vendor', 'client', 'mentor', 'advisor')) NOT NULL,
    services_offered TEXT[] DEFAULT '{}',
    location VARCHAR(200),

    -- Rating and verification
    average_rating DECIMAL(2,1) DEFAULT 0.0 CHECK (average_rating >= 0.0 AND average_rating <= 5.0),
    review_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    verification_date DATE,

    -- Metadata
    added_by UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'pending_review')) DEFAULT 'pending_review',

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Partner reviews (member feedback)
CREATE TABLE partner_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id UUID NOT NULL REFERENCES ecosystem_partners(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    would_recommend BOOLEAN,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(partner_id, reviewer_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Core table indexes
CREATE INDEX idx_users_club_id ON users(club_id);
CREATE INDEX idx_meetings_club_id ON meetings(club_id);
CREATE INDEX idx_meetings_date ON meetings(date);
CREATE INDEX idx_speeches_meeting_id ON speeches(meeting_id);
CREATE INDEX idx_speeches_user_id ON speeches(user_id);
CREATE INDEX idx_meeting_roles_meeting_id ON meeting_roles(meeting_id);

-- Member profiles indexes
CREATE INDEX idx_member_profiles_club_id ON member_profiles(club_id);
CREATE INDEX idx_member_profiles_user_id ON member_profiles(user_id);
CREATE INDEX idx_member_profiles_industry ON member_profiles(industry);
CREATE INDEX idx_member_profiles_venture_stage ON member_profiles(venture_stage);
CREATE INDEX idx_member_profiles_path_level ON member_profiles(path_level);

-- Privacy settings indexes
CREATE INDEX idx_privacy_settings_user_id ON privacy_settings(user_id);
CREATE INDEX idx_privacy_settings_club_id ON privacy_settings(club_id);

-- Speech evaluations indexes
CREATE INDEX idx_speech_evaluations_speech_id ON speech_evaluations(speech_id);
CREATE INDEX idx_speech_evaluations_club_id ON speech_evaluations(club_id);

-- Pathways progress indexes
CREATE INDEX idx_pathways_progress_user_id ON pathways_progress(user_id);
CREATE INDEX idx_pathways_progress_club_id ON pathways_progress(club_id);

-- Ecosystem partners indexes
CREATE INDEX idx_ecosystem_partners_industry ON ecosystem_partners(industry);
CREATE INDEX idx_ecosystem_partners_partnership_type ON ecosystem_partners(partnership_type);
CREATE INDEX idx_ecosystem_partners_status ON ecosystem_partners(status);
CREATE INDEX idx_ecosystem_partners_location ON ecosystem_partners(location);

-- Partner reviews indexes
CREATE INDEX idx_partner_reviews_partner_id ON partner_reviews(partner_id);
CREATE INDEX idx_partner_reviews_club_id ON partner_reviews(club_id);

-- Composite indexes for search
CREATE INDEX idx_member_profiles_search ON member_profiles(club_id, industry, venture_stage, path_level);
CREATE INDEX idx_ecosystem_partners_search ON ecosystem_partners(industry, partnership_type, status, location);

-- =====================================================
-- TRIGGERS
-- =====================================================

CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meetings_updated_at BEFORE UPDATE ON meetings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_speeches_updated_at BEFORE UPDATE ON speeches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meeting_roles_updated_at BEFORE UPDATE ON meeting_roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_member_profiles_updated_at BEFORE UPDATE ON member_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_privacy_settings_updated_at BEFORE UPDATE ON privacy_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_speech_evaluations_updated_at BEFORE UPDATE ON speech_evaluations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_pathways_progress_updated_at BEFORE UPDATE ON pathways_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ecosystem_partners_updated_at BEFORE UPDATE ON ecosystem_partners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_partner_reviews_updated_at BEFORE UPDATE ON partner_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE speeches ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE privacy_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE speech_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE pathways_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecosystem_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_reviews ENABLE ROW LEVEL SECURITY;

-- Club isolation policies
CREATE POLICY "Users can view own club" ON clubs FOR SELECT USING (auth.uid() IN (SELECT id FROM users WHERE club_id = clubs.id));
CREATE POLICY "Users can view own club members" ON users FOR SELECT USING (club_id IN (SELECT club_id FROM users WHERE id = auth.uid()));
CREATE POLICY "Users can view own club meetings" ON meetings FOR SELECT USING (club_id IN (SELECT club_id FROM users WHERE id = auth.uid()));
CREATE POLICY "Users can view own club speeches" ON speeches FOR SELECT USING (meeting_id IN (SELECT id FROM meetings WHERE club_id IN (SELECT club_id FROM users WHERE id = auth.uid())));
CREATE POLICY "Users can view own club meeting roles" ON meeting_roles FOR SELECT USING (meeting_id IN (SELECT id FROM meetings WHERE club_id IN (SELECT club_id FROM users WHERE id = auth.uid())));

-- Member profile policies (multi-tier)
CREATE POLICY "Public profile access" ON member_profiles FOR SELECT USING (
    user_id = auth.uid() OR
    id IN (
        SELECT mp.id FROM member_profiles mp
        JOIN privacy_settings ps ON mp.user_id = ps.user_id
        WHERE ps.show_photo = true OR ps.show_venture_info = true OR ps.show_expertise = true OR ps.show_bio = true
    )
);

CREATE POLICY "Members can create profiles" ON member_profiles FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Users update own profiles" ON member_profiles FOR UPDATE USING (user_id = auth.uid());

-- Privacy settings policies
CREATE POLICY "User controls own privacy" ON privacy_settings FOR ALL USING (user_id = auth.uid());

-- Ecosystem partners policies (members-only)
CREATE POLICY "Members only partner access" ON ecosystem_partners FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid())
);

CREATE POLICY "Verified users can add partners" ON ecosystem_partners FOR INSERT WITH CHECK (added_by = auth.uid());
CREATE POLICY "Partners updated by admins" ON ecosystem_partners FOR UPDATE USING (
    added_by = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- Partner reviews policies
CREATE POLICY "Member partner reviews" ON partner_reviews FOR SELECT USING (
    reviewer_id = auth.uid() OR
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Members can review partners" ON partner_reviews FOR INSERT WITH CHECK (
    reviewer_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Reviewers update own reviews" ON partner_reviews FOR UPDATE USING (reviewer_id = auth.uid());

-- Speech evaluation policies
CREATE POLICY "Speech evaluation access" ON speech_evaluations FOR SELECT USING (
    speech_id IN (SELECT id FROM speeches WHERE user_id = auth.uid()) OR
    evaluator_id = auth.uid() OR
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid() AND role IN ('officer', 'admin')) OR
    (is_public = true AND club_id IN (SELECT club_id FROM users WHERE id = auth.uid()))
);

CREATE POLICY "Members can create evaluations" ON speech_evaluations FOR INSERT WITH CHECK (
    evaluator_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Evaluators update own evaluations" ON speech_evaluations FOR UPDATE USING (evaluator_id = auth.uid());

-- Pathways progress policies
CREATE POLICY "Pathways progress access" ON pathways_progress FOR SELECT USING (
    user_id = auth.uid() OR
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Members can track pathways" ON pathways_progress FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid())
);

CREATE POLICY "Users update own pathways" ON pathways_progress FOR UPDATE USING (user_id = auth.uid());

-- =====================================================
-- SAMPLE DATA
-- =====================================================

INSERT INTO clubs (name, charter_number, timezone) VALUES
('Pitchmasters Toastmasters', '12345', 'Asia/Singapore'),
('Tech Speakers Club', '67890', 'America/New_York')
ON CONFLICT DO NOTHING;

-- Schema rebuild complete!