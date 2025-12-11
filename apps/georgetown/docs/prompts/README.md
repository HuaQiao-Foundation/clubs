# Handoff Prompts Workflow

## Purpose

After Claude Code conversation compaction, create a **dated handoff prompt** to transfer context seamlessly to the next session. This prevents re-discussion of resolved issues and maintains project continuity.

---

## When to Create a Handoff Prompt

Create a handoff prompt when:
- ✅ Conversation has been compacted (message history compressed)
- ✅ Significant strategic decisions were made
- ✅ Complex multi-phase work is in progress
- ✅ Next session CTO needs full context to continue

**Trigger phrase:** CEO says "handoff to fresh session after compaction"

---

## Handoff Prompt Template

```markdown
# Session Handoff Prompt: [Brief Description]
**Date:** YYYY-MM-DD
**Session Type:** [Planning/Implementation/Debugging/etc.]
**Next Session Focus:** [What should next CTO prioritize?]

---

## Context Summary
[2-3 paragraphs: What is the current state of the project?]

**Key Decisions Made:**
- Decision 1
- Decision 2

---

## Completed Work This Session
1. ✅ [Deliverable 1]
2. ✅ [Deliverable 2]

---

## Immediate Next Steps (Priority Order)
1. [Action 1]
2. [Action 2]

---

## Technical Context for Next Session
- Current tech stack
- Recent file changes
- Git status
- Database schema state

---

## Questions for Next Session CTO
- Open design decisions
- CEO feedback needed
- Blockers to resolve

---

## Reference Documents Created
- [File 1](path/to/file1.md)
- [File 2](path/to/file2.md)

---

## Success Criteria for Next Session
- ✅ Minimum deliverable 1
- ✅ Minimum deliverable 2

---

## Commands to Run on Session Start
```bash
# Verification commands
git status
npm run dev
```

---

**End of Handoff Prompt**
**Next Session CTO:** [Clear directive]
```

---

## File Naming Convention

**Format:** `YYYY-MM-DD-brief-description-handoff.md`

**Examples:**
- `2025-12-02-global-platform-handoff.md`
- `2025-12-15-attendance-system-handoff.md`
- `2026-01-10-launch-preparation-handoff.md`

---

## Directory Structure

```
docs/prompts/
├── README.md (this file)
├── 2025-12-02-global-platform-handoff.md
├── 2025-12-15-attendance-system-handoff.md
└── archive/ (prompts older than 30 days)
    └── 2025-11-15-speaker-system-handoff.md
```

---

## Cleanup Protocol

**Monthly cleanup (1st of each month):**
1. Review all handoff prompts in `docs/prompts/`
2. Archive prompts older than 30 days → `docs/prompts/archive/`
3. Delete archive prompts older than 90 days (unless historically significant)

**Keep indefinitely:**
- Major milestone handoffs (v1.0 launch, etc.)
- Strategic pivot decisions
- Architecture redesigns

---

## Benefits

1. **Seamless continuity** - Next session CTO has full context immediately
2. **Prevent re-work** - Avoid re-discussing resolved issues
3. **Clear priorities** - Next steps are explicit, not inferred
4. **Historical record** - Track decision-making over time
5. **CEO efficiency** - CEO doesn't repeat context manually

---

## Example Usage

**Session 1 (Today):**
- CEO and CTO discuss global Rotary platform transformation
- Create comprehensive plan in `docs/plans/`
- Conversation gets compacted (message limit reached)
- CTO creates `2025-12-02-global-platform-handoff.md`

**Session 2 (Tomorrow):**
- CEO starts fresh session with new CTO instance
- CEO: "Read the latest handoff prompt in docs/prompts/"
- New CTO reads `2025-12-02-global-platform-handoff.md`
- CTO immediately understands context and continues brand color fix
- No time wasted re-explaining strategic decisions

---

## Integration with Existing Workflows

**Relates to:**
- [docs/workflows/dev-journal-workflow.md](../workflows/dev-journal-workflow.md) - Implementation documentation
- [docs/plans/](../plans/) - Strategic planning documents
- [docs/dev-journals/](../dev-journals/) - Completed work logs

**Difference:**
- **Dev journals** = Post-implementation documentation ("what we built")
- **Plans** = Pre-implementation strategy ("what we will build")
- **Handoff prompts** = Mid-implementation context transfer ("what we're building now")

---

**Established:** 2025-12-02
**Owner:** CTO (Claude Code)
**Review Cadence:** Monthly cleanup, template updates as needed
