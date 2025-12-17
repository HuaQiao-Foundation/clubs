# ADR-001: Adopt Markdown-Based Backlog Management System

**Status**: Accepted
**Date**: 2025-12-17
**Decision Makers**: CTO (autonomous)
**Stakeholders**: CEO, Future developers

---

## Context

The Clubs monorepo manages multiple React applications (Georgetown Rotary, Pitchmasters) with ongoing feature development, bug fixes, and technical improvements. Previously, task tracking was informal with no standardized system for:
- Logging feature requests from CEO
- Prioritizing work
- Tracking implementation status
- Maintaining historical record of decisions
- Estimating effort for planning

As a solo developer operation (CTO) receiving input from CEO, we need a lightweight system that:
- Requires minimal overhead
- Lives in the codebase (version controlled)
- Provides visibility to both CTO and CEO
- Scales from current needs without over-engineering
- Follows 2025 industry best practices for solo developers

## Decision

We will adopt a **markdown-based backlog management system** consisting of:

1. **BACKLOG.md** - Active backlog table tracking all pending/in-progress items
2. **BACKLOG-ARCHIVE.md** - Historical record of completed/cancelled items
3. **docs/backlog-management-system.md** - Process documentation and best practices
4. **Integration with git workflow** - Reference backlog IDs in commits and PRs

### Core Components

**Backlog Table Columns**:
- ID (e.g., GEO-001, PM-002, MONO-003)
- Priority (P0-P3)
- Status (Backlog, In Progress, Blocked, Done, Cancelled)
- Feature description
- Project (Georgetown, Pitchmasters, Monorepo, Shared)
- Type (Feature, Bug, Enhancement, Refactor, Docs, Tech Debt)
- Estimate (XS through XXL)
- Date added
- Notes/links

**Process**:
- CEO requests → CTO logs and details
- Weekly grooming sessions (Mondays)
- Implementation updates status in real-time
- Quarterly archiving of completed items
- Maximum 30-50 active items to prevent bloat

## Alternatives Considered

### Alternative 1: GitHub Projects
**Pros**:
- Native GitHub integration
- Visual kanban boards
- Advanced filtering and views

**Cons**:
- Requires UI context switching
- Not visible in codebase itself
- Overkill for solo developer
- Data not version controlled in git

**Verdict**: Too heavy for current needs. Good upgrade path if team grows.

### Alternative 2: External Tools (Trello, Notion, ClickUp)
**Pros**:
- Rich features and visualizations
- Mobile apps
- Collaboration features

**Cons**:
- Additional tool/login to manage
- Data lives outside codebase
- Most require subscriptions for full features
- Context switching overhead

**Verdict**: Unnecessary complexity. Markdown keeps everything in one place.

### Alternative 3: Simple TODO.md or Issues in Code Comments
**Pros**:
- Even simpler than structured backlog
- Zero overhead

**Cons**:
- No prioritization framework
- No historical tracking
- No effort estimation
- Hard to communicate status to CEO
- No accountability

**Verdict**: Too informal for multi-project monorepo.

### Alternative 4: Git Issues Only
**Pros**:
- GitHub native
- Discussion threads
- Labels and milestones

**Cons**:
- Requires creating issues for every task
- No single view of all priorities
- Harder to maintain overview
- More clicks to see status

**Verdict**: Better for bug tracking than comprehensive backlog management.

## Rationale

### Why This Decision

1. **Git-Native**: Backlog is version controlled alongside code
   - See what was prioritized when
   - Audit trail of all decisions
   - Rollback if needed

2. **Zero Tooling Overhead**: Uses only markdown and git
   - No sign-ups, subscriptions, or external services
   - Works offline
   - No vendor lock-in

3. **Transparent**: CEO can view backlog directly on GitHub
   - No permissions or access issues
   - Same view for both CEO and CTO
   - Easy to share with future team members

4. **Industry Best Practices**: Based on 2025 research
   - Regular grooming (weekly)
   - Prioritization frameworks (RICE)
   - Lean backlog (30-50 items max)
   - Balanced mix of work types
   - Effort estimation

5. **Right-Sized**: Matches current team size
   - Solo developer friendly
   - Low maintenance burden
   - Easy to adopt and follow
   - Scales up when needed

6. **Developer-Friendly**: Integrates with existing workflow
   - Reference IDs in commits
   - Link from PRs
   - Markdown editing in IDE
   - Searchable via grep/search

