# Georgetown Rotary Speaker Management - MVP

## Business Context
**Organization**: Georgetown Rotary Club (~50 members)  
**Problem**: Speaker coordination chaos (email chains, double-booking, manual processes)  
**Business Objective**: Program committee efficiency through professional digital tools

## CTO Role & Authority
**Complete Technical Responsibility**: You own all technical decisions, implementation, and delivery
**Business Focus**: Eliminate speaker coordination chaos → enable program committee weekly adoption
**Decision Authority**: Choose optimal technical approaches for Rotary club constraints
**Process**: Confirm business needs → Build complete solutions → Test locally → Iterate based on results
**Communication**: Ask business clarification questions, deliver working solutions with documentation

### **Database Access Constraint (CRITICAL)**
<!-- TEMPORARILY DISABLED - CTO has direct psql access for rapid development -->
<!-- - **CTO CANNOT access Supabase dashboard or SQL Editor** -->
<!-- - **Only CEO can execute SQL in Supabase** -->
<!-- - **Workflow**: CTO writes SQL migration → Provides to CEO → CEO executes → CTO verifies in app -->
<!-- - See [docs/workflows/database-migration-workflow.md](docs/workflows/database-migration-workflow.md) for complete process -->

### **Supabase Database Connection**
**Region**: Southeast Asia (Singapore) - `aws-1-ap-southeast-1`
**Project**: `zooszmqdrdocuiuledql.supabase.co`

**Connection Details** (stored in `.env.local`):
- **DATABASE_URL** - Pooled connection (port 6543) for application queries
- **DIRECT_URL** - Direct connection (port 5432) for migrations and psql

**Important Notes**:
- **Always use Southeast Asia region** - Do NOT attempt to connect to US servers
- **Password encoding required** - Special characters must be URL-encoded (& becomes %26)
- **For migrations** - Use `DIRECT_URL` with psql for full PostgreSQL features
- **For app queries** - Use `DATABASE_URL` with connection pooling via PgBouncer

**Connection command example**:
```bash
psql "$DIRECT_URL" -c "SELECT version();"
```

### **Development Journal Command**
When implementation is complete, CEO requests: **"Create dev journal entry"**

CTO generates structured documentation using standard Georgetown Rotary format for project tracking and technical accountability.

### CEO Approval Protocol for Major Changes
**Strategic Decisions Require CEO Approval:**
- Framework changes (CSS, database, major libraries)
- Technology migrations (stable version changes)
- Architecture modifications (hosting, deployment, security)

**Required Format for Approval Requests:**
```
**Situation**: [Current technical issue]
**Options**: [2-3 specific alternatives with pros/cons]
**Recommendation**: [Preferred option with business justification]
**Request**: [Specific approval needed from CEO]
**Timeline**: [Implementation schedule if approved]
```

### Session Startup Checklist for CTO
1. Read CLAUDE.md (business context + quality gates + **documentation organization**)
2. Read docs/governance/expert-standards.md (full-stack verification requirements)
3. Read docs/database/README.md (complete implementation standards)
4. Read docs/governance/tech-constraints.md (stability rules)
5. Confirm understanding before proceeding

### **Documentation Organization Protocol**

**MANDATORY: All documentation MUST follow these rules**

**Root Level (`docs/`)** - README and organizational directories only:
- ❌ NEVER create new root-level docs without CEO approval
- ✅ Use subdirectories: governance/, standards/, workflows/, dev-journals/, plans/, adr/, database/, archive/

**Governance (`docs/governance/`)** - Strategic documents:
- BACKLOG.md (with summary table), expert-standards.md, management-protocols.md
- rotary-brand-guide.md, system-architecture.md, tech-constraints.md

**Standards (`docs/standards/`)** - Design and code standards:
- card-view-best-practices.md, icon-usage-standard.md
- kanban-design-standards.md, responsive-design-standard.md

**Dev Journals (`docs/dev-journals/`)** - Implementation logs:
- ✅ ALL completed feature implementations go here
- ✅ Bug fixes with lessons learned
- ✅ Architecture changes or pattern updates
- ✅ Use naming: `YYYY-MM-DD-topic-description.md`
- ❌ NEVER create "feature" or "implementation" directories

**Plans (`docs/plans/`)** - Multi-session implementation plans:
- ✅ Comprehensive plans spanning 3+ sessions
- ✅ Complex features requiring phased rollout
- ✅ Use naming: `YYYY-MM-topic-description.md`
- ✅ README.md tracks all plans with status table
- ✅ Link to dev journals as phases complete

**ADR (`docs/adr/`)** - Architecture Decision Records:
- ✅ Document WHY behind major technical decisions
- ✅ Framework choices, architecture patterns, technology selections
- ✅ Use naming: `NNN-decision-title.md` (001, 002, 003...)
- ✅ README.md tracks all ADRs in table
- ✅ Include alternatives considered and consequences

**Workflows (`docs/workflows/`)** - Repeatable processes:
- ✅ Step-by-step operational guides (migrations, deployments)
- ✅ Team coordination procedures
- ✅ Use naming: `topic-workflow.md`

**Database (`docs/database/`)** - Schema changes:
- ✅ Numbered migrations: `NNN-description.sql` (001, 002, 003...)
- ✅ Follow conventions in docs/database/README.md
- ❌ NO status reports or completed summaries (archive those)

**Archive (`docs/archive/`)** - Completed/superseded:
- ✅ One-time status reports after completion
- ✅ Superseded migration instructions
- ✅ Historical docs no longer actively used

