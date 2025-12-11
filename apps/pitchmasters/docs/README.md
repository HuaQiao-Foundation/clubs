# Pitchmasters Documentation Guide

**Purpose**: Navigate project documentation efficiently
**Maintained by**: Claude Code (CTO)
**Last updated**: 2025-10-08

---

## Quick Navigation

### Strategic Documents (Root Level)

**[PDD.md](PDD.md)** - Product Design Document
- Business context and requirements
- Phase definitions and success criteria
- Quality gates and constraints
- **When to reference**: Understanding business goals, feature prioritization

**[TIS.md](TIS.md)** - Technical Implementation Specification
- Complete technical architecture
- Database schema and design decisions
- Technology stack and patterns
- **When to reference**: Technical decisions, implementation details

**[expert-standards.md](expert-standards.md)** - Full-Stack Verification Requirements
- Quality assurance standards
- Testing and validation protocols
- Code review requirements
- **When to reference**: Quality gates, verification checklists

**[management-protocols.md](management-protocols.md)** - Team Workflows & Approval Processes
- Team roles and responsibilities
- Approval workflows for major changes
- Communication protocols
- **When to reference**: Decision-making process, escalation paths

**[tech-constraints.md](tech-constraints.md)** - Stability & Technology Rules
- Technology selection criteria
- Version stability requirements
- Constraints and guardrails
- **When to reference**: Technology decisions, framework upgrades

**[toastmasters-brand-guide.md](toastmasters-brand-guide.md)** - Brand Standards & Compliance
- Official color palette (Loyal Blue, True Maroon, etc.)
- Typography standards (Montserrat, Source Sans 3)
- Logo usage requirements
- Photography guidelines and compliance rules
- **When to reference**: UI/UX design, brand compliance verification

---

## Documentation Directories

### [archive/](archive/)
**Purpose**: Completed/superseded documentation

**Contents**:
- Sprint completion reports
- One-time technical audits
- Superseded planning documents
- Historical TODO tracking

**When to add**:
- Sprint retrospectives after completion
- Status reports that are no longer actively referenced
- Planning documents replaced by newer versions
- One-time diagnostic reports

---

### [database/](database/)
**Purpose**: Database architecture and SQL management

**Contents**:
- `database-protocol.md` - Multi-club architecture standards
- `sql-scripts/` - Numbered migration files and queries

**When to reference**:
- Schema changes and migrations
- Multi-tenant isolation patterns
- RLS policy implementation

**SQL Migration Convention**: `NNN-description.sql` (sequential numbering)

---

### [dev-journals/](dev-journals/)
**Purpose**: Implementation session logs and technical decisions

**Naming Convention**: `YYYY-MM-DD-topic-description.md`

**Contents**:
- Feature implementation details
- Technical decision documentation
- Problem-solving approaches
- Lessons learned

**When to add**:
- After completing significant feature implementation
- When making important technical decisions
- To document problem-solving approaches

**Current Entries**:
- `2025-09-28-sprint-1-completion-fixes.md`
- `2025-09-29-mobile-ux-optimization.md`
- `2025-09-28-favicon-implementation.md`

---

### [reference-data/](reference-data/)
**Purpose**: Static reference data files for development and testing

**Contents**:
- `member-data.csv` - Sample member roster for CSV import testing
- `README.md` - Documentation of all reference data files

**When to add**:
- CSV/JSON data for import operations
- Sample/seed data for testing
- Official reference lists (countries, timezones, etc.)
- Configuration templates

**When to reference**:
- CSV import script development
- Database schema field mapping
- Testing data requirements

---

### [workflows/](workflows/)
**Purpose**: Repeatable process documentation

**Contents**:
- `cloudflare-deployment-workflow.md` - Production deployment guide
- `search-engine-blocking-workflow.md` - Privacy protection and bot blocking
- `image-asset-management-workflow.md` - Image and asset handling procedures

**When to add**:
- Processes repeated 3+ times
- Step-by-step operational procedures
- Deployment, testing, or maintenance workflows

