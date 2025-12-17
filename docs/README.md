# Clubs Monorepo Documentation

**Purpose**: Organized documentation for monorepo-level concerns, architecture decisions, and shared knowledge across all club applications.

**Last Updated**: 2025-12-17

---

## Quick Reference

### 📁 Directory Structure

```
docs/
├── README.md                          ← This file (documentation index)
│
├── adr/                               ← Architecture Decision Records
│   └── ADR-001-backlog-management-system.md
│
├── archive/                           ← Completed/historical documentation
│   └── backlog-2025.md                ← Archived backlog items from 2025
│
├── dev-journals/                      ← Monorepo-level implementation logs
│   └── YYYY-MM-DD-*.md
│
├── handoffs/                          ← Session handoff prompts for Claude
│   └── *.md
│
├── plans/                             ← Monorepo implementation plans
│   ├── README.md
│   └── *.md
│
├── protocols/                         ← Repeatable processes
│   └── *.md
│
├── reference/                         ← Quick reference guides
│   └── *.md
│
└── technical-briefings/               ← Technical analysis documents
    └── *.md
```

---

## 📚 Core Documentation

### Monorepo Management

| File | Purpose |
|------|---------|
| [backlog-management-system.md](backlog-management-system.md) | Backlog management process, best practices, workflow |
| [BACKLOG.md](../BACKLOG.md) | Active backlog tracking (root level) |

### Architecture Decisions (adr/)

Architecture Decision Records document significant technical decisions:

| File | Purpose |
|------|---------|
| [ADR-001-backlog-management-system.md](adr/ADR-001-backlog-management-system.md) | Markdown-based backlog system decision |

### Protocols (Repeatable Processes)

| File | Purpose |
|------|---------|
| [direct-database-access.md](protocols/direct-database-access.md) | Direct database connection procedures |
| [systematic-troubleshooting.md](protocols/systematic-troubleshooting.md) | Troubleshooting workflow and methodology |

### Reference (Quick Guides)

| File | Purpose |
|------|---------|
| [database-quick-reference.md](reference/database-quick-reference.md) | Database connection strings and common commands |
| [pwa-implementation-lessons-learned.md](reference/pwa-implementation-lessons-learned.md) | PWA implementation best practices and gotchas |

---

## 🗂️ Subdirectories

### adr/ (Architecture Decision Records)
**Purpose**: Document significant technical and architectural decisions
**Format**: ADR-NNN-short-title.md
**When to create**: Major technology choices, process changes, structural decisions

### archive/
**Purpose**: Completed work, historical snapshots, superseded documentation
**Contents**: Completed backlog items (by year), outdated reports, point-in-time analyses
**Naming**: `backlog-YYYY.md` for archived backlogs, original names for other archived docs

### dev-journals/
**Purpose**: Monorepo-level implementation logs (typescript fixes, pnpm migration, etc.)
**Naming**: `YYYY-MM-DD-topic-description.md`
**Scope**: Cross-project changes, monorepo tooling, shared infrastructure

### handoffs/
**Purpose**: Session handoff prompts for Claude Code
**Contents**: Context-rich prompts for starting new sessions or handing off complex work
**When to create**: Before ending complex sessions, for recurring tasks

### plans/
**Purpose**: Implementation plans for monorepo-level features
**Contents**: Cloudflare deployment, PWA implementation, monorepo tooling
**Format**: See [plans/README.md](plans/README.md)

### protocols/
**Purpose**: Repeatable operational processes
**Contents**: Database access procedures, troubleshooting workflows, deployment protocols
**When to create**: Process used 3+ times across projects

### reference/
**Purpose**: Quick reference guides and cheat sheets
**Contents**: Database quick reference, lessons learned compilations
**When to create**: Information referenced frequently during development

### technical-briefings/
**Purpose**: In-depth technical analysis and research
**Contents**: Technology evaluations, architecture explorations, performance analyses
**Scope**: Monorepo-wide technical concerns

---

## 🔍 Finding Information

