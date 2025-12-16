# Brandmine Monorepo Structure - Technical Report

**Prepared for**: External CTO
**Date**: 2025-12-16
**Author**: Brandmine CTO (Claude Code)
**Version**: 1.0

---

## Executive Summary

Brandmine operates a **dual-app monorepo** combining a static content site (Hugo) with a React-based CRM (Hub). This architecture enables content teams to manage a multilingual brand discovery platform while internal teams coordinate business development operations—all synchronized through a shared PostgreSQL database (Supabase).

**Key Metrics**:
- **2 production applications** (Hugo static site + React Hub CRM)
- **4 shared packages** (TypeScript types, configs)
- **60+ brand profiles**, **37+ founder profiles** (trilingual: EN/RU/ZH)
- **~160 database migrations** (shared + app-specific)
- **Monorepo tooling**: pnpm workspaces + Turbo

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
┌─────────────────────────────────────────────────────────────┐
│                    Brandmine Monorepo                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐                 ┌──────────────────┐   │
│  │   Hugo (SSG)    │                 │   Hub (React)    │   │
│  │  brandmine.ai   │                 │  hub.brandmine.ai│   │
│  │                 │                 │                  │   │
│  │ • 60+ brands    │                 │ • CRM            │   │
│  │ • 37+ founders  │                 │ • Contacts       │   │
│  │ • Insights      │◄───Sync────────►│ • Deals          │   │
│  │ • Updates       │   Scripts       │ • Tasks          │   │
│  │ • EN/RU/ZH      │                 │ • Story Ideas    │   │
│  └─────────────────┘                 └──────────────────┘   │
│          │                                     │             │
│          └──────────────┬──────────────────────┘             │
│                         │                                    │
│                         ▼                                    │
│              ┌─────────────────────┐                         │
│              │  Supabase (Postgres)│                         │
│              │  • Content (brands) │                         │
│              │  • CRM (contacts)   │                         │
│              │  • Storage (images) │                         │
│              └─────────────────────┘                         │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Shared Packages (workspace:*)                │  │
│  │  • @brandmine/shared-types                             │  │
│  │  • @brandmine/typescript-config                        │  │
│  │  • @brandmine/eslint-config                            │  │
│  │  • @brandmine/prettier-config                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Monorepo** | pnpm workspaces | 9.15.0 | Dependency management |
| **Build orchestration** | Turbo | 2.6.3 | Task caching, parallelization |
| **Hugo (SSG)** | Hugo | 0.150.0 | Static site generation |
| **Hub (React)** | React | 19.1.0 | Internal CRM application |
| **Styling** | Tailwind CSS | 4.1.11 | Utility-first CSS (both apps) |
| **Database** | Supabase (PostgreSQL) | - | Shared data layer |
| **Package manager** | pnpm | 9.15.0 | Workspace-native, fast |
| **Type system** | TypeScript | 5.8.3 | Type safety (Hub + scripts) |

---

## Workspace Structure

### Directory Tree

```
brandmine-monorepo/
├── apps/
│   ├── hugo/                # Static site (Hugo 0.150.0)
│   │   ├── content/         # Markdown content (brands, founders, insights)
│   │   ├── layouts/         # Go templates
│   │   ├── assets/          # Processed assets (CSS, JS, images)
│   │   ├── static/          # Static assets (fonts only)
│   │   ├── data/            # Hugo data files (taxonomies)
│   │   ├── i18n/            # UI translations (EN/RU/ZH)
│   │   ├── scripts/         # Hugo-specific scripts
│   │   ├── hugo.yaml        # Hugo config
│   │   └── package.json     # Dependencies
│   │
│   └── hub/                 # React CRM (Vite + React 19)
│       ├── src/             # React source code
│       │   ├── components/  # Feature-based components
│       │   ├── contexts/    # React contexts
│       │   ├── hooks/       # Custom hooks
│       │   ├── lib/         # Core libraries
│       │   └── utils/       # Utilities
│       ├── supabase/        # Hub-specific migrations
│       │   └── migrations/  # CRM schema (contacts, deals)
│       ├── public/          # Static assets
│       ├── scripts/         # Build utilities
│       ├── vite.config.ts   # Vite config
│       └── package.json     # Dependencies
│
├── packages/
│   ├── shared-types/        # TypeScript types (both apps)
│   ├── typescript-config/   # Shared tsconfig.json
│   ├── eslint-config/       # Shared ESLint rules
│   └── prettier-config/     # Shared Prettier config
│
├── scripts/
│   ├── node/                # Data sync scripts (Hugo ↔ Supabase)
│   ├── migrations/          # Shared migrations (brands, founders)
│   │   └── shared/          # ~157 SQL files
│   ├── queries/             # Utility SQL queries
│   ├── lighthouse/          # Lighthouse CI scripts
│   ├── validation/          # Content validation
│   ├── deno/                # Legacy Deno scripts (archived)
│   └── archive/             # Archived scripts
│
├── docs/
│   ├── hugo/                # Hugo-specific docs
│   ├── hub/                 # Hub-specific docs
│   ├── database/            # Schema, migrations guide
│   ├── workflows/           # Team workflows
│   ├── brand/               # Brand strategy, guidelines
│   ├── technical/           # Technical references
│   ├── adr/                 # Architecture Decision Records
│   ├── backlog/             # Feature backlog
│   ├── dev-journal/         # Development notes
│   ├── briefings/           # Technical briefings
│   ├── prompts/             # Handoff prompts
│   └── research-archive/    # Published research provenance
│
├── data/
│   ├── version.json         # Git commit info (auto-generated)
│   ├── last-sync.json       # Sync timestamps (Hugo ↔ Supabase)
│   └── last-sync-*.json     # Sync metadata per content type
│
├── research/                # Active research (in-progress)
│
├── backups/                 # Database backups (gitignored)
│
├── logs/                    # Script logs (gitignored)
│
├── pnpm-workspace.yaml      # Workspace configuration
├── turbo.json               # Turbo task config
├── package.json             # Root package.json (scripts)
├── .env.local               # Environment variables (gitignored)
├── lighthouserc.json        # Lighthouse CI config (root)
├── CLAUDE.md                # Project instructions for AI
└── README.md                # Project overview
```

