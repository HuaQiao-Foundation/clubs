
# TECHNICAL IMPLEMENTATION SPECIFICATION (TIS)
**Pitchmasters Platform - MVP Architecture**  
**Version 1.0** | **Date: September 30, 2025**

## 1. TECHNOLOGY STACK

### Frontend
- **Framework**: React 19.1.1 + TypeScript 5.7.2
- **Build Tool**: Vite 7.1.6
- **Routing**: React Router DOM 7.9.3
- **Styling**: Tailwind CSS 3.4.17 + Custom CSS
- **UI Libraries**: @dnd-kit (drag-drop), Lucide React (icons), date-fns (dates)

### Backend & Database
- **Database**: Supabase (PostgreSQL 15) - Free Tier
- **Authentication**: Supabase Auth (JWT)
- **Real-time**: Supabase Realtime (WebSocket)
- **Storage**: Supabase Storage (file uploads) - Free Tier

### Hosting & Deployment
- **Hosting**: Cloudflare Pages (free tier, global edge network)
- **Domain**: pitchmasters.app (Cloudflare DNS)
- **SSL**: Automatic via Cloudflare
- **CI/CD**: GitHub Actions → Cloudflare Pages

### Development Tools
- **Version Control**: Git + GitHub
- **Code Quality**: ESLint 9.15.0, TypeScript ESLint 8.15.0
- **Package Manager**: npm
- **Testing**: Manual testing + future automated tests

## 2. DATABASE ARCHITECTURE

### Multi-Tenant Schema Design

```sql
-- Root tenant table
CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  charter_number VARCHAR(50),
  timezone VARCHAR(50) DEFAULT 'UTC+8',
  meeting_visibility VARCHAR(50) DEFAULT 'public', -- public, members_only, private
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Club members with role-based access
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  birthday DATE, -- For birthday recognition
  role VARCHAR(50) DEFAULT 'member', -- member, officer, admin
  officer_position VARCHAR(100), -- president, vpe, secretary, treasurer, saa, vppr, vpm
  pathways_path VARCHAR(100),
  pathways_level INTEGER DEFAULT 1,
  photo_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(email, club_id)
);

-- Pathways badges and achievements
CREATE TABLE pathways_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  badge_type VARCHAR(100) NOT NULL, -- level_1, level_2, level_3, level_4, level_5, dtm, etc
  badge_name VARCHAR(255) NOT NULL,
  path_name VARCHAR(100), -- pathways path name
  earned_date DATE NOT NULL,
  certificate_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Awards and recognition
CREATE TABLE awards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  award_type VARCHAR(100) NOT NULL, -- best_speaker, best_evaluator, cc, alb, acs, acg, als, dtm
  award_name VARCHAR(255) NOT NULL,
  award_date DATE NOT NULL,
  description TEXT,
  certificate_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Meeting management
CREATE TABLE meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  meeting_type VARCHAR(50) DEFAULT 'regular', -- regular, special, demo
  meeting_mode VARCHAR(50) DEFAULT 'hybrid', -- in_person, online, hybrid
  meeting_link TEXT, -- Zoom/Teams link for online/hybrid meetings
  recording_url TEXT, -- Post-meeting recording link
  status VARCHAR(50) DEFAULT 'scheduled', -- scheduled, in_progress, completed, cancelled
  agenda_pdf_url TEXT,
  guest_visibility BOOLEAN DEFAULT TRUE, -- Allow cross-club guests to see this meeting
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cross-club guest registrations
CREATE TABLE guest_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
  guest_name VARCHAR(255) NOT NULL,
  guest_email VARCHAR(255) NOT NULL,
  guest_club_name VARCHAR(255), -- If guest is from another club
  guest_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL, -- If registered user from another club
  registration_status VARCHAR(50) DEFAULT 'pending', -- pending, approved, declined
  attended BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attendance confirmation system
CREATE TABLE attendance_confirmations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, declined
  confirmed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(meeting_id, user_id)
);

-- Meeting roles assignment
CREATE TABLE meeting_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  role_type VARCHAR(100) NOT NULL, -- toastmaster, evaluator, timer, grammarian, ah_counter, table_topics_master
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Speech tracking
CREATE TABLE speeches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  manual VARCHAR(100), -- pathways, cc, cl, etc
  project_number INTEGER,
  objectives TEXT[],
  duration_minutes INTEGER,
  evaluator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  recording_url TEXT, -- Individual speech recording if available
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Digital evaluations
CREATE TABLE evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  speech_id UUID REFERENCES speeches(id) ON DELETE CASCADE,
  evaluator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  commendations TEXT[],
  recommendations TEXT[],
  overall_score INTEGER, -- 1-5
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Club analytics data (aggregated metrics)
CREATE TABLE club_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  metric_date DATE NOT NULL,
  active_members INTEGER DEFAULT 0,
  meetings_held INTEGER DEFAULT 0,
  speeches_delivered INTEGER DEFAULT 0,
  guests_attended INTEGER DEFAULT 0,
  average_attendance_rate DECIMAL(5,2),
  member_engagement_score DECIMAL(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(club_id, metric_date)
);

-- Member engagement tracking
CREATE TABLE member_engagement (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  metric_date DATE NOT NULL,
  meetings_attended INTEGER DEFAULT 0,
  speeches_given INTEGER DEFAULT 0,
  roles_filled INTEGER DEFAULT 0,
  evaluations_given INTEGER DEFAULT 0,
  engagement_score DECIMAL(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, metric_date)
);

-- Member profiles (Phase 3)
CREATE TABLE member_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  venture_name VARCHAR(255),
  industry VARCHAR(100),
  expertise_areas TEXT[],
  public_bio TEXT,
  contact_info JSONB,
  visibility_settings JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ecosystem partners (Phase 3)
CREATE TABLE ecosystem_partners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  company_name VARCHAR(255) NOT NULL,
  industry VARCHAR(100),
  partnership_type VARCHAR(100),
  description TEXT,
  contact_details JSONB,
  verification_status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Row Level Security (RLS) Policies

```sql
-- Users can only see their club's data
CREATE POLICY "Users see own club data" ON users
  FOR SELECT USING (club_id = current_club_id());

