# [Problem Title] Troubleshooting Log

**Date**: YYYY-MM-DD
**Problem**: [One-line description of the issue]
**Component/App**: [File path OR app name - e.g., `apps/georgetown/src/components/EventsList.tsx` OR `Georgetown app - Event filtering`]
**Trigger**: [What caused you to start systematic troubleshooting]
  - Examples: "3rd failed attempt", "circular debugging", "behavior contradicts docs", "deployment fails repeatedly"

---

## Observed Behavior

### What IS Happening
[Paste exact error message, screenshot, or detailed description of wrong behavior]

```
[Error message or console output if applicable]
```

### What SHOULD Happen
[Clear description of expected correct behavior]

### Evidence (Actual Data from System)
[Database query results, API responses, log output, build errors - ACTUAL DATA, not assumptions]

**Environment**:
- App: [Georgetown | Pitchmasters | Monorepo-wide]
- Node version: [e.g., v20.10.0]
- pnpm version: [e.g., 10.24.0]
- Browser: [if UI issue]
- Build type: [dev | production]
- Platform: [macOS | Linux | Cloudflare Pages]

**Reproduction Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Data Evidence**:
```sql
-- Example: Database query showing actual state
SELECT field1, field2 FROM table WHERE condition ORDER BY field DESC LIMIT 10;
```

**Result**:
```
[Paste actual query results here]
```

---

## Failed Attempts Log

### ❌ Attempt 1: [Short name for this approach]

**Hypothesis**: [What did you think would fix it?]

**Code changed**: [Specific files and line numbers]
```javascript
// File: apps/georgetown/src/components/Example.tsx
// Lines: 45-50

// Old code
const oldWay = something;

// New code (that didn't work)
const newWay = somethingElse;
```

**Result**: FAILED

**Error/Behavior**:
```
[What error or wrong behavior occurred]
```

**Why it failed**: [TBD initially, then update when you learn more]

**Timestamp**: YYYY-MM-DD HH:MM

---

### ❌ Attempt 2: [Short name for this approach]

**Hypothesis**: [What did you think would fix it?]

**Code changed**: [Specific files and line numbers]
```javascript
// Code that didn't work
```

**Result**: FAILED

**Error/Behavior**:
```
[What error or wrong behavior occurred]
```

**Why it failed**: [TBD initially, then update when you learn more]

**Timestamp**: YYYY-MM-DD HH:MM

---

### ❌ Attempt 3: [Short name for this approach]

**Hypothesis**: [What did you think would fix it?]

**Code changed**: [Specific files and line numbers]
```javascript
// Code that didn't work
```

**Result**: FAILED

**Error/Behavior**:
```
[What error or wrong behavior occurred]
```

**Why it failed**: [TBD initially, then update when you learn more]

**Timestamp**: YYYY-MM-DD HH:MM

---

## Current Hypotheses (Ranked by Likelihood)

### 1. [Hypothesis Name]
**Description**: [What you think is happening]

**Evidence FOR**:
- [Data point that supports this]
- [Observation that suggests this]

**Evidence AGAINST**:
- [Data point that contradicts this]
- [Fact that makes this unlikely]

**Test Plan**: [How will you verify/disprove this hypothesis?]
1. [Specific test step 1]
2. [Specific test step 2]

**Priority**: [High | Medium | Low] - [Reason for priority]

---

### 2. [Hypothesis Name]
**Description**: [What you think is happening]

**Evidence FOR**:
- [Data point that supports this]

**Evidence AGAINST**:
- [Data point that contradicts this]

**Test Plan**:
1. [Specific test step]

**Priority**: [High | Medium | Low] - [Reason]

---

## Simplification Checkpoint

**⚠️ REQUIRED after 1st failed attempt - Answer these questions:**

### Does Similar Working Code Exist?
```bash
# Search commands used
cd apps/georgetown && pnpm exec grep -r "pattern"
cd apps/pitchmasters && pnpm exec grep -r "pattern"
```

**Findings**:
- [What working patterns were found]
- [Files with similar functionality]

### Are We Overengineering?
- [What's the simplest possible solution?]
- [Can we strip this down to basics?]

### Can We Copy/Adapt Existing Code?
- [Link to similar working code in codebase]
- [What modifications would be needed]

### Monorepo-Specific Checks
- [ ] Issue occurs in both apps or just one?
- [ ] Shared dependency version mismatch?
- [ ] Clean build reproduces issue? `pnpm clean && pnpm install && pnpm build`
- [ ] Works in other app? (isolation test)

---

## Investigation Log

### Investigation 1: [What are you testing?]

**Timestamp**: YYYY-MM-DD HH:MM
**Hypothesis being tested**: [Which hypothesis from above]
**Method**: [Tool/approach]

**Command/Code**:
```javascript
// Exact code or command used
```

**Result**:
```
[Paste actual output here]
```

**Conclusion**: [What does this tell you?]

---

## Solution (✅ Fill this in once problem is solved)

### Root Cause Identified

**What was actually wrong**: [Technical explanation of the real problem]

**Why previous attempts failed**:
- **Attempt 1** failed because: [Reason]
- **Attempt 2** failed because: [Reason]

**Key insight**: [What was the "aha!" moment?]

---

### ✅ What DOES Work

**Code change**:
```javascript
// File: path/to/file.tsx
// BEFORE (broken):
const broken = () => {};

// AFTER (working):
const working = () => {};
```

**Why this works**: [Technical explanation]

---

### Verification Checklist

**Basic**:
- [ ] Confirmed fix resolves issue
- [ ] Tested edge cases
- [ ] Removed debug logging

**Monorepo**:
- [ ] Tested: `pnpm dev:[app]`
- [ ] Production build: `pnpm build:[app]`
- [ ] Clean build: `pnpm clean && pnpm install && pnpm build:[app]`
- [ ] Type check: `pnpm typecheck`

---

## Lessons Learned

**What we now know**:
- [Key insight 1]
- [Key insight 2]

**How to prevent**:
- [Prevention strategy 1]

**Documentation to update**:
- [ ] [Link to doc]

---

## Status

**Current Status**: [IN PROGRESS | RESOLVED | BLOCKED]

**If RESOLVED**: Date: YYYY-MM-DD HH:MM

---

## Notes

[Additional observations]