---

## Application Details

### Hugo Static Site (`apps/hugo/`)

**Purpose**: Public-facing Brandmine website - multilingual content delivery showcasing Global South brands, founders, and market insights.

**Tech Stack**:
- Hugo 0.150.0 (static site generator)
- Tailwind CSS 4 (utility-first styling)
- Alpine.js 3.14.1 (minimal JavaScript, self-hosted)
- Self-hosted fonts (PT Sans/Serif for EN/RU, Noto Sans SC for Chinese)

**Content Types**:
1. **Brands** (`content/brands/`) - 60+ profiles (business metrics, resilience stories)
2. **Founders** (`content/founders/`) - 37+ profiles (6-phase timeline narratives)
3. **Insights** (`content/insights/`) - Market analysis articles (6 categories)
4. **Updates** (`content/updates/`) - Blog posts (company news)
5. **Dimensions** (`content/dimensions/`) - Taxonomy pages (markets, sectors, attributes, signals)

**Multilingual Support**:
- **Languages**: English (default), Russian, Chinese
- **File naming**: `index.en.md`, `index.ru.md`, `index.zh.md`
- **URL patterns**:
  - English: `/brands/sugar-cosmetics/` (no `/en/` prefix)
  - Russian: `/ru/brands/sugar-cosmetics/`
  - Chinese: `/zh/brands/sugar-cosmetics/`

**Key Features**:
- Mobile-first design (320px-414px primary viewport)
- Dark mode (automatic system preference via `prefers-color-scheme`)
- SEO-optimized (OpenGraph images, structured data)
- Progressive Web App (PWA) capabilities (offline access, installable)
- Lighthouse CI (automated quality assurance)

**Image Processing**:
- All source images in `assets/images/` (Hugo processes them)
- WebP conversion, responsive sizing, lazy loading
- Front matter contains **filenames only** (templates construct full paths)

**Deployment**: Cloudflare Pages (brandmine.ai)

**Commands**:
```bash
pnpm dev:hugo        # Start dev server (localhost:1313)
pnpm build:hugo      # Production build
pnpm validate        # Content validation
pnpm lighthouse      # Lighthouse CI audits
```

**Documentation**:
- [apps/hugo/README.md](../../apps/hugo/README.md)
- [apps/hugo/STRUCTURE.md](../../apps/hugo/STRUCTURE.md)
- [docs/hugo/](../hugo/)

---

### Hub React CRM (`apps/hub/`)

**Purpose**: Internal hub for managing contacts, deals, tasks, communications, brands, founders, and story ideas pipeline.

**Tech Stack**:
- React 19.1.0 + TypeScript 5.8.3
- Vite 7.0.4 (dev server & build)
- Tailwind CSS 4.1.11 (same styling system as Hugo)
- shadcn/ui (Radix UI + Tailwind components)
- Supabase (PostgreSQL + real-time subscriptions)
- React Admin (ra-core, ra-supabase for CRUD operations)

**Key Features**:
1. **Contact Management** - Full CRM with custom fields
2. **Deal Pipeline** - Kanban board, stages, value tracking
3. **Task System** - Reminders, calendar, assignees
4. **Email Capture** - CC to auto-save as notes
5. **Brand Management** - Edit brands, sync to Hugo
6. **Founder Management** - Edit founder profiles
7. **Story Ideas Pipeline** - Filtering, bulk actions, CSV import
8. **Updates CMS** - WYSIWYG editor for blog posts (no markdown required)
9. **Insights CMS** - Rich text editor for market analysis articles
10. **Activity Logs** - Full audit trail
11. **Import/Export** - CSV bulk operations
12. **Command Palette** - Cmd+K search across all resources

