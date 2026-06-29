# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records (ADRs) for the Georgetown Rotary application.

## What is an ADR?

An Architecture Decision Record captures an important architectural decision made along with its context and consequences. ADRs help future developers (including future you) understand why certain decisions were made.

## When to Create an ADR

Create an ADR when you make a significant decision about:
- Technology choices (frameworks, libraries, databases)
- Architectural patterns (state management, routing, data flow)
- Infrastructure decisions (hosting, deployment, region selection)
- Security policies (authentication, authorization, data handling)
- Development workflows (git strategy, deployment process)

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-supabase-singapore-migration.md) | Migrate Database to Singapore Region | Accepted | 2025-12-16 |
| [002](002-social-sharing-open-graph-limitations.md) | Social Sharing / Open Graph Limitations | Accepted | — |
| [006](006-no-map-embedding-china-policy.md) | No Map Embedding (China Policy) | Accepted | — |
| [007](007-knowledge-base-content-architecture.md) | Knowledge Base / Wiki Content Architecture | Accepted | 2026-06-29 |

## ADR Status Definitions

- **Proposed**: Under consideration
- **Accepted**: Decision made and implemented
- **Deprecated**: No longer recommended
- **Superseded**: Replaced by a newer ADR

## Creating a New ADR

1. Copy [template.md](template.md)
2. Name it with the next sequential number: `NNNN-descriptive-title.md`
3. Fill in all sections
4. Update this index
5. Commit with message: `docs(adr): Add ADR-NNNN descriptive title`
