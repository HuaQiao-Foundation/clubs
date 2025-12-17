# Systematic Troubleshooting Protocol

**Purpose**: Standard methodology for debugging complex technical issues with proper documentation and systematic investigation.

**Status**: Active Protocol
**Last Updated**: 2025-12-17
**Applies To**: All apps in Clubs monorepo (Georgetown, Pitchmasters)

**Based on**: 2025 industry best practices from [Google SRE](https://sre.google/sre-book/effective-troubleshooting/), [Graphite debugging guide](https://graphite.dev/guides/debugging-best-practices-guide), and [systematic debugging approaches](https://ntietz.com/blog/how-i-debug-2023/).

---

## When to Use This Protocol

**✅ TRIGGER this protocol when:**
- ❌ **Second failed fix attempt** - Same problem, different approach didn't work
- ❌ **Multiple possible causes** - 3+ hypotheses about root cause
- ❌ **Circular debugging** - Repeating attempts without clear progress
- ❌ **Integration issues** - Multiple systems/libraries interacting unexpectedly
- ❌ **Behavior contradicts documentation** - System not working as expected
- ❌ **Build/deployment failures** - Issues persist across multiple attempts
- ❌ **Database migration problems** - Data inconsistencies or query failures
- ❌ **Monorepo dependency issues** - Version conflicts or workspace problems

**❌ DO NOT use for:**
- ✅ Simple typos or obvious syntax errors
- ✅ First-time fixes that succeed
- ✅ Well-understood problems with known solutions
- ✅ Standard development workflow tasks

---

## The Systematic Process

### Phase 1: Document & Baseline (MANDATORY)

**Create troubleshooting log file**:

For app-specific issues:
- Georgetown: `apps/georgetown/docs/dev-journals/YYYY-MM-DD-[problem-slug]-troubleshooting.md`
- Pitchmasters: `apps/pitchmasters/docs/dev-journals/YYYY-MM-DD-[problem-slug]-troubleshooting.md`

For monorepo-wide issues:
- Root: `docs/dev-journals/YYYY-MM-DD-[problem-slug]-troubleshooting.md`

**Use the template**: Copy from `docs/templates/troubleshooting-log-template.md`

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
- ✅ Query Supabase database for actual values (if DB-related)
- ✅ Check browser console logs
- ✅ Review network requests (if API-related)
- ✅ Inspect component state (React DevTools)
- ✅ Check build output and bundle sizes (if build-related)
- ✅ Review Cloudflare Pages logs (if deployment-related)

**Monorepo-specific checks**:
- ✅ Verify pnpm workspace is in sync: `pnpm install`
- ✅ Check if issue occurs in both apps or just one
- ✅ Confirm shared dependencies are correct versions
- ✅ Test with clean build: `pnpm clean && pnpm install && pnpm build`

**Best practice**: "Don't assume—verify every assumption with data."

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
## Hypothesis 1: React Router 7 hydration mismatch in Georgetown

Evidence FOR:
- Error only occurs on initial page load
- Works fine after client-side navigation
- React 19 + SSR known for hydration issues

Evidence AGAINST:
- Same code works in Pitchmasters app
- No console warnings about hydration

Test plan:
1. Check if SSR is enabled in vite.config.ts
2. Add console.log to see server vs client render
3. Test with SSR disabled for this route
```

**Common monorepo hypothesis patterns**:
```markdown
## Hypothesis: Dependency version mismatch between apps

Evidence FOR:
- Georgetown uses React 19.0.0
- Pitchmasters uses React 19.1.0
- Error occurs in both apps

Evidence AGAINST:
- pnpm workspace should enforce single version
- No console warnings about multiple React versions

Test plan:
1. Check package.json in both apps
2. Run `pnpm list react` to see installed versions
3. Verify pnpm-lock.yaml has single React entry
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
### Investigation 3: Added console.log to DataProvider
**Timestamp**: 2025-12-17 14:30
**Hypothesis**: Supabase query returning wrong data
**Code added**:
```javascript
console.log('[Supabase Query]:', query, params);
```
**Result**: Query is correct, but transformation is wrong
**Conclusion**: Problem is NOT the query—it's the data transformation layer
```

**Monorepo-specific testing**:
- Test in both apps to isolate app-specific vs. shared issues
- Use `pnpm dev:georgetown` or `pnpm dev:pitchmasters` for isolated testing
- Check if issue reproduces in production build: `pnpm build:[app]`

---

### Phase 5: Simplify Before Solving (CRITICAL)

**⚠️ STOP after first failed attempt** and answer these:

**Simplification Checkpoint**:
- [ ] **Does similar working code exist?** Search codebase for proven patterns
  ```bash
  cd apps/georgetown && pnpm exec grep -r "similar-pattern"
  cd apps/pitchmasters && pnpm exec grep -r "similar-pattern"
  ```
- [ ] **Are we overengineering?** What's the simplest possible solution?
- [ ] **Can we copy/adapt existing code?** Don't reinvent the wheel
- [ ] **What would a beginner do?** Sometimes naive approaches work best
- [ ] **Is there a simpler library feature?** Check official docs for built-in capabilities
- [ ] **Can we use pnpm workspace features?** Shared dependencies, workspace protocols

**Document findings** in troubleshooting log before proceeding to attempt #2.

**Example patterns to search for**:
```bash
# Find Supabase auth patterns
pnpm exec grep -r "supabase.auth" apps/

# Find React Router patterns
pnpm exec grep -r "useNavigate" apps/

# Find form validation patterns
pnpm exec grep -r "validation" apps/
```

---

### Phase 6: Fix & Verify

**Once root cause found**:

**A. Document the solution**:
```markdown
## ✅ Solution Found

**Root cause**: React Router 7 SSR hydration mismatch in Georgetown app

**Why attempts failed**:
- Attempt 1: Changed component - didn't address hydration timing
- Attempt 2: Modified Vite config - SSR still enabled
- Attempt 3: Disabled SSR for this route - THIS WORKED

**Fix**: Updated `vite.config.ts` to exclude problematic route from SSR

**Why this works**: Route doesn't need SSR, and client-side only rendering avoids hydration mismatch
```

**B. Verify thoroughly**:
- ✅ Reproduce original problem conditions
- ✅ Confirm fix resolves issue
- ✅ Check for side effects in the affected app
- ✅ Test in the OTHER app if using shared dependencies
- ✅ Test edge cases
- ✅ Test production build: `pnpm build:[app] && pnpm preview:[app]`
- ✅ Add regression test if possible

**C. Clean up**:
- ✅ Remove debug logging
- ✅ Update troubleshooting log with "RESOLVED" status
- ✅ Add lessons learned section
- ✅ Update app-specific CLAUDE.md if pattern should be documented

---

## Critical Rules

### 🚫 NEVER Do These:

1. **Stack multiple changes** - Test one thing at a time
2. **Skip documentation** - Every test must be logged
3. **Assume without verifying** - Check actual data
4. **Repeat failed approaches** - Read your own log first
5. **Debug without reproduction** - Must be able to trigger issue consistently
6. **Change both apps simultaneously** - Isolate to one app first
7. **Skip clean build testing** - Always test with fresh build

### ✅ ALWAYS Do These:

1. **Start with data** - Query database, check logs, inspect state
2. **Form hypothesis BEFORE coding** - Write it down
3. **Add instrumentation BEFORE changes** - See what's happening
4. **Document failures** - They guide you to solution
5. **Test smallest change** - Isolate variables
6. **Test in isolation** - One app at a time when possible
7. **Check monorepo integrity** - Run `pnpm install` if in doubt

---

## Monorepo-Specific Tools & Commands

### Workspace Debugging

```bash
# Check workspace integrity
pnpm install --frozen-lockfile

# List all dependencies for a package
pnpm list react --depth=0

# Check which app depends on what
pnpm why react

# Clean and rebuild everything
pnpm clean && pnpm install && pnpm build

# Build and test specific app
pnpm build:georgetown && pnpm preview:georgetown
pnpm build:pitchmasters && pnpm preview:pitchmasters
```

### Database Inspection (Supabase)

```bash
# Georgetown database
cd apps/georgetown && source .env.local
psql "$DATABASE_URL" -c "SELECT * FROM speakers ORDER BY created_at DESC LIMIT 10;"

# Pitchmasters database
cd apps/pitchmasters && source .env.local
psql "$DATABASE_URL" -c "SELECT * FROM members ORDER BY created_at DESC LIMIT 10;"
```

### Browser Debugging

- **Chrome DevTools → Console tab**: Check for errors
- **Chrome DevTools → Network tab**: Filter by XHR for API calls
- **React DevTools → Components**: Inspect component state
- **Application → Storage**: Check localStorage/sessionStorage

### Code Instrumentation

```javascript
// Temporary debug logging with context
console.log('[DEBUG Georgetown/Speakers]:', { variable1, variable2 });
console.log('[DEBUG Pitchmasters/Members]:', { variable1, variable2 });
console.trace('[DEBUG] Call stack');
```

### Build Analysis

```bash
# Analyze bundle size
pnpm build:georgetown
pnpm build:pitchmasters

# Check for duplicate dependencies
pnpm list --depth=1 | grep -E "react|react-dom"

# Verify TypeScript compilation
pnpm typecheck
```

---

## Success Metrics

**✅ You know troubleshooting is working when**:
- ✅ Each test eliminates possibilities
- ✅ Hypotheses get more specific (not more general)
- ✅ Evidence accumulates for one root cause
- ✅ You can explain WHY previous attempts failed
- ✅ Pattern emerges showing clear path forward

**❌ You know troubleshooting is failing when**:
- ❌ Repeating same tests
- ❌ Making random changes ("maybe this will work")
- ❌ Can't explain why previous attempts failed
- ❌ No new data after 3+ attempts
- ❌ Jumping between apps without isolating issue
- ❌ Modifying shared dependencies without understanding impact

**Recovery action**: Stop coding, go back to Phase 2 (gather MORE data)

---

## Template & Examples

**Template**: [docs/templates/troubleshooting-log-template.md](../templates/troubleshooting-log-template.md)

**Example logs** (when they exist):
- `docs/dev-journals/YYYY-MM-DD-[example]-troubleshooting.md`
- `apps/georgetown/docs/dev-journals/YYYY-MM-DD-[example]-troubleshooting.md`
- `apps/pitchmasters/docs/dev-journals/YYYY-MM-DD-[example]-troubleshooting.md`

---

## Protocol Activation

### 🚨 AUTOMATIC TRIGGER

**Claude Code (CTO) MUST automatically initiate this protocol after:**
- **3 failed attempts** to resolve the same issue
- **Circular debugging detected** (repeating same approaches)
- **Multiple possible causes** identified (3+ hypotheses)

**Activation message**:
> "⚠️ **TROUBLESHOOTING PROTOCOL ACTIVATED**
>
> Three failed attempts detected. Initiating systematic troubleshooting protocol.
> Creating troubleshooting log: [path]
>
> Following structured process from [docs/protocols/systematic-troubleshooting.md](../protocols/systematic-troubleshooting.md)"

### 📞 MANUAL ACTIVATION

**CEO can call this protocol into action anytime by saying:**
- "Use troubleshooting protocol"
- "Activate systematic troubleshooting"
- "Start troubleshooting protocol"

**CTO will then**:
1. Create troubleshooting log from template
2. Document all previous failed attempts
3. Follow the systematic process
4. Update log after each investigation step
5. Report findings and continue until resolved

---

## Integration with Development Workflow

### CEO/CTO Workflow Integration

When CTO (Claude Code) encounters a complex issue:

1. **CTO**: Recognizes trigger condition (3rd failed attempt OR manual activation)
2. **CTO**: Announces protocol activation
3. **CTO**: Creates troubleshooting log using template
4. **CTO**: Works through systematic protocol phases
5. **CTO**: Updates log after each investigation
6. **CTO**: Documents solution and lessons learned
7. **CTO**: Informs CEO if issue reveals architectural concerns

### Handoff to Future Sessions

When troubleshooting spans multiple sessions:

1. **Current session**: Create/update troubleshooting log
2. **Current session**: Commit log to git with descriptive message
3. **Future session**: Read troubleshooting log FIRST
4. **Future session**: Continue from last documented hypothesis
5. **Future session**: Update log with new findings

### Backlog Integration

If troubleshooting reveals:
- **Technical debt**: Add item to [BACKLOG.md](../../BACKLOG.md)
- **Missing feature**: Document in app-specific docs
- **Process improvement**: Update relevant workflow in docs/
- **Architecture issue**: Consider creating ADR in [docs/adr/](../adr/)

---

## References & Best Practices

This protocol is based on industry best practices from:
- [Google SRE - Effective Troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
- [Graphite Debugging Best Practices Guide](https://graphite.dev/guides/debugging-best-practices-guide)
- [Systematic Debugging Approach](https://ntietz.com/blog/how-i-debug-2023/)
- [Fullview Software Troubleshooting Best Practices](https://www.fullview.io/blog/software-troubleshooting-best-practices)

---

## Review & Maintenance

**Quarterly Review**: Check if protocol needs updates based on:
- New tools added to stack
- New debugging patterns discovered
- Process improvements identified
- Team feedback

**Next Review**: 2026-03-17

---

**Remember**: The goal is not to never have bugs, but to never debug the same issue twice in the same way.

---

**Last Updated**: 2025-12-17
**Status**: Active Protocol - Auto-activates after 3 failed attempts