**Authentication**:
- WebAuthn passkeys (passwordless login)
- Supabase Auth integration

**Deployment**: Cloudflare Pages (hub.brandmine.ai)

**Commands**:
```bash
pnpm dev:hub         # Start dev server (localhost:5173)
pnpm build:hub       # Production build
pnpm test            # Run tests (Vitest)
pnpm lighthouse:hub  # Lighthouse audits
```

**Documentation**:
- [apps/hub/README.md](../../apps/hub/README.md)
- [apps/hub/STRUCTURE.md](../../apps/hub/STRUCTURE.md)
- [docs/hub/](../hub/)

---

## Shared Packages

All packages use `workspace:*` protocol for internal dependencies.

### `@brandmine/shared-types`

**Purpose**: TypeScript type definitions shared between Hugo sync scripts and Hub React app.

**Exports**:
```typescript
// Brand, Founder, Insight, Update types
export interface Brand {
  id: string;
  slug: string;
  title: string;
  markets: string[];
  sectors: string[];
  attributes: string[];
  signals: string[];
  // ... 40+ fields
}

export interface Founder {
  id: string;
  slug: string;
  name: string;
  company: string;
  timeline: TimelineEvent[];
  // ... 30+ fields
}

// Taxonomy types (markets, sectors, attributes, signals)
// Database schema types
```

**Used by**:
- Hub React components (type-safe data access)
- Node sync scripts (`scripts/node/*.js`)
- Database migrations (reference types)

**Location**: `packages/shared-types/src/`

---

### `@brandmine/typescript-config`

**Purpose**: Shared TypeScript compiler configuration.

**Provides**:
- `tsconfig.base.json` - Base config for all TS projects
- `tsconfig.react.json` - React-specific config (Hub)
- `tsconfig.node.json` - Node-specific config (scripts)

**Used by**: Hub app, sync scripts

---

### `@brandmine/eslint-config`

**Purpose**: Shared ESLint rules for code quality.

**Rules**:
- React best practices (hooks, JSX)
- TypeScript-specific linting
- Import sorting
- Accessibility checks

**Used by**: Hub app (code quality enforcement)

---

### `@brandmine/prettier-config`

**Purpose**: Shared Prettier configuration for consistent code formatting.

**Settings**:
- 2-space indentation
- Single quotes
- Trailing commas (ES5)
- 80-character line width

**Used by**: Hub app, documentation files

---

## Scripts & Tooling

### Node Scripts (`scripts/node/`)

**Data Synchronization** (Hugo ↔ Supabase):

| Script | Direction | Purpose | Safety |
|--------|-----------|---------|--------|
| `sync-to-supabase.js` | Hugo → DB | Sync brands + founders to database | **Incremental by default** (only changed files) |
| `sync-from-supabase.js` | DB → Hugo | Pull brands/founders from database to Hugo files | Safe (read-only from DB perspective) |
| `sync-all.js` | Hugo → DB | Master orchestrator (founders → brands → insights) | Calls sync-to-supabase with dependency order |
| `sync-updates-to-supabase.js` | Hugo → DB | Sync Updates articles (NEW files only) | **Safe mode** by default (--new-only) |
| `sync-updates-from-supabase.js` | DB → Hugo | Pull Updates from database | **PRIMARY sync direction** for Updates |
| `sync-insights-to-supabase.js` | Hugo → DB | Sync Insights articles (NEW files only) | Safe mode by default (--new-only) |
| `sync-insights-from-supabase.js` | DB → Hugo | Pull Insights from database | Primary sync direction for Insights |

**Key Features**:
- **Incremental sync** (10-100x faster for typical edits)
- **Timestamp tracking** (uses `data/last-sync.json`)
- **Dry-run mode** (`--dry-run` to preview changes)
- **Validation** (pre-sync checks for incomplete translations)
- **Backup creation** (automatic before destructive operations)
- **Shortcode handling** (database stores prose-only, scripts reinsert `{{< timeline >}}`)

**Usage Examples**:
```bash
# Incremental sync (fast, default)
node scripts/node/sync-to-supabase.js

# Full sync (all content)
node scripts/node/sync-to-supabase.js --full

# Pull specific content from database
node scripts/node/sync-from-supabase.js --sector=wine

# Dry run (preview changes)
node scripts/node/sync-insights-to-supabase.js --dry-run
```

**Other Node Scripts**:
- `add-db-ids-to-frontmatter.js` - Backfill database IDs to Hugo front matter
- `upload-brand-image.js` - Upload brand images to Supabase Storage
- `upload-founder-image.js` - Upload founder portraits
- `upload-insight-image.js` - Upload insight hero images
- `upload-update-image.js` - Upload update hero images

---

### Migrations (`scripts/migrations/`)

**Two-tier system**:

1. **Shared migrations** (`scripts/migrations/shared/`) - ~157 SQL files
   - Brands, founders, insights, updates, dimensions
   - Content-related schema (public-facing data)
   - Applied manually: `psql $DATABASE_URL -f shared/NNN-migration.sql`

