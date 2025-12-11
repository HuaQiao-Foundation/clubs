# Checklists Directory

**Purpose**: Reusable testing, quality, and operational checklists for Georgetown Rotary project management

**When to Use**: Create checklists for repeatable verification tasks that need consistent execution

---

## Checklist Types

### Testing Checklists
Systematic testing procedures for features, phases, or releases:
- Feature testing (e.g., `phase3-rsvp-attendance-testing.md`)
- UAT testing guides
- Regression testing
- Mobile responsiveness verification
- Cross-browser compatibility

### Quality Checklists
Code quality and standards verification:
- Pre-commit checks
- Code review guidelines
- Documentation completeness
- Accessibility compliance (WCAG 2.1)
- Rotary brand compliance

### Deployment Checklists
Production deployment verification:
- Pre-deployment checks
- Post-deployment verification
- Rollback procedures
- Environment configuration

### Operational Checklists
Ongoing maintenance and operations:
- Database backup verification
- Security audit
- Performance monitoring
- Analytics review

---

## Naming Convention

Use descriptive, action-oriented names:
- `phase3-rsvp-attendance-testing.md` ✅
- `pre-deployment-checklist.md` ✅
- `code-review-checklist.md` ✅
- `test.md` ❌ (too vague)

---

## Checklist Structure

Each checklist should include:

1. **Purpose** - What this checklist verifies
2. **When to Use** - Trigger conditions for using this checklist
3. **Prerequisites** - What must be ready before starting
4. **Checklist Items** - Numbered, checkbox format
5. **Pass/Fail Criteria** - How to determine success
6. **Next Steps** - What to do after completion

---

## Example Template

```markdown
# [Feature/Process Name] Checklist

**Purpose**: [What this verifies]
**When to Use**: [Trigger condition]
**Estimated Time**: [How long this takes]

## Prerequisites
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Checklist

### Section 1
- [ ] Item 1
- [ ] Item 2

### Section 2
- [ ] Item 1
- [ ] Item 2

## Pass Criteria
✅ All items checked = PASS
⚠️ 1-2 items failed = Fix and re-test
❌ 3+ items failed = Review implementation

## Next Steps
- If PASS → [What to do next]
- If FAIL → [Remediation steps]
```

---

## Current Checklists

| Checklist | Purpose | Created | Status |
|-----------|---------|---------|--------|
| [phase3-rsvp-attendance-testing.md](phase3-rsvp-attendance-testing.md) | Phase 3 RSVP & Attendance feature testing | 2025-12-02 | Active |

---

## How This Differs from Other Docs

| Directory | Purpose | Example |
|-----------|---------|---------|
| **checklists/** | Repeatable verification tasks | Testing checklist, code review checklist |
| **workflows/** | Step-by-step processes | Database migration workflow, deployment workflow |
| **plans/** | Implementation roadmaps | Multi-phase feature plans |
| **dev-journals/** | Completed work logs | What was built and how |
| **standards/** | Design & code standards | Mobile-first design standard |

**Key Difference**: Checklists are **verification tools** you run repeatedly. Workflows are **operational processes**. Plans are **implementation guides**.

---

## Usage Examples

**Scenario 1**: Just finished implementing a feature
→ Use: **Testing checklist** (e.g., `phase3-rsvp-attendance-testing.md`)

**Scenario 2**: About to deploy to production
→ Use: **Deployment checklist** (e.g., `pre-deployment-checklist.md`)

**Scenario 3**: Reviewing a pull request
→ Use: **Code review checklist** (e.g., `code-review-checklist.md`)

**Scenario 4**: Need to migrate database
→ Use: **Workflow** (e.g., `docs/workflows/database-migration-workflow.md`) ← NOT a checklist

---

## Creating New Checklists

1. Copy template structure above
2. Add to checklists/ directory
3. Update README table
4. Link from relevant docs (plans, dev-journals)
5. Test checklist with actual usage
6. Refine based on team feedback
