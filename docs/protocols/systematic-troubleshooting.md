# Troubleshooting Protocol

**Purpose**: Standard methodology for debugging complex technical issues with proper documentation and systematic investigation.

**Based on**: 2025 industry best practices from [Google SRE](https://sre.google/sre-book/effective-troubleshooting/), [Graphite debugging guide](https://graphite.dev/guides/debugging-best-practices-guide), and [systematic debugging approaches](https://ntietz.com/blog/how-i-debug-2023/).

---

## When to Use This Protocol

Trigger this protocol when:
- ✅ **Second failed fix attempt** - Same problem, different approach didn't work
- ✅ **Multiple possible causes** - 3+ hypotheses about root cause
- ✅ **Circular debugging** - Repeating attempts without clear progress
- ✅ **Integration issues** - Multiple systems/libraries interacting unexpectedly
- ✅ **Behavior contradicts documentation** - System not working as expected

**DO NOT** use for:
- ❌ Simple typos or obvious syntax errors
- ❌ First-time fixes that succeed
- ❌ Well-understood problems with known solutions

---

## The Systematic Process

### Phase 1: Document & Baseline (MANDATORY)

**Create troubleshooting log file**: `docs/dev-journal/YYYY-MM-DD-[problem-slug]-troubleshooting.md`

**Required sections**:
```markdown
# [Problem Title] Troubleshooting Log

**Date**: YYYY-MM-DD
**Problem**: [One-line description]
**Component**: [File path or system name]
**Trigger**: [What caused investigation - 2nd failed attempt, circular debugging, etc.]

---

## Observed Behavior

**What is happening** (screenshot/error message):
[Paste exact error or screenshot]

**What should happen**:
[Expected behavior]

**Evidence** (data from system):
[Database query results, log output, API response]

---

## Failed Attempts Log

### ❌ Attempt 1: [Approach name]
**Hypothesis**: [What you thought would fix it]
**Code changed**: [Specific lines/files]
**Result**: FAILED
**Why it failed**: [TBD or root cause if known]
**Timestamp**: YYYY-MM-DD HH:MM

### ❌ Attempt 2: [Approach name]
**Hypothesis**: [What you thought would fix it]
**Code changed**: [Specific lines/files]
**Result**: FAILED
**Why it failed**: [TBD or root cause if known]
**Timestamp**: YYYY-MM-DD HH:MM

---

## Current Hypotheses

1. **[Hypothesis name]**: [Description]
   - Evidence for: [What suggests this]
   - Evidence against: [What contradicts this]
   - Test plan: [How to verify]

2. **[Hypothesis name]**: [Description]
   - Evidence for:
   - Evidence against:
   - Test plan:

---

## Investigation Log

### Investigation 1: [What you're testing]
**Timestamp**: YYYY-MM-DD HH:MM
**Method**: [Tool/approach used]
**Command/Code**:
```
[Exact command or code snippet]
```
**Result**:
[What you found]

**Conclusion**: [What this tells you]

---

## Solution (Once Found)

### ✅ What DOES Work
**Root cause**: [Actual problem]
**Fix**: [Exact solution]
**Code**:
```
[Working code]
```
**Verification**: [How to confirm it works]
**Why this works**: [Technical explanation]

---

## Lessons Learned

**What we now know**:
- [Key insight 1]
- [Key insight 2]

**How to prevent**:
- [Future safeguard 1]
- [Future safeguard 2]
```

---

### Phase 2: Reproduce & Gather Data

**Step 1: Reproduce the bug consistently**
- ✅ Document exact steps to reproduce
- ✅ Note environmental conditions (browser, data state, etc.)
- ✅ Capture screenshots/error messages
- ✅ Record timestamps

**Step 2: Gather baseline data**
- ✅ Query database for actual values
- ✅ Check browser console logs
- ✅ Review network requests (if applicable)
- ✅ Inspect component state (React DevTools, etc.)

**Best practice**: "Don't assume—verify every assumption with data." ([Google SRE approach](https://sre.google/sre-book/effective-troubleshooting/))

---

### Phase 3: Form Hypotheses (Systematic)

**For each potential cause, document**:
1. **Hypothesis statement**: "I think X is causing Y because..."
2. **Evidence FOR**: What data supports this?
3. **Evidence AGAINST**: What contradicts this?
4. **Test plan**: How can I verify/disprove this?

**Prioritize hypotheses** by:
- Likelihood (based on evidence)
- Impact (how much would this explain?)
- Ease of testing (quick tests first)

**Example**:
```markdown
## Hypothesis 1: React Admin pagination is fetching wrong data

Evidence FOR:
- Database query shows correct order (verified)
- UI shows wrong order despite correct database

Evidence AGAINST:
- Custom sort function should override database order

Test plan:
1. Add console.log to see what data React Admin fetches
2. Add console.log to see sortedData output
3. Compare both outputs
```

---

### Phase 4: Test Systematically (Divide & Conquer)

**Testing approach** ([Graphite guide](https://graphite.dev/guides/debugging-best-practices-guide)):

**A. Add instrumentation BEFORE changing code**:
```javascript
// Add debug logging first
console.log('[DEBUG] Input data:', data);
console.log('[DEBUG] After sort:', sortedData);
console.log('[DEBUG] Rendered order:', sortedData.map(i => i.title));
```

**B. Test ONE hypothesis at a time**:
- ✅ Make single, isolated change
- ✅ Run test
- ✅ Document result in log IMMEDIATELY
- ✅ Revert if it doesn't work (don't stack changes)

**C. Use binary search approach**:
- Test middle of system first
- Eliminate half of possibilities
- Narrow down systematically

**D. Document EVERY test**:
```markdown
### Investigation 3: Added console.log to sort function
**Timestamp**: 2025-12-12 14:30
**Code added**:
```javascript
console.log('[SORT] Comparing:', a.title, b.title);
```
**Result**: Logs show sort IS running, but wrong order persists
**Conclusion**: Problem is NOT that sort isn't running
```

---

### Phase 5: Fix & Verify

**Once root cause found**:

**A. Document the solution**:
```markdown
## ✅ Solution Found

**Root cause**: React Admin `<List>` component's `sort` prop was overriding client-side sort

**Why attempts failed**:
- Attempt 1: Changed sort field but React Admin still controlled order
- Attempt 2: Added custom sort but React Admin fetched pre-sorted data
- Attempt 3: Changed to neutral sort - THIS WORKED

**Fix**: Changed `sort={{ field: "published_date", order: "DESC" }}` to `sort={{ field: "id", order: "ASC" }}`

**Why this works**: Neutral sort lets client-side custom sort function control final order
```

**B. Verify thoroughly**:
- ✅ Reproduce original problem conditions
- ✅ Confirm fix resolves issue
- ✅ Check for side effects
- ✅ Test edge cases
- ✅ Add regression test if possible

**C. Clean up**:
- ✅ Remove debug logging
- ✅ Update troubleshooting log with "RESOLVED" status
- ✅ Add lessons learned section

---

## Critical Rules

### 🚫 NEVER Do These:

1. **Stack multiple changes** - Test one thing at a time
2. **Skip documentation** - Every test must be logged
3. **Assume without verifying** - Check actual data
4. **Repeat failed approaches** - Read your own log first
5. **Debug without reproduction** - Must be able to trigger issue consistently

### ✅ ALWAYS Do These:

1. **Start with data** - Query database, check logs, inspect state
2. **Form hypothesis BEFORE coding** - Write it down
3. **Add instrumentation BEFORE changes** - See what's happening
4. **Document failures** - They guide you to solution
5. **Test smallest change** - Isolate variables

---

## Tools & Commands

### Database inspection:
```bash
cd apps/hub && source .env.local
/opt/homebrew/opt/libpq/bin/psql "$DATABASE_URL" -c "SELECT * FROM table ORDER BY field DESC LIMIT 10;"
```

### Browser debugging:
- Chrome DevTools → Console tab
- React DevTools → Components tab
- Network tab → Filter by XHR

### Code instrumentation:
```javascript
// Temporary debug logging
console.log('[DEBUG Component]:', { variable1, variable2 });
console.trace('[DEBUG] Call stack');
```

---

## Success Metrics

**You know troubleshooting is working when**:
- ✅ Each test eliminates possibilities
- ✅ Hypotheses get more specific (not more general)
- ✅ Evidence accumulates for one root cause
- ✅ You can explain WHY previous attempts failed

**You know troubleshooting is failing when**:
- ❌ Repeating same tests
- ❌ Making random changes ("maybe this will work")
- ❌ Can't explain why previous attempts failed
- ❌ No new data after 3+ attempts

**Recovery action**: Stop coding, go back to Phase 2 (gather MORE data)

---

## Template Location

**Full template**: `docs/dev-journal/TEMPLATE-troubleshooting-log.md` (to be created)

**Example logs**:
- `docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md` (resolved)
- `docs/dev-journal/2025-12-12-updates-sort-order-troubleshooting.md` (in progress)

---

## Sources

This protocol is based on 2025 industry best practices from:

- [Google SRE - Effective Troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
- [Graphite Debugging Best Practices Guide](https://graphite.dev/guides/debugging-best-practices-guide)
- [Systematic Debugging Approach](https://ntietz.com/blog/how-i-debug-2023/)
- [Fullview Software Troubleshooting Best Practices](https://www.fullview.io/blog/software-troubleshooting-best-practices)
- [Asana Ultimate Issue Log Template](https://asana.com/templates/issue-log)

---

**Last Updated**: 2025-12-12
**Status**: Active protocol - use for all complex debugging
