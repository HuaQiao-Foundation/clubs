# Documentation Systems & Project Management

**Date**: 2025-12-08
**Purpose**: Documentation architecture and project management patterns
**Audience**: CTO (for Rotary Club and similar projects)
**Project**: Brandmine Hugo + Hub

---

## Executive Summary

Brandmine uses a **multi-tier documentation system** optimized for AI-assisted development with Claude Code. This document captures the architecture, principles, and workflows that enable effective project management across strategic, technical, and operational documentation.

**Key Insight**: Documentation is treated as code—versioned, refactored, and deleted when obsolete. This prevents documentation debt while preserving critical knowledge.

**Production Status**: ✅ 2+ years refinement, 30+ ADRs, 100+ dev journal entries, comprehensive workflow guides

---

## Table of Contents

1. [Documentation Philosophy](#documentation-philosophy)
2. [Directory Structure](#directory-structure)
3. [Architecture Decision Records (ADRs)](#architecture-decision-records-adrs)
4. [Dev Journal System](#dev-journal-system)
5. [Backlog Management](#backlog-management)
6. [Workflow Documentation](#workflow-documentation)
7. [Technical Reference](#technical-reference)
8. [Handoff Prompts](#handoff-prompts)
9. [Circular Debugging Prevention](#circular-debugging-prevention)
10. [Documentation Lifecycle](#documentation-lifecycle)
11. [AI Assistant Integration](#ai-assistant-integration)
12. [Key Takeaways](#key-takeaways)

---

## Documentation Philosophy

### 1. Documentation as Code

**Principle**: Treat documentation like software—version control, refactor, delete obsolete content.

```
Documentation Debt = Technical Debt

- Outdated docs are worse than no docs
- Duplication creates maintenance burden
- Archive rarely-accessed content
- Delete truly obsolete content
```

**Why This Matters**:
- ✅ Documentation stays current (not aspirational)
- ✅ Search finds relevant content (not noise)
- ✅ AI assistants get accurate context (not contradictions)
- ✅ New developers trust docs (not question accuracy)

**Rotary Club Implication**: Build cleanup into your workflow. Review docs monthly, delete outdated content.

---

### 2. Single Source of Truth (No Duplication)

**Rule**: Every piece of information lives in exactly ONE location.

**Bad Pattern** (duplication):
```
CLAUDE.md: "Database schema in docs/database/"
README.md: "Database schema in docs/database/"
docs/database/README.md: "Database schema documented here"
docs/technical/README.md: "Database info in docs/database/"
```

**Good Pattern** (single source):
```
CLAUDE.md: "Database: See docs/database/README.md"
docs/database/README.md: [complete database documentation]
```

**Cross-Reference Pattern**:
```markdown
# In CLAUDE.md
**Database**: See [docs/database/README.md](docs/database/README.md)

# In workflow guide
**Schema Changes**: See [database migration workflow](../database/guides/change-protocol.md)
```

**Rotary Club Implication**: Write once, link everywhere. Update in one place, accurate everywhere.

---

### 3. Documentation Hierarchy

**Strategic → Reference → Operational**

```
┌─────────────────────────────────────────┐
│         Strategic (Why & What)          │
│  - Vision, mission, values              │
│  - Brand strategy, positioning          │
│  - ADRs (architectural decisions)       │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│         Reference (How It Works)        │
│  - Technical architecture               │
│  - Database schema                      │
│  - System design                        │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│         Operational (How To Do)         │
│  - Workflows, checklists                │
│  - Dev journal (daily notes)            │
│  - Backlog (task tracking)              │
└─────────────────────────────────────────┘
```

**Why Hierarchy Matters**:
- Strategic docs change rarely (stable foundation)
- Reference docs updated with architecture (moderate change)
- Operational docs change frequently (deleted when complete)

**Rotary Club Implication**: Organize by permanence. Strategic docs in root, operational in dated folders.

---

## Directory Structure

### Complete Documentation Tree

```
docs/
├── README.md                    # Master index (you are here)
├── CLAUDE.md                    # ⭐ AI assistant context (root level)
│
├── brand/                       # Strategic documentation
│   ├── brand-strategy.md        # Vision, mission, values, voice
│   ├── brand-guide.md           # Visual identity, colors
│   ├── founder-bios.md          # About Randal & Olya
│   └── accessibility-standards.md # Colorblind design standards
│
├── technical/                   # Technical reference
│   ├── README.md                # Technical overview
│   ├── hugo-essentials.md       # Hugo patterns (200+ lines)
│   ├── taxonomy-guide.md        # 4-dimension system
│   ├── color-system.md          # Complete color reference
│   ├── css-architecture.md      # Scoping guidelines
│   ├── modal-system.md          # Shared modal pattern
│   └── timeline-system.md       # Story arc visualization
│
├── database/                    # Database documentation
│   ├── README.md                # Database overview
│   ├── schema-design.md         # Complete schema
│   ├── contact-forms.md         # Form implementation
│   ├── security-implementation.md # RLS policies
│   ├── guides/                  # Step-by-step procedures
│   │   ├── setup-guide.md
│   │   ├── change-protocol.md
│   │   └── ownership-verification.md
│   └── schemas/                 # JSON schemas
│
├── workflows/                   # Process documentation
│   ├── README.md
│   ├── reference/               # Standards & patterns
│   │   ├── ceo-coo-cto-workflow.md  # Team collaboration
│   │   ├── roles-and-responsibilities.md
│   │   └── brand-profile-content-architecture.md
│   ├── guides/                  # Step-by-step workflows
│   │   ├── translation-workflow.md
│   │   ├── brand-verification-workflow.md
│   │   └── add-dimension-workflow.md
│   └── architecture/            # System design
│       ├── timeline-system.md
│       └── story-arc-system.md
│
├── adr/                         # Architecture Decision Records
│   ├── README.md                # ADR index (30 decisions)
│   ├── 0001-decision-documentation-workflow.md
│   ├── 0002-hub-as-single-source-of-truth.md
│   ├── 0020-dnd-kit-migration-for-react-19.md
│   ├── 0026-circular-debugging-prevention-protocol.md
│   └── 0030-webauthn-passkeys-primary-authentication.md
│
├── dev-journal/                 # Daily implementation logs
│   ├── 2025-11-29-incremental-sync-implementation.md
│   ├── 2025-12-07-lighthouse-ci-implementation.md
│   ├── 2025-12-08-webauthn-supabase-binary-data-reference.md
│   └── archive/                 # Older entries (>1 month)
│
├── backlog/                     # Task management
│   ├── README.md                # Backlog system overview
│   └── technical.md             # CTO technical backlog
│
├── prompts/                     # Handoff prompts for multi-session work
│   ├── incremental-sync-insights.md
│   └── quick-filter-phase-4-preset-manager.md
│
├── plans/                       # Planning documents (before implementation)
│   ├── quick-filter-table-plan.md
│   └── color-system-audit-plan.md
│
├── briefings/                   # Executive summaries & technical briefings
│   ├── 2025-12-05-rotary-club-app-auth-architecture.md
│   ├── 2025-12-07-lighthouse-ci-assessment.md
│   └── 2025-12-08-hub-architecture-technical-briefing.md
│
└── research-archive/            # Completed research (published articles)
    ├── README.md                # Archive catalog
    ├── founders/
    ├── brands/
    └── insights/
```

**Key Principles**:
- Every directory has README.md (orientation for new readers)
- Dated files use `YYYY-MM-DD-topic.md` format
- Numbered files use `0000-topic.md` format (4 digits, zero-padded)
- Archives contain historical content (rarely accessed)

---

## Architecture Decision Records (ADRs)

### What Are ADRs?

**Definition**: Immutable records of significant architectural decisions.

**Format**: Structured markdown following [industry standard](https://github.com/joelparkerhenderson/architecture-decision-record)

**Example**: [ADR-0002: Hub as Single Source of Truth](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)

---

### ADR Template

```markdown
# ADR-XXXX: Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Decision Maker**: Who made this call?
**Context**: What problem are we solving?

---

## Context and Problem Statement

What's the situation? What constraints exist?
What questions are we trying to answer?

## Decision

What are we doing? Be specific and actionable.

## Alternatives Considered

What else did we evaluate?

1. **Option A** - Why rejected?
2. **Option B** - Why rejected?
3. **Option C (chosen)** - Why selected?

## Consequences

### Positive
- ✅ Benefit 1
- ✅ Benefit 2

### Negative
- ⚠️ Trade-off 1
- ⚠️ Risk 2

### Neutral
- 📝 Observation 1

## Implementation

How do we do this? (high-level only, details in dev journal)

## Monitoring

How do we know it's working?

## References

- Links to external docs
- Links to internal docs
- Related ADRs

---

**Status Updates**:
- YYYY-MM-DD: Status change, implementation notes
```

---

### When to Write an ADR

**Write ADRs for**:
- ✅ Technology choices (React vs Vue, PostgreSQL vs MongoDB)
- ✅ Architecture patterns (microservices vs monolith, REST vs GraphQL)
- ✅ Security decisions (auth strategy, data encryption)
- ✅ Performance trade-offs (bundle size vs features)
- ✅ Data modeling (single source of truth, schema design)
- ✅ Process changes (workflow modifications, team structure)

**Don't Write ADRs for**:
- ❌ Bug fixes (dev journal entry)
- ❌ Feature implementation details (dev journal)
- ❌ Temporary decisions (dev journal)
- ❌ Routine maintenance (commit messages)

**Rule of Thumb**: If the decision affects architecture for >6 months, write an ADR.

---

### ADR Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded]
```

**Statuses**:
- **Proposed**: Under discussion, not yet implemented
- **Accepted**: Implemented, in production use
- **Deprecated**: No longer recommended, but not replaced
- **Superseded**: Replaced by another ADR (link to new ADR)

**Key Rule**: ADRs are **immutable** after acceptance. To change decision, create new ADR that supersedes old one.

**Why Immutable**: Preserves decision history. Future developers understand "why did we do X at that time?"

---

### ADR Examples from Brandmine

**Strategic Decisions**:
- [ADR-0002: Hub as Single Source of Truth](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)
- [ADR-0009: Backlog System Simplification](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0009-backlog-system-simplification.md)

**Technology Choices**:
- [ADR-0020: dnd-kit Migration for React 19](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0020-dnd-kit-migration-for-react-19.md)
- [ADR-0030: WebAuthn Passkeys Primary Authentication](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0030-webauthn-passkeys-primary-authentication.md)

**Performance Optimizations**:
- [ADR-0017: Incremental Sync for Hugo-Supabase](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0017-incremental-sync-for-hugo-supabase.md)

**Process Changes**:
- [ADR-0026: Circular Debugging Prevention Protocol](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0026-circular-debugging-prevention-protocol.md)

**Total**: 30 ADRs (as of 2025-12-08)

**Rotary Club Implication**: Start ADRs from day 1. Document technology choices immediately.

---

## Dev Journal System

### Purpose

**Daily implementation logs** capturing what was built, how, and why.

**Format**: Chronological, narrative, flexible structure

**Audience**: Future developers (including yourself in 3 months)

---

### Dev Journal Template

```markdown
# [Topic] - Session Summary

**Date**: YYYY-MM-DD
**Status**: Complete | In Progress
**Related**: ADR-XXXX, Issue #YYY

---

## Context

What problem are we solving? What was the starting state?

## Implementation

### Phase 1: [Component Name]
What did we build? Key code changes?

**Files Modified**:
- `path/to/file.tsx` - What changed?
- `path/to/file.css` - What changed?

**Key Patterns**:
```typescript
// Code example showing pattern
```

### Phase 2: [Next Component]
...

## Learnings

What worked? What didn't? What would we do differently?

## Testing

How did we verify it works?

## Next Steps

What's left to do? (if in progress)

---

**Commits**: abc1234, def5678
**Time**: 3 hours
```

---

### Dev Journal vs ADR

| Aspect | Dev Journal | ADR |
|--------|-------------|-----|
| **Purpose** | Daily progress log | Architectural decision |
| **Frequency** | Multiple per week | 1-2 per month |
| **Format** | Flexible, narrative | Structured template |
| **Permanence** | Archived after 1 month | Permanent (immutable) |
| **Audience** | Implementation details | Strategic context |
| **Example** | "Added timeline component with GSAP animations" | "Why we chose WebAuthn over magic links" |

**When to Use**:
- Dev Journal: **Implementation** details, debugging, feature completion
- ADR: **Decision** rationale, trade-offs, alternatives

**Overlap**: ADR explains "why we chose X", dev journal explains "how we implemented X"

---

### Dev Journal Archiving

**Rule**: Archive entries older than 1 month.

**Before**:
```
docs/dev-journal/
├── 2025-10-03-session-summary.md
├── 2025-10-05-founder-profile-redesign.md
├── 2025-11-29-incremental-sync-implementation.md
└── 2025-12-08-webauthn-production-deployment.md
```

**After** (monthly cleanup):
```
docs/dev-journal/
├── 2025-12-07-lighthouse-ci-implementation.md
├── 2025-12-08-webauthn-production-deployment.md
└── archive/
    ├── 2025-10-03-session-summary.md
    ├── 2025-10-05-founder-profile-redesign.md
    └── 2025-11-29-incremental-sync-implementation.md
```

**Why Archive**: Keeps active journal lean. Old entries searchable but not cluttering navigation.

**Rotary Club Implication**: Monthly cleanup prevents documentation sprawl.

---

## Backlog Management

### Simplified System (ADR-0009)

**Philosophy**: Lean backlog, detail emerges during implementation.

**Structure**:
```
docs/backlog/
├── README.md        # System overview
└── technical.md     # CTO technical backlog
```

**Entry Format** (minimal):
```markdown
### #036: Cloudflare-Style Inline Filters Enhancement
**Status**: backlogged
**Type**: feature
**Added**: 2025-12-07

Experimental inline filter UI implemented for Brands page. If successful, extend to other entity types (founders, insights, dimensions).

**Acceptance Criteria**:
- Multi-select for attributes/signals
- Date range picker
- Filter presets (save/load)
- Rollout to all entity list pages
```

**Key Principles**:
1. **2-3 line description** (not 100+ lines of specification)
2. **Detail emerges during work** (not before)
3. **CTO maintains** (not CEO)
4. **Weekly cleanup** (mark completed items)

---

### Adding Backlog Items

**CEO Command**:
```
"CTO, backlog this: [idea/task description]"
```

**CTO Response**:
1. Create entry with unique ID (#XXX)
2. Add scope and acceptance criteria (brief)
3. Confirm: "Added to backlog as #036"

**Example Conversation**:
```
CEO: "CTO, backlog this: Add passkey enrollment UI to Hub settings page"

CTO: "Added to backlog as #037: Hub Passkey Enrollment UI
- Add 'Create Passkey' button in Settings
- Device name input (optional)
- Success/error messaging
- List existing passkeys with delete option"
```

---

### Backlog Statuses

| Status | Meaning |
|--------|---------|
| **backlogged** | Not started, prioritized later |
| **planned** | Detailed plan exists (in `docs/plans/`) |
| **in-progress** | Actively being implemented |
| **completed** | Done, marked with completion date |
| **postponed** | Deferred until conditions change |

---

### Content Planning (NOT in Backlog)

**Critical Change** (ADR-0002, ADR-0009):

Content planning moved from markdown backlog to Hub database:

**Old Pattern** (markdown backlog):
```
docs/backlog/
├── brands.md        # Brand research priorities
├── founders.md      # Founder profile research
└── insights.md      # Story ideas
```

**New Pattern** (database-first):
```
Hub (Supabase):
├── brands table       # Brand research priorities
├── founders table     # Founder profile research
└── story_ideas table  # Content pipeline
```

**Why**: Database is queryable, filterable, collaborative. Markdown is static.

**Rotary Club Implication**: Use database for operational task tracking, backlog for strategic initiatives.

---

## Workflow Documentation

### Three-Tier System

**Reference** (`workflows/reference/`):
- Standards, patterns, terminology
- Example: [ceo-coo-cto-workflow.md](/Users/randaleastman/dev/brandmine-hugo/docs/workflows/reference/ceo-coo-cto-workflow.md)

**Guides** (`workflows/guides/`):
- Step-by-step checklists
- Example: [translation-workflow.md](/Users/randaleastman/dev/brandmine-hugo/docs/workflows/guides/translation-workflow.md)

**Architecture** (`workflows/architecture/`):
- System design documentation
- Example: [timeline-system.md](/Users/randaleastman/dev/brandmine-hugo/docs/workflows/architecture/timeline-system.md)

---

### Workflow Guide Template

```markdown
# [Workflow Name]

**Purpose**: What does this workflow accomplish?
**Frequency**: How often is this done?
**Owner**: Who performs this?

---

## Prerequisites

What must be true before starting?
- Tool X installed
- Access to Y system
- Understanding of Z concept

## Steps

### 1. [First Step]
What to do, in detail.

```bash
# Command examples
npm run command
```

**Verification**: How do you know this step succeeded?

### 2. [Second Step]
...

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Error X | Reason | Fix Y |

## Examples

Real-world example of this workflow in action.

## Related

- Link to related workflows
- Link to technical docs
```

---

## Technical Reference

### Purpose

**Permanent technical documentation** explaining how systems work.

**Location**: `docs/technical/`

**Examples**:
- [hugo-essentials.md](/Users/randaleastman/dev/brandmine-hugo/docs/technical/hugo-essentials.md) - Hugo patterns (200+ lines)
- [taxonomy-guide.md](/Users/randaleastman/dev/brandmine-hugo/docs/technical/taxonomy-guide.md) - 4-dimension system
- [color-system.md](/Users/randaleastman/dev/brandmine-hugo/docs/technical/color-system.md) - Complete palette reference

---

### Technical Reference Template

```markdown
# [System Name]

**Purpose**: What is this system?
**Scope**: What does it cover?
**Audience**: Who needs this?

---

## Quick Reference

Most common patterns/commands/usages.

## Architecture

How does this system work?

```
┌─────────────────────┐
│   Component A       │
│   (Description)     │
└─────────────────────┘
          ↓
┌─────────────────────┐
│   Component B       │
└─────────────────────┘
```

## Core Concepts

Key terminology and definitions.

## Usage Patterns

Common scenarios with code examples.

## Advanced Topics

Edge cases, optimizations, troubleshooting.

## Examples

Real implementations from codebase.

## Related

Links to ADRs, workflows, dev journal entries.
```

---

## Handoff Prompts

### Purpose

**Comprehensive prompts for multi-session projects** that can be used in fresh Claude sessions.

**Location**: `docs/prompts/`

**When to Create**:
- Project spans multiple days
- Context window will expire before completion
- Need to hand off to different developer
- Complex implementation with multiple phases

---

### CEO Command

**Command**: "Give me a handoff prompt" OR "Create a handoff prompt"

**CTO Response**:
1. Creates detailed handoff prompt with:
   - Current state summary
   - What's complete
   - What needs implementation
   - Technical specifications
   - File locations and code examples
   - Acceptance criteria
   - Testing checklist
2. **Automatically saves** to `docs/prompts/[descriptive-name].md`
3. Confirms: "Handoff prompt saved to docs/prompts/[filename]"

---

### Handoff Prompt Template

```markdown
# [Feature/Project Name] - Handoff Prompt

**Date**: YYYY-MM-DD
**Status**: Ready for implementation | Partially complete
**Phase**: X of Y

---

## Context

What is this project? Why are we doing it?

## Current State

### Completed
- ✅ Phase 1: [what's done]
- ✅ Phase 2: [what's done]

### In Progress
- 🔄 Phase 3: [current work]

### Not Started
- ⏳ Phase 4: [future work]

## Technical Specifications

### Database Schema
```sql
-- SQL here
```

### Component Architecture
Where do files go? What patterns to use?

### Key Code Examples
```typescript
// Reference implementation
```

## Acceptance Criteria

- [ ] Feature X works
- [ ] Tests pass
- [ ] Documentation updated

## Testing Checklist

- [ ] Test case 1
- [ ] Test case 2

## Files to Modify

- `path/to/file.tsx` - What to change
- `path/to/file.css` - What to add

## Related Documentation

- ADR-XXXX: [link]
- Dev Journal: [link]
- Technical Reference: [link]

---

**Next Session**: Start with Phase 3 implementation using specs above.
```

---

### Example Handoff Prompts

**From Brandmine**:
- [incremental-sync-insights.md](/Users/randaleastman/dev/brandmine-hugo/docs/prompts/incremental-sync-insights.md) - Extend incremental sync to insights
- [quick-filter-phase-4-preset-manager.md](/Users/randaleastman/dev/brandmine-hugo/docs/prompts/quick-filter-phase-4-preset-manager.md) - Phase 4 filter presets

**Benefits**:
- ✅ Preserve context across sessions
- ✅ Enable knowledge transfer
- ✅ Audit trail of implementation plans
- ✅ Consistent handoffs between developers

**Rotary Club Implication**: Create handoff prompts for all multi-day projects.

---

## Circular Debugging Prevention

### Protocol (ADR-0026)

**Purpose**: Stop wasting time repeating failed debugging approaches.

**File Format**: `docs/dev-journal/YYYY-MM-DD-[problem]-reference.md`

**When to Create**:
- ✅ Second failed approach to same problem
- ✅ Multiple possible solutions (3+ approaches)
- ✅ Integration between unfamiliar libraries/systems
- ✅ Behavior contradicts documentation
- ✅ Issue requires web research

---

### Technical Reference Doc Template

```markdown
# [Problem] - Technical Reference

**Date**: YYYY-MM-DD
**Status**: ✅ PRODUCTION SOLUTION VERIFIED | 🔄 IN PROGRESS
**Purpose**: Prevent circular debugging

---

## Executive Summary

**Problem**: [1 sentence]
**Root Cause**: [1 sentence]
**Solution**: [1 sentence]

---

## Proven Facts

### ❌ What DOES NOT Work

1. **Approach 1** - [Why it failed]
   - Result: [Actual outcome]
   - Tested: [Date/time]
   - Evidence: [Log output, error message]

2. **Approach 2** - [Why it failed]
   ...

### ✅ What DOES Work

**Working Solution**: [Approach name]
- Format: [Code/pattern]
- Why: [Explanation]
- Source: [Link to documentation/discussion]

**Implementation**:
```typescript
// Complete working code
```

---

## Verification Checklist

How to confirm solution works:
- [ ] Check 1
- [ ] Check 2

---

## Timeline of Attempts

1. **Approach 1** (YYYY-MM-DD HH:MM) - Failed ❌
2. **Approach 2** (YYYY-MM-DD HH:MM) - Failed ❌
3. **Approach 3** (YYYY-MM-DD HH:MM) - Working ✅

---

## Research Sources

- [Official Documentation](https://...)
- [GitHub Discussion #XXXX](https://...)
- [Stack Overflow](https://...)

---

## Common Error Messages & Causes

| Error | Cause | Fix |
|-------|-------|-----|
| Error A | Reason 1 | Solution X |
| Error B | Reason 2 | Solution Y |

---

**Last Updated**: YYYY-MM-DD HH:MM UTC
**Verified Working**: ✅ Production verified YYYY-MM-DD
**Maintainer**: CTO (Claude Code)
```

---

### Example: WebAuthn Binary Data Handling

**File**: [docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md](/Users/randaleastman/dev/brandmine-hugo/docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md)

**Problem**: Storing WebAuthn COSE public keys (Uint8Array) in Supabase PostgreSQL

**Failed Approaches Documented**:
1. ❌ Passing Uint8Array directly (JSON-serialized as object)
2. ❌ Passing ArrayBuffer (serialized as empty object)
3. ❌ Base64 encoding without decode directive (stored as text)

**Working Solution Documented**:
✅ PostgreSQL hex format (`\x` prefix)

**Value**: Saved future debugging time. Anyone hitting this issue finds solution immediately.

**Rotary Club Implication**: Document complex debugging sessions IMMEDIATELY, not later.

---

## Documentation Lifecycle

### Creation Phase

**When**: During or immediately after implementation

**Process**:
1. **Dev journal entry** - Daily log of what was built
2. **ADR if needed** - For architectural decisions
3. **Update technical reference** - If system architecture changed
4. **Create workflow guide** - If new process introduced
5. **Commit with docs** - Code + documentation in same commit

---

### Maintenance Phase

**Monthly Review**:
- Archive old dev journal entries (>1 month)
- Update technical reference if patterns changed
- Mark completed backlog items
- Delete truly obsolete documentation

**Quarterly Audit**:
- Review ADR statuses (any deprecated?)
- Consolidate duplicate workflows
- Check cross-references (broken links?)
- Update version numbers and dates

---

### Deletion Phase

**When to Delete**:
- ✅ Point-in-time reports (replaced by current codebase)
- ✅ Migration records (one-time operations, completed)
- ✅ Duplicate content (consolidated elsewhere)
- ✅ Aspirational docs (never implemented, no longer relevant)

**When to Archive** (not delete):
- 📦 Historical decisions (ADRs - keep forever)
- 📦 Research that informed decisions
- 📦 Old dev journal entries (rarely accessed but searchable)

**Deletion Checklist**:
- [ ] Is this information available elsewhere? (in code, other docs)
- [ ] Will anyone need this in 6 months?
- [ ] Does this create confusion with current system?
- [ ] Is this truly obsolete or just old?

**Rule**: If unsure, archive to `docs/archive/`. Delete from archive after 1 year if unused.

---

## AI Assistant Integration

### CLAUDE.md - The Master Context File

**Location**: `/CLAUDE.md` (project root)

**Purpose**: **Single essential file** that AI assistants (Claude Code, Claude Console) read before every session.

**Contents**:
```markdown
# Project Strategic Context & Quick Reference

## Quick Links
- Brand Strategy: docs/brand/brand-strategy.md
- Technical Reference: docs/technical/README.md
- Database: docs/database/README.md
- ADRs: docs/adr/README.md

## Critical Constraints
[NEVER VIOLATE] rules that prevent breaking changes

## Role Titles
CEO, COO, CTO, Research Director - who does what

## Backlog System
How to add items, format

## Quick Commands
"CTO, backlog this"
"Give me a handoff prompt"
"Document this as ADR"

... [rest of essential context]
```

**Why Root Level**: Claude Code automatically includes root-level files in context.

**Length**: ~800 lines (optimized for AI token limits, 2025 best practices)

---

### Documentation Discovery Pattern

**Problem**: AI can't read entire docs/ directory every session (token limit)

**Solution**: Hierarchical discovery

```
1. Claude reads CLAUDE.md (automatic, always)
2. CLAUDE.md points to relevant README files
3. README files index specific documentation
4. AI reads only what's needed for current task
```

**Example Flow**:
```
User: "How do I add a new database migration?"

Claude reads CLAUDE.md → sees "Database: docs/database/README.md"
       reads docs/database/README.md → sees "Migrations: guides/change-protocol.md"
       reads guides/change-protocol.md → provides answer
```

**Rotary Club Implication**: Create README in every directory. Link hierarchically.

---

### Documentation Patterns for AI

**Good Pattern** (hierarchical):
```markdown
# CLAUDE.md
**Database**: See [docs/database/README.md](docs/database/README.md)

# docs/database/README.md
**Schema Changes**: See [guides/change-protocol.md](guides/change-protocol.md)

# docs/database/guides/change-protocol.md
[Complete step-by-step workflow]
```

**Bad Pattern** (flat):
```markdown
# CLAUDE.md
[500 lines of database documentation inline]
```

**Why**: AI token limits. Hierarchical docs let AI fetch only what's needed.

---

## Key Takeaways

### For Documentation Systems

1. **Treat Docs as Code**: Version, refactor, delete obsolete content regularly.

2. **Single Source of Truth**: Write once, link everywhere. No duplication.

3. **Hierarchical Organization**: Strategic (permanent) → Reference (stable) → Operational (frequent change).

4. **Documentation Types**:
   - ADRs for architectural decisions (immutable)
   - Dev journal for daily progress (archived monthly)
   - Technical reference for system documentation (updated as needed)
   - Workflows for repeatable processes (updated as process evolves)

5. **AI Integration**: CLAUDE.md at root → README in every directory → specific docs as needed.

6. **Backlog Simplification**: Lean entries (2-3 lines), detail emerges during implementation.

7. **Handoff Prompts**: Create for all multi-session projects. Auto-save to `docs/prompts/`.

8. **Circular Debugging**: Document complex debugging IMMEDIATELY. Save future time.

9. **Monthly Cleanup**: Archive old journal, mark completed tasks, delete obsolete docs.

10. **README Everywhere**: Every directory has orientation doc for new readers.

### For Project Management

11. **Database-First Task Tracking**: Use database (Hub) for operational tasks, backlog for strategic initiatives.

12. **CEO Commands**: Simple commands ("backlog this", "document this") integrate with workflow.

13. **CTO Ownership**: CTO maintains backlog status, CEO adds items, COO reviews strategic alignment.

14. **Content Planning**: Moved from markdown to database (queryable, filterable, collaborative).

15. **Weekly Reviews**: Catch stale items, mark completions, archive old entries.

### Documentation Lifecycle

16. **Create During Work**: Dev journal entry + ADR (if needed) + updated reference docs.

17. **Archive Monthly**: Old dev journal entries (>1 month) to `archive/`.

18. **Delete Quarterly**: Truly obsolete docs (point-in-time reports, duplicate content).

19. **Update Continuously**: Technical reference, workflows evolve with codebase.

20. **Preserve History**: ADRs immutable (create new to supersede), git history tracks changes.

---

## References

### Internal Documentation
- [CLAUDE.md](/Users/randaleastman/dev/brandmine-hugo/CLAUDE.md) - Master AI context
- [docs/README.md](/Users/randaleastman/dev/brandmine-hugo/docs/README.md) - Documentation index
- [docs/adr/README.md](/Users/randaleastman/dev/brandmine-hugo/docs/adr/README.md) - ADR index
- [docs/backlog/README.md](/Users/randaleastman/dev/brandmine-hugo/docs/backlog/README.md) - Backlog system

### Key ADRs
- [ADR-0001: Decision Documentation Workflow](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0001-decision-documentation-workflow.md)
- [ADR-0002: Hub as Single Source of Truth](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)
- [ADR-0009: Backlog System Simplification](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0009-backlog-system-simplification.md)
- [ADR-0026: Circular Debugging Prevention Protocol](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0026-circular-debugging-prevention-protocol.md)

### External Resources
- [AWS ADR Best Practices](https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/)
- [GitHub ADR Repository](https://github.com/joelparkerhenderson/architecture-decision-record)
- [Documentation as Code](https://www.writethedocs.org/guide/docs-as-code/)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-08
**Author**: CTO (Claude Code)
**Next Review**: 2026-01-08 (1 month)

**Status**: ✅ Production-ready reference for similar projects
