# HuaQiao Foundation Monorepo Structure - Technical Report

**Prepared for**: External CTO / Technical Stakeholders
**Date**: 2025-12-16
**Author**: HuaQiao CTO (Claude Code)
**Version**: 1.0

---

## Executive Summary

The HuaQiao Foundation monorepo is a **single-app monorepo with shared packages** architecture, built to connect Rotary clubs in Asia with funding partners through a modern service project exchange platform. The initial focus is Bridge (project marketplace), with future expansion to the main Foundation website.

**Key Metrics**:
- **2 applications** (1 production, 1 placeholder): Bridge platform + Foundation main site
- **2 shared packages**: shared components/i18n + auto-generated database types
- **1 Supabase workspace**: PostgreSQL database with 17.3KB initial migration
- **Monorepo tooling**: pnpm workspaces (10.24.0) + Turborepo (2.3.3)
- **Languages**: English + Simplified Chinese (i18next)
- **Target regions**: ASEAN countries (10 nations)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Workspace Structure](#workspace-structure)
3. [Application Details](#application-details)
4. [Shared Packages](#shared-packages)
5. [Scripts & Tooling](#scripts--tooling)
6. [Database Architecture](#database-architecture)
7. [Build & Deployment](#build--deployment)
8. [Documentation Structure](#documentation-structure)
9. [Development Workflow](#development-workflow)
10. [Key Design Decisions](#key-design-decisions)

---

## Architecture Overview

### High-Level Diagram

```
┌────────────────────────────────────────────────────────────┐
│                 HuaQiao Foundation Monorepo                 │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐          ┌──────────────────────┐ │
│  │   Bridge (React)    │          │  Main (Placeholder)  │ │
│  │   Project Exchange  │          │  Foundation Website  │ │
│  │                     │          │                      │ │
│  │ • Project listings  │          │ • (Future)           │ │
│  │ • Club profiles     │          │                      │ │
│  │ • Partner matching  │          │                      │ │
│  │ • Project submission│          │                      │ │
│  │ • Interest tracking │          │                      │ │
│  │ • EN/ZH i18n        │          │                      │ │
│  └─────────────────────┘          └──────────────────────┘ │
│          │                                                   │
│          │                                                   │
│          ▼                                                   │
│  ┌──────────────────────┐                                   │
│  │ Supabase (Postgres)  │                                   │
│  │ • 10 ASEAN countries │                                   │
│  │ • 7 Areas of Focus   │                                   │
│  │ • 17 SDGs            │                                   │
│  │ • Projects (6 status)│                                   │
│  │ • Clubs & Orgs       │                                   │
│  │ • Contacts           │                                   │
│  │ • Interest tracking  │                                   │
│  │ • RLS policies       │                                   │
│  └──────────────────────┘                                   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Shared Packages (workspace:*)               │  │
│  │  • @huaqiao/shared (Logo, i18n, utils)                │  │
│  │  • @huaqiao/types (auto-generated DB types)           │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Monorepo** | pnpm workspaces | 10.24.0 | Dependency management |
| **Build orchestration** | Turborepo | 2.3.3 | Task caching, parallelization |
| **Bridge (React SPA)** | React | 19.2.1 | Service project exchange |
| **Build tool** | Vite | 7.2.7 | Dev server & production builds |
| **Styling** | Tailwind CSS | 4.1.17 | Utility-first CSS (PostCSS plugin) |
| **Database** | Supabase (PostgreSQL) | - | Data layer + Auth + Storage |
| **Type system** | TypeScript | 5.9.3 | Type safety (strict mode) |
| **Routing** | TanStack Router | 1.140.0 | File-based routing |
| **Data fetching** | TanStack Query | 5.90.12 | Server state management |
| **Forms** | React Hook Form | 7.68.0 | Form state + validation |
| **Validation** | Zod | 4.1.13 | Runtime schema validation |
| **i18n** | i18next | 25.7.2 | Internationalization (EN/ZH) |
| **Bot protection** | Cloudflare Turnstile | 1.3.1 | CAPTCHA alternative |
| **Deployment** | Cloudflare Pages | - | Hosting + CDN |

---

## Workspace Structure

### Directory Tree

```
huaqiao/
├── apps/
│   ├── bridge/                    # Service project exchange platform
│   │   ├── src/                   # React source code
│   │   │   ├── components/        # React components
│   │   │   │   ├── ErrorBoundary.tsx
│   │   │   │   ├── layout/        # Header, Footer, Layout
│   │   │   │   └── ui/            # shadcn/ui components
│   │   │   ├── contexts/          # AuthContext (state machine)
│   │   │   ├── lib/               # Supabase client, utilities
│   │   │   ├── pages/             # 16 route pages
│   │   │   ├── types/             # TypeScript types
│   │   │   ├── main.tsx           # App entry point
│   │   │   ├── routeTree.tsx      # TanStack Router config
│   │   │   └── index.css          # Global styles
│   │   ├── public/                # Static assets
│   │   ├── index.html             # HTML entry point
│   │   ├── package.json           # Dependencies
│   │   ├── tsconfig.json          # TypeScript config (strict)
│   │   ├── vite.config.ts         # Vite configuration
│   │   └── postcss.config.js      # Tailwind v4 + autoprefixer
│   │
│   └── main/                      # Foundation main website (placeholder)
│       ├── package.json           # Dependencies
│       └── README.md              # Placeholder documentation
│
├── packages/
│   ├── shared/                    # Shared components, i18n, utilities
│   │   ├── src/
│   │   │   ├── components/        # Logo.tsx, BridgeIcon
│   │   │   ├── i18n/              # i18next setup
│   │   │   │   ├── index.ts       # i18n initialization
│   │   │   │   ├── LanguageSwitcher.tsx
│   │   │   │   └── locales/
│   │   │   │       ├── en.json    # English translations
│   │   │   │       └── zh-CN.json # Simplified Chinese
│   │   │   ├── utils/             # cn() classname utility
│   │   │   ├── types/             # Shared type definitions
│   │   │   └── index.ts           # Public exports
│   │   ├── package.json           # Exports configuration
│   │   └── tsconfig.json          # TypeScript config
│   │
│   └── types/                     # Auto-generated database types
│       ├── src/
│       │   ├── database.ts        # Generated from Supabase schema
│       │   └── index.ts           # Exports
│       ├── package.json           # Gen:types script
│       └── tsconfig.json          # TypeScript config
│
├── supabase/                      # Supabase configuration
│   ├── migrations/
│   │   └── 20251208000001_initial_schema.sql  # Core schema (17.3KB)
│   ├── functions/                 # Edge Functions (empty)
│   └── package.json               # Supabase CLI scripts
│
├── docs/                          # Documentation
│   ├── architecture/              # Design docs, briefings, reports
│   │   ├── 2025-12-08-huaqiao-bridge-cto-briefing-v2.md
│   │   ├── monorepo-decision-brief.md
│   │   ├── monorepo-assessment.md
│   │   ├── monorepo-best-practices-2025.md
│   │   ├── clubs-monorepo-structure-report.md
│   │   ├── palette-tomato-timberwolf.md
│   │   └── huaqiao-monorepo-structure-report.md  ← THIS DOCUMENT
│   ├── adr/                       # Architecture Decision Records
│   │   ├── README.md              # ADR index
│   │   ├── template.md            # ADR template
│   │   └── 0001-typography-and-internationalization.md
│   ├── copy/                      # Website copy and content
│   │   ├── website-copy.md
│   │   └── huaqiao-bridge-website-copy.md
│   ├── plans/                     # Implementation plans
│   │   └── turnstile-setup.md
│   ├── ref/                       # Reference materials
│   │   ├── huaqiao-narrative.md
│   │   └── rotary-organization.md
│   └── dev-journal/               # Development notes
│
├── pnpm-workspace.yaml            # Workspace definition
├── turbo.json                     # Turbo task config
├── package.json                   # Root package.json
├── tsconfig.json                  # Root TypeScript config
├── .env.example                   # Environment template
├── .gitignore                     # Git ignore rules
├── CLAUDE.md                      # Project instructions for AI
└── README.md                      # Project overview
```

---

## Application Details

### Bridge Service Project Exchange (`apps/bridge/`)

**Purpose**: Web platform connecting Rotary clubs in ASEAN with funding partners to accelerate service project implementation.

**Business Model**: Free for Rotary clubs, value-add for funders seeking vetted projects aligned with UN SDGs and Rotary's 7 Areas of Focus.

**Tech Stack**:
- React 19.2.1 + TypeScript 5.9.3 (strict mode)
- Vite 7.2.7 (dev server & build)
- Tailwind CSS 4.1.17 (new PostCSS plugin architecture)
- TanStack Router 1.140.0 (file-based routing)
- TanStack Query 5.90.12 (server state)
- React Hook Form 7.68.0 + Zod 4.1.13 (forms)
- Supabase 2.86.2 (PostgreSQL + Auth)
- i18next 25.7.2 (internationalization)
- Cloudflare Turnstile 1.3.1 (bot protection)

**Key Features**:
1. **Project Discovery** - Browse approved service projects by country, SDG, area of focus
2. **Project Submission** - Rotary clubs submit projects via multi-step form (797 lines)
3. **Club Profiles** - Club directory with verification status
4. **Interest Tracking** - Partners express interest, HQF staff manage follow-ups
5. **Multilingual** - English + Simplified Chinese with browser detection
6. **Role-Based Access** - Public, Rotarian, Club Admin, Partner, HQF Staff, HQF Admin
7. **Bot Protection** - Turnstile on contact/submission forms
8. **Responsive Design** - Mobile-first Tailwind CSS

**Page Structure** (16 pages):

| Route | Component | Lines | Purpose |
|-------|-----------|-------|---------|
| `/` | HomePage | - | Landing with hero, features |
| `/projects` | ProjectsPage | - | Browse all approved projects |
| `/projects/:slug` | ProjectDetailPage | - | Individual project view |
| `/submit` | SubmitProjectPage | 797 | Project submission form |
| `/for-clubs` | ForClubsPage | - | Info for Rotary clubs |
| `/for-partners` | ForPartnersPage | - | Info for funding partners |
| `/about` | AboutPage | - | Foundation information |
| `/yeyaya` | YeYaYaPage | - | HuaQiao history (2004-2016) |
| `/contact` | ContactPage | - | Contact form (with Turnstile) |
| `/sdgs` | SDGsPage | - | UN SDG reference |
| `/style-guide` | StyleGuidePage | - | Design system reference |
| `/style-guide-sans` | StyleGuideSansPage | - | Alternative font demo |
| `/icon-demo` | IconDemoPage | - | Icon library reference |
| `*` | NotFoundPage | - | 404 fallback |

**Authentication**:
- State machine pattern (initial → checking → authenticated/guest)
- Custom storage wrapper validates tokens before Supabase reads
- Prevents "Invalid Refresh Token" errors on page load
- Auto-refresh enabled for valid sessions

**Deployment**: Cloudflare Pages

**Commands**:
```bash
pnpm dev:bridge          # Start dev server (localhost:5173)
pnpm build:bridge        # Production build
pnpm typecheck           # TypeScript validation (monorepo-wide)
```

**Documentation**:
- Root: [CLAUDE.md](/Users/randaleastman/dev/huaqiao/CLAUDE.md) - Project instructions
- Briefing: [docs/architecture/2025-12-08-huaqiao-bridge-cto-briefing-v2.md](../2025-12-08-huaqiao-bridge-cto-briefing-v2.md)
- Copy: [docs/copy/huaqiao-bridge-website-copy.md](../../copy/huaqiao-bridge-website-copy.md)

---

### Main Foundation Website (`apps/main/`)

**Purpose**: HuaQiao Foundation main website (future development).

**Current Status**: Placeholder with package.json only.

**Planned Features**:
- Foundation mission, history, team
- News and updates
- Donor information
- Annual reports
- Events and milestones

**Deployment**: Cloudflare Pages (future)

---

## Shared Packages

All packages use `workspace:*` protocol for internal dependencies.

### `@huaqiao/shared`

**Purpose**: Shared components, internationalization, and utilities for all HuaQiao apps.

**Exports** (package.json):
```json
{
  ".": "./src/index.ts",
  "./components": "./src/components/index.ts",
  "./utils": "./src/utils/index.ts",
  "./types": "./src/types/index.ts",
  "./i18n": "./src/i18n/index.ts",
  "./i18n/LanguageSwitcher": "./src/i18n/LanguageSwitcher.tsx"
}
```

**Key Components**:

1. **Logo.tsx** (56 lines) - HuaQiao Bridge branding
   - BridgeIcon SVG component
   - Logo component with variants (default, light)
   - Option to show/hide icon
   - Responsive sizing

2. **LanguageSwitcher.tsx** - Language selection UI
   - Dropdown with EN/ZH options
   - Browser language detection
   - localStorage persistence
   - i18next integration

**Internationalization Setup**:
- Framework: i18next 25.7.2 + react-i18next 16.4.0
- Languages: English (en), Simplified Chinese (zh-CN)
- Detection: browser language with localStorage fallback
- Namespace support for organization
- Translation files: `locales/en.json`, `locales/zh-CN.json`

**Utilities**:
- `cn()` - Classname utility using clsx + tailwind-merge
- Clean API for conditional classes

**Peer Dependencies**:
```json
{
  "react": "^19.0.0",
  "react-dom": "^19.0.0",
  "i18next": "^25.0.0",
  "react-i18next": "^16.0.0"
}
```

**Used by**: Bridge app (main consumer)

**Location**: `packages/shared/src/`

---

### `@huaqiao/types`

**Purpose**: Auto-generated TypeScript types from Supabase database schema.

**Generation Process**:
1. Start local Supabase: `pnpm --filter @huaqiao/supabase start`
2. Generate types: `pnpm --filter @huaqiao/types gen:types`
3. Outputs to: `packages/types/src/database.ts`

**Exports**:
```typescript
// Database schema types
export type Database = { /* generated types */ }
export type Tables<T> = Database['public']['Tables'][T]['Row']
export type Enums<T> = Database['public']['Enums'][T]
// ... additional helpers
```

**Turbo Task Configuration**:
```json
{
  "@huaqiao/types#gen:types": {
    "dependsOn": ["@huaqiao/supabase#start"],
    "outputs": ["src/database.ts"]
  }
}
```

**Used by**: Bridge app (database queries)

**Location**: `packages/types/src/`

**CRITICAL**: Never manually edit `database.ts` - always regenerate from schema.

---

## Scripts & Tooling

### Root Package Scripts

**File**: `package.json`

```json
{
  "scripts": {
    "dev": "turbo run dev",
    "dev:bridge": "turbo run dev --filter=@huaqiao/bridge",
    "dev:main": "turbo run dev --filter=@huaqiao/main",
    "build": "turbo run build",
    "build:bridge": "turbo run build --filter=@huaqiao/bridge",
    "build:main": "turbo run build --filter=@huaqiao/main",
    "typecheck": "turbo run typecheck",
    "clean": "rm -rf node_modules apps/*/node_modules packages/*/node_modules"
  }
}
```

**Usage**:
```bash
# Development
pnpm dev              # Start all apps in parallel
pnpm dev:bridge       # Bridge only
pnpm dev:main         # Main only (placeholder)

# Production builds
pnpm build            # Build all apps
pnpm build:bridge     # Bridge only
pnpm build:main       # Main only

# Quality assurance
pnpm typecheck        # Full monorepo type checking

# Maintenance
pnpm clean            # Remove all dependencies
pnpm install          # Fresh install
```

---

### Supabase Package Scripts

**File**: `supabase/package.json`

```json
{
  "scripts": {
    "start": "supabase status || supabase start",
    "stop": "supabase stop",
    "reset": "supabase db reset || supabase start",
    "test": "supabase test db",
    "lint": "supabase db lint",
    "diff": "supabase db diff",
    "push": "supabase db push",
    "gen:types": "supabase gen types typescript --local > ../packages/types/src/database.ts"
  }
}
```

**Usage**:
```bash
# Local development
pnpm --filter @huaqiao/supabase start     # Start local Supabase
pnpm --filter @huaqiao/supabase stop      # Stop local instance
pnpm --filter @huaqiao/supabase reset     # Reset to clean state

# Database operations
pnpm --filter @huaqiao/supabase test db   # Run database tests
pnpm --filter @huaqiao/supabase lint      # Lint SQL migrations
pnpm --filter @huaqiao/supabase diff      # Show migration diffs
pnpm --filter @huaqiao/supabase push      # Push migrations to remote

# Type generation
pnpm --filter @huaqiao/supabase gen:types # Generate TypeScript types
```

---

### Vite Configuration

**File**: `apps/bridge/vite.config.ts`

**Key Settings**:
- React plugin with JSX support
- Path aliases: `@/` → `./src/`
- ESM output
- Build optimization for production

---

### PostCSS Configuration

**File**: `apps/bridge/postcss.config.js`

**Tailwind CSS v4** (new PostCSS-first architecture):
```javascript
export default {
  plugins: {
    '@tailwindcss/postcss': {},    // Tailwind v4 PostCSS plugin
    autoprefixer: {}                // Vendor prefixing
  }
}
```

**Migration Notes**:
- Tailwind v4 uses PostCSS plugin (not JIT compiler)
- More performant build times
- Better tree-shaking

---

## Database Architecture

### Supabase (PostgreSQL)

**Migration Files**:
- Location: `supabase/migrations/`
- Initial schema: `20251208000001_initial_schema.sql` (17.3 KB)
- Pattern: Immutable migrations (create new, never edit existing)

**Schema Overview**:

### ENUM Types (Controlled Vocabularies)

```sql
-- Project categorization
CREATE TYPE area_of_focus AS ENUM (
  'peace',
  'disease_prevention',
  'water_sanitation',
  'maternal_child_health',
  'education',
  'economic_development',
  'environment'
);

-- Project lifecycle
CREATE TYPE project_status AS ENUM (
  'draft',
  'submitted',
  'under_review',
  'approved',
  'funded',
  'in_progress',
  'completed',
  'declined'
);

-- Organization types
CREATE TYPE organization_type AS ENUM (
  'rotary',           -- Rotary clubs
  'rotaract',         -- Rotaract clubs
  'jci'               -- Junior Chamber International
);

CREATE TYPE partner_organization_type AS ENUM (
  'foundation',       -- Charitable foundations
  'corporate',        -- Corporate CSR
  'family_office',    -- Family offices
  'ngo',              -- NGOs
  'government',       -- Government agencies
  'other'
);

-- User roles (authorization)
CREATE TYPE user_role AS ENUM (
  'public',           -- Unauthenticated users
  'rotarian',         -- Verified Rotary members
  'club_admin',       -- Club officers
  'partner',          -- Funding partners
  'hqf_staff',        -- HQF staff
  'hqf_admin'         -- HQF administrators
);

-- Contact management
CREATE TYPE contact_type AS ENUM (
  'rotarian',
  'donor',
  'partner',
  'hqf_staff',
  'other'
);

-- Interest tracking
CREATE TYPE interest_type AS ENUM (
  'funding',
  'volunteering',
  'partnership',
  'information'
);

CREATE TYPE interest_status AS ENUM (
  'new',
  'contacted',
  'in_discussion',
  'converted',
  'declined'
);
```

---

### Core Tables

**1. Reference Data (Static)**

```sql
-- ASEAN countries (10 nations)
CREATE TABLE countries (
  code CHAR(2) PRIMARY KEY,          -- ISO 3166-1 alpha-2
  name VARCHAR(100) NOT NULL,
  flag_emoji CHAR(2),
  is_asean BOOLEAN DEFAULT true
);
-- Data: PH, ID, TH, MY, VN, KH, MM, SG, LA, BN

-- Rotary's 7 Areas of Focus
CREATE TABLE areas_of_focus_ref (
  id area_of_focus PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  color_hex CHAR(7),
  icon_name VARCHAR(50)
);
-- Data: peace, disease_prevention, water_sanitation, maternal_child_health,
--       education, economic_development, environment

-- UN Sustainable Development Goals (17 SDGs)
CREATE TABLE sdgs (
  id INTEGER PRIMARY KEY,             -- 1-17
  title VARCHAR(200) NOT NULL,
  description TEXT,
  color_hex CHAR(7) NOT NULL,         -- Official UN SDG colors
  icon_url TEXT
);
```

**2. Organizations**

```sql
-- Rotary/Rotaract/JCI Clubs
CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  organization_type organization_type NOT NULL DEFAULT 'rotary',
  district VARCHAR(50),               -- Rotary district (e.g., D3810)
  country_code CHAR(2) REFERENCES countries(code),
  city VARCHAR(100),
  contact_email VARCHAR(255),
  is_verified BOOLEAN DEFAULT false,  -- HQF verification status
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Indexes: country_code, organization_type, slug

-- Non-Rotary Organizations (Funders, Partners)
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  organization_type partner_organization_type NOT NULL,
  country_code CHAR(2) REFERENCES countries(code),
  website_url TEXT,
  description TEXT,
  logo_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Individual Contacts
CREATE TABLE contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  contact_type contact_type NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(50),
  whatsapp VARCHAR(50),
  linkedin_url TEXT,
  role_title VARCHAR(100),
  tags TEXT[],
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT club_or_org CHECK (
    (club_id IS NOT NULL AND organization_id IS NULL) OR
    (club_id IS NULL AND organization_id IS NOT NULL)
  )
);
-- Indexes: email, club_id, organization_id

-- User Profiles (extends auth.users)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  user_role user_role DEFAULT 'public',
  club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  is_verified BOOLEAN DEFAULT false,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**3. Projects (Core Entity)**

```sql
CREATE TABLE projects (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(150) UNIQUE NOT NULL,

  -- Ownership
  submitting_club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  project_lead_contact_id UUID REFERENCES contacts(id),

  -- Basic Info
  title VARCHAR(300) NOT NULL,
  summary TEXT NOT NULL,                     -- 2-3 sentences
  description TEXT NOT NULL,                 -- Full project details

  -- Classification
  primary_area_of_focus area_of_focus NOT NULL,
  secondary_areas_of_focus area_of_focus[],
  sdg_tags INTEGER[],                        -- Array of SDG IDs (1-17)

  -- Location
  country_code CHAR(2) NOT NULL REFERENCES countries(code),
  region VARCHAR(100),
  city VARCHAR(100),
  location_description TEXT,

  -- Beneficiaries
  beneficiary_count INTEGER,
  beneficiary_description TEXT,
  beneficiary_demographics JSONB,            -- { age_groups, gender, vulnerable }

  -- Budget
  budget_amount NUMERIC(12, 2),              -- Up to 999,999,999.99
  budget_currency CHAR(3) DEFAULT 'USD',
  budget_breakdown JSONB,                    -- Itemized costs

  -- Timeline
  proposed_start_date DATE,
  duration_months INTEGER,
  milestones JSONB,                          -- [ { title, target_date, description } ]

  -- Status
  status project_status DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- HQF Internal
  is_yeyaya_recommended BOOLEAN DEFAULT false,  -- Featured flag
  internal_notes TEXT,                          -- Staff notes
  review_feedback TEXT,                         -- Feedback for club
  declined_reason TEXT                          -- Reason if declined
);
-- Indexes: status, country_code, primary_area_of_focus, submitting_club_id, slug
-- Filtered index: is_yeyaya_recommended = TRUE
```

**4. Project Activity**

```sql
-- Project Updates (Progress Reports)
CREATE TABLE project_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  update_type VARCHAR(50) NOT NULL,          -- milestone, progress, completion, issue
  title VARCHAR(300) NOT NULL,
  content TEXT NOT NULL,
  images TEXT[],                             -- Array of image URLs
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Index: project_id

-- Interest Expressions (Partner → Project)
CREATE TABLE interest_expressions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

  -- Contact Info
  contact_name VARCHAR(200) NOT NULL,
  contact_email VARCHAR(255) NOT NULL,
  contact_phone VARCHAR(50),
  organization_name VARCHAR(200),

  -- Interest Details
  interest_type interest_type NOT NULL,
  message TEXT,

  -- HQF Tracking
  status interest_status DEFAULT 'new',
  hqf_notes TEXT,
  followed_up_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Indexes: project_id, status

-- Investments (HQF Internal Tracking)
CREATE TABLE investments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  investor_organization_id UUID REFERENCES organizations(id),

  amount NUMERIC(12, 2),
  currency CHAR(3) DEFAULT 'USD',
  status VARCHAR(50),                        -- watching, interested, committed, disbursed, completed, declined

  notes TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Indexes: project_id, status
```

---

### Views

**Public Projects View** (security boundary):
```sql
CREATE VIEW projects_public_view AS
SELECT
  p.id, p.slug, p.title, p.summary,
  p.primary_area_of_focus, p.sdg_tags,
  p.country_code, p.city,
  p.budget_amount, p.budget_currency,
  p.status,
  c.name AS club_name, c.city AS club_city, c.country_code AS club_country
FROM projects p
JOIN clubs c ON p.submitting_club_id = c.id
WHERE p.status IN ('approved', 'funded', 'in_progress', 'completed')
  AND c.is_active = true;
```

---

### Row Level Security (RLS)

**All tables have RLS enabled**. Key policies:

**Clubs**:
- `public_read`: Active clubs visible to all
- `hqf_all`: HQF staff/admin full access

**Projects**:
- `public_read`: Approved/funded/in_progress/completed visible to all
- `club_manage`: Club members manage their club's projects
- `hqf_all`: HQF staff/admin full access

**Interest Expressions**:
- `public_insert`: Anyone can express interest
- `hqf_all`: HQF manages all

**Investments**:
- `hqf_only`: HQF staff/admin only

**User Profiles**:
- `own_read`: Users can read their profile
- `hqf_all`: HQF manages all

**Contacts**:
- `club_read`: Club members see club contacts
- `hqf_all`: HQF manages all

**Project Updates**:
- `public_read`: Public sees updates on approved projects
- `club_manage`: Club members manage updates

**Organizations**:
- `public_read`: Public can view
- `hqf_all`: HQF manages all

---

### Key Indexes

**Performance Optimization**:
```sql
-- Projects
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_country ON projects(country_code);
CREATE INDEX idx_projects_area ON projects(primary_area_of_focus);
CREATE INDEX idx_projects_club ON projects(submitting_club_id);
CREATE INDEX idx_projects_slug ON projects(slug);
CREATE INDEX idx_projects_yeyaya ON projects(is_yeyaya_recommended) WHERE is_yeyaya_recommended = TRUE;

-- Contacts
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_club ON contacts(club_id);
CREATE INDEX idx_contacts_org ON contacts(organization_id);

-- Clubs
CREATE INDEX idx_clubs_country ON clubs(country_code);
CREATE INDEX idx_clubs_type ON clubs(organization_type);
CREATE INDEX idx_clubs_slug ON clubs(slug);

-- Interest Expressions
CREATE INDEX idx_interest_project ON interest_expressions(project_id);
CREATE INDEX idx_interest_status ON interest_expressions(status);

-- Investments
CREATE INDEX idx_investments_project ON investments(project_id);
CREATE INDEX idx_investments_status ON investments(status);

-- Project Updates
CREATE INDEX idx_updates_project ON project_updates(project_id);
```

---

### Triggers

**Automatic Timestamp Updates**:
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Applied to all tables with updated_at column
CREATE TRIGGER set_updated_at BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
-- ... (all other tables)
```

---

## Build & Deployment

### Turborepo Configuration

**File**: `turbo.json`

**Global Dependencies**:
```json
{
  "globalDependencies": ["**/.env*"],
  "globalEnv": [
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY",
    "SUPABASE_SERVICE_KEY"
  ]
}
```

**Task Pipeline**:

| Task | Dependencies | Cache | Outputs | Notes |
|------|--------------|-------|---------|-------|
| `build` | `^build` (dependencies first) | Yes | `dist/**` | Apps build after packages |
| `dev` | none | No | - | Persistent dev servers |
| `lint` | `^lint` | Yes | - | Monorepo-wide linting |
| `test` | `@huaqiao/supabase#start`, `^build` | Yes | - | Tests require local DB |
| `typecheck` | `^typecheck` | Yes | - | Full monorepo type checking |
| `@huaqiao/supabase#start` | none | No | - | Starts local Supabase |
| `@huaqiao/supabase#stop` | none | No | - | Stops local Supabase |
| `@huaqiao/supabase#reset` | none | No | - | Resets local database |
| `@huaqiao/types#gen:types` | `@huaqiao/supabase#start` | - | `src/database.ts` | Auto-generates types |

**Benefits**:
- Parallel execution (packages build in parallel where possible)
- Caching (skip unchanged tasks)
- Dependency-aware (types generate after Supabase starts)
- Incremental builds

---

### pnpm Workspace

**File**: `pnpm-workspace.yaml`

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'supabase'
```

**Advantages**:
- **Fast installs** (content-addressable storage)
- **Disk efficiency** (shared dependencies via symlinks)
- **Strict dependency isolation** (no phantom dependencies)
- **Workspace protocol** (`workspace:*` for internal packages)

---

### Environment Variables

**File**: `.env.example`

```bash
# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Cloudflare Turnstile (bot protection)
# Get keys from: https://dash.cloudflare.com/?to=/:account/turnstile
VITE_TURNSTILE_SITE_KEY=your-site-key
TURNSTILE_SECRET_KEY=your-secret-key

# Optional: AI Integration (for Edge Functions)
ANTHROPIC_API_KEY=your-api-key
```

**Important**:
- All env files are gitignored
- Use `VITE_` prefix for client-side variables (Vite requirement)
- Copy `.env.example` to `.env` and fill in real values

---

### Deployment Platform

**Target**: Cloudflare Pages

**Build Commands**:
```bash
# Bridge app
pnpm build:bridge        # Outputs to apps/bridge/dist/

# Main site (future)
pnpm build:main          # Outputs to apps/main/dist/
```

**Deployment Config** (inferred):
- Build directory: `apps/bridge/dist/`
- Build command: `pnpm build:bridge`
- Node version: 18+ (Vite 7 requirement)

**Environment Variables** (Cloudflare Pages):
- Set in Cloudflare dashboard
- Same as `.env.example` (without `VITE_` prefix for secrets)

---

### TypeScript Configuration

**Root** (`tsconfig.json`):
```json
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**Bridge App** (`apps/bridge/tsconfig.json`):
- Extends root config
- Path aliases: `@/` → `./src/`
- React JSX transform
- ESNext target

**Strict Mode Enforcement**:
- No `any` types permitted
- All TypeScript errors must be fixed, never suppressed
- Type-safe database queries via generated types

---

## Documentation Structure

### Organization

```
docs/
├── architecture/                   # Design and architecture docs
│   ├── 2025-12-08-huaqiao-bridge-cto-briefing-v2.md (606 lines)
│   ├── monorepo-decision-brief.md (154 lines)
│   ├── monorepo-assessment.md (331 lines)
│   ├── monorepo-best-practices-2025.md (286 lines)
│   ├── clubs-monorepo-structure-report.md (1119 lines)
│   ├── palette-tomato-timberwolf.md (190 lines)
│   └── huaqiao-monorepo-structure-report.md  ← THIS DOCUMENT
│
├── adr/                            # Architecture Decision Records
│   ├── README.md                   # ADR index
│   ├── template.md                 # ADR template
│   └── 0001-typography-and-internationalization.md (182 lines)
│
├── copy/                           # Website copy and content
│   ├── website-copy.md (910 lines)
│   └── huaqiao-bridge-website-copy.md (910 lines)
│
├── plans/                          # Implementation plans
│   └── turnstile-setup.md (210 lines)
│
├── ref/                            # Reference materials
│   ├── huaqiao-narrative.md        # Foundation history
│   ├── rotary-organization.md      # Rotary structure
│   └── other-sites-architecture.md # Competitor analysis
│
├── dev-journal/                    # Development notes
│   └── [dated entries]             # Chronological implementation logs
│
└── README.md                       # Documentation index
```

### Key Documents

**Entry Points**:
- [CLAUDE.md](/Users/randaleastman/dev/huaqiao/CLAUDE.md) - Project instructions for AI assistants
- [README.md](/Users/randaleastman/dev/huaqiao/README.md) - Project overview
- [docs/README.md](../README.md) - Documentation index

**Architecture Decisions**:
- [docs/adr/README.md](../adr/README.md) - ADR index
- [docs/adr/template.md](../adr/template.md) - Template for new ADRs
- [docs/adr/0001-typography-and-internationalization.md](../adr/0001-typography-and-internationalization.md) - i18n/font decisions

**Technical Briefings**:
- [docs/architecture/2025-12-08-huaqiao-bridge-cto-briefing-v2.md](../architecture/2025-12-08-huaqiao-bridge-cto-briefing-v2.md) - Comprehensive CTO briefing
- [docs/architecture/monorepo-decision-brief.md](../architecture/monorepo-decision-brief.md) - Monorepo rationale

**Content**:
- [docs/copy/huaqiao-bridge-website-copy.md](../../copy/huaqiao-bridge-website-copy.md) - Website messaging and copy

---

## Development Workflow

### Typical Development Flow

**1. Initial Setup**:
```bash
# Clone repository
git clone git@github.com:brandomy/huaqiao-bridge.git
cd huaqiao

# Install dependencies
pnpm install

# Set up environment
cp .env.example .env
# Edit .env with real Supabase credentials

# Start local Supabase
pnpm --filter @huaqiao/supabase start

# Generate database types
pnpm --filter @huaqiao/types gen:types

# Start dev server
pnpm dev:bridge
# → http://localhost:5173
```

**2. Feature Development** (Bridge app):
```bash
# Create new page
cd apps/bridge/src/pages
mkdir new-feature
touch new-feature/NewFeaturePage.tsx

# Add to route tree
vim src/routeTree.tsx

# Test locally
pnpm dev:bridge

# Type check
pnpm typecheck

# Build for production
pnpm build:bridge

# Commit changes
git add apps/bridge/
git commit -m "feat(bridge): Add new feature page"
```

**3. Shared Component Updates**:
```bash
# Add new shared component
cd packages/shared/src/components
touch NewComponent.tsx

# Export from index
vim components/index.ts

# Update package exports
vim ../package.json

# Type check (monorepo-wide)
pnpm typecheck

# Apps using workspace:* auto-detect changes
# Rebuild Bridge to test
pnpm build:bridge

# Commit
git add packages/shared/
git commit -m "feat(shared): Add NewComponent"
```

**4. Database Migrations**:
```bash
# Create new migration
cd supabase/migrations
touch $(date +%Y%m%d%H%M%S)_add_new_table.sql

# Write SQL migration
vim $(ls -t | head -1)

# Apply to local database
pnpm --filter @huaqiao/supabase reset

# Regenerate types
pnpm --filter @huaqiao/types gen:types

# Verify in app
pnpm dev:bridge

# Commit migration + generated types
git add supabase/migrations/ packages/types/src/database.ts
git commit -m "feat(db): Add new_table for feature"

# Push to remote Supabase (when ready)
pnpm --filter @huaqiao/supabase push
```

**5. Internationalization**:
```bash
# Add new translations
cd packages/shared/src/i18n/locales

# Edit English
vim en.json
# Add: "newKey": "English text"

# Edit Chinese
vim zh-CN.json
# Add: "newKey": "中文文本"

# Use in component
import { useTranslation } from 'react-i18next';

const { t } = useTranslation();
return <h1>{t('newKey')}</h1>;

# Commit
git add packages/shared/src/i18n/
git commit -m "feat(i18n): Add newKey translations"
```

---

### Git Workflow

**Branch Strategy**:
- `main` - Production branch
- Feature branches for new features
- Atomic commits per logical change

**Commit Message Conventions**:
```bash
# Bridge app changes
git commit -m "feat(bridge): Add project submission form"
git commit -m "fix(bridge): Resolve Turnstile validation bug"

# Shared package changes
git commit -m "feat(shared): Add Logo component"
git commit -m "fix(i18n): Correct Chinese translation"

# Database changes
git commit -m "feat(db): Add interest_expressions table"
git commit -m "fix(db): Add missing index on projects.status"

# Monorepo-level changes
git commit -m "chore: Update pnpm to 10.24.0"
git commit -m "docs: Add monorepo structure report"
```

**Current Status** (from git status):
```
On branch: main
Untracked: docs/architecture/huaqiao-monorepo-structure-report.md
```

---

## Key Design Decisions

### 1. Monorepo vs. Separate Repositories

**Decision**: Monorepo with pnpm workspaces + Turborepo

**Rationale**:
- ✅ **Shared components** (Logo, i18n, utilities across Bridge + Main)
- ✅ **Atomic commits** (database + app changes in single commit)
- ✅ **Unified tooling** (TypeScript, Tailwind, ESLint configs)
- ✅ **Simplified deployments** (single Git push triggers both apps)
- ✅ **Type safety** (shared database types prevent drift)
- ✅ **Future expansion** (Main site reuses Bridge components)

**Trade-offs**:
- ❌ Larger repo size (~96 MB currently)
- ❌ Requires monorepo tooling knowledge (pnpm, Turbo)
- ✅ Outweighed by developer productivity gains

**ADR**: [docs/architecture/monorepo-decision-brief.md](../architecture/monorepo-decision-brief.md)

---

### 2. Database as Single Source of Truth (SSOT)

**Decision**: Supabase database is authoritative for all schema changes

**Rationale**:
- ✅ **Migration-based versioning** (immutable SQL files in version control)
- ✅ **Type generation** (auto-generate TypeScript types from schema)
- ✅ **Row Level Security** (authorization at database layer)
- ✅ **Audit trail** (migrations document all schema changes)
- ✅ **Team coordination** (no schema drift between environments)

**Implementation**:
- All schema changes via `supabase/migrations/` directory
- Never manually edit committed migrations (create new ones)
- Types regenerated via `gen:types` script
- RLS policies applied before inserting data

**Critical Rule**: [CLAUDE.md Line 23](/Users/randaleastman/dev/huaqiao/CLAUDE.md#L23)

---

### 3. TypeScript Strict Mode Everywhere

**Decision**: TypeScript strict mode enabled in all packages

**Rationale**:
- ✅ **Type safety** (catch errors at compile time)
- ✅ **Better IDE support** (autocomplete, refactoring)
- ✅ **Maintainability** (self-documenting code)
- ✅ **Quality assurance** (enforced by CI/CD)

**Enforcement**:
```typescript
strict: true
noUnusedLocals: true
noUnusedParameters: true
noFallthroughCasesInSwitch: true
noUncheckedIndexedAccess: true
exactOptionalPropertyTypes: true
```

**Critical Rule**: [CLAUDE.md Line 24](/Users/randaleastman/dev/huaqiao/CLAUDE.md#L24) - No `any` types, fix errors never suppress

**ADR**: Implicit (established in initial setup)

---

### 4. Internationalization (i18n) from Day One

**Decision**: Build i18n support into shared package from the start

**Rationale**:
- ✅ **ASEAN focus** (multilingual region, Chinese capital flows)
- ✅ **Browser detection** (auto-detect user language)
- ✅ **Easy expansion** (add languages without refactoring)
- ✅ **Type-safe translations** (TypeScript autocomplete for keys)

**Languages**:
- English (en) - Default, international audience
- Simplified Chinese (zh-CN) - Primary funder demographic

**Framework**: i18next 25.7.2 (industry standard, React integration)

**ADR**: [docs/adr/0001-typography-and-internationalization.md](../adr/0001-typography-and-internationalization.md)

---

### 5. Tailwind CSS v4 (PostCSS Plugin Architecture)

**Decision**: Adopt Tailwind CSS v4 with new PostCSS plugin

**Rationale**:
- ✅ **Performance** (faster builds than JIT compiler)
- ✅ **Better tree-shaking** (smaller production bundles)
- ✅ **Future-proof** (official Tailwind v4 architecture)
- ✅ **Familiar API** (same utility classes as v3)

**Migration Notes**:
- Uses `@tailwindcss/postcss` plugin (not `tailwindcss` JIT compiler)
- Configuration in `postcss.config.js`
- Compatible with Vite 7

---

### 6. TanStack Router (Not React Router)

**Decision**: Use TanStack Router for file-based routing

**Rationale**:
- ✅ **Type-safe routing** (full TypeScript support)
- ✅ **File-based routes** (convention over configuration)
- ✅ **Built-in data loading** (loader patterns)
- ✅ **Modern architecture** (designed for React 18+)
- ✅ **Better DX** (autocomplete for route paths)

**Version**: 1.140.0

**Configuration**: `apps/bridge/src/routeTree.tsx`

---

### 7. Row Level Security (RLS) First

**Decision**: Write RLS policies before inserting production data

**Rationale**:
- ✅ **Security by default** (authorization at database layer)
- ✅ **Role-based access** (public, rotarian, club_admin, partner, hqf_staff, hqf_admin)
- ✅ **Prevents data leaks** (can't bypass with client-side code)
- ✅ **Auditable** (policies in version control)

**Implementation**:
- All tables have RLS enabled
- Policies applied in initial migration
- Public views for approved content
- HQF staff have full access via `hqf_all` policies

**Critical Rule**: [CLAUDE.md Line 25](/Users/randaleastman/dev/huaqiao/CLAUDE.md#L25)

---

### 8. Immutable Migrations

**Decision**: Never edit committed migrations, always create new ones

**Rationale**:
- ✅ **Version control integrity** (Git history matches DB state)
- ✅ **Team coordination** (no conflicts from editing same migration)
- ✅ **Audit trail** (all schema changes documented)
- ✅ **Rollback safety** (can revert individual migrations)

**Pattern**:
```bash
# ❌ WRONG - editing existing migration
vim supabase/migrations/20251208000001_initial_schema.sql

# ✅ CORRECT - creating new migration
touch supabase/migrations/$(date +%Y%m%d%H%M%S)_add_new_field.sql
```

**Critical Rule**: [CLAUDE.md Line 26](/Users/randaleastman/dev/huaqiao/CLAUDE.md#L26)

---

### 9. Cloudflare Turnstile (Not reCAPTCHA)

**Decision**: Use Cloudflare Turnstile for bot protection

**Rationale**:
- ✅ **Privacy-focused** (no tracking cookies)
- ✅ **Better UX** (fewer annoying challenges)
- ✅ **Free tier** (generous limits)
- ✅ **China-accessible** (works behind GFW)
- ✅ **React integration** (@marsidev/react-turnstile)

**Usage**: Contact form, project submission form

**Documentation**: [docs/plans/turnstile-setup.md](../../plans/turnstile-setup.md)

---

### 10. ASEAN-Only Geographic Scope

**Decision**: Restrict geographic scope to 10 ASEAN countries

**Rationale**:
- ✅ **Strategic focus** (HuaQiao 2.0 mission: unlock ASEAN service projects)
- ✅ **Data quality** (manageable scope for verification)
- ✅ **Funder appeal** (clear regional focus)
- ✅ **UI simplicity** (country dropdown with 10 options, not 200)

**Countries**: Philippines, Indonesia, Thailand, Malaysia, Vietnam, Cambodia, Myanmar, Singapore, Laos, Brunei

**Implementation**: `countries` table with `is_asean` filter

---

## Summary of Key Strengths

1. **Modern Tech Stack**: React 19, TypeScript 5.9, Vite 7, Tailwind v4, Supabase
2. **Type Safety**: Strict TypeScript + auto-generated database types
3. **Internationalization**: i18next with EN/ZH support from day one
4. **Monorepo Architecture**: Shared packages + Turborepo orchestration
5. **Database-First Design**: Immutable migrations + RLS policies + type generation
6. **Role-Based Access**: Public, Rotarian, Club Admin, Partner, HQF Staff/Admin
7. **Geographic Focus**: ASEAN-only (10 countries)
8. **Bot Protection**: Cloudflare Turnstile (privacy-focused)
9. **Documented Decisions**: ADR pattern for architectural choices
10. **Quality Enforcement**: Strict TypeScript, RLS-first, immutable migrations

---

## Common Gotchas & Best Practices

### Gotchas

1. **Environment variables**: Must use `VITE_` prefix for client-side vars (Vite requirement)
2. **Database types**: Must regenerate after schema changes (`pnpm --filter @huaqiao/types gen:types`)
3. **Supabase local dev**: Types generation requires running local Supabase instance
4. **Migration immutability**: Never edit committed migrations (create new ones)
5. **RLS policies**: Must be applied before inserting production data
6. **Workspace protocol**: Shared packages use `workspace:*` (not version numbers)
7. **Tailwind v4**: Uses `@tailwindcss/postcss` plugin (not JIT compiler)
8. **TanStack Router**: Different API than React Router (file-based routes)

### Best Practices

1. **Run from root**: Always run workspace commands from monorepo root
   ```bash
   pnpm dev:bridge          # From root
   # NOT: cd apps/bridge && pnpm dev
   ```

2. **Install at root**: Run `pnpm install` at root, not in individual apps
   ```bash
   pnpm install             # At root (installs all workspaces)
   ```

3. **Type generation workflow**:
   ```bash
   # 1. Start local Supabase
   pnpm --filter @huaqiao/supabase start

   # 2. Apply migration
   pnpm --filter @huaqiao/supabase reset

   # 3. Regenerate types
   pnpm --filter @huaqiao/types gen:types

   # 4. Verify in app
   pnpm dev:bridge
   ```

4. **Commit messages**: Use conventional commits with scope
   ```bash
   git commit -m "feat(bridge): Add project submission form"
   git commit -m "fix(db): Add missing index on projects.status"
   git commit -m "docs: Update monorepo structure report"
   ```

5. **Translation workflow**: Update both EN and ZH files simultaneously
   ```bash
   # Add to en.json
   "newKey": "English text"

   # Add to zh-CN.json
   "newKey": "中文文本"

   # Use in component
   const { t } = useTranslation();
   return <h1>{t('newKey')}</h1>;
   ```

6. **Database changes**: Always write RLS policies before inserting data
   ```sql
   -- 1. Create table
   CREATE TABLE new_table (...);

   -- 2. Enable RLS
   ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

   -- 3. Create policies
   CREATE POLICY "public_read" ON new_table FOR SELECT USING (true);
   CREATE POLICY "hqf_all" ON new_table FOR ALL USING (is_hqf_user());

   -- 4. Insert data (now protected)
   INSERT INTO new_table VALUES (...);
   ```

7. **Type-safe database queries**: Use generated types
   ```typescript
   import { Database } from '@huaqiao/types';
   import { supabase } from '@/lib/supabase';

   type Project = Database['public']['Tables']['projects']['Row'];

   const { data, error } = await supabase
     .from('projects')
     .select('*')
     .eq('status', 'approved');
   ```

8. **Clean builds**: Use Turbo's cache for faster rebuilds
   ```bash
   pnpm build               # Uses cache
   pnpm build --force       # Bypass cache (clean build)
   ```

---

## Contact & Maintenance

**Project Owner**: Randal Eastman (CEO, HuaQiao Foundation)

**Primary Maintainer**: HuaQiao CTO (Claude Code)

**Documentation Updates**: This report should be updated when:
- New applications added to monorepo (Main site development)
- Shared packages created/modified
- Database schema changes (major migrations)
- Major architectural decisions made (new ADRs)
- Technology stack upgrades (React, TypeScript, Supabase versions)

**Version History**:
- **v1.0** (2025-12-16) - Initial technical report

---

## Appendices

### A. File Extensions & Conventions

| Extension | Purpose | Example |
|-----------|---------|---------|
| `.tsx` | TypeScript React component | `ProjectCard.tsx` |
| `.ts` | TypeScript utility/type | `supabase.ts` |
| `.sql` | Database migration | `20251208000001_initial_schema.sql` |
| `.json` | Configuration | `package.json`, `en.json` |
| `.md` | Markdown documentation | `CLAUDE.md` |
| `.yaml` | YAML configuration | `pnpm-workspace.yaml` |

---

### B. Environment Variables

**Required in `.env`**:
```bash
# Supabase (required)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Cloudflare Turnstile (required for forms)
VITE_TURNSTILE_SITE_KEY=0x4AAAAAAA...
TURNSTILE_SECRET_KEY=0x4AAAAAAA...

# Optional
ANTHROPIC_API_KEY=sk-ant-...  # For AI-powered Edge Functions
```

**Cloudflare Pages Environment Variables**:
- Set in Cloudflare dashboard under Pages → Settings → Environment Variables
- Use same names (Cloudflare auto-injects `VITE_` prefix if needed)

---

### C. Useful Commands Reference

```bash
# Monorepo Management
pnpm install                             # Install all dependencies
pnpm clean                               # Remove all node_modules

# Development
pnpm dev                                 # All apps in parallel
pnpm dev:bridge                          # Bridge only
pnpm dev:main                            # Main only (future)

# Production Builds
pnpm build                               # Build all apps
pnpm build:bridge                        # Bridge only
pnpm build:main                          # Main only (future)

# Quality Assurance
pnpm typecheck                           # Full monorepo type checking

# Database (Supabase)
pnpm --filter @huaqiao/supabase start    # Start local Supabase
pnpm --filter @huaqiao/supabase stop     # Stop local Supabase
pnpm --filter @huaqiao/supabase reset    # Reset to clean state
pnpm --filter @huaqiao/supabase test db  # Run database tests
pnpm --filter @huaqiao/supabase lint     # Lint SQL migrations
pnpm --filter @huaqiao/supabase diff     # Show migration diffs
pnpm --filter @huaqiao/supabase push     # Push migrations to remote

# Type Generation
pnpm --filter @huaqiao/types gen:types   # Generate TypeScript types from schema

# Git
git status                               # Check changes
git add apps/bridge/                     # Stage Bridge changes
git commit -m "feat(bridge): Add feature" # Commit with conventional message
git push origin main                     # Push to GitHub
```

---

### D. Technology Version Matrix

| Dependency | Bridge | Main | Shared | Types | Notes |
|------------|--------|------|--------|-------|-------|
| React | 19.2.1 | - | peer dep | - | ✅ Latest stable |
| TypeScript | 5.9.3 | - | 5.9.3 | 5.9.3 | ✅ Aligned |
| Vite | 7.2.7 | - | - | - | ✅ Latest |
| Tailwind CSS | 4.1.17 | - | - | - | ✅ v4 PostCSS plugin |
| TanStack Router | 1.140.0 | - | - | - | File-based routing |
| TanStack Query | 5.90.12 | - | - | - | Server state |
| Supabase JS | 2.86.2 | - | - | - | PostgreSQL + Auth |
| i18next | 25.7.2 | - | peer dep | - | ✅ Latest |
| react-i18next | 16.4.0 | - | peer dep | - | React integration |
| React Hook Form | 7.68.0 | - | - | - | Form state |
| Zod | 4.1.13 | - | - | - | Runtime validation |
| Cloudflare Turnstile | 1.3.1 | - | - | - | Bot protection |
| pnpm | 10.24.0 | - | - | - | Package manager |
| Turborepo | 2.3.3 | - | - | - | Build orchestration |

**Version Alignment**: All critical dependencies aligned across monorepo.

---

### E. Project Statistics

**Repository**:
- Total size: 96 MB
- Git remote: git@github.com:brandomy/huaqiao-bridge.git
- Current branch: main

**Code Metrics**:
- Bridge app: 37 TS/TSX files
- Shared package: 6 components + i18n setup
- Database migrations: 1 (17.3 KB initial schema)
- Documentation: ~5,097 lines across markdown files

**Database Schema**:
- Tables: 11 core + 3 reference
- Views: 1 (projects_public_view)
- Indexes: 16+ performance indexes
- Enums: 7 controlled vocabularies
- Triggers: 1 (update_updated_at)

**Supported Languages**:
- English (en) - Default
- Simplified Chinese (zh-CN)

**Geographic Scope**:
- ASEAN countries: 10
- Rotary Areas of Focus: 7
- UN SDGs: 17

**User Roles**:
- Public (unauthenticated)
- Rotarian (verified members)
- Club Admin (club officers)
- Partner (funders)
- HQF Staff (foundation staff)
- HQF Admin (administrators)

---

**End of Report**