**Need to know...**
- **Backlog process?** → [backlog-management-system.md](backlog-management-system.md)
- **Active tasks?** → [BACKLOG.md](../BACKLOG.md) (root level)
- **Why we chose X?** → Search [adr/](adr/)
- **How to do Y?** → Search [protocols/](protocols/)
- **What happened when?** → Search [dev-journals/](dev-journals/) by date
- **Implementation plan for Z?** → Search [plans/](plans/)
- **Quick reference for Z?** → Search [reference/](reference/)
- **Completed work?** → [archive/](archive/)

---

## 📝 Documentation Workflow

### When to Create Monorepo-Level Documentation

**adr/** (rare - major decisions only):
- Technology stack changes affecting all apps
- Monorepo tooling decisions (pnpm, build system, etc.)
- Cross-project architectural patterns
- Process/workflow changes

**dev-journals/** (occasional - after monorepo work):
- TypeScript configuration changes
- Build system updates (Vite, pnpm)
- Monorepo tooling improvements
- Cross-project refactors

**protocols/** (as needed - repeatable processes):
- Processes used across multiple projects
- Deployment procedures
- Database management workflows
- Troubleshooting guides

**plans/** (before major work):
- Monorepo infrastructure changes
- Cross-project feature rollouts
- Technology migrations

**handoffs/** (before session ends):
- Complex work requiring continuation
- Recurring maintenance tasks
- Onboarding scenarios

---

## 🎯 Key Conventions

### File Naming

- **ADRs**: `ADR-NNN-short-title.md` (e.g., `ADR-001-backlog-management-system.md`)
- **Dev journals**: `YYYY-MM-DD-description.md` (e.g., `2025-12-17-pnpm-migration.md`)
- **Plans**: `YYYY-MM-DD-plan-name.md` or `feature-implementation-plan.md`
- **Protocols**: `process-name-protocol.md` (e.g., `database-access-protocol.md`)
- **Reference**: `topic-quick-reference.md` (e.g., `database-quick-reference.md`)

### When to Archive

Move docs to `archive/` when:
- Backlog items completed (archive quarterly by year)
- Point-in-time reports/snapshots (structure analyses, etc.)
- Superseded by newer approaches
- Historical value but not actively referenced
- Completed implementation plans

---

## 🏗️ Organization Principles

1. **Monorepo Scope Only** - App-specific docs live in app directories
2. **Clear Separation** - ADRs vs. Plans vs. Implementation vs. Reference
3. **Active vs. Archived** - Keep archive/ clean and organized
4. **Single Source of Truth** - No redundant documentation
5. **Cross-Reference Freely** - Link to app docs when relevant
6. **Purposeful Directories** - Every directory earns its place

---

## 📊 App-Specific Documentation

This folder contains **only monorepo-level documentation**. For app-specific docs:

- **Georgetown**: [apps/georgetown/docs/](../apps/georgetown/docs/)
- **Pitchmasters**: [apps/pitchmasters/docs/](../apps/pitchmasters/docs/)

Each app maintains its own comprehensive documentation structure including:
- Governance and standards
- Database schemas and migrations
- Dev journals for app-specific work
- Workflows and procedures
- Reference data

---

## 🔧 Maintenance

**Weekly**: Review active plans and handoffs
**Monthly**: Review dev-journals for archival candidates
**Quarterly**: Archive completed backlog items by year
**Annually**: Audit ADRs for accuracy and relevance

---

## 🌟 Why This Structure?

**Benefits**:
- **Clear Scope** - Obvious what's monorepo vs. app-specific
- **Easy Navigation** - Find docs in 2 clicks or less
- **Reduced Clutter** - Only 2 files at root (README + backlog system)
- **Scales Well** - Can add apps without reorganizing
- **Matches App Structure** - Similar patterns to Georgetown docs

**Follows 2025 Best Practices**:
- ✅ Separation of concerns (decisions vs. implementation vs. reference)
- ✅ Purpose-based organization (not file-type based)
- ✅ Minimal root clutter
- ✅ Clear navigation paths
- ✅ Active vs. archived separation

---

**Structure Model**: Based on Georgetown documentation best practices
**Maintained by**: CTO (Claude Code)
**Created**: 2025-12-17
**Next Review**: 2026-01-17