-- Officers can manage their club
CREATE POLICY "Officers manage club" ON meetings
  FOR ALL USING (
    club_id = current_club_id() AND
    user_role() IN ('officer', 'admin')
  );

-- Members can view meeting details
CREATE POLICY "Members view meetings" ON meetings
  FOR SELECT USING (club_id = current_club_id());

-- Public meetings visible to all for guest registration
CREATE POLICY "Public meetings visible" ON meetings
  FOR SELECT USING (guest_visibility = TRUE AND status = 'scheduled');

-- Members can see own badges and achievements
CREATE POLICY "Members see own achievements" ON pathways_badges
  FOR SELECT USING (user_id = auth.uid());

-- Members can see other club members' badges (public profiles)
CREATE POLICY "Club members see peer badges" ON pathways_badges
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM users WHERE club_id = current_club_id()
    )
  );
```

### Indexes for Performance

```sql
CREATE INDEX idx_users_club_id ON users(club_id);
CREATE INDEX idx_users_birthday ON users(birthday) WHERE birthday IS NOT NULL;
CREATE INDEX idx_meetings_club_id_date ON meetings(club_id, date);
CREATE INDEX idx_meetings_guest_visibility ON meetings(guest_visibility, status);
CREATE INDEX idx_speeches_meeting_id ON speeches(meeting_id);
CREATE INDEX idx_attendance_meeting_id ON attendance_confirmations(meeting_id);
CREATE INDEX idx_pathways_badges_user_id ON pathways_badges(user_id);
CREATE INDEX idx_awards_user_id ON awards(user_id);
CREATE INDEX idx_member_engagement_user_date ON member_engagement(user_id, metric_date);
CREATE INDEX idx_club_analytics_club_date ON club_analytics(club_id, metric_date);
```

## 3. APPLICATION ARCHITECTURE

### File Structure
```
pitchmasters/
├── public/
│   ├── assets/
│   │   └── fonts/          # Self-hosted Montserrat, Source Sans 3
│   └── manifest.webmanifest
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── AttendanceConfirmation.tsx
│   │   ├── RoleAssignment.tsx
│   │   ├── AgendaBuilder.tsx
│   │   ├── MemberDirectory.tsx
│   │   ├── MemberProfile.tsx
│   │   ├── BadgeDisplay.tsx
│   │   ├── AwardsShowcase.tsx
│   │   ├── BirthdayWidget.tsx
│   │   ├── GuestRegistration.tsx
│   │   ├── MeetingCalendar.tsx
│   │   ├── ClubAnalyticsDashboard.tsx
│   │   └── Layout.tsx
│   ├── pages/              # Route-specific pages
│   │   ├── Dashboard.tsx
│   │   ├── MeetingsPage.tsx
│   │   ├── PublicMeetingsCalendar.tsx
│   │   ├── MembersPage.tsx
│   │   ├── MemberProfilePage.tsx
│   │   ├── AnalyticsPage.tsx
│   │   └── CommunityPage.tsx
│   ├── hooks/              # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useClub.ts
│   │   ├── useAnalytics.ts
│   │   └── useDebounce.ts
│   ├── lib/                # External services
│   │   └── supabase.ts
│   ├── types/              # TypeScript definitions
│   │   └── index.ts
│   ├── utils/              # Helper functions
│   │   ├── permissions.ts
│   │   ├── privacy.ts
│   │   └── analytics.ts
│   └── App.tsx
├── docs/                   # Project documentation
│   ├── claude.md           # Claude Code instructions
│   ├── PDD.md              # This document
│   ├── TIS.md              # Technical specs
│   ├── database/
│   │   └── database-protocol.md
│   └── expert-standards.md
├── TODO.md                 # Sprint tracking
└── package.json
```

### Component Architecture

**Club Analytics Dashboard Flow**:
```
ClubAnalyticsDashboard Component
  ↓
  ├── Fetch club_analytics aggregated data
  ├── Fetch member_engagement individual metrics
  ├── Calculate trends (attendance, engagement, growth)
  ├── Display key metrics cards
  │   ├── Active Members
  │   ├── Meeting Attendance Rate
  │   ├── Speeches Per Month
  │   ├── Guest Conversion Rate
  │   └── Member Engagement Score
  ├── Show charts (attendance trends, role distribution)
  ├── Member health alerts (at-risk members)
  └── Export reports (PDF/CSV)