2. **Hub migrations** (`apps/hub/supabase/migrations/`) - ~30 SQL files
   - CRM schema (contacts, deals, tasks, companies)
   - Internal business operations
   - Applied via Supabase CLI: `cd apps/hub && supabase db push`

**Migration Naming**: `NNN-descriptive-name.sql` (sequential numbers)

**Documentation**: [scripts/migrations/README.md](../../scripts/migrations/README.md)

---

### Validation Scripts (`scripts/validation/`)

**Content Validation**:
- Pre-build validation for Hugo content
- Checks for required fields, translation completeness
- Called automatically before Hugo builds

---

### Lighthouse CI (`scripts/lighthouse/`)

**Performance Monitoring**:
- Automated quality assurance (performance, accessibility, SEO)
- Runs on 5 pages × 3 runs each = 15 audits per build
- Thresholds enforced (Performance: 60, Accessibility: 94, SEO: 92)

**Configuration**: `lighthouserc.json` (repo root)

**Commands**:
```bash
pnpm lighthouse        # Hugo site audits
pnpm lighthouse:hub    # Hub app audits
```

---

## Database Architecture

### Supabase (PostgreSQL)

**Connection**:
- **Region**: Singapore (ap-southeast-1)
- **Pooler**: Transaction pooler for connection management
- **Auth**: Supabase Auth (WebAuthn passkeys)
- **Storage**: Supabase Storage (images, documents)

**Schema Overview**:

| Table Group | Tables | Purpose |
|-------------|--------|---------|
| **Content** | `brands`, `founders`, `insights`, `updates` | Public-facing content |
| **Taxonomy** | `markets`, `sectors`, `attributes`, `signals` | Categorization system |
| **CRM** | `contacts`, `companies`, `deals`, `tasks` | Internal business operations |
| **Relationships** | `brand_founders`, `brand_markets`, etc. | Many-to-many joins |
| **System** | `passkey_credentials`, `activity_logs` | Infrastructure |

**Key Features**:
- **Soft delete** (trash bin for brands, founders, insights, updates)
- **Full-text search** (PostgreSQL `tsvector` for brands, founders)
- **Lean views** (`brands_card_view`, `founders_card_view` - 4-5x faster list queries)
- **Auto avatars** (Gravatar fetching for contacts)
- **Real-time subscriptions** (live updates in Hub)

**Storage Buckets**:
- `brands` - Brand logos, product images
- `founders` - Founder portraits
- `insights` - Insight hero images
- `updates` - Update hero images + gallery images
- `dimensions` - Taxonomy dimension images

**Documentation**: [docs/database/README.md](../database/README.md)

---

## Build & Deployment

### Turbo Configuration

**File**: `turbo.json`

**Task Pipeline**:
```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["public/**", "dist/**"],
      "cache": true
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"],
      "cache": true
    }
  }
}
```

**Benefits**:
- Parallel execution (both apps build simultaneously)
- Caching (skip unchanged packages)
- Dependency-aware (shared-types builds first)

---

### pnpm Workspace

**File**: `pnpm-workspace.yaml`

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

**Advantages**:
- **Fast installs** (content-addressable storage)
- **Disk efficiency** (shared dependencies)
- **Strict dependency isolation** (no phantom dependencies)
- **Workspace protocol** (`workspace:*` for internal packages)

---

### Root Package Scripts

**File**: `package.json`

```json
{
  "scripts": {
    "dev": "turbo run dev --parallel",
    "dev:hugo": "turbo run dev --filter=@brandmine/hugo",
    "dev:hub": "turbo run dev --filter=@brandmine/hub",
    "build": "turbo run build",
    "build:hugo": "turbo run build --filter=@brandmine/hugo",
    "build:hub": "turbo run build --filter=@brandmine/hub",
    "sync": "node scripts/node/sync-to-supabase.js",
    "sync-all": "node scripts/node/sync-all.js",
    "migrate": "node scripts/run-migrations.js",
    "lighthouse": "pnpm --filter @brandmine/hugo lighthouse"
  }
}
```

**Usage**:
```bash
# Development
pnpm dev              # Start both apps in parallel
pnpm dev:hugo         # Hugo only
pnpm dev:hub          # Hub only

# Production builds
pnpm build            # Build both apps
pnpm build:hugo       # Hugo static site
pnpm build:hub        # Hub React app

# Data sync
pnpm sync             # Hugo → Supabase (incremental)
pnpm sync-all         # Full sync (founders → brands → insights)

# Quality assurance
pnpm lighthouse       # Run Lighthouse CI
```

---

### Deployment Platforms

| App | Platform | URL | Build Command | Output Dir |
|-----|----------|-----|---------------|------------|
| **Hugo** | Cloudflare Pages | brandmine.ai | `pnpm build:hugo` | `apps/hugo/public/` |
| **Hub** | Cloudflare Pages | hub.brandmine.ai | `pnpm build:hub` | `apps/hub/dist/` |

