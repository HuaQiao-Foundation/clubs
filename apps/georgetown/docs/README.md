# Georgetown Rotary Documentation

**Purpose**: Organized technical and business documentation for Georgetown Rotary Club's speaker management system.

**Last Updated**: 2025-12-17

---

## Quick Reference

### 📁 Directory Structure

```
docs/
├── README.md                          ← This file (documentation index)
│
├── governance/                        ← Strategic governance (6 files)
│   ├── BACKLOG.md                     ← Active task tracking
│   ├── expert-standards.md
│   ├── management-protocols.md
│   ├── rotary-brand-guide.md
│   ├── system-architecture.md
│   └── tech-constraints.md
│
├── standards/                         ← Design/code standards (4 files)
│   ├── card-view-best-practices.md
│   ├── icon-usage-standard.md
│   ├── kanban-design-standards.md
│   └── responsive-design-standard.md
│
├── database/                          ← SQL migrations (68+ files)
├── dev-journals/                      ← Implementation history (46 files)
├── workflows/                         ← Repeatable processes & operations
│   ├── operational/                   ← Runtime operations (backups, etc.)
│   └── testing/                       ← Test checklists
├── user-guides/                       ← End-user documentation (1 file)
├── reference/                         ← Rotary International data (3 files)
├── knowledge-transfer/                ← Reusable patterns & best practices
│   └── best-practices/                ← Best practices from other projects
└── archive/                           ← Completed/superseded docs (40+ files)
```

---

## 📚 Core Documentation

### Governance (Strategic Decisions)

| File | Purpose |
|------|---------|
| [expert-standards.md](governance/expert-standards.md) | CTO requirements, quality assurance standards |
| [management-protocols.md](governance/management-protocols.md) | Team roles, decision authority, communication protocols |
| [rotary-brand-guide.md](governance/rotary-brand-guide.md) | Brand colors, typography, logo protection |
| [system-architecture.md](governance/system-architecture.md) | Complete tech stack, components, database schema |
| [tech-constraints.md](governance/tech-constraints.md) | Technology selection rules (stability requirements) |

### Standards (Design & Code Patterns)

| File | Purpose |
|------|---------|
| [card-view-best-practices.md](standards/card-view-best-practices.md) | Card layout patterns, responsive design, mobile-first |
| [icon-usage-standard.md](standards/icon-usage-standard.md) | Icon sizing, touch targets, accessibility |
| [kanban-design-standards.md](standards/kanban-design-standards.md) | Board view design patterns, drag-and-drop UX |
| [responsive-design-standard.md](standards/responsive-design-standard.md) | Breakpoints, mobile-first approach, touch optimization |

---

## 🗂️ Subdirectories

### database/
**Purpose**: SQL migrations and database documentation
**Contents**: 56 numbered migration files (001-048+), README, database-protocol
**Naming**: `NNN-description.sql` (e.g., `001-locations-migration.sql`)

### dev-journals/
**Purpose**: Implementation logs and feature documentation
**Contents**: 46 dated entries documenting completed work (consolidated from dev-journal/ and dev-journals/)
**Naming**: `YYYY-MM-DD-topic-description.md` (e.g., `2025-10-17-mobile-first-optimization.md`)

### workflows/
**Purpose**: Repeatable process documentation and operational procedures
**Structure**:
- Root level: General workflows (deployment, migration, dev-journal, etc.)
- `operational/`: Runtime operations (automated backups, database operations)
- `testing/`: Test checklists and QA procedures
**Key Files**:
- [ceo-coo-cto-workflow.md](workflows/ceo-coo-cto-workflow.md) - Team coordination
- [database-migration-workflow.md](workflows/database-migration-workflow.md) - How to do migrations
- [cloudflare-deployment-workflow.md](workflows/cloudflare-deployment-workflow.md) - Deployment process
- [dev-journal-workflow.md](workflows/dev-journal-workflow.md) - How to document work
- [operational/automated-backups.md](workflows/operational/automated-backups.md) - Backup procedures
- [testing/phase3-rsvp-attendance-testing.md](workflows/testing/phase3-rsvp-attendance-testing.md) - RSVP testing checklist

### user-guides/
**Purpose**: End-user documentation for Rotary members
**Contents**: 1 guide
**File**: [timeline-user-guide.md](user-guides/timeline-user-guide.md) - Using timeline feature

### reference/
**Purpose**: Rotary International official data (formerly reference-data/)
**Contents**: 3 reference documents
**Update**: Annually in June (before new Rotary year)

### knowledge-transfer/
**Purpose**: Reusable patterns, components, and best practices
**Structure**:
- `best-practices/`: Best practices from other projects (formerly "best practices from our other projects")
- `reusable-components/`: Shareable React components
- `reusable-hooks/`: Shareable React hooks
- `reusable-utilities/`: Shareable utility functions
**Key Files**:
- [react-spa-playbook.md](knowledge-transfer/react-spa-playbook.md) - React SPA patterns
- [toastmasters-adaptation-guide.md](knowledge-transfer/toastmasters-adaptation-guide.md) - Adapting this codebase

### archive/
**Purpose**: Completed or superseded documentation
**Contents**: 27 archived files
**When to archive**: Completed implementations, one-time diagnostics, superseded approaches

---

## 🔍 Finding Information