**When to reference**:
- Deployment procedures
- Environment configuration
- Build optimization
- Security implementations and audits
- Asset management and brand compliance

---

## Finding Information

### Decision Tree

**"Where do I find..."**

1. **Business requirements and success criteria?**
   → [PDD.md](PDD.md)

2. **Technical architecture and stack decisions?**
   → [TIS.md](TIS.md)

3. **Database schema or migration info?**
   → [database/database-protocol.md](database/database-protocol.md)
   → [database/sql-scripts/](database/sql-scripts/)

4. **Brand colors, fonts, or design standards?**
   → [toastmasters-brand-guide.md](toastmasters-brand-guide.md)

5. **How a specific feature was implemented?**
   → [dev-journals/](dev-journals/) (search by date or topic)

6. **Quality standards and approval processes?**
   → [expert-standards.md](expert-standards.md), [management-protocols.md](management-protocols.md), [tech-constraints.md](tech-constraints.md)

7. **Deployment, security, or asset management procedures?**
   → [workflows/cloudflare-deployment-workflow.md](workflows/cloudflare-deployment-workflow.md)
   → [workflows/search-engine-blocking-workflow.md](workflows/search-engine-blocking-workflow.md)
   → [workflows/image-asset-management-workflow.md](workflows/image-asset-management-workflow.md)

8. **Historical sprint reports or completed plans?**
   → [archive/](archive/)

---

## Creating New Documentation

### Documentation Protocol

**Root Level (docs/)** - ONLY 2 strategic documents:
- ✅ `PDD.md` (Product Design Doc)
- ✅ `TIS.md` (Technical Implementation Spec)
- ❌ **NEVER create new root-level docs without CEO approval**

**Dev Journals (dev-journals/)** - Implementation logs:
- ✅ ALL completed implementations go here
- ✅ Use naming: `YYYY-MM-DD-topic-description.md`
- ❌ **NEVER create "feature" or "implementation" directories**

**Workflows (workflows/)** - Repeatable processes:
- ✅ Step-by-step operational guides
- ✅ Use naming: `topic-workflow.md`

**Archive (archive/)** - Completed/superseded:
- ✅ Sprint completion reports after review
- ✅ One-time status/audit reports
- ✅ Superseded planning documents

**Decision Tree for New Documentation:**

1. **Completed implementation?**
   → `dev-journals/YYYY-MM-DD-topic.md`

2. **Repeatable process?**
   → `workflows/topic-workflow.md`

3. **Database migration?**
   → `database/sql-scripts/NNN-description.sql`

4. **Sprint completion report?**
   → `archive/` (after review)

5. **Strategic governance change?**
   → Ask CEO before creating root-level doc

---

## Documentation Structure Overview

```
docs/
├── README.md                    # This file - navigation guide
├── PDD.md                       # Product Design Document
├── TIS.md                       # Technical Implementation Spec
├── expert-standards.md          # Full-stack verification requirements
├── management-protocols.md      # Team workflows & approval processes
├── tech-constraints.md          # Stability & technology rules
├── toastmasters-brand-guide.md  # Brand standards & compliance
├── archive/                     # Completed/superseded documentation
├── database/                    # Schema and SQL management
├── dev-journals/                # Implementation session logs
├── reference-data/              # Static data files for development
└── workflows/                   # Repeatable processes
```

---

## Metrics

**Current Documentation**:
- Root strategic docs: 2 (PDD, TIS)
- Archive files: 7
- Dev journal entries: 3
- Total documentation files: ~30+

**Organization Health**:
- ✅ Root directory clean (2 strategic docs only)
- ✅ Logical directory organization
- ✅ Clear naming conventions
- ✅ Active vs archived separation
- ✅ Database centralized with SQL migrations

---

## Questions?

**For documentation questions**:
- Check this README first
- Reference [CLAUDE.md](../CLAUDE.md) for project instructions
- Ask CEO for strategic documentation decisions

---

**Maintained by**: Claude Code (CTO)
**Pattern Source**: Brandmine/Georgetown documentation best practices
**Next Review**: As structure evolves or after CEO feedback
