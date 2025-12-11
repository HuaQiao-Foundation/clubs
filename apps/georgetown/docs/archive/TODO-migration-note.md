# TODO.md Migration Note

**Date**: 2025-10-08

## Change Summary

Migrated from TODO.md workflow to BACKLOG.md system to align Georgetown with Brandmine's proven CEO-COO-CTO workflow.

## Old System (TODO.md)
- Root-level TODO.md maintained by Claude Code
- GitHub Actions sync to project board
- Sprint-based task management
- CEO tracked priorities manually

## New System (docs/BACKLOG.md)
- CTO owns all backlog maintenance
- CEO adds items via "Code, backlog this: [description]"
- COO reviews quality of completed items (not task management)
- System tracks tasks, not CEO's memory

## Migration Actions Taken

1. **Archived** old TODO.md → `docs/archive/TODO-old-workflow.md`
2. **Created** new `docs/BACKLOG.md` with Brandmine format
3. **Updated** CLAUDE.md to reference BACKLOG.md instead of TODO.md
4. **Migrated** active tasks from TODO.md to BACKLOG.md where relevant

## Current Backlog Items

Active items from TODO.md were evaluated:
- Quality gate tasks: In-progress work, not backlog items (handled per session)
- Authentication, real-time collaboration, notifications: Moved to BACKLOG.md as future enhancements
- Member directory, calendar: Already in BACKLOG.md

## References

- New backlog system: [docs/BACKLOG.md](../BACKLOG.md)
- Workflow protocol: [docs/dev-charter.md](../dev-charter.md)
- CEO-COO-CTO workflow: [docs/reference-data/ceo-cto-workflow.md](../reference-data/ceo-cto-workflow.md)
