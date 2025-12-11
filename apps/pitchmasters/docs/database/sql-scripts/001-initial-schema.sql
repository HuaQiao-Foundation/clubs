-- ============================================================
-- Migration: 001-initial-schema.sql
-- Purpose: Multi-club database foundation with RLS
-- Created: 2025-09-27
-- Deployed to Production: 2025-09-27
-- Prerequisites: None (initial schema)
-- ============================================================
-- Pitchmasters Multi-Club Database Schema
-- Designed for tenant isolation and scalability

-- Enable Row Level Security
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Meetings table (scoped to clubs)
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

-- Speeches table (linked to meetings and users)
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

-- Meeting roles table (functional roles in meetings)
CREATE TABLE meeting_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    role_type VARCHAR(30) CHECK (role_type IN ('toastmaster', 'evaluator', 'timer', 'grammarian', 'ah_counter', 'table_topics_master')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(meeting_id, role_type)
);

-- Indexes for performance
CREATE INDEX idx_users_club_id ON users(club_id);
CREATE INDEX idx_meetings_club_id ON meetings(club_id);
CREATE INDEX idx_meetings_date ON meetings(date);
CREATE INDEX idx_speeches_meeting_id ON speeches(meeting_id);
CREATE INDEX idx_speeches_user_id ON speeches(user_id);
CREATE INDEX idx_meeting_roles_meeting_id ON meeting_roles(meeting_id);

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meetings_updated_at BEFORE UPDATE ON meetings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_speeches_updated_at BEFORE UPDATE ON speeches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meeting_roles_updated_at BEFORE UPDATE ON meeting_roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security Policies
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE speeches ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_roles ENABLE ROW LEVEL SECURITY;

-- Club isolation policies (users can only access their own club's data)
CREATE POLICY "Users can view own club" ON clubs FOR SELECT USING (auth.uid() IN (SELECT id FROM users WHERE club_id = clubs.id));
CREATE POLICY "Users can view own club members" ON users FOR SELECT USING (club_id IN (SELECT club_id FROM users WHERE id = auth.uid()));
CREATE POLICY "Users can view own club meetings" ON meetings FOR SELECT USING (club_id IN (SELECT club_id FROM users WHERE id = auth.uid()));
CREATE POLICY "Users can view own club speeches" ON speeches FOR SELECT USING (meeting_id IN (SELECT id FROM meetings WHERE club_id IN (SELECT club_id FROM users WHERE id = auth.uid())));
CREATE POLICY "Users can view own club meeting roles" ON meeting_roles FOR SELECT USING (meeting_id IN (SELECT id FROM meetings WHERE club_id IN (SELECT club_id FROM users WHERE id = auth.uid())));

-- Insert policies for officers and admins
CREATE POLICY "Officers can insert meetings" ON meetings FOR INSERT WITH CHECK (
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid() AND role IN ('officer', 'admin'))
);

CREATE POLICY "Members can insert speeches" ON speeches FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    meeting_id IN (SELECT id FROM meetings WHERE club_id IN (SELECT club_id FROM users WHERE id = auth.uid()))
);

-- Sample data for development
INSERT INTO clubs (name, charter_number, timezone) VALUES
('Pitchmasters Toastmasters', '12345', 'Asia/Singapore'),
('Tech Speakers Club', '67890', 'America/New_York');

-- This completes the multi-club database schema with tenant isolation