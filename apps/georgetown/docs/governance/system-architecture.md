# Georgetown Rotary Speaker Management - Technical Specification

**Status**: ✅ Production (Deployed and Active)
**Last Updated**: 2025-10-15
**Related Dev Journals**: See [docs/dev-journals/](../dev-journals/)

---

## System Overview

**Project**: Georgetown Rotary Speaker Management System
**Architecture**: Single Page Application (SPA) with Supabase Backend
**Deployment**: Cloudflare Pages (Static Site Generation - China-accessible)
**Target Users**: 50+ Georgetown Rotary Club members (mobile-first)

## Technology Stack

### Frontend Framework & Dependencies
- **React 19.1.1** - UI framework with concurrent features
- **TypeScript 5.8.3** - Type safety and developer experience
- **React Router DOM 7.9.2** - Client-side routing
- **Vite 7.1.6** - Build tool and development server

### UI & Interaction Libraries
- **@dnd-kit/* (6.3.1, 10.0.0, 3.2.2)** - Drag and drop functionality for kanban
- **Lucide React 0.544.0** - Icon system (lightweight, tree-shakeable)
- **date-fns 4.1.0** - Date manipulation and formatting

### Database & Backend
- **Supabase 2.57.4** - PostgreSQL database with real-time subscriptions
- **Environment Variables**: VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY

### Styling & Design System
- **Tailwind CSS 3.4.17** - Utility-first CSS framework
- **Custom Rotary Brand Colors** - Official Rotary International palette
- **Self-hosted Open Sans** - Typography without CDN dependencies

### Build & Development Tools
- **ESLint 9.35.0** - Code linting with React-specific rules
- **PostCSS 8.5.6** - CSS processing for Tailwind
- **Autoprefixer 10.4.21** - CSS vendor prefixing
- **Vite Image Optimizer 2.0.2** - Asset optimization pipeline

## Architecture

### Application Type
**Single Page Application (SPA)** with client-side routing and real-time data synchronization.

### Core Components Architecture
```
App.tsx (Router)
├── KanbanBoard (669 lines) - Speaker kanban workflow with unified navigation
├── SpeakerBureauView (339 lines) - Export/portfolio view
├── CalendarView (255 lines) - Schedule management
├── MemberDirectory (286 lines) - Member management
├── TimelineView (450+ lines) - Annual Rotary year history with narrative editing
├── PhotoGallery (340 lines) - Club photo gallery with search and filtering
├── ServiceProjectsPage - Project management with kanban and cards views
├── PartnersPage - Community partner management
└── AppLayout - Unified navigation wrapper for all sections
```

### Data Flow Pattern
1. **Supabase Client** (`src/lib/supabase.ts`) - Single database connection
2. **Database Config** (`src/lib/database-config.ts`) - Schema version control
3. **Type Definitions** (`src/types/database.ts`) - TypeScript interfaces
4. **Real-time Updates** - Supabase subscriptions for live collaboration

### Mobile Responsiveness Strategy
- **Mobile-first design** (320px-414px primary breakpoints)
- **Touch-optimized interfaces** (44px minimum touch targets)
- **Gesture-based navigation** (swipe between kanban columns)
- **Responsive breakpoints** scaling to 1920px desktop

### Project Structure
```
src/
├── components/           # React components (20+ files)
├── lib/                 # Database configuration and utilities
├── types/               # TypeScript type definitions
├── assets/              # Local fonts, icons, images, styles
└── icons/               # Custom SVG icon components

public/
└── assets/
    ├── fonts/          # Self-hosted Open Sans family
    ├── images/         # Optimized brand assets
    └── documents/      # Static resources

docs/                   # Comprehensive project documentation
├── dev-journals/       # Development history and decisions
├── database/          # Schema documentation
├── brand-assets/      # Brand compliance protocols
└── integrations/      # Third-party service documentation
```

## Data Layer

### Database Schema (Supabase/PostgreSQL)

#### Speakers Table
```typescript
type Speaker = {
  id: string                    # Primary key
  name: string                  # Required field
  job_title?: string           # Marketing field
  email?: string               # Contact information
  phone?: string               # Contact information
  organization?: string        # Affiliation
  topic: string                # Presentation topic (required)
  description?: string         # Marketing field
  primary_url?: string         # Marketing field
  additional_urls?: string[]   # Marketing field
  linkedin_url?: string        # Marketing field
  notes?: string               # Internal notes
  status: 'ideas' | 'approached' | 'agreed' | 'scheduled' | 'spoken' | 'dropped'
  scheduled_date?: string      # ISO date string
  is_rotarian?: boolean        # Marketing field
  rotary_club?: string         # Marketing field
  recommend?: boolean          # Speaker bureau recommendation
  recommendation_date?: string # Speaker bureau workflow
  recommendation_notes?: string # Speaker bureau workflow
  proposer_id?: string         # Member who proposed speaker
  position: number             # Kanban position within status
  created_at: string           # Timestamp
  updated_at: string           # Timestamp
  created_by: string           # User tracking
  updated_by: string           # User tracking
}
```

#### Members Table
```typescript
type Member = {
  id: string                   # Primary key
  prefix?: string             # Title (Dr., Mr., etc.)
  name: string                # Required field
  job_title?: string          # Professional title
  birth_month?: number        # Birthday tracking (1-12)
  birth_day?: number          # Birthday tracking (1-31)
  gender?: string             # Demographics
  rotary_profile_url?: string # Rotary International profile
  rotary_resume?: string      # Rotary service history
  role?: string               # Club position
  type?: string               # Member classification
  member_since?: string       # Join date
  email?: string              # Contact information
  mobile?: string             # Contact information
  phf?: string                # Paul Harris Fellow level
  charter_member?: boolean    # Founding member status
  classification?: string     # Professional classification
  linkedin?: string           # Professional networking
  company_name?: string       # Employer/business
  company_url?: string        # Business website
  active: boolean             # Membership status
  created_at: string          # Timestamp
  updated_at: string          # Timestamp
}
```

#### Rotary Years Table
```typescript
type RotaryYear = {
  id: string                              # Primary key
  rotary_year: string                     # "YYYY-YYYY" format (e.g., "2025-2026")
  start_date: string                      # July 1 of start year
  end_date: string                        # June 30 of end year

  # Club information
  club_name: string                       # Georgetown Rotary Club
  club_number: number                     # Rotary club ID
  district_number: number                 # Rotary district
  charter_date: string                    # Club founding date

  # Leadership themes
  club_president_name: string             # Club president
  club_president_theme?: string           # Presidential theme
  club_president_theme_logo_url?: string  # Theme logo URL
  club_president_photo_url?: string       # Official portrait

  ri_president_name?: string              # RI president
  ri_president_theme?: string             # RI theme
  ri_president_theme_logo_url?: string    # RI theme logo

  dg_name?: string                        # District governor
  dg_theme?: string                       # DG theme
  dg_theme_logo_url?: string              # DG theme logo
  district_governor_photo_url?: string    # DG portrait

  # Annual documentation (Phase 5)
  summary?: string                        # Year overview (2-3 sentences)
  narrative?: string                      # Detailed story
  highlights: { title: string; description: string }[]  # Major achievements
  challenges: { issue: string; resolution: string }[]   # Lessons learned

  # Statistics (auto-calculated from linked records)
  stats: {
    meetings?: number                     # Total meetings held
    speakers?: number                     # Speakers who presented
    projects?: number                     # Completed projects
    beneficiaries?: number                # Total people served
    project_value_rm?: number             # Total project value (RM)
    volunteer_hours?: number              # Total volunteer hours
  }

  photos: { url: string; caption: string }[]  # Year photo gallery
  created_at: string                      # Timestamp
  updated_at: string                      # Timestamp
}
```

#### Club Photos Table (Migration 032 - Pending CEO Execution)
```typescript
type ClubPhoto = {
  id: string                    # Primary key
  storage_path: string          # Supabase storage path (club-photos bucket)
  caption: string               # Photo description (required)
  photographer?: string         # Credit to photographer
  photo_date: string            # Date photo was taken (ISO date)
  event_location?: string       # Where photo was taken

  # Event categorization
  event_type: 'meeting' | 'service' | 'social' | 'observance' | 'fellowship'

  # Organization
  rotary_year_id?: string       # Link to Rotary year (auto-detected from photo_date)
  tags: string[]                # Searchable tags (JSONB array)

  # Metadata
  uploaded_by?: string          # User who uploaded
  created_at: string            # Timestamp
  updated_at: string            # Timestamp
}
```

### Schema Version Control
- **Database Config** controls field availability based on migration status
- **Marketing Fields** toggle via `HAS_MARKETING_FIELDS` flag
- **Backward Compatibility** ensures graceful degradation for unmigrated schemas

### Authentication & Authorization
- **Supabase Auth** for user management
- **Row Level Security (RLS)** for data access control
- **Anonymous access** configured for club member usage

## Build Configuration

### Vite Configuration Highlights
- **React Plugin** with hot module replacement
- **Image Optimization** pipeline for performance
- **Security Headers** (X-Robots-Tag, X-Frame-Options, Content Security)
- **Asset Organization** (fonts, images, documents in dedicated directories)
- **SEO Blocking** for internal club tool privacy

### Deployment Pipeline (Cloudflare Pages)
```
Framework: Vite
Build command: npm run build
Output directory: dist
Install command: npm ci
Node version: 18 or later
```

**Why Cloudflare Pages:**
- Vercel is blocked in China
- Cloudflare's global network provides China accessibility
- Compatible with Vite static builds
- Environment variables managed in Cloudflare dashboard

### Security & Privacy Configuration
- **Search Engine Control** - robots.txt policy (ADR-001): public content indexed, member data blocked
- **Frame Protection** - X-Frame-Options: DENY
- **Content Type Protection** - X-Content-Type-Options: nosniff
- **Referrer Policy** - strict-origin-when-cross-origin

## Unique Features & Technical Decisions

### Georgetown Rotary-Specific Functionality

#### 1. Kanban Speaker Workflow
- **Six-stage pipeline**: Ideas → Approached → Agreed → Scheduled → Spoken → Dropped
- **Drag-and-drop interface** with @dnd-kit for intuitive status updates
- **Mobile gesture support** with swipe navigation between columns
- **Real-time collaboration** via Supabase subscriptions

#### 2. Speaker Bureau Export System
- **Professional portfolio generation** for external sharing
- **Recommendation workflow** with approval tracking
- **Export-ready formatting** for Rotary District distribution

#### 3. Mobile-First Design Philosophy
- **Touch-optimized interfaces** (44px minimum touch targets)
- **Single-column mobile kanban** with horizontal swipe navigation
- **Collapsible navigation** for maximum content space
- **Fast mobile loading** optimized for meeting usage

#### 4. Rotary Brand Compliance
- **Official color palette** (Azure #005daa, Gold #f7a81b)
- **Protected brand assets** with optimization restrictions
- **Professional typography** (self-hosted Open Sans)
- **Consistent visual hierarchy** aligned with Rotary standards

#### 5. China-Friendly Architecture
- **Self-hosted assets** (fonts, icons, images)
- **Network independence** (no external CDN dependencies)
- **Local font serving** from /public/assets/fonts/
- **No blocked services** (Google Fonts, Analytics, etc.)

#### 6. Timeline System (Phases 1-6) ✅ Complete
- **Annual Rotary year history** with leadership themes and statistics
- **Auto-linking system** for speakers (when dragged to "Spoken") and projects (when marked "Completed")
- **Narrative editing** with auto-save (2-second debounce) for year summaries, highlights, and challenges
- **Real-time statistics** updating via Supabase subscriptions
- **Multi-level leadership themes** (RI President, District Governor, Club President)
- **Photo gallery integration** with year-specific albums
- **Member statistics** with growth indicators (new, transferred, resigned)
- **Mobile-responsive timeline** with touch-friendly interactions

#### 7. Photo Gallery System (Phase 5B) ✅ Complete
- **Standalone gallery page** (/photos) with professional lightbox
- **Search and filtering** by caption, photographer, tags, Rotary year, event type
- **Comprehensive metadata** - caption, photographer, location, event date, tags
- **Event categorization** - meeting, service, social, observance, fellowship
- **Image optimization** - client-side compression (max 2MB, 1920px width)
- **Timeline integration** - year-specific photo galleries with edit access control
- **Rotary year auto-detection** from photo date for automatic organization

### Performance Optimizations
- **Image optimization pipeline** with quality controls
- **Tree-shakeable icons** (Lucide React)
- **Code splitting** via Vite's rollup configuration
- **Asset fingerprinting** for cache optimization
- **Lighthouse score targets** >90 on mobile

### Data Architecture Decisions
- **Position-based ordering** for kanban columns (vs. database sorting)
- **Real-time subscriptions** for collaborative editing
- **Schema versioning** for graceful feature rollout
- **Optimistic updates** with conflict resolution

### Security & Privacy Features
- **Selective SEO control** via robots.txt (public content indexed, member data blocked)
- **Professional security headers** for production deployment
- **Environment variable management** for sensitive credentials
- **Row-level security** for multi-user access control

## Development Standards

### Code Quality
- **TypeScript strict mode** for type safety
- **ESLint configuration** with React and accessibility rules
- **Consistent file organization** with feature-based structure
- **Component composition patterns** for reusability

### Testing Strategy
- **Manual QA requirements** before deployment
- **Cross-browser compatibility** (Chrome, Safari, Firefox minimum)
- **Mobile device verification** (iOS/Android responsive testing)
- **Performance monitoring** via Network tab analysis

### Documentation Standards
- **Development journals** for decision tracking
- **Database migration documentation** for schema changes
- **Brand asset protocols** for visual consistency
- **Integration summaries** for third-party services

---

**Technical Maturity**: Production-ready system serving Georgetown Rotary's 50+ member community with professional-grade reliability, mobile optimization, and brand compliance standards worthy of Rotary International leadership.