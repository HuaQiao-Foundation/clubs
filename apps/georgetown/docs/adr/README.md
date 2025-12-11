# Architecture Decision Records (ADRs)

This directory contains records of architectural decisions made for the Georgetown Rotary Club application.

## Purpose

ADRs document **why** we made significant technical decisions. They provide context for future developers and help avoid repeating past discussions.

## Format

Each ADR follows the template in `adr-template.md` and includes:
- **Context**: What is the issue we're facing?
- **Decision**: What did we decide?
- **Consequences**: What are the implications?
- **Alternatives Considered**: What other options did we evaluate?

## Naming Convention

ADRs are numbered sequentially:
- `001-technology-choice.md`
- `002-architecture-pattern.md`
- etc.

## ADR Index

| # | Title | Date | Status | Decision |
|---|-------|------|--------|----------|
| 001 | [Use Vite for Frontend Build](001-use-vite-for-build.md) | 2024-XX-XX | Accepted | Selected Vite over Webpack for faster dev experience |
| 002 | [Choose Supabase for Backend](002-choose-supabase-backend.md) | 2024-XX-XX | Accepted | PostgreSQL + Auth + Realtime in one platform |
| 003 | [Mobile-First Design Approach](003-mobile-first-design.md) | 2024-XX-XX | Accepted | Members primarily use phones during meetings |
| 004 | [Self-Hosted Fonts Strategy](004-self-hosted-fonts.md) | 2024-XX-XX | Accepted | China accessibility + network independence |
| 005 | [Card-Based UI Pattern](005-card-based-ui-pattern.md) | 2024-XX-XX | Accepted | Consistent, mobile-friendly component architecture |
| 006 | [No Map Embedding (China Policy)](006-no-map-embedding-china-policy.md) | 2025-12-02 | Accepted | Removed map links due to OSM data quality + China policy compliance |

## Status Values

- **Proposed**: Under discussion
- **Accepted**: Decision made and implemented
- **Deprecated**: No longer relevant
- **Superseded**: Replaced by a newer decision

## Creating a New ADR

1. Copy `adr-template.md`
2. Number it sequentially (next available number)
3. Fill out all sections
4. Add entry to the table above
5. Commit with descriptive message

## Best Practices

- **Write ADRs early**: Document decisions when context is fresh
- **Keep them brief**: Focus on the decision, not implementation details
- **Include consequences**: Both positive and negative outcomes
- **Link related ADRs**: Reference previous decisions when relevant
- **Update status**: Mark as Deprecated or Superseded when appropriate