**Environment Variables** (Cloudflare Pages):
- `CF_PAGES_COMMIT_SHA` - Git commit hash (auto-provided)
- `CF_PAGES_COMMIT_DATE` - Commit date
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase public API key
- `DATABASE_URL` - PostgreSQL connection string (for migrations)

---

## Documentation Structure

### Organization

```
docs/
├── hugo/                  # Hugo-specific technical docs
│   ├── content-architecture/
│   ├── multilingual/
│   └── image-processing/
│
├── hub/                   # Hub-specific technical docs
│   ├── architecture/
│   ├── pwa/
│   └── prompts/
│
├── database/              # Shared database documentation
│   ├── schema-design.md
│   ├── contact-forms.md
│   └── storage-buckets.md
│
├── workflows/             # Team workflows
│   ├── guides/           # Step-by-step procedures
│   └── reference/        # Reference documentation
│
├── brand/                 # Brand strategy, guidelines
│   ├── brand-strategy.md
│   ├── brand-guide.md
│   └── accessibility-standards.md
│
├── technical/             # Cross-cutting technical docs
│   ├── hugo-essentials.md
│   ├── color-system.md
│   ├── dark-mode-implementation-guide.md
│   └── monorepo-structure-report.md  ← THIS DOCUMENT
│
├── adr/                   # Architecture Decision Records
│   ├── 0001-decision-documentation-workflow.md
│   ├── 0025-minimal-pwa-for-hugo-static-site.md
│   └── ... (25 ADRs total)
│
├── backlog/               # Feature backlog
│   └── technical.md
│
├── dev-journal/           # Development notes, troubleshooting logs
│   ├── 2025-12-12-quick-filter-array-contains-reference.md
│   └── archive/
│
├── briefings/             # Technical briefings, assessments
│   ├── 2025-12-07-lighthouse-ci-assessment.md
│   └── ...
│
├── prompts/               # Handoff prompts for multi-session projects
│   └── ...
│
├── research-archive/      # Published research provenance
│   ├── README.md
│   ├── north-korea-skincare/
│   └── founders/
│
└── protocols/             # Mandatory procedures
    ├── README.md
    ├── systematic-troubleshooting.md
    ├── publishing-updates.md
    └── publishing-insights.md
```

### Key Documents

**Entry Points**:
- [CLAUDE.md](../../CLAUDE.md) - Project instructions for AI assistants (token-optimized)
- [README.md](../../README.md) - Project overview
- [docs/README.md](../README.md) - Documentation index

**Architecture Decisions**:
- [docs/adr/README.md](../adr/README.md) - ADR index (25+ decisions documented)

**Protocols** (Mandatory Procedures):
- [docs/protocols/README.md](../protocols/README.md) - CRITICAL workflows
- [docs/protocols/systematic-troubleshooting.md](../protocols/systematic-troubleshooting.md) - Debugging protocol
- [docs/protocols/publishing-updates.md](../protocols/publishing-updates.md) - Updates workflow
- [docs/protocols/publishing-insights.md](../protocols/publishing-insights.md) - Insights workflow

---

## Development Workflow

### Typical Development Flow

**1. Content Creation** (Hugo):
```bash
# Create new brand profile
cd apps/hugo
hugo new content/brands/brand-slug/index.en.md

# Add brand images
mkdir -p assets/images/brands/brand-slug/originals/
# Copy brand-logo.jpg to originals/

# Edit front matter + content
vim content/brands/brand-slug/index.en.md

# Test locally
hugo server

# Sync to database
cd ../..
node scripts/node/sync-to-supabase.js

# Commit
git add apps/hugo/content/brands/brand-slug/
git commit -m "feat(brands): Add Brand Name profile"
```

**2. CRM Development** (Hub):
```bash
# Create new feature
cd apps/hub/src/components/atomic-crm/
mkdir new-feature/

# Add React components
touch new-feature/NewFeatureList.tsx
touch new-feature/NewFeatureEdit.tsx

# Add database migration
cd supabase/migrations/
touch $(date +%Y%m%d)_create_new_feature_table.sql

# Test locally
cd ../..
pnpm dev:hub

# Run tests
pnpm test

# Type check
pnpm type-check

# Commit
git add .
git commit -m "feat(hub): Add new feature module"
```

**3. Shared Type Updates**:
```bash
# Edit shared types
vim packages/shared-types/src/index.ts

# Both apps auto-detect changes (workspace:* protocol)
# Rebuild Hub
pnpm build:hub

# Rebuild Hugo scripts (if needed)
node scripts/node/sync-to-supabase.js
```