```

**Badge & Awards Display Flow**:
```
MemberProfile Component
  ↓
  ├── Fetch pathways_badges for user
  ├── Fetch awards for user
  ├── Display badge gallery (visual icons)
  ├── Show achievement timeline
  ├── Calculate completion progress
  └── Link to certificate URLs
```

**Cross-Club Guest System Flow**:
```
PublicMeetingsCalendar Component
  ↓
  ├── Fetch meetings WHERE guest_visibility = TRUE
  ├── Display calendar view (all clubs)
  ├── Filter by date, club, meeting type
  └── Enable guest registration

GuestRegistration Component
  ↓
  ├── Capture guest details (name, email, club)
  ├── Submit to guest_registrations table
  ├── Send confirmation email
  ├── Add guest to meeting attendance
  └── Track guest conversion metrics
```

### State Management
- **Local State**: React useState for component-level state
- **Global State**: React Context for auth, club, user data
- **Server State**: Supabase queries with real-time subscriptions
- **Form State**: Controlled components with validation
- **Analytics State**: Aggregated metrics with daily cron jobs

### API Integration Pattern
```typescript
// Supabase client setup
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
);

// Example: Fetch meetings with badges and analytics
const { data: meetings, error } = await supabase
  .from('meetings')
  .select(`
    *,
    meeting_roles(*, users(*, pathways_badges(*))),
    guest_registrations(*)
  `)
  .eq('club_id', clubId)
  .order('date', { ascending: true });

// Example: Club analytics query
const { data: analytics } = await supabase
  .from('club_analytics')
  .select('*')
  .eq('club_id', clubId)
  .gte('metric_date', startDate)
  .lte('metric_date', endDate)
  .order('metric_date', { ascending: true });
```

## 4. MOBILE-FIRST DESIGN IMPLEMENTATION

### Responsive Breakpoints
```css
/* Mobile-first approach */
/* 320px-414px: Primary mobile experience */
/* 415px-767px: Large phones/small tablets */
/* 768px-1023px: Tablets */
/* 1024px+: Desktop enhancement */
```

### Touch Optimization
- **Minimum touch targets**: 44px × 44px
- **Swipe gestures**: useSwipeGesture custom hook
- **One-handed operation**: Bottom navigation, thumb-friendly zones
- **Offline support**: Service worker + IndexedDB caching

### Performance Targets
- **First Contentful Paint**: <1.5s
- **Largest Contentful Paint**: <2.5s
- **Total Blocking Time**: <200ms
- **Cumulative Layout Shift**: <0.1
- **Bundle Size**: <500KB initial, <1MB total

## 5. TOASTMASTERS BRAND COMPLIANCE

### Color Palette Implementation
```css
:root {
  /* Primary Colors */
  --loyal-blue: #004165;
  --true-maroon: #772432;
  --cool-gray: #A9B2B1;
  --white: #ffffff;
  --black: #000000;
  
  /* Accent Color (use sparingly) */
  --happy-yellow: #F2DF74;
  
  /* Startup Complementary Colors */
  --innovation-green: #10B981;
  --founder-orange: #F59E0B;
  --insight-purple: #8B5CF6;
}
```

### Typography Implementation
```css
@font-face {
  font-family: 'Montserrat';
  src: url('/assets/fonts/Montserrat-Regular.woff2') format('woff2');
  font-weight: 400;
  font-display: swap;
}