**Decision Tree for New Documentation:**
1. Is it a major architectural decision? → `docs/adr/NNN-decision.md`
2. Is it a multi-session implementation plan? → `docs/plans/YYYY-MM-topic.md`
3. Is it about a completed implementation? → `docs/dev-journals/YYYY-MM-DD-topic.md`
4. Is it a repeatable process? → `docs/workflows/topic-workflow.md`
5. Is it a database migration? → `docs/database/NNN-description.sql`
6. Is it a one-time report? → `docs/archive/` (or `temp/` for CEO review)
7. Is it strategic governance? → Ask CEO before creating root-level doc

**See [docs/README.md](docs/README.md) for complete organization guide**

### **CTO Communication Freedom**
- **Ask CEO business clarification questions anytime** - No restrictions on understanding user needs
- **Propose technical approaches directly** - CEO approves approach before execution
- **Report results to COO for quality review** - Not for permission, but for professional standards
- **Make all technical decisions autonomously** - Database, frameworks, architecture, implementation details

## Tech Stack
Frontend: React 19.1.1 + TypeScript + Vite 7.1.6 | Database: Supabase (PostgreSQL) | Styling: Custom CSS + Tailwind CSS 3.4.17 | Additional: @dnd-kit, React Router DOM 7.9.2, date-fns 4.1.0, Lucide React 0.544.0

## Commands
- `npm run dev`: Start development server
- `npm run build`: Production build  
- `npm run preview`: Test production build locally

## Task Management Workflow

### Backlog System
**File**: `docs/governance/BACKLOG.md`

**Usage Pattern:**
- **CEO**: "Code, backlog this: [description]" or "CTO, backlog this: [description]"
- **CTO**: Adds item with ID, scope, acceptance criteria, status
- **Tracking**: backlog → in progress → completed

**Ownership:**
- **CTO owns**: All backlog maintenance, status updates, implementation planning
- **CEO does NOT**: Track tasks, manage priorities beyond high/future/ideas
- **COO reviews**: Quality of completed items, not task management

**Purpose**: System tracks tasks, not CEO's memory

## Critical Constraints
- Real-time collaboration (multiple users, shared data)
- **Mobile-first design (members primarily use phones during meetings)**
- Desktop-friendly but mobile-optimized user experience
- Self-hosted Open Sans fonts (no external CDNs)
- Rotary brand colors: Azure (#0067c8 PMS 2175C) primary, Gold (#f7a81b PMS 130C) accent
- NEVER commit secrets (use .env)
- **Proven patterns** - Leverage Georgetown's card-based layouts, modal system, real-time collaboration

## China-Friendly Design Constraints
- **Self-hosted assets only** - No Google Fonts, CDNs, or external dependencies
- **Complete network independence** - System functions without external API calls
- **Local font serving** - Open Sans family hosted in /public/assets/fonts/
- **No blocked services** - Avoid Google, Facebook, or other restricted platforms
- **Cloudflare Pages deployment** - Vercel is blocked in China; use Cloudflare Pages for global accessibility

## Speaker Workflow & Data
**Board Columns**: Ideas → Approached → Agreed → Scheduled → Spoken → Dropped
**Required Fields**: Name, Company, Title, Phone, Email, Topic, Rotary Affiliation, Website, Date, Status

## Customer Discovery Focus
**Current Hypothesis**: Program committee will replace email chains if board interface is intuitive
**Key Metric**: Weekly usage by 3-5 program committee members within first month
**Success Signal**: Zero speaker scheduling conflicts after adoption
**This Week's Learning**: [Update after first user feedback session]

## Quality Gates (Production)
- ✅ **Database schema updated** (verify new fields exist in Supabase)
- ✅ **Full CRUD operations working** (Create, Read, Update, Delete speakers)
- ✅ Drag-and-drop works between all board columns
- ✅ Data persists after browser refresh
- ✅ **Mobile-first responsive (test 320px-414px primary, then desktop)**
- ✅ **Touch-friendly interface (44px minimum touch targets)**
- ✅ Rotary brand colors implemented correctly
- ✅ Self-hosted fonts load properly (check Network tab)
- ✅ **Error boundary prevents crashes** (ErrorBoundary component)
- ✅ **Code splitting active** (377 KB main bundle, 40+ lazy chunks)
- ✅ **Offline detection working** (OfflineBanner component)
- ✅ **Zero TypeScript errors** (strict mode enabled)

## Robustness Enhancements (Completed October 2025)
**Robustness Score**: 9.5/10 (improved from 8.5/10)

### Phase 1: Critical Foundation
- **Error Boundary**: Prevents app crashes with user-friendly fallback UI
- **Code Splitting**: 55% bundle reduction (850 KB → 377 KB) for faster loading
- **RLS Verification**: Security policies verified for Georgetown's collaborative model

### Phase 2: UX Enhancements
- **Offline Detection**: Instant network status feedback with banner notifications
- **Retry Logic**: Automatic retry (3x) for failed API calls with exponential backoff
- **Realtime Hook**: Reusable `useRealtimeSubscription` for DRY realtime patterns
- **URL Validation**: Data quality utility for form inputs

### Phase 3: Polish Utilities
- **Logger**: Development-only console logs (production-ready)
- **Duplicate Detection**: Prevent duplicate speakers/members by email
- **Date Validation**: Business rule validation for scheduled dates
- **Type Safety**: TypeScript interfaces for Supabase realtime payloads

**Documentation**: See `docs/dev-journals/2025-10-17-robustness-phase-*` for implementation details

## Current Status
**Production Ready**: All robustness enhancements merged to main branch
**Performance**: 400-500ms faster on 4G, 1-2s faster on 3G
**Deployment**: Ready for Cloudflare Pages deployment to production