**4. Database Migrations**:
```bash
# Shared content migrations (brands, founders)
vim scripts/migrations/shared/157-add-new-field.sql

# Test locally
source .env.local
psql "$DATABASE_URL" -f scripts/migrations/shared/157-add-new-field.sql

# Document in APPLIED.md
vim scripts/migrations/APPLIED.md

# Commit
git add scripts/migrations/
git commit -m "feat(db): Add new_field to brands table"

# Hub-specific migrations (CRM)
cd apps/hub
vim supabase/migrations/$(date +%Y%m%d)_add_crm_feature.sql

# Apply via Supabase CLI
supabase db push
```

### Git Hooks

**Post-commit hook** (`.git/hooks/post-commit`):
- Auto-generates `data/version.json` with commit hash and date
- Hugo uses this for local dev version display
- Production uses `CF_PAGES_COMMIT_SHA` from Cloudflare

---

## Key Design Decisions

### 1. Monorepo vs. Separate Repos

**Decision**: Monorepo with pnpm workspaces + Turbo

**Rationale**:
- ✅ **Shared types** (Brand, Founder interfaces across Hugo + Hub)
- ✅ **Atomic commits** (content + CRM changes in single commit)
- ✅ **Unified tooling** (ESLint, Prettier, TypeScript configs)
- ✅ **Simplified deployments** (single Git push triggers both apps)
- ✅ **Code reuse** (shared utilities, constants)

**Trade-offs**:
- ❌ Larger repo size (~500MB with all content)
- ❌ Requires monorepo tooling knowledge (pnpm workspaces, Turbo)
- ✅ Outweighed by developer productivity gains

**ADR**: [ADR-0001: Decision Documentation Workflow](../adr/0001-decision-documentation-workflow.md) (monorepo assumed from inception)

---

### 2. Database as Source of Truth (SSOT)

**Decision**: Supabase database is authoritative for all content (not Hugo files)

**Rationale**:
- ✅ **Hub CMS** enables non-technical team to publish updates (no Git/Markdown)
- ✅ **Version history** (database audit logs vs. Git history)
- ✅ **Relationships** (many-to-many joins easier in SQL than Hugo)
- ✅ **Real-time collaboration** (multiple editors, no merge conflicts)
- ✅ **Full-text search** (PostgreSQL `tsvector` for brands/founders)

**Implementation**:
- Hugo files are **generated artifacts** (sync FROM database)
- CTO can edit Hugo for complex articles (sync TO database once)
- Database owns canonical data, Hugo rebuilds from database

**Protocols**:
- [docs/protocols/publishing-updates.md](../protocols/publishing-updates.md) - Updates workflow (95% Hub CMS, 5% Hugo)
- [docs/protocols/publishing-insights.md](../protocols/publishing-insights.md) - Insights workflow (90% Hugo, 10% Hub CMS)

**ADR**: [ADR-0017: Incremental Sync for Hugo-Supabase](../adr/0017-incremental-sync-hugo-supabase.md)

---

### 3. Incremental Sync by Default

**Decision**: `sync-to-supabase.js` only syncs **changed files** by default (not full sync)

**Rationale**:
- ✅ **10-100x faster** for typical edits (30 seconds vs. 2 minutes)
- ✅ **Reduced database load** (only updated records)
- ✅ **Safer** (limits blast radius of errors)
- ✅ **Better developer experience** (fast feedback loop)

**Implementation**:
- Timestamp tracking in `data/last-sync.json`
- File modification time comparison (`fs.statSync().mtime`)
- `--full` flag for baseline syncs after schema changes

**ADR**: [ADR-0017: Incremental Sync for Hugo-Supabase](../adr/0017-incremental-sync-hugo-supabase.md)

---

### 4. Two-Tier Migration System

**Decision**: Separate migrations for shared content vs. Hub CRM

**Rationale**:
- ✅ **Separation of concerns** (public content vs. internal CRM)
- ✅ **Different deployment cadences** (content daily, CRM weekly)
- ✅ **Clear ownership** (CTO for content, Hub team for CRM)
- ✅ **Easier rollbacks** (smaller blast radius)

**Structure**:
```
scripts/migrations/shared/    # Content (brands, founders, insights)
apps/hub/supabase/migrations/ # CRM (contacts, deals, tasks)
```

**Documentation**: [scripts/migrations/README.md](../../scripts/migrations/README.md)

---

### 5. Hugo for Static Site (Not Next.js/Gatsby)

**Decision**: Hugo static site generator (not React-based SSG)

