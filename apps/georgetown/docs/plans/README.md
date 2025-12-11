# Implementation Plans

This directory contains comprehensive plans for multi-session features and initiatives.

## Purpose

Plans document **how** we'll implement complex features that span multiple work sessions. They bridge the gap between ADRs (why) and Dev Journals (what we did).

## When to Create a Plan

Create a plan when:
- Feature requires 3+ work sessions
- Implementation touches multiple systems
- Requires careful phased rollout
- Needs coordination across team members
- Has significant technical complexity

## Format

Each plan follows the template in `plan-template.md` and includes:
- **Overview**: What are we building and why?
- **Phases**: How will we break down the work?
- **Technical Approach**: What patterns and technologies?
- **Success Criteria**: How do we know we're done?

## Naming Convention

Plans use descriptive names with dates:
- `2024-10-timeline-system-implementation.md`
- `2024-11-mobile-app-migration.md`
- etc.

## Plans Index

| Plan | Status | Start Date | Target | Phases | Owner |
|------|--------|------------|--------|--------|-------|
| [Timeline System Implementation](2024-10-timeline-system-implementation.md) | Completed | 2024-10-01 | 2024-10-15 | 6 | CTO |
| [Photo Gallery Enhancement](2024-10-photo-gallery-enhancement.md) | Completed | 2024-10-20 | 2024-10-25 | 3 | CTO |
| [Member Portal Redesign](2025-01-member-portal-redesign.md) | Planned | 2025-01-XX | 2025-02-XX | 4 | CTO |

## Status Values

- **Planned**: Designed but not started
- **In Progress**: Active development
- **Paused**: On hold, waiting for dependencies
- **Completed**: Fully implemented and tested
- **Cancelled**: No longer pursuing

## Plan Lifecycle

```
1. Draft Plan → 2. CEO Review → 3. Approved → 4. In Progress → 5. Dev Journals → 6. Completed
```

## Creating a New Plan

1. Copy `plan-template.md`
2. Name it with date and topic
3. Fill out all sections thoroughly
4. Get CEO approval before starting work
5. Add entry to the table above
6. Update status as you progress
7. Write Dev Journal entries as you complete phases

## Best Practices

- **Be specific**: Include technical details, not just business requirements
- **Break into phases**: Each phase should be 1-2 sessions of work
- **Define success**: Clear acceptance criteria for each phase
- **Update regularly**: Keep status current as work progresses
- **Link to journals**: Reference dev journal entries as phases complete
- **Archive completed plans**: Move to archive after 6 months

## Relationship to Other Docs

- **ADRs**: Reference relevant architecture decisions
- **Dev Journals**: Create journal entries as you complete phases
- **Backlog**: Plans pull from and feed back into the backlog
- **Standards**: Plans should follow established standards