@font-face {
  font-family: 'Source Sans 3';
  src: url('/assets/fonts/SourceSans3-Regular.woff2') format('woff2');
  font-weight: 400;
  font-display: swap;
}

h1, h2, h3 { font-family: 'Montserrat', sans-serif; }
body { font-family: 'Source Sans 3', sans-serif; }
```

### Required Disclaimer Component
```typescript
export const ToastmastersDisclaimer = () => (
  <footer className="text-sm text-cool-gray p-4">
    The information on this website is for the sole use of Toastmasters' 
    members, for Toastmasters business only. It is not to be used for 
    solicitation and distribution of non-Toastmasters material or information.
  </footer>
);
```

## 6. DEPLOYMENT STRATEGY

### Cloudflare Pages Configuration
```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloudflare Pages
on:
  push:
    branches: [main]
    
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: pitchmasters
          directory: dist
```

### Environment Variables
```bash
# .env.local (development)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Cloudflare Pages (production)
# Set via dashboard: Settings > Environment Variables
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY
```

### Build Optimization
```javascript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom', 'react-router-dom'],
          'supabase': ['@supabase/supabase-js'],
          'ui': ['@dnd-kit/core', 'lucide-react', 'date-fns']
        }
      }
    },
    chunkSizeWarningLimit: 1000,
    sourcemap: false,
    minify: 'esbuild'
  }
});
```

## 7. DEVELOPMENT WORKFLOW

### Git Branching Strategy
```
main (production)
  ↓
develop (staging)
  ↓
feature/attendance-confirmation
feature/analytics-dashboard
feature/guest-system
feature/badges-awards
```

### Daily Development Cycle
1. **Morning**: Claude Code reviews TODO.md against PDD phase goals
2. **Development**: Implement features with manual testing
3. **Testing**: Manual verification on mobile + desktop
4. **Commit**: Descriptive commits with TODO.md updates
5. **Push**: Triggers GitHub Actions sync
6. **Deploy**: Automatic to Cloudflare Pages staging

### Sprint Cycle (2 weeks)
- **Monday Week 1**: Sprint planning with CEO referencing PDD
- **Daily**: Standup via TODO.md updates
- **Friday Week 2**: Sprint review against PDD success metrics, retrospective
- **Weekend**: Buffer for completion

## 8. TESTING STRATEGY

### Manual Testing Checklist
```markdown
- [ ] Mobile (320px): Core functions work
- [ ] Tablet (768px): Layout adapts properly
- [ ] Desktop (1920px): Enhanced features display
- [ ] Touch targets: All buttons ≥44px
- [ ] Fonts: Self-hosted assets load
- [ ] Brand compliance: Colors, logos, disclaimer present
- [ ] Performance: <3s load time on 3G
- [ ] Authentication: Login/logout flows
- [ ] Multi-club: Data isolation verified
- [ ] Analytics: Dashboard displays accurate metrics
- [ ] Badges: Display correctly on profiles
- [ ] Guest system: Registration and RSVP working
- [ ] Birthday widget: Shows upcoming birthdays
```

### Future Automated Testing
- **Unit Tests**: Vitest for utility functions
- **Integration Tests**: Testing Library for components
- **E2E Tests**: Playwright for critical user flows
- **Performance Tests**: Lighthouse CI

## 9. MONITORING & ANALYTICS

### Performance Monitoring
```typescript
// Custom hook for Core Web Vitals
export const usePerformanceMetrics = () => {
  useEffect(() => {
    if ('web-vital' in window) {
      getCLS(console.log);
      getFID(console.log);
      getLCP(console.log);
    }
  }, []);
};
```

### Club Analytics Implementation
```typescript
// Cron job to aggregate daily metrics
export const calculateDailyAnalytics = async (clubId: string) => {
  const today = new Date();
  const thirtyDaysAgo = new Date(today.setDate(today.getDate() - 30));
  
  // Calculate active members (attended in last 30 days)
  const { data: activeMembers } = await supabase
    .from('attendance_confirmations')
    .select('user_id')
    .eq('status', 'confirmed')
    .gte('created_at', thirtyDaysAgo);
  
  // Calculate average attendance rate
  // Calculate engagement scores
  // Store in club_analytics table
};
```

### Error Tracking (Future)
- **Sentry**: Production error monitoring
- **Supabase Logs**: Database query performance
- **Cloudflare Analytics**: Traffic patterns, edge performance

### User Analytics (Privacy-Respecting)
- **Plausible Analytics**: GDPR-compliant, no cookies
- **Supabase**: Custom event tracking for business metrics
- **Focus**: Member engagement, feature adoption, retention

## 10. FEATURE IMPLEMENTATION PRIORITY

### Phase 1: Core Operations (Weeks 1-12)
**Sprint 1 (Weeks 1-4): Foundation**
- Multi-club database schema with new tables (badges, awards, analytics, guests)
- Smart attendance confirmation system
- Algorithmic role assignment
- Mobile-first responsive framework
- Member profiles with birthday field

**Sprint 2 (Weeks 5-8): Meeting Management**
- Smart agenda builder
- Speech scheduling with Pathways tracking
- Digital evaluation system
- Meeting calendar with guest visibility
- Recording URL fields

**Sprint 3 (Weeks 9-12): Recognition & Analytics**
- Pathways badge system (display on profiles)
- Awards showcase on member profiles
- Birthday recognition widget
- Club analytics dashboard (basic metrics)
- DCP progress tracking

### Phase 2: Community (Weeks 13-24)
**Sprint 4 (Weeks 13-16): Cross-Club Features**
- Public meeting calendar
- Guest registration system
- Cross-club RSVP workflow
- Post-meeting recording links
- Enhanced analytics (guest conversion tracking)

**Sprint 5 (Weeks 17-20): Enhanced Recognition**
- Achievement celebration automation
- Email notifications for badges/awards
- Member milestone timelines
- Club leaderboards (optional)
- Enhanced birthday features

**Sprint 6 (Weeks 21-24): Advanced Analytics**
- Member engagement scoring
- At-risk member alerts
- Predictive insights
- Officer dashboards
- Export reports (PDF/CSV)

### Phase 3: Multi-Club Scale (Weeks 25-52)
- Cross-club networking directory
- Advanced community platform
- China infrastructure optimization
- Integration ecosystem
- Revenue preparation (future Phase 4)

---

## INTEGRATION WITH EXISTING DOCUMENTATION

### Updated claude.md Structure
```markdown
# Pitchmasters Toastmasters Club Management - MVP