**Rationale**:
- ✅ **Performance** (Hugo builds 60+ pages in <2 seconds)
- ✅ **Simplicity** (no JavaScript required for content rendering)
- ✅ **Multilingual** (Hugo's native i18n is excellent)
- ✅ **SEO** (static HTML, no hydration delay)
- ✅ **China accessibility** (self-hosted assets, no CDN dependencies)
- ✅ **Stability** (Hugo 0.150.0 is mature, minimal breaking changes)

**Trade-offs**:
- ❌ Go templating language (less familiar than JSX)
- ❌ Limited client-side interactivity (Alpine.js fills gap)
- ✅ Outweighed by build speed and simplicity

**ADR**: Implicit (Hugo chosen before ADR system established)

---

### 6. China-Safe Architecture

**Decision**: All JavaScript libraries self-hosted (no CDN usage)

**Rationale**:
- ✅ **Accessibility** (China blocks googleapis, jsdelivr, gstatic)
- ✅ **Performance** (no DNS lookups to blocked domains)
- ✅ **Reliability** (no third-party downtime)
- ✅ **Privacy** (no tracking via CDN providers)

**Implementation**:
- Alpine.js: `apps/hugo/static/js/alpine.min.js` (v3.14.1)
- Fonts: `apps/hugo/static/fonts/` (PT Sans/Serif, Noto Sans SC)
- Exception: Umami analytics (optional, non-blocking)

**CRITICAL Constraint**: [CLAUDE.md Line 104](../../CLAUDE.md#L104-L107)

---

### 7. Taxonomy Constraint (4 Categories Only)

**Decision**: STRICT limit of 4 taxonomy categories (markets, sectors, attributes, signals)

**Rationale**:
- ✅ **Cognitive simplicity** (users understand 4 filters easily)
- ✅ **Mobile UX** (4 tabs fit on small screens)
- ✅ **Prevents taxonomy sprawl** (forces deliberate design)
- ✅ **Strategic alignment** (8+4 formula: 8 attributes + 4 signals)

**Implementation**:
- Configuration: `apps/hugo/hugo.yaml` (taxonomies section)
- Data: `apps/hugo/data/taxonomies/*.json`
- No new categories permitted (CTO authority)

**CRITICAL Constraint**: [CLAUDE.md Line 97](../../CLAUDE.md#L97)

**ADR**: Implicit (established in brand strategy)

---

### 8. Minimal Bold Usage (Bold Formatting Policy)

**Decision**: Reserve bold for native script glossing and key statistics only

**Rationale**:
- ✅ **Mobile-first** (excessive bold creates visual fatigue on small screens)
- ✅ **Cognitive load** (strategic restraint improves scannability)
- ✅ **Scholarly precision** (glossing serves verification, not decoration)
- ✅ **Narrative flow** (over-bolding disrupts reading rhythm)

**Guidelines**:
- ✅ **ALWAYS use bold** for native script glossing (first mention only)
  - Example: `**Mikhail Nikolaev Sr. (Михаил Николаев)** founded...`
- ✅ Key statistics in data sections
- ❌ **NEVER use bold** for entire opening sentences, rhetorical questions, or standalone transitions

**Reference**: [CLAUDE.md Lines 214-275](../../CLAUDE.md#L214-L275)

---

### 9. Dark Mode Strategy

**Decision**: Site-wide dark mode respecting system preference (`prefers-color-scheme`)

**Rationale**:
- ✅ **2025 best practice** (dark mode expected by users)
- ✅ **Accessibility** (reduces eye strain in low-light environments)
- ✅ **Battery life** (OLED screens benefit from dark mode)
- ✅ **Professional appearance** (modern design standard)

**Implementation**:
- CSS variables (`--bg-primary`, `--text-primary`, etc.)
- Automatic switching via media query
- All components, edge cases, validation states supported

**Status**: Phase 3 Complete - Production Ready (2025-12-10)

**ADR**: [ADR-0034: Site-Wide Dark Mode Strategy](../adr/0034-site-wide-dark-mode-strategy.md)

---

### 10. Lighthouse CI for Quality Assurance

**Decision**: Automated Lighthouse audits on every build

**Rationale**:
- ✅ **Performance enforcement** (prevent regressions)
- ✅ **Accessibility compliance** (WCAG AA standards)
- ✅ **SEO validation** (meta tags, structured data)
- ✅ **Best practices** (security headers, HTTPS)

**Thresholds** (Phase 1 - Conservative):
- Performance: WARN at 60 (baseline)
- Accessibility: ERROR at 94 (enforce current level)
- SEO: ERROR at 92
- Critical audits: `color-contrast`, `lcp-lazy-loaded`, `heading-order`, `errors-in-console`

**Configuration**: `lighthouserc.json` (repo root)

**Documentation**: [docs/briefings/2025-12-07-lighthouse-ci-assessment.md](../briefings/2025-12-07-lighthouse-ci-assessment.md)

---

## Summary of Key Strengths

1. **Unified Codebase**: Monorepo enables atomic commits, shared types, consistent tooling
2. **Content-Database Sync**: Bidirectional sync allows CTO (Hugo) and team (Hub CMS) workflows
3. **Multilingual First-Class**: Hugo's native i18n + content sync supports EN/RU/ZH seamlessly
4. **Performance-Optimized**: Hugo builds (2 sec), incremental sync (30 sec), Lighthouse CI enforcement
5. **Type Safety**: Shared TypeScript types prevent drift between Hugo scripts and Hub React app
6. **Documented Decisions**: 25+ ADRs capture architectural rationale for future maintainers
7. **Automated Quality**: Lighthouse CI + content validation prevent regressions
8. **China-Accessible**: Self-hosted assets ensure site works in restricted regions
9. **Mobile-First**: 320px-414px primary viewport, dark mode, PWA capabilities

---

## Common Gotchas & Best Practices

### Gotchas

1. **Front matter image paths**: Use filenames only (e.g., `image: portrait-formal.jpg`), NOT full paths
2. **YAML quoting**: Minimal quoting policy (only quote multi-word values with spaces, ISO dates, special chars)
3. **Hugo i18n location**: MUST be in `/apps/hugo/i18n/` (not `/data/translations/`)
4. **Database SSOT**: Updates/Insights database owns canonical data, Hugo files are generated
5. **Sync direction**: Updates = Database → Hugo (primary), Insights = Hugo → Database (primary)
6. **Migration tiers**: Shared content (`scripts/migrations/shared/`) vs. Hub CRM (`apps/hub/supabase/migrations/`)
7. **Taxonomy constraint**: ONLY 4 categories (markets, sectors, attributes, signals), no additions permitted
8. **Control terms**: `eventType`, `contentTier`, taxonomy slugs MUST remain English (Hugo template matching)

### Best Practices

1. **Incremental sync first**: Use default incremental sync for speed, `--full` only after schema changes
2. **Dry-run migrations**: Test all SQL migrations with `--dry-run` before applying
3. **ADRs for architecture**: Document significant decisions in `docs/adr/` (not Slack/email)
4. **Troubleshooting logs**: After 3 failed debug attempts, create log in `docs/dev-journal/`
5. **Native script glossing**: Always gloss at first mention (e.g., `**Perfect Diary (完美日记)**`)
6. **Mobile-first testing**: Test on 320px viewport (iPhone SE) before desktop
7. **Colorblind-safe design**: Use blue-based spectrum (never red-green combinations)
8. **Self-hosted dependencies**: ALL JavaScript libraries in `static/` (no CDN usage)

---

## Contact & Maintenance

**Primary Maintainer**: Brandmine CTO (Claude Code)

**Key Stakeholders**:
- CEO (Randal) - Content strategy, business decisions
- Research Director (Claude Research) - Deep investigation, timeline creation
- COO (Claude Console) - Strategic review, quality assurance

**Documentation Updates**: This report should be updated when:
- New applications added to monorepo
- Shared packages created/modified
- Migration system changes
- Major architectural decisions made

**Version History**:
- **v1.0** (2025-12-16) - Initial technical report for external CTO

---

## Appendices

### A. File Extensions & Conventions

| Extension | Purpose | Example |
|-----------|---------|---------|
| `.en.md` | English markdown content | `index.en.md` |
| `.ru.md` | Russian markdown content | `index.ru.md` |
| `.zh.md` | Chinese markdown content | `index.zh.md` |
| `.tsx` | TypeScript React component | `BrandList.tsx` |
| `.ts` | TypeScript utility/type | `dataProvider.ts` |
| `.sql` | Database migration | `157-add-field.sql` |
| `.json` | Data file | `taxonomies/markets.json` |
| `.yaml` | Configuration | `hugo.yaml` |

### B. Environment Variables

**Required in `.env.local`**:
```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres

# Optional
VITE_UMAMI_WEBSITE_ID=xxx  # Analytics (optional)
```

**Auto-provided by Cloudflare Pages**:
```bash
CF_PAGES_COMMIT_SHA=abc123...
CF_PAGES_COMMIT_DATE=2025-12-16T10:30:00Z
```

### C. Useful Commands Reference

```bash
# Monorepo
pnpm install                           # Install all dependencies
pnpm dev                               # Start both apps in parallel
pnpm build                             # Build both apps
turbo run build --dry                  # Preview build tasks

# Hugo
cd apps/hugo
hugo server                            # Dev server (localhost:1313)
hugo server --buildFuture              # Include future-dated content
hugo --gc --minify                     # Production build

# Hub
cd apps/hub
pnpm dev                               # Dev server (localhost:5173)
pnpm build                             # Production build
pnpm test                              # Run tests
pnpm type-check                        # TypeScript validation

# Database
source .env.local
psql "$DATABASE_URL"                   # Connect to database
psql "$DATABASE_URL" -f migration.sql  # Apply migration

# Sync
node scripts/node/sync-to-supabase.js              # Hugo → DB (incremental)
node scripts/node/sync-to-supabase.js --full       # Hugo → DB (full)
node scripts/node/sync-from-supabase.js            # DB → Hugo
node scripts/node/sync-all.js                      # Full orchestrated sync

# Quality
pnpm lighthouse                        # Lighthouse CI (Hugo)
pnpm lighthouse:hub                    # Lighthouse CI (Hub)
pnpm validate                          # Content validation

# Utilities
node scripts/node/add-db-ids-to-frontmatter.js     # Backfill DB IDs
node scripts/node/upload-brand-image.js brand-slug # Upload image
```

---

**End of Report**
