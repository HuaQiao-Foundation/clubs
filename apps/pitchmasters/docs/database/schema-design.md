# Pitchmasters Database Schema Design

**Purpose**: Comprehensive database schema documentation
**Last Updated**: 2025-10-08
**Current Phase**: Phase 1 - Internal MVP
**Database**: Supabase PostgreSQL with Row Level Security

---

## Table of Contents

1. [Schema Overview](#schema-overview)
2. [Core Tables](#core-tables)
3. [Extended Tables](#extended-tables)
4. [Row Level Security](#row-level-security)
5. [Indexes & Performance](#indexes--performance)
6. [Migration History](#migration-history)

---

## Schema Overview

### Architecture Principles

**Multi-Tenant Isolation**:
- Club-level tenant boundaries via `club_id` foreign keys
- Row Level Security (RLS) enforces data segregation
- UUID primary keys for global uniqueness and scalability

**Scalability Design**:
- Indexed foreign keys for efficient queries
- Composite indexes for common search patterns
- Prepared for horizontal partitioning

**Data Privacy**:
- Three-tier access model (public/member/private)
- Granular privacy controls per user
- GDPR-compliant data handling

---

## Core Tables

### clubs

**Purpose**: Top-level tenant definition for multi-club architecture

**Schema**:
```sql
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    charter_number VARCHAR(50) UNIQUE,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Fields**:
- `id`: UUID primary key
- `name`: Club name (e.g., "Pitchmasters Toastmasters")
- `charter_number`: Official Toastmasters charter (unique across clubs)
- `timezone`: Club's primary timezone for meeting scheduling

**Relationships**: Root table, referenced by all club-scoped tables

**RLS**: Users can only view their own club

---

### users

**Purpose**: Club members with role-based access control

**Schema**:
```sql
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
```

**Key Fields**:
- `id`: UUID primary key (linked to Supabase Auth)
- `email`: User email (unique per club, allows multi-club membership)
- `full_name`: Display name
- `club_id`: Tenant isolation (foreign key to clubs)
- `role`: Permission level (member/officer/admin)

**Roles**:
- **member**: Basic access, can create speeches
- **officer**: Meeting management, member data access
- **admin**: Full club management, user role assignment

**Relationships**:
- Belongs to one club (via `club_id`)
- Has one member_profile (via user_id)
- Has many speeches, meeting_roles

**RLS**: Users can view members in their own club only

**Indexes**:
- `idx_users_club_id` - Fast club-scoped queries

---

### meetings

**Purpose**: Toastmasters meeting scheduling and management

**Schema**:
```sql
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
```

**Key Fields**:
- `id`: UUID primary key
- `club_id`: Tenant isolation
- `title`: Meeting title/theme
- `date`, `start_time`, `end_time`: Scheduling
- `meeting_type`: Regular/special/demo meetings
- `status`: Meeting lifecycle state

**Meeting Types**:
- **regular**: Standard club meetings
- **special**: Officer installations, contests, etc.
- **demo**: Public demo meetings for guests

**Status Values**:
- **scheduled**: Not yet started
- **in_progress**: Currently happening
- **completed**: Finished
- **cancelled**: Cancelled meeting

**Relationships**:
- Belongs to one club (via `club_id`)
- Has many speeches, meeting_roles

**RLS**: Users can view meetings in their own club only

**Indexes**:
- `idx_meetings_club_id` - Club-scoped queries
- `idx_meetings_date` - Date-based filtering

---

### speeches

**Purpose**: Speech tracking and Pathways/manual progress

**Schema**:
```sql
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
```

**Key Fields**:
- `id`: UUID primary key
- `meeting_id`: Links to specific meeting
- `user_id`: Speaker
- `title`: Speech title
- `manual`: Pathways path or traditional manual name
- `project_number`: Project number in path/manual
- `objectives`: Learning objectives (array)
- `duration_minutes`: Target speech duration

**Pathways Support**:
- 11 Pathways paths (Dynamic Leadership, etc.)
- 55+ projects across all paths
- Traditional Competent Communicator/Advanced manuals

**Relationships**:
- Belongs to one meeting (via `meeting_id`)
- Delivered by one user (via `user_id`)
- Inherits club_id from meeting

**RLS**: Users can view speeches in their club's meetings

**Indexes**:
- `idx_speeches_meeting_id` - Meeting-scoped queries
- `idx_speeches_user_id` - User progress tracking

---

### meeting_roles

**Purpose**: Functional roles in Toastmasters meetings

**Schema**:
```sql
CREATE TABLE meeting_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    role_type VARCHAR(30) CHECK (role_type IN ('toastmaster', 'evaluator', 'timer', 'grammarian', 'ah_counter', 'table_topics_master')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(meeting_id, role_type)
);
```

**Key Fields**:
- `id`: UUID primary key
- `meeting_id`: Links to specific meeting
- `user_id`: Assigned member (nullable for TBD roles)
- `role_type`: Toastmasters functional role

**Role Types** (Official Toastmasters roles):
- **toastmaster**: Meeting coordinator
- **evaluator**: Speech evaluator
- **timer**: Time keeper
- **grammarian**: Word usage tracker
- **ah_counter**: Filler word counter
- **table_topics_master**: Impromptu speaking coordinator

**Uniqueness**: One role per meeting (enforced by UNIQUE constraint)

**Relationships**:
- Belongs to one meeting (via `meeting_id`)
- Assigned to one user (via `user_id`)

**RLS**: Users can view roles in their club's meetings

**Indexes**:
- `idx_meeting_roles_meeting_id` - Meeting role lists

---

## Extended Tables

### member_profiles

**Purpose**: Extended member information with privacy controls

**Schema** (abbreviated, see migration 002 for complete):
```sql
CREATE TABLE member_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    -- Public tier (visible to all)
    photo_url VARCHAR(500),
    path_level VARCHAR(50) DEFAULT 'Level 1',
    current_path VARCHAR(100) DEFAULT 'Dynamic Leadership',
    venture_name VARCHAR(200),
    venture_description TEXT,
    industry VARCHAR(100),
    expertise_areas TEXT[] DEFAULT '{}',
    bio TEXT,

    -- Member-only tier (authenticated members)
    phone VARCHAR(30),
    linkedin_url VARCHAR(500),
    website_url VARCHAR(500),
    networking_interests TEXT[] DEFAULT '{}',
    speech_count INTEGER DEFAULT 0,

    -- Private tier (individual + officers)
    personal_goals TEXT,
    communication_goals TEXT,
    officer_notes TEXT,

    -- Additional fields (migration 003)
    city VARCHAR(100),
    country VARCHAR(100),
    tm_member_number VARCHAR(50),
    member_type VARCHAR(20) CHECK (member_type IN ('New', 'Dual', 'Transfer', 'Reinstated')),
    officer_role VARCHAR(100),
    is_founder BOOLEAN DEFAULT false,
    is_rotarian BOOLEAN DEFAULT false,
    joining_date DATE,
    birthday_month VARCHAR(20),
    birthday_day INTEGER CHECK (birthday_day BETWEEN 1 AND 31),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Access Tiers**:

1. **Public Tier** (anyone can see if privacy settings allow):
   - Photo, path level, venture info, expertise, bio

2. **Member-Only Tier** (authenticated club members):
   - Contact info, networking interests, progress metrics

3. **Private Tier** (individual + officers only):
   - Personal goals, officer notes, sensitive info

**Relationships**:
- One-to-one with users (via `user_id`)
- Belongs to one club (via `club_id`)

**RLS**: Controlled by privacy_settings table

**Indexes**:
- Composite search index on common query fields
- Individual indexes on city, country, member_type, is_founder

---

### privacy_settings

**Purpose**: Granular privacy controls for member profiles

**Schema**:
```sql
CREATE TABLE privacy_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,

    -- Public tier controls
    show_photo BOOLEAN DEFAULT true,
    show_venture_info BOOLEAN DEFAULT true,
    show_expertise BOOLEAN DEFAULT true,
    show_bio BOOLEAN DEFAULT true,

    -- Member-only tier controls
    show_phone BOOLEAN DEFAULT false,
    show_linkedin BOOLEAN DEFAULT true,
    show_networking_interests BOOLEAN DEFAULT true,
    show_speech_stats BOOLEAN DEFAULT true,

    -- Cross-club visibility
    allow_cross_club_visibility BOOLEAN DEFAULT false,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Default Settings** (privacy-first):
- Most public tier fields visible by default
- Contact info (phone) private by default
- Cross-club visibility disabled by default

**Usage**: RLS policies check these flags before returning data

---

## Row Level Security

### Security Model

**Authentication**: Supabase Auth with JWT tokens
**Authorization**: RLS policies + role-based checks
**Tenant Isolation**: Club-scoped via `club_id`

### Key RLS Policies

**clubs**:
```sql
CREATE POLICY "clubs_view_own" ON clubs
FOR SELECT
USING (id = public.get_current_user_club_id());
```

**users**:
```sql
CREATE POLICY "users_view_same_club" ON users
FOR SELECT
USING (club_id = public.get_current_user_club_id());
```

**meetings** (officers can insert):
```sql
CREATE POLICY "Officers can insert meetings" ON meetings FOR INSERT WITH CHECK (
    club_id IN (SELECT club_id FROM users WHERE id = auth.uid() AND role IN ('officer', 'admin'))
);
```

**member_profiles** (privacy-aware):
```sql
-- Users always see their own profile
CREATE POLICY "users_own_profile" ON member_profiles
FOR SELECT
USING (user_id = auth.uid());

-- Others see based on privacy settings
CREATE POLICY "users_view_others_profiles" ON member_profiles
FOR SELECT
USING (
    user_id != auth.uid() AND
    user_id IN (SELECT user_id FROM privacy_settings WHERE ...)
);
```

### Helper Functions

**get_current_user_club_id()**: Security definer function to avoid RLS recursion
```sql
CREATE OR REPLACE FUNCTION public.get_current_user_club_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT club_id FROM users WHERE id = auth.uid() LIMIT 1;
$$;
```

---

## Indexes & Performance

### Primary Indexes

**Foreign Keys**:
- `idx_users_club_id` - Club membership queries
- `idx_meetings_club_id` - Club meeting lists
- `idx_speeches_meeting_id` - Meeting agenda
- `idx_speeches_user_id` - User progress tracking
- `idx_meeting_roles_meeting_id` - Role assignments

**Date-Based**:
- `idx_meetings_date` - Calendar views, upcoming meetings

**Search Optimization**:
- `idx_member_profiles_search` - Composite index for member directory
- Individual indexes on city, country, member_type, is_founder

### Performance Targets

- **Member directory search**: <200ms for 500 members
- **Meeting queries**: <50ms for recent meetings
- **User progress**: <100ms for speech history

---

## Migration History

### Sequential Migration Files

**001-initial-schema.sql** (2025-09-27):
- Core tables: clubs, users, meetings, speeches, meeting_roles
- Basic RLS policies
- Performance indexes
- Sample data

**002-member-profiles-extension.sql** (2025-09-28):
- member_profiles table with three-tier access
- privacy_settings table with granular controls
- ecosystem_partners and speech_evaluations tables
- Privacy-aware RLS policies

**003-add-csv-fields.sql** (2025-09-28):
- Additional member_profiles columns for CSV import
- City, country, citizenship, TM member number
- Member type, officer role, team, level
- Founder/Rotarian flags, birthday tracking
- Enhanced search indexes

**004-fix-rls-policies.sql** (2025-09-28):
- Fix infinite recursion in member_profiles RLS
- Corrected policy structure to avoid circular dependencies

**005-add-public-read-policy.sql** (2025-09-28):
- Enable public read access for visible profiles
- Allow unauthenticated visitors to see member directory
- Privacy-controlled visibility

**006-fix-users-rls-recursion.sql** (2025-09-28):
- Security definer function to break RLS recursion
- Updated users and clubs policies
- Performance optimization

**007-rebuild-schema.sql** (2025-09-28):
- Complete schema rebuild for Sprint 1
- Consolidated all previous changes
- WARNING: Drops all tables (use for fresh start only)

---

## Current State

**Production Status**: Phase 1 MVP schema deployed
**Total Tables**: 7 core + extended tables
**RLS Policies**: Fully implemented with recursion fixes
**Performance**: All targets met (<200ms searches)

**Next Phase**: Phase 2 will add cross-club networking features

---

## References

- **Protocol**: [database-protocol.md](database-protocol.md) - Architecture standards
- **Migrations**: [sql-scripts/](sql-scripts/) - Executable SQL files
- **Setup Guide**: [guides/setup-guide.md](guides/setup-guide.md) - Step-by-step instructions

---

**Maintained by**: Claude Code (CTO)
**Last Migration**: 007-rebuild-schema.sql (2025-09-28)
**Next Review**: After Phase 2 planning