**Need to know...**
- **How the system works?** → [governance/system-architecture.md](governance/system-architecture.md)
- **What tech we can use?** → [governance/tech-constraints.md](governance/tech-constraints.md)
- **Brand/color guidelines?** → [governance/rotary-brand-guide.md](governance/rotary-brand-guide.md)
- **Team roles/authority?** → [governance/management-protocols.md](governance/management-protocols.md)
- **Quality standards?** → [governance/expert-standards.md](governance/expert-standards.md)
- **How to design cards?** → [standards/card-view-best-practices.md](standards/card-view-best-practices.md)
- **Icon sizing rules?** → [standards/icon-usage-standard.md](standards/icon-usage-standard.md)
- **Mobile-first patterns?** → [standards/responsive-design-standard.md](standards/responsive-design-standard.md)
- **How to do migrations?** → [workflows/database-migration-workflow.md](workflows/database-migration-workflow.md)
- **How to deploy?** → [workflows/cloudflare-deployment-workflow.md](workflows/cloudflare-deployment-workflow.md)
- **How feature X was built?** → Search [dev-journals/](dev-journals/) by date
- **Database schema?** → [database/README.md](database/README.md) and migration files
- **Rotary official data?** → [reference/](reference/)
- **Reusable patterns?** → [knowledge-transfer/](knowledge-transfer/)
- **Testing procedures?** → [workflows/testing/](workflows/testing/)
- **Backup procedures?** → [workflows/operational/](workflows/operational/)

---

## 📝 Documentation Workflow

### When to Create Documentation

**governance/** (rare - core strategic only):
- Business rules affecting all development
- Governance and decision-making processes
- Brand compliance requirements
- Active task tracking (BACKLOG.md)
- **Ask CEO before** creating new governance docs

**standards/** (occasional - design patterns):
- Reusable design patterns (used 3+ times)
- Code quality standards
- UI/UX conventions
- Accessibility requirements

**dev-journals/** (common - after completing work):
- Completed feature implementations
- Bug fixes with valuable lessons
- Architecture or pattern changes
- Use naming: `YYYY-MM-DD-topic-description.md`

**workflows/** (as needed - repeatable processes):
- Processes repeated 3+ times
- Step-by-step operational guides
- Team coordination procedures
- Use naming: `topic-workflow.md`

**database/** (for schema changes):
- Numbered migrations: `NNN-description.sql`
- Follow [database/README.md](database/README.md) conventions

---

## 🎯 Key Conventions

### File Naming

- **Governance docs**: `kebab-case.md` (e.g., `system-architecture.md`)
- **Standards docs**: `kebab-case-standard.md` (e.g., `icon-usage-standard.md`)
- **Dev journals**: `YYYY-MM-DD-description.md` (e.g., `2025-10-17-mobile-first-optimization.md`)
- **SQL migrations**: `NNN-description.sql` (e.g., `001-locations-migration.sql`)
- **Workflows**: `topic-workflow.md` (e.g., `database-migration-workflow.md`)
- **User guides**: `feature-user-guide.md` (e.g., `timeline-user-guide.md`)

### When to Archive

Move docs to `archive/` when:
- Implementation completed (status reports, migration instructions)
- Content superseded by newer approach
- Historical value but not actively referenced
- One-time diagnostics or troubleshooting guides
- Analysis documents after decision made

---

## 🏗️ Organization Principles

1. **Minimal Root** - Only README at root level (BACKLOG in governance/)
2. **Clear Separation** - Governance vs. Standards vs. Implementation
3. **Active vs. Archived** - Separate completed work from active docs
4. **Single Source of Truth** - No redundant documentation
5. **Clear Naming** - Obvious purpose from filename alone
6. **Purposeful Directories** - Every directory earns its place
7. **Easy Navigation** - Find anything in 2 clicks or less

---

## 🔧 Maintenance

**Monthly**: Review dev-journals for archival candidates
**Quarterly**: Audit documentation accuracy against codebase
**Annually**: Update Rotary reference data (June, before new Rotary year)

---

## 📊 Documentation Statistics

- **Root files**: 1 (README.md only)
- **Governance docs**: 6 strategic documents (includes BACKLOG.md)
- **Standards docs**: 4 design/code patterns
- **Database migrations**: 68+ files
- **Dev journals**: 46 implementation logs (consolidated)
- **Workflows**: 13+ process guides (including operational & testing subdirs)
- **User guides**: 1 end-user document
- **Reference data**: 3 Rotary documents
- **Knowledge transfer**: 20+ reusable patterns, components, hooks
- **Archived**: 40+ completed/superseded docs

**Total documentation**: 160+ files organized across 11 directories

---

## 🌟 Why This Structure?

**Benefits**:
- **Easy Onboarding** - New developers find docs in seconds
- **Clear Ownership** - Know who approves what (CEO = governance, CTO = standards)
- **Reduced Clutter** - Root has only 1 file (README.md)
- **Better Search** - Grouped by purpose, not alphabetically
- **Scales Well** - Can add new categories without reorganizing

**Follows 2025 Best Practices**:
- ✅ Separation of concerns (governance vs. standards vs. implementation)
- ✅ Purpose-based organization (not file-type based)
- ✅ Minimal root clutter (1 file - cleaner than Brandmine's 6)
- ✅ Clear navigation paths
- ✅ Active vs. archived separation

---

**Structure Model**: Based on [Brandmine documentation best practices](https://brandmine.com)
**Maintained by**: CTO (Claude Code)
**Last Reorganization**: 2025-12-17 (consolidated directories, improved organization)
**Next Review**: 2026-01-17

---

## 📋 Recent Changes (2025-12-17)

- ✅ Merged `dev-journal/` into `dev-journals/` (46 total files)
- ✅ Renamed `reference-data/` to `reference/` for consistency
- ✅ Consolidated `operations/`, `protocols/`, and `checklists/` into `workflows/` subdirectories
- ✅ Renamed `knowledge-transfer/best practices from our other projects/` to `best-practices/`
- ✅ Updated all directory references and file counts
- ✅ Enhanced navigation shortcuts