## Business Context (from PDD)
Building the world's first mobile-optimized, multi-club Toastmasters platform specifically designed for startup founders (18-80), solving operational pain points while enabling global community connections.

## Current Phase (from PDD Section 3)
**Phase 1: Internal MVP** (Weeks 1-12)
**Goal**: Solve Pitchmasters' operational challenges first
**Success**: Meeting planning <15 min, 95% attendance accuracy, digital badges/analytics operational
**See**: docs/PDD.md for complete requirements

## Tech Stack (from TIS Section 1)
React 19.1.1 + TypeScript + Vite 7.1.6 | Supabase PostgreSQL | Cloudflare Pages | Tailwind CSS | Self-hosted fonts | Free Tier First

## Quality Gates (from PDD Section 7)
- [ ] Meeting planning time <15 minutes
- [ ] Club analytics dashboard operational
- [ ] Digital badges on member profiles
- [ ] Birthday recognition automated
- [ ] Mobile-first (320px-414px) with 44px touch targets
- [ ] <3s load times on 3G networks
- [ ] Toastmasters brand compliance verified

## This Week's Implementation (from TODO.md)
[Current sprint tasks from TODO.md]

## Critical Constraints
- **Multi-club architecture** with complete tenant isolation
- **Free tier first** - No payment features until Phase 4
- **Toastmasters brand compliance** - Official colors, fonts, disclaimers
- **Mobile-first** - Founders primarily use phones
- **China-friendly** - Self-hosted assets, zero external dependencies
- **Community-focused** - Cross-club guest system, recognition features

## References
- **PDD**: docs/PDD.md (business requirements, phases, success criteria)
- **TIS**: docs/TIS.md (technical architecture, database schema, implementation)
- **Sprint Tracking**: TODO.md (daily task management)
- **Database Protocol**: docs/database/database-protocol.md
- **Brand Guidelines**: docs/toastmasters-brand-guide.md
```

### Document Hierarchy
```
docs/
├── PDD.md                      # Business requirements (CEO owns)
├── TIS.md                      # Technical specs (Claude Code implements)
├── claude.md                   # Quick reference (synced from PDD/TIS)
├── expert-standards.md         # Quality verification standards
├── database/
│   └── database-protocol.md    # Multi-club architecture details
├── toastmasters-brand-guide.md # Brand compliance requirements
└── sprints/
    ├── sprint-1-foundation.md  # Current sprint detailed tasks
    ├── sprint-2-management.md  # Next sprint
    └── sprint-3-recognition.md # Recognition & analytics sprint
```