### Supporting Evidence

Research from authoritative sources on solo developer project management (2025):
- [Game Developer: Five Productivity Tips for Solo Devs](https://www.gamedeveloper.com/production/five-productivity-tips-for-solo-devs)
- [Atlassian: Product Backlog Best Practices](https://www.atlassian.com/agile/scrum/backlogs)
- [Everhour: Backlog Grooming Best Practices 2025](https://everhour.com/blog/backlog-grooming/)
- [Bitovi: GitHub Projects for Solo Developers](https://www.bitovi.com/blog/github-projects-for-solo-developers)
- [Backlog.md: Markdown-Native Task Management](https://github.com/MrLesk/Backlog.md)

All emphasize:
- Regular refinement cycles
- Prioritization frameworks
- Lean backlog maintenance
- Simple tools for solo developers
- Focus on value delivery

## Consequences

### Positive

1. **Improved Visibility**: Both CEO and CTO see same backlog state
2. **Better Planning**: Effort estimates inform scheduling discussions
3. **Historical Context**: Archive provides project timeline and decisions
4. **Reduced Mental Load**: System holds state, not CTO's memory
5. **Standardized Communication**: Clear format for requests and updates
6. **Velocity Insights**: Over time, understand estimation accuracy
7. **Onboarding Aid**: Future team members see full project history
8. **Portable**: Easy to migrate to other tools if needs change

### Negative

1. **Manual Maintenance**: Requires discipline to update regularly
   - *Mitigation*: Weekly grooming reminder, make it habit

2. **No Advanced Features**: No charts, burndowns, notifications
   - *Mitigation*: Acceptable tradeoff for simplicity; upgrade path exists

3. **Merge Conflicts**: Possible if editing backlog simultaneously
   - *Mitigation*: Unlikely with solo developer; easy to resolve

4. **Limited Sorting/Filtering**: No dynamic views
   - *Mitigation*: Keep backlog small enough to scan visually

### Neutral

1. **Weekly Time Commitment**: 15-30 minutes for grooming
2. **Learning Curve**: Both CEO and CTO need to learn new system
3. **Discipline Required**: System only works if maintained

## Implementation

### Timeline
- **Day 1** (2025-12-17): Create system, document, and initial backlog
- **Week 1-2**: Adoption phase, use for all new requests
- **Week 3-4**: Refinement, adjust as needed
- **Week 4+**: Steady state, weekly grooming routine

### Success Criteria (After 4 Weeks)
- [ ] Backlog maintained under 50 items
- [ ] Weekly grooming sessions completed
- [ ] All new features logged with IDs
- [ ] Commits reference backlog IDs
- [ ] CEO satisfied with visibility
- [ ] CTO finds system helpful not burdensome

### Review Schedule
- **4 weeks**: Initial retrospective - is it working?
- **12 weeks**: Full review - keep, adjust, or replace?
- **Ongoing**: Continuous minor improvements

## Compliance

This decision aligns with:
- **Solo Developer Best Practices** (2025 research-backed)
- **Agile Principles** (adapted for solo context)
- **Lean Methodology** (eliminate waste, focus on value)
- **DevOps Culture** (automation, documentation, transparency)

## References

### Internal
- [Backlog Management System Documentation](../backlog-management-system.md)
- [BACKLOG.md](../../BACKLOG.md)
- [BACKLOG-ARCHIVE.md](../../BACKLOG-ARCHIVE.md)
- [HuaQiao Deployment Brief](../huaqiao-backlog-deployment-brief.md)

### External Research
1. Game Developer. (2025). "Five Productivity Tips for Solo Devs"
2. Atlassian. (2025). "Product Backlog: Tips for Creation and Prioritization"
3. Everhour. (2025). "Backlog Grooming: Best Agile Practices for 2025"
4. Bitovi. (2025). "Project Management for One: GitHub Projects for Solo Developers"
5. Cloudwards. (2025). "Best Project Management Software for Solopreneurs"
6. MrLesk. (2024). "Backlog.md - Markdown-native Task Manager"
7. Agilemania. (2025). "How to Manage a Large or Complex Product Backlog"

## Amendments

None yet. Future amendments will be appended below with date and description.

---

**ADR Template Version**: 1.0
**Last Updated**: 2025-12-17
**Next Review**: 2025-02-17 (8 weeks)
