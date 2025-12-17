# Clubs Monorepo Structure - Technical Report

**Prepared for**: External CTO / Technical Stakeholders
**Date**: 2025-12-16
**Author**: Clubs CTO (Claude Code)
**Version**: 1.0

---

## Executive Summary

The Clubs monorepo houses **two specialized club management applications**: Georgetown (Rotary speaker/event coordination) and Pitchmasters (Toastmasters club operations). This architecture enables rapid parallel development of domain-specific club management solutions while maintaining consistent technical standards and deployment infrastructure.

**Key Metrics**:
- **2 production applications** (React 19 + TypeScript + Vite 7)
- **Independent feature sets** (speaker management vs. meeting roles)
- **Shared technology stack** (React, Supabase, Cloudflare deployment)
- **Monorepo tooling**: npm workspaces (no task orchestration layer)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Workspace Structure](#workspace-structure)
3. [Application Details](#application-details)
4. [Shared Technologies](#shared-technologies)
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
┌─────────────────────────────────────────────────────────────┐
│                    Clubs Monorepo                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────┐         ┌──────────────────────┐   │
│  │  Georgetown (React) │         │ Pitchmasters (React) │   │
│  │  Rotary Speakers    │         │ Toastmasters Club    │   │
│  │                     │         │                      │   │
│  │ • Speaker pipeline  │         │ • Meeting planning   │   │
│  │ • Event scheduling  │         │ • Member roles       │   │
│  │ • Member mgmt       │         │ • Speech tracking    │   │
│  │ • Program coord     │         │ • Performance data   │   │
│  │ • TipTap editor     │         │ • Digital badges     │   │
│  └─────────────────────┘         └──────────────────────┘   │
│          │                                   │               │
│          └──────────┬────────────────────────┘               │
│                     │                                        │
│                     ▼                                        │
│          ┌──────────────────────┐                            │
│          │ Supabase (Postgres)  │                            │
│          │ • Independent DBs    │                            │
│          │ • Auth (Georgetown)  │                            │
│          │ • Storage (both)     │                            │
│          └──────────────────────┘                            │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │          Shared Infrastructure                         │  │
│  │  • npm workspaces (dependency management)              │  │
│  │  • Tailwind CSS (both apps)                            │  │
│  │  • React Router 7 (both apps)                          │  │
│  │  • DnD Kit (drag-drop in both)                         │  │
│  │  • Cloudflare Pages (deployment)                       │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Monorepo** | npm workspaces | 9.0.0+ | Dependency management |
| **Georgetown** | React | 19.1.1 | Rotary speaker management |
| **Pitchmasters** | React | 19.1.1 | Toastmasters club operations |
| **Build tool** | Vite | 7.1.6 | Dev server & production builds |
| **Styling** | Tailwind CSS | 3.4.17 | Utility-first CSS (both apps) |
| **Database** | Supabase (PostgreSQL) | - | Data persistence |
| **Type system** | TypeScript | 5.7-5.8 | Type safety |
| **Routing** | React Router | 7.9.x | Client-side routing |
| **Drag & Drop** | DnD Kit | 6.x-10.x | Interactive UIs |
| **Deployment** | Cloudflare Pages | - | Hosting & CDN |

---

## Workspace Structure

### Directory Tree

```
clubs/
├── apps/
│   ├── georgetown/              # Rotary speaker management
│   │   ├── src/                 # React source code
│   │   │   ├── components/      # React components
│   │   │   ├── contexts/        # React contexts
│   │   │   ├── hooks/           # Custom hooks
│   │   │   ├── lib/             # Supabase client, utilities
│   │   │   ├── pages/           # Route pages
│   │   │   └── types/           # TypeScript types
│   │   ├── public/              # Static assets
│   │   ├── docs/                # Georgetown-specific docs
│   │   │   ├── governance/      # Strategic docs (BACKLOG, expert-standards)
│   │   │   ├── standards/       # Design standards (card-view, icons)
│   │   │   ├── workflows/       # Process guides
│   │   │   ├── dev-journals/    # Development logs
│   │   │   ├── plans/           # Implementation plans
│   │   │   ├── adr/             # Architecture Decision Records
│   │   │   ├── database/        # DB schema, migration guides
│   │   │   └── archive/         # Historical documentation
│   │   ├── supabase/            # Database migrations
│   │   │   └── migrations/      # SQL migration files
│   │   ├── vite.config.ts       # Vite configuration
│   │   ├── tailwind.config.js   # Tailwind CSS config
│   │   ├── tsconfig.json        # TypeScript config
│   │   ├── package.json         # Dependencies
│   │   ├── claude.md            # Georgetown AI instructions
│   │   └── .env.example         # Environment template
│   │
│   └── pitchmasters/            # Toastmasters club management
│       ├── src/                 # React source code
│       │   ├── components/      # React components
│       │   ├── contexts/        # React contexts
│       │   ├── hooks/           # Custom hooks
│       │   ├── lib/             # Supabase client, utilities
│       │   ├── pages/           # Route pages
│       │   └── types/           # TypeScript types
│       ├── public/              # Static assets
│       ├── docs/                # Pitchmasters-specific docs
│       │   ├── PDD.md           # Product Design Document
│       │   ├── TIS.md           # Technical Implementation Spec
│       │   ├── expert-standards.md
│       │   ├── database/        # Multi-club architecture docs
│       │   ├── tech-constraints.md
│       │   └── toastmasters-brand-guide.md
│       ├── supabase/            # Database migrations
│       │   └── migrations/      # SQL migration files
│       ├── vite.config.ts       # Vite configuration
│       ├── tailwind.config.js   # Tailwind CSS config
│       ├── tsconfig.json        # TypeScript config
│       ├── package.json         # Dependencies
│       ├── claude.md            # Pitchmasters AI instructions
│       └── .env.cloudflare.example  # Environment template
│
├── docs/                        # Shared monorepo documentation
│   └── monorepo-structure-report.md  ← THIS DOCUMENT
│
├── package.json                 # Root package.json (workspace scripts)
├── CLAUDE.md                    # Monorepo-level instructions
├── MONOREPO-HANDOFF-PROMPT.md   # Project handoff guide
├── README.md                    # Project overview
└── .gitignore                   # Git ignore rules
```

---

## Application Details

### Georgetown Rotary Speaker Management (`apps/georgetown/`)

**Purpose**: Rotary club speaker and event management system for Georgetown Rotary Club (~50 members).

**Business Objective**: Eliminate speaker coordination chaos through professional digital tools enabling program committee weekly adoption.

**Tech Stack**:
- React 19.1.1 + TypeScript 5.8.3
- Vite 7.1.6 (dev server & build)
- Tailwind CSS 3.4.17
- Supabase (PostgreSQL + Auth)
- React Router 7.9.2
- TipTap 3.11.0 (rich text editor)
- DnD Kit 6.3.1/10.0.0 (drag-and-drop)
- Lucide React 0.544.0 (icons)

**Key Features**:
1. **Speaker Pipeline Management** - Track speaker status (potential → confirmed → completed)
2. **Event Scheduling** - Calendar-based event planning
3. **Member Management** - Member directory with roles
4. **Program Coordination** - Weekly meeting program planning
5. **Rich Text Notes** - TipTap editor for detailed notes
6. **Drag-and-Drop UI** - Sortable lists and kanban boards

**Database Region**: Southeast Asia (Singapore) - `aws-1-ap-southeast-1`

**Authentication**: Supabase Auth (enabled for Georgetown)

**Deployment**: Cloudflare Pages (port 5180 local dev)

**Commands**:
```bash
npm run dev:georgetown       # Start dev server (localhost:5180)
npm run build:georgetown     # Production build
npm run lint                 # ESLint
npm run typecheck            # TypeScript validation
```

**Documentation**:
- [apps/georgetown/claude.md](../apps/georgetown/claude.md) - AI instructions
- [apps/georgetown/docs/](../apps/georgetown/docs/) - Complete docs structure
- [apps/georgetown/docs/governance/BACKLOG.md](../apps/georgetown/docs/governance/BACKLOG.md) - Feature backlog
- [apps/georgetown/docs/governance/expert-standards.md](../apps/georgetown/docs/governance/expert-standards.md) - Quality standards
- [apps/georgetown/docs/database/README.md](../apps/georgetown/docs/database/README.md) - Database implementation guide

**Project Owner**: CEO (Randal)
**Role Structure**: CEO (business strategy) → CTO (technical execution)

---

### Pitchmasters Toastmasters Club Management (`apps/pitchmasters/`)

**Purpose**: World's first mobile-optimized, multi-club Toastmasters platform designed for startup founders (18-80).

**Business Objective**: Solve Pitchmasters operational challenges first, then enable global multi-club growth.

**Current Phase**: Phase 1 - Internal MVP (Weeks 1-12)
- Success criteria: Meeting planning <15 min, 95% attendance accuracy, digital badges operational

**Tech Stack**:
- React 19.1.1 + TypeScript 5.7.2
- Vite 7.1.6 (dev server & build)
- Tailwind CSS 3.4.17
- Supabase (PostgreSQL, no auth initially)
- React Router 7.9.3
- DnD Kit 6.1.0/8.0.0 (drag-and-drop)
- Lucide React 0.544.0 (icons)

**Key Features** (from PDD):
1. **Meeting Planning** - 15-minute weekly meeting setup
2. **Member Role Management** - Assign/track Toastmasters roles
3. **Speech Tracking** - Track speech projects and progress
4. **Performance Analytics** - Member performance data
5. **Digital Badges** - Achievement tracking
6. **Multi-Club Architecture** - Scalable for global expansion

**Database Architecture**: Multi-club design (clubs as partitioning key)

**Deployment**: Cloudflare Pages (port 5190 local dev)

**Commands**:
```bash
npm run dev:pitchmasters      # Start dev server (localhost:5190)
npm run build:pitchmasters    # Production build
npm run preview               # Test production build
npm run lint                  # ESLint
npm run typecheck             # TypeScript validation
```

**Documentation**:
- [apps/pitchmasters/claude.md](../apps/pitchmasters/claude.md) - AI instructions
- [apps/pitchmasters/docs/PDD.md](../apps/pitchmasters/docs/PDD.md) - Product Design Document
- [apps/pitchmasters/docs/TIS.md](../apps/pitchmasters/docs/TIS.md) - Technical Implementation Spec
- [apps/pitchmasters/docs/database/database-protocol.md](../apps/pitchmasters/docs/database/database-protocol.md) - Multi-club database standards
- [apps/pitchmasters/docs/toastmasters-brand-guide.md](../apps/pitchmasters/docs/toastmasters-brand-guide.md) - Brand compliance

**Project Owner**: CEO (Randal)
**Role Structure**: CEO (business strategy) → COO (strategic advisor & QA) → CTO (technical execution)

---

## Shared Technologies

### npm Workspaces

**Configuration**: Root `package.json` with workspace definitions

```json
{
  "workspaces": [
    "apps/*"
  ]
}
```

**Benefits**:
- Single `node_modules` at root (deduplicated dependencies)
- Workspace-level commands (`npm run dev --workspace=rotary-speakers`)
- Parallel development of both apps
- Consistent dependency versions

**Important Notes**:
- No shared packages currently (apps are independent)
- Each app maintains its own `package.json`
- Dependencies installed at root with `npm install`

---

### Tailwind CSS

**Version**: 3.4.17 (both apps)

**Configuration**: Each app has its own `tailwind.config.js`

**Common Patterns**:
- Utility-first CSS
- Responsive design (mobile-first)
- Custom color schemes per app
- Dark mode support (Georgetown has dark mode)

---

### React Router

**Versions**:
- Georgetown: 7.9.2
- Pitchmasters: 7.9.3

**Usage**: Client-side routing for single-page applications

---

### DnD Kit

**Versions**:
- Georgetown: 6.3.1 (@dnd-kit/core), 10.0.0 (@dnd-kit/sortable)
- Pitchmasters: 6.1.0 (@dnd-kit/core), 8.0.0 (@dnd-kit/sortable)

**Usage**: Drag-and-drop interfaces (kanban boards, sortable lists)

---

### Supabase

**Client**: @supabase/supabase-js
- Georgetown: 2.57.4
- Pitchmasters: 2.50.0

**Services Used**:
- PostgreSQL database (independent databases per app)
- Storage (both apps)
- Auth (Georgetown only)

**Connection Pattern**: Each app configures its own Supabase client

---

## Scripts & Tooling

### Root Package Scripts

**File**: `package.json`

```json
{
  "scripts": {
    "dev:georgetown": "npm run dev --workspace=rotary-speakers",
    "dev:pitchmasters": "npm run dev --workspace=pitchmasters-club-management",
    "dev": "npm run dev:georgetown & npm run dev:pitchmasters",
    "build:georgetown": "npm run build --workspace=rotary-speakers",
    "build:pitchmasters": "npm run build --workspace=pitchmasters-club-management",
    "build": "npm run build --workspaces --if-present",
    "lint": "npm run lint --workspaces --if-present",
    "typecheck": "npm run typecheck --workspaces --if-present",
    "clean": "rm -rf node_modules apps/*/node_modules apps/*/dist"
  }
}
```

**Usage**:
```bash
# Development
npm run dev                  # Start both apps in parallel
npm run dev:georgetown       # Georgetown only (port 5180)
npm run dev:pitchmasters     # Pitchmasters only (port 5190)

# Production builds
npm run build                # Build both apps
npm run build:georgetown     # Georgetown only
npm run build:pitchmasters   # Pitchmasters only

# Quality assurance
npm run lint                 # Lint all apps
npm run typecheck            # Type check all apps

# Maintenance
npm run clean                # Remove all dependencies and build artifacts
```

---

### Build Tools

**Vite Configuration**: Each app has its own `vite.config.ts`

**Common Vite Plugins**:
- `@vitejs/plugin-react` (React Fast Refresh)
- `vite-plugin-image-optimizer` (Georgetown only - image optimization)

**Build Outputs**:
- Georgetown: `apps/georgetown/dist/`
- Pitchmasters: `apps/pitchmasters/dist/`

---

### TypeScript Configuration

**Version Range**: TypeScript 5.7-5.8

**Configuration**: Each app has its own `tsconfig.json`

**Common Settings**:
- Strict mode enabled
- ES2020 target
- ESNext module
- React JSX transform

---

## Database Architecture

### Georgetown Database

**Region**: Southeast Asia (Singapore) - `aws-1-ap-southeast-1`
**Project**: `zooszmqdrdocuiuledql.supabase.co`

**Connection Types**:
- **DATABASE_URL** - Pooled connection (port 6543) for app queries via PgBouncer
- **DIRECT_URL** - Direct connection (port 5432) for migrations and psql

**Key Tables** (inferred from app structure):
- `speakers` - Speaker profiles and status
- `events` - Rotary events and meetings
- `members` - Club member directory
- `programs` - Meeting programs

**Features**:
- Supabase Auth integration
- Real-time subscriptions (likely)
- Storage buckets for documents/images

**Migration Management**:
- SQL migrations in `apps/georgetown/supabase/migrations/`
- Applied via psql using DIRECT_URL
- CTO has direct database access for rapid development

**Documentation**: [apps/georgetown/docs/database/README.md](../apps/georgetown/docs/database/README.md)

---

### Pitchmasters Database

**Architecture**: Multi-club design with clubs as partitioning key

**Key Design Principles** (from database-protocol.md):
- Clubs table as central entity
- Foreign keys to `club_id` for multi-tenancy
- Scalable for global expansion

**Expected Tables** (from PDD):
- `clubs` - Club directory
- `members` - Multi-club member profiles
- `meetings` - Meeting schedules
- `roles` - Toastmasters role assignments
- `speeches` - Speech tracking
- `badges` - Digital achievement badges

**Migration Management**:
- SQL migrations in `apps/pitchmasters/supabase/migrations/`
- Multi-club constraints enforced

**Documentation**: [apps/pitchmasters/docs/database/database-protocol.md](../apps/pitchmasters/docs/database/database-protocol.md)

---

## Build & Deployment

### Deployment Platforms

| App | Platform | Build Command | Output Dir | Port (Dev) |
|-----|----------|---------------|------------|------------|
| **Georgetown** | Cloudflare Pages | `npm run build:georgetown` | `apps/georgetown/dist/` | 5180 |
| **Pitchmasters** | Cloudflare Pages | `npm run build:pitchmasters` | `apps/pitchmasters/dist/` | 5190 |

**Deployment Strategy**: Both apps deploy independently to Cloudflare Pages

---

### Environment Variables

**Georgetown** (`.env` files):
```bash
# Supabase
VITE_SUPABASE_URL=https://zooszmqdrdocuiuledql.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://pooler:password@region.pooler.supabase.com:6543/postgres
DIRECT_URL=postgresql://postgres:password@region.pooler.supabase.com:5432/postgres
```

**Pitchmasters** (`.env.cloudflare` template):
```bash
# Supabase
VITE_SUPABASE_URL=https://project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Important**:
- Environment files are gitignored
- Example files provided (`.env.example`, `.env.cloudflare.example`)
- Password encoding required for special characters (& becomes %26)

---

## Documentation Structure

### Root Level Documentation

```
docs/
└── monorepo-structure-report.md     # This document
```

**Monorepo Instructions**:
- `CLAUDE.md` - Monorepo context for AI assistants
- `MONOREPO-HANDOFF-PROMPT.md` - Project handoff guide
- `README.md` - Project overview

---

### Georgetown Documentation

**Comprehensive documentation structure in `apps/georgetown/docs/`**:

```
apps/georgetown/docs/
├── README.md                        # Documentation index
├── governance/                      # Strategic documents
│   ├── BACKLOG.md                   # Feature backlog with summary table
│   ├── expert-standards.md          # Full-stack verification standards
│   ├── management-protocols.md      # Role definitions, workflows
│   ├── rotary-brand-guide.md        # Rotary branding requirements
│   ├── system-architecture.md       # High-level architecture
│   └── tech-constraints.md          # Stability and framework rules
├── standards/                       # Design and code standards
│   ├── card-view-best-practices.md  # Card component patterns
│   ├── icon-usage-standard.md       # Lucide icon standards
│   ├── kanban-design-standards.md   # Kanban board design
│   └── responsive-design-standard.md # Mobile-first design rules
├── workflows/                       # Process guides
│   └── database-migration-workflow.md # Database change process
├── dev-journals/                    # Development logs
│   └── [dated entries]              # Chronological implementation logs
├── plans/                           # Implementation plans
│   └── [feature-specific plans]     # Detailed technical plans
├── adr/                             # Architecture Decision Records
│   └── [numbered ADRs]              # Architectural decisions
├── database/                        # Database documentation
│   ├── README.md                    # Complete implementation guide
│   └── [schema docs]                # Table definitions, relationships
└── archive/                         # Historical documentation
    └── [deprecated docs]            # No longer current documents
```

**Key Documents**:
- **Entry Point**: `apps/georgetown/claude.md` - AI assistant instructions
- **Backlog**: `docs/governance/BACKLOG.md` - Prioritized feature list
- **Standards**: `docs/governance/expert-standards.md` - Quality requirements
- **Database**: `docs/database/README.md` - Complete DB implementation guide

---

### Pitchmasters Documentation

**Strategic documentation in `apps/pitchmasters/docs/`**:

```
apps/pitchmasters/docs/
├── PDD.md                           # Product Design Document
├── TIS.md                           # Technical Implementation Spec
├── expert-standards.md              # Quality standards
├── tech-constraints.md              # Stability rules
├── toastmasters-brand-guide.md      # Brand compliance
└── database/
    └── database-protocol.md         # Multi-club architecture standards
```

**Key Documents**:
- **Entry Point**: `apps/pitchmasters/claude.md` - AI assistant instructions
- **Product Spec**: `docs/PDD.md` - Complete product requirements
- **Technical Spec**: `docs/TIS.md` - Implementation details
- **Database**: `docs/database/database-protocol.md` - Multi-club design

---

## Development Workflow

### Typical Development Flow

**1. Working on Georgetown**:
```bash
# Navigate to project root
cd /path/to/clubs

# Install dependencies (if needed)
npm install

# Start Georgetown dev server
npm run dev:georgetown

# Make changes to apps/georgetown/src/
# Changes hot-reload automatically

# Type check
npm run typecheck --workspace=rotary-speakers

# Build for production
npm run build:georgetown

# Commit changes
git add apps/georgetown/
git commit -m "feat(georgetown): Add speaker pipeline feature"
```

**2. Working on Pitchmasters**:
```bash
# Navigate to project root
cd /path/to/clubs

# Install dependencies (if needed)
npm install

# Start Pitchmasters dev server
npm run dev:pitchmasters

# Make changes to apps/pitchmasters/src/
# Changes hot-reload automatically

# Type check
npm run typecheck --workspace=pitchmasters-club-management

# Build for production
npm run build:pitchmasters

# Commit changes
git add apps/pitchmasters/
git commit -m "feat(pitchmasters): Add meeting planning module"
```

**3. Working on Both Apps Simultaneously**:
```bash
# Start both dev servers in parallel
npm run dev

# Georgetown: localhost:5180
# Pitchmasters: localhost:5190

# Make changes to either app
# Each app hot-reloads independently
```

**4. Database Migrations**:

**Georgetown** (direct psql access):
```bash
# Create migration file
cd apps/georgetown/supabase/migrations/
touch $(date +%Y%m%d%H%M%S)_add_feature.sql

# Write SQL migration
vim $(date +%Y%m%d%H%M%S)_add_feature.sql

# Apply migration using DIRECT_URL
source apps/georgetown/.env.local
psql "$DIRECT_URL" -f apps/georgetown/supabase/migrations/[timestamp]_add_feature.sql

# Verify in app
npm run dev:georgetown
```

**Pitchmasters** (similar pattern):
```bash
# Create migration file
cd apps/pitchmasters/supabase/migrations/
touch $(date +%Y%m%d%H%M%S)_add_multi_club_support.sql

# Apply migration
source apps/pitchmasters/.env
psql "$DATABASE_URL" -f apps/pitchmasters/supabase/migrations/[timestamp]_add_multi_club_support.sql
```

---

### Git Workflow

**Branch Strategy**: (Inferred - not explicitly documented)
- `main` - Production branch
- Feature branches for new features
- Atomic commits per app

**Commit Message Conventions**:
```bash
# Georgetown changes
git commit -m "feat(georgetown): Add speaker filtering"
git commit -m "fix(georgetown): Resolve calendar date bug"

# Pitchmasters changes
git commit -m "feat(pitchmasters): Add role assignment UI"
git commit -m "docs(pitchmasters): Update PDD with badge requirements"

# Monorepo-level changes
git commit -m "chore: Update npm workspace scripts"
git commit -m "docs: Add monorepo structure report"
```

**Current Status** (from git status):
```
On branch: main
Modified: README.md, apps/georgetown/claude.md, apps/pitchmasters/claude.md
Untracked: CLAUDE.md, MONOREPO-HANDOFF-PROMPT.md, docs/
```

---

## Key Design Decisions

### 1. Monorepo vs. Separate Repositories

**Decision**: Monorepo with npm workspaces

**Rationale**:
- ✅ **Shared technology stack** (React, Vite, Tailwind, Supabase patterns)
- ✅ **Consistent tooling** (same linting, build, deployment processes)
- ✅ **Single development environment** (one repo clone, one npm install)
- ✅ **Simplified dependency management** (deduplicated node_modules)
- ✅ **Parallel development** (both apps evolve simultaneously)
- ✅ **Unified deployment** (same Cloudflare Pages workflow)

**Trade-offs**:
- ❌ Larger repo size (two full React applications)
- ❌ Potential for accidental cross-contamination
- ✅ Outweighed by development velocity gains

---

### 2. npm Workspaces (Not Yarn/pnpm)

**Decision**: Standard npm workspaces (no Yarn, pnpm, or Turbo)

**Rationale**:
- ✅ **Simplicity** (native npm feature, no additional tooling)
- ✅ **Stability** (npm 9.0.0+ has mature workspace support)
- ✅ **Minimal dependencies** (no monorepo-specific packages)
- ✅ **Easy onboarding** (standard npm commands)

**Trade-offs**:
- ❌ No task caching (unlike Turbo)
- ❌ Slower installs than pnpm
- ✅ Acceptable for 2-app monorepo scale

---

### 3. Independent Apps (No Shared Packages)

**Decision**: Apps are self-contained with no shared code packages

**Rationale**:
- ✅ **Domain independence** (Rotary and Toastmasters have different requirements)
- ✅ **Deployment independence** (no cross-app dependencies)
- ✅ **Simplicity** (no package versioning coordination)
- ✅ **Faster iterations** (change one app without affecting the other)

**Current State**: No `packages/` directory exists

**Future Consideration**: Could add shared packages if patterns emerge (e.g., `@clubs/ui-components`)

---

### 4. Separate Supabase Databases

**Decision**: Each app has its own Supabase database/project

**Rationale**:
- ✅ **Data isolation** (Rotary data separate from Toastmasters data)
- ✅ **Independent scaling** (different usage patterns)
- ✅ **Security** (no cross-app data access)
- ✅ **Simpler migrations** (no multi-tenancy complexity in Georgetown)

**Implementation**:
- Georgetown: Southeast Asia (Singapore) region
- Pitchmasters: Multi-club architecture (separate project)

---

### 5. Port Separation for Local Development

**Decision**: Fixed ports for each app (Georgetown: 5180, Pitchmasters: 5190)

**Rationale**:
- ✅ **Predictable URLs** (consistent local development)
- ✅ **Parallel development** (run both apps simultaneously)
- ✅ **No port conflicts** (10-port gap prevents collisions)

**Configuration**: Set in each app's `vite.config.ts`

---

### 6. App-Specific Documentation

**Decision**: Each app maintains its own `docs/` directory (no shared docs packages)

**Rationale**:
- ✅ **Context proximity** (docs live with code)
- ✅ **Domain specificity** (Rotary vs. Toastmasters have different processes)
- ✅ **Independent evolution** (docs update with app changes)
- ✅ **Reduced coordination** (no cross-app doc dependencies)

**Structure**:
- Georgetown: Comprehensive governance/standards/workflows structure
- Pitchmasters: PDD/TIS strategic documentation
- Root: Monorepo-level documentation only

---

### 7. Cloudflare Pages Deployment

**Decision**: Both apps deploy to Cloudflare Pages

**Rationale**:
- ✅ **Static site hosting** (React SPAs build to static files)
- ✅ **Global CDN** (fast worldwide access)
- ✅ **Free tier** (generous limits for club apps)
- ✅ **Git integration** (automatic deployments)
- ✅ **Environment variables** (per-deployment config)

**Build Commands**:
- Georgetown: `npm run build:georgetown`
- Pitchmasters: `npm run build:pitchmasters`

---

### 8. TypeScript Strict Mode

**Decision**: TypeScript strict mode enabled in both apps

**Rationale**:
- ✅ **Type safety** (catch errors at compile time)
- ✅ **Better IDE support** (autocomplete, refactoring)
- ✅ **Maintainability** (self-documenting code)
- ✅ **Quality assurance** (enforced by expert-standards.md)

**Enforcement**: TypeScript 5.7-5.8 with strict compiler options

---

### 9. Tailwind CSS Over Other CSS Solutions

**Decision**: Tailwind CSS for styling (both apps)

**Rationale**:
- ✅ **Rapid development** (utility-first workflow)
- ✅ **Consistent spacing/colors** (design system via config)
- ✅ **Mobile-first** (responsive design by default)
- ✅ **Small bundle sizes** (purged unused CSS)
- ✅ **Strong community** (extensive documentation)

**Version**: 3.4.17 (consistent across both apps)

---

### 10. React Router 7 Over Alternatives

**Decision**: React Router 7 for client-side routing

**Rationale**:
- ✅ **Industry standard** (most popular React routing library)
- ✅ **Type safety** (TypeScript support)
- ✅ **Nested routes** (clean route organization)
- ✅ **Data loading** (loader/action patterns)
- ✅ **Latest version** (7.x with modern features)

**Consistency**: Both apps use React Router 7.9.x

---

## Summary of Key Strengths

1. **Independent Development**: Apps can evolve separately while sharing infrastructure
2. **Consistent Technology**: Same React/TypeScript/Vite stack reduces context switching
3. **Simple Tooling**: Standard npm workspaces (no complex build orchestration)
4. **Clear Separation**: Each app has dedicated docs, database, deployment
5. **Parallel Work**: Run both apps simultaneously for cross-reference development
6. **Domain Focus**: Rotary-specific and Toastmasters-specific implementations
7. **Documentation-First**: Comprehensive docs in both apps (governance, standards, workflows)
8. **Modern Stack**: React 19, TypeScript 5.7+, Vite 7, Tailwind 3.4
9. **Cloudflare Deployment**: Fast, free, global CDN for both apps
10. **Type Safety**: Strict TypeScript across all code

---

## Common Gotchas & Best Practices

### Gotchas

1. **Workspace naming**: Package names differ from directory names
   - Directory: `apps/georgetown/` → Package: `rotary-speakers`
   - Directory: `apps/pitchmasters/` → Package: `pitchmasters-club-management`

2. **Port conflicts**: Ensure Georgetown (5180) and Pitchmasters (5190) ports are free

3. **Environment files**: Each app has different env file patterns
   - Georgetown: `.env`, `.env.example`, `.env.local`
   - Pitchmasters: `.env.cloudflare.example`

4. **Database regions**: Georgetown uses Singapore region (must specify in connection)

5. **Password encoding**: Special characters in database URLs must be URL-encoded (& → %26)

6. **Independent dependencies**: Apps can have different versions of same package
   - Georgetown: Supabase 2.57.4
   - Pitchmasters: Supabase 2.50.0

7. **No shared packages**: Cannot import code between apps (intentional isolation)

8. **Build outputs**: Each app outputs to its own `dist/` directory

---

### Best Practices

1. **Run from root**: Always run workspace commands from monorepo root
   ```bash
   npm run dev:georgetown          # From root
   # NOT: cd apps/georgetown && npm run dev
   ```

2. **Install at root**: Run `npm install` at root, not in individual apps
   ```bash
   npm install                     # At root (deduplicates dependencies)
   ```

3. **App-specific work**: Use workspace filters for targeted commands
   ```bash
   npm run typecheck --workspace=rotary-speakers
   ```

4. **Prefix commits**: Include app name in commit messages
   ```bash
   git commit -m "feat(georgetown): Add feature"
   git commit -m "fix(pitchmasters): Fix bug"
   ```

5. **Read app docs first**: Check `apps/{app}/claude.md` before starting work
   - Georgetown: Business context, quality gates, documentation organization
   - Pitchmasters: PDD/TIS, role structure, multi-club architecture

6. **Respect app independence**: Don't create cross-app dependencies
   - Keep code self-contained per app
   - Consider shared package only if strong pattern emerges

7. **Document architecture decisions**: Use ADR pattern (Georgetown) for significant choices

8. **Development journals**: Create dev journal entries after major implementations
   - Georgetown: `docs/dev-journals/`
   - Pitchmasters: (Pattern not yet established)

9. **Test locally first**: Always test in local dev server before building
   ```bash
   npm run dev:georgetown          # Test changes
   npm run build:georgetown        # Then build
   ```

10. **Clean builds**: Use clean command when dependencies get messy
    ```bash
    npm run clean                   # Remove all node_modules and dist
    npm install                     # Fresh install
    ```

---

## Contact & Maintenance

**Monorepo Owner**: CEO (Randal)

**Georgetown Team**:
- CEO (Randal) - Business strategy
- CTO (Claude Code) - Technical execution

**Pitchmasters Team**:
- CEO (Randal) - Business strategy
- COO (Claude Console) - Strategic advisor & QA
- CTO (Claude Code) - Technical execution

**Documentation Updates**: This report should be updated when:
- New applications added to monorepo
- Shared packages created
- Monorepo tooling changes (workspace config, build system)
- Major architectural decisions affecting both apps

**Version History**:
- **v1.0** (2025-12-16) - Initial technical report based on Brandmine template

---

## Appendices

### A. File Extensions & Conventions

| Extension | Purpose | Example |
|-----------|---------|---------|
| `.tsx` | TypeScript React component | `SpeakerCard.tsx` |
| `.ts` | TypeScript utility/type | `supabase.ts` |
| `.md` | Markdown documentation | `BACKLOG.md` |
| `.sql` | Database migration | `20251216120000_add_speakers_table.sql` |
| `.json` | Configuration | `package.json`, `tsconfig.json` |
| `.js` | JavaScript config | `tailwind.config.js` |

---

### B. Environment Variables

**Georgetown** (`.env.local`):
```bash
# Supabase
VITE_SUPABASE_URL=https://zooszmqdrdocuiuledql.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://pooler:password@region.pooler.supabase.com:6543/postgres
DIRECT_URL=postgresql://postgres:password@region.pooler.supabase.com:5432/postgres
```

**Pitchmasters** (`.env`):
```bash
# Supabase
VITE_SUPABASE_URL=https://project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Important**:
- All env files are gitignored
- Use `.env.example` templates
- URL-encode special characters in passwords

---

### C. Useful Commands Reference

```bash
# Monorepo Management
npm install                          # Install all dependencies
npm run clean                        # Remove node_modules and dist

# Development
npm run dev                          # Both apps in parallel
npm run dev:georgetown               # Georgetown only (port 5180)
npm run dev:pitchmasters             # Pitchmasters only (port 5190)

# Production Builds
npm run build                        # Build both apps
npm run build:georgetown             # Georgetown only
npm run build:pitchmasters           # Pitchmasters only

# Quality Assurance
npm run lint                         # Lint all apps
npm run typecheck                    # Type check all apps
npm run lint --workspace=rotary-speakers          # Lint Georgetown
npm run typecheck --workspace=pitchmasters-club-management  # Type check Pitchmasters

# Database (Georgetown example)
source apps/georgetown/.env.local
psql "$DIRECT_URL"                   # Connect to database
psql "$DIRECT_URL" -c "SELECT version();"  # Test connection
psql "$DIRECT_URL" -f migration.sql  # Apply migration

# Git
git status                           # Check changes
git add apps/georgetown/             # Stage Georgetown changes
git commit -m "feat(georgetown): Add feature"  # Commit with prefix
git add apps/pitchmasters/           # Stage Pitchmasters changes
git commit -m "feat(pitchmasters): Add feature"  # Commit with prefix
```

---

### D. Directory Size & Complexity

**Approximate Line Counts** (TypeScript/React code):
- Georgetown: ~5,000-10,000 lines (estimated)
- Pitchmasters: ~3,000-7,000 lines (estimated, early stage)

**Documentation**:
- Georgetown: Comprehensive (20+ docs across governance/standards/workflows)
- Pitchmasters: Strategic (PDD, TIS, database protocol)
- Root: Minimal (monorepo overview only)

**Database Migrations**:
- Georgetown: Multiple migration files (exact count in `supabase/migrations/`)
- Pitchmasters: Initial migrations (multi-club architecture)

---

### E. Technology Version Matrix

| Dependency | Georgetown | Pitchmasters | Notes |
|------------|-----------|--------------|-------|
| React | 19.1.1 | 19.1.1 | ✅ Aligned |
| TypeScript | 5.8.3 | 5.7.2 | ⚠️ Minor version difference |
| Vite | 7.1.6 | 7.1.6 | ✅ Aligned |
| Tailwind CSS | 3.4.17 | 3.4.17 | ✅ Aligned |
| React Router | 7.9.2 | 7.9.3 | ⚠️ Patch version difference |
| Supabase JS | 2.57.4 | 2.50.0 | ⚠️ Minor version difference |
| DnD Kit Core | 6.3.1 | 6.1.0 | ⚠️ Minor version difference |
| DnD Kit Sortable | 10.0.0 | 8.0.0 | ⚠️ Major version difference |
| Lucide React | 0.544.0 | 0.544.0 | ✅ Aligned |

**Version Alignment Recommendations**:
- **Critical**: Keep React, Vite, Tailwind aligned (currently ✅)
- **Moderate**: Align TypeScript, React Router, Supabase when convenient
- **Low Priority**: DnD Kit versions (different feature needs)

---

**End of Report**
