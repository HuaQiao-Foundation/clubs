# Georgetown Troubleshooting Protocol

**Purpose**: Systematic methodology for debugging complex technical issues with proper documentation and loop prevention.

**Based on**: 2025 industry best practices and lessons learned from Georgetown, Brandmine, and HuaQiao projects.

---

## When to Trigger This Protocol

Use this protocol when you encounter:

- ✅ **Second failed fix attempt** - Same problem persists after trying different approach
- ✅ **Three or more possible root causes** - Multiple competing hypotheses
- ✅ **Circular debugging detected** - Repeating attempts without clear progress
- ✅ **Integration issues** - Multiple systems/libraries interacting unexpectedly
- ✅ **Behavior contradicts documentation** - System not working as expected
- ✅ **Shell/environment issues** - Variable loading, path resolution, permission problems

**DO NOT use for**:
- ❌ Simple typos or obvious syntax errors
- ❌ First-time fixes that succeed
- ❌ Well-understood problems with known solutions

---

## Critical Rules

### 🚫 NEVER Do These

1. **Continue past 3 failures with same approach** - Pivot after 3 attempts
2. **Stack multiple changes** - Test one thing at a time
3. **Skip documentation** - Every test MUST be logged
4. **Assume without verifying** - Always check actual data/output
5. **Repeat failed approaches** - Read your own log first
6. **Debug without reproduction** - Must trigger issue consistently
7. **Use placeholders or guesses** - Verify exact values

### ✅ ALWAYS Do These

1. **Start with data** - Query database, check logs, inspect state
2. **Form hypothesis BEFORE coding** - Write it down
3. **Add instrumentation BEFORE changes** - See what's happening
4. **Document failures immediately** - They guide you to solution
5. **Test smallest change possible** - Isolate variables
6. **Research after 3 failures** - Web search for best practices
7. **Create troubleshooting log** - Real-time documentation

---

## The Systematic Process

### Phase 1: Document & Baseline (MANDATORY)

**Create troubleshooting log**: `docs/dev-journal/YYYY-MM-DD-[problem-slug]-troubleshooting.md`

**Required sections**:
```markdown
# [Problem Title] Troubleshooting Log

**Date**: YYYY-MM-DD
**Problem**: [One-line description]
**Component**: [File path or system name]
**Trigger**: [What caused investigation]
**Status**: IN PROGRESS

---

## Troubleshooting Protocol (2025 Best Practices)

### Protocol Rules
1. **Maximum 3 attempts** with same approach before pivoting
2. **Document each attempt** with exact command and output
3. **Research before retry** - use web search after 3 failures
4. **Root cause analysis** - identify why, not just what failed
5. **Prevention** - document solution for future reference

### Attempt Log

#### Attempt #1: [Approach name]
**Time**: YYYY-MM-DD HH:MM
**Approach**: [Description of what you tried]
**Command/Code**:
```bash
[Exact command or code]
```
**Result**: ❌ FAILED
**Error**: [Exact error message]
**Root Cause**: [Analysis of why it failed]
**Lesson**: [What this teaches us]

---

## 🔍 RESEARCH PHASE (After 3 Failures)

**Web Search Queries**:
1. [Query 1 - what you searched]
2. [Query 2 - what you searched]

**Key Findings**:
- [Finding 1 with source link]
- [Finding 2 with source link]

---

## 🎯 NEW APPROACH (Post-Research)

#### Approach #4: [New approach name]
**Strategy**: [Description]
**Rationale**: [Why this should work based on research]
**Implementation**:
```bash
[Code or commands]
```

---

## Decision Matrix

| Approach | Complexity | Risk | Success Likelihood | Time |
|----------|------------|------|-------------------|------|
| #4 [Name] | Low/Med/High | Low/Med/High | Low/Med/High/Very High | X min |
| #5 [Name] | Low/Med/High | Low/Med/High | Low/Med/High/Very High | X min |

---

## ✅ FINAL SOLUTION

### Root Cause
**Problem**: [What was actually wrong]

**Why previous attempts failed**:
1. **Attempt #1**: [Why it didn't work]
2. **Attempt #2**: [Why it didn't work]
3. **Attempt #3**: [Why it didn't work]

### Working Solution
**Approach**: [What finally worked]

**Benefits**:
- ✅ [Benefit 1]
- ✅ [Benefit 2]

### Implementation
**Files updated**:
- `path/to/file1.ext` - [What changed]
- `path/to/file2.ext` - [What changed]

**Test results**:
```bash
$ [command to verify]
[successful output]
```

---

## Lessons Learned

### Technical Insights
1. **[Key insight 1]**: [Explanation]
2. **[Key insight 2]**: [Explanation]

### Process Insights
1. **[What worked well in debugging]**
2. **[What we should do differently]**

### Prevention Measures
1. **[How to prevent this in future]**
2. **[Documentation or tooling to add]**

---

## Status: ✅ RESOLVED

**Date Resolved**: YYYY-MM-DD
**Time Spent**: ~XX minutes
**Approaches Tested**: X (Y failed, Z succeeded)
**Final Outcome**: [Summary]

---

## References

- [Source 1](URL)
- [Source 2](URL)
```

---

### Phase 2: Reproduce & Gather Data

**Step 1: Reproduce consistently**
- ✅ Document exact steps to reproduce
- ✅ Note environmental conditions
- ✅ Capture screenshots/error messages
- ✅ Record timestamps

**Step 2: Gather baseline data**
- ✅ Check actual values (database, files, environment variables)
- ✅ Review logs (browser console, server logs, shell output)
- ✅ Inspect component state (React DevTools, etc.)
- ✅ Test in isolation (minimal reproduction)

**Best practice**: "Don't assume—verify every assumption with data."

---

### Phase 3: Form Hypotheses Systematically

**For each potential cause, document**:

```markdown
## Hypothesis #N: [Name]

**Statement**: I think X is causing Y because Z

**Evidence FOR**:
- [What data supports this]
- [What behavior matches this]

**Evidence AGAINST**:
- [What contradicts this]
- [What doesn't fit]

**Test plan**:
1. [How to verify - specific command or action]
2. [Expected result if hypothesis is correct]
3. [Expected result if hypothesis is wrong]

**Priority**: High/Medium/Low
```

**Prioritize hypotheses by**:
- Likelihood (based on evidence)
- Impact (how much would this explain?)
- Ease of testing (quick tests first)

---

### Phase 4: Test Systematically

**A. Manual verification FIRST**
- Test the simplest possible case
- Use hardcoded values to isolate issue
- Example: If script fails, test command manually with literal values

**B. Add instrumentation BEFORE changing code**
```bash
# Add debug output first
echo "DEBUG: Variable value = $VAR"
echo "DEBUG: File contents:"
cat file.txt | head -5
```

**C. Test ONE hypothesis at a time**
- ✅ Make single, isolated change
- ✅ Run test
- ✅ Document result IMMEDIATELY
- ✅ Revert if doesn't work (don't stack changes)

**D. Use divide-and-conquer**
- Test middle of system first
- Eliminate half of possibilities
- Narrow down systematically

---

### Phase 5: Research (After 3 Failed Attempts)

**Trigger**: Same issue after 3 different approaches

**Process**:
1. **Web search for current best practices**
   ```
   Query format: "[technology] [problem] 2025 best practices"
   Example: "bash load environment variables 2025 best practices"
   ```

2. **Document findings in troubleshooting log**
   - Include source URLs
   - Note recommended approaches
   - Identify patterns in solutions

3. **Create new approaches based on research**
   - Test most promising approach first
   - Use decision matrix to prioritize

---

### Phase 6: Fix & Verify

**Once root cause found**:

**A. Document the solution**
- Write down what worked
- Explain WHY it works
- Note why previous attempts failed

**B. Verify thoroughly**
- ✅ Reproduce original problem conditions
- ✅ Confirm fix resolves issue
- ✅ Check for side effects
- ✅ Test edge cases
- ✅ Add regression test if possible

**C. Clean up**
- ✅ Remove debug logging
- ✅ Update troubleshooting log with "RESOLVED" status
- ✅ Add lessons learned section
- ✅ Update documentation if needed

---

## Georgetown-Specific Patterns

### Common Issue Types

#### 1. Environment Variable Loading
**Symptoms**: Variables empty or malformed, shell parsing errors

**Common causes**:
- URL query parameters in values (`?param=value`)
- Special characters not escaped
- Quotes in .env file breaking `source` command

**Troubleshooting steps**:
1. Test with hardcoded value first
2. Echo variable to see actual value
3. Check for shell interpretation issues
4. Consider using component environment variables (e.g., PG* for PostgreSQL)

**Example**: [2025-12-16 backup script troubleshooting](../dev-journal/2025-12-16-backup-script-troubleshooting.md)

---

#### 2. Supabase Connection Issues
**Symptoms**: Connection refused, DNS errors, authentication failures

**Common causes**:
- Using deprecated connection format (`db.*.supabase.co`)
- Wrong pooler (port 5432 vs 6543)
- Password not URL-encoded
- Wrong region in connection string

**Troubleshooting steps**:
1. Verify connection string format matches current Supabase docs
2. Check password URL encoding (^ → %5E, $ → %24, % → %25)
3. Confirm pooler hostname (aws-1-REGION.pooler.supabase.com)
4. Test with `psql` or `pg_dump` directly

**Example**: [2025-12-16 Singapore migration](../dev-journal/2025-12-16-singapore-database-migration.md)

---

#### 3. React State Management
**Symptoms**: UI not updating, stale data, infinite loops

**Common causes**:
- Missing dependencies in useEffect
- State updates causing re-renders
- Props not triggering re-computation

**Troubleshooting steps**:
1. Add console.logs to track renders
2. Use React DevTools to inspect state
3. Check dependency arrays
4. Verify memo/useMemo usage

---

#### 4. Build/Deployment Issues
**Symptoms**: Build fails, runtime errors in production, missing env vars

**Common causes**:
- Environment variables not set in Cloudflare
- Wrong build command
- Missing dependencies
- Type errors not caught locally

**Troubleshooting steps**:
1. Run build locally first (`npm run build`)
2. Check all env vars in Cloudflare dashboard
3. Review build logs for specific errors
4. Test production bundle locally

---

## Tools & Commands

### Database inspection
```bash
cd apps/georgetown
source .env.local
psql "$DATABASE_URL" -c "SELECT * FROM table LIMIT 10;"
```

### Environment variable debugging
```bash
# Print all env vars
printenv | grep VITE

# Test variable loading
source .env.local && echo "VAR=$VAR"

# Check file encoding
od -c .env.local | head
```

### PostgreSQL connection testing
```bash
# Test connection
psql "$DATABASE_URL" -c "SELECT version();"

# Use component variables
export PGHOST=host PGPORT=port PGDATABASE=db PGUSER=user PGPASSWORD=pass
psql -c "SELECT 1;"
```

### Browser debugging
- Chrome DevTools → Console tab
- React DevTools → Components tab
- Network tab → Filter by XHR
- Application tab → Local Storage

---

## Success Metrics

**Working protocol indicators**:
- ✅ Each test eliminates possibilities
- ✅ Hypotheses get more specific (not more general)
- ✅ Evidence accumulates for one root cause
- ✅ You can explain WHY previous attempts failed
- ✅ New data gathered with each attempt

**Failing protocol indicators**:
- ❌ Repeating same tests
- ❌ Making random changes ("maybe this will work")
- ❌ Can't explain why previous attempts failed
- ❌ No new data after 3+ attempts
- ❌ Increasing number of possible causes

**Recovery action**: Stop coding, go back to Phase 2 (gather MORE data)

---

## Reference Examples

**Completed troubleshooting logs**:
- [2025-12-16: Backup Script Environment Variable Loading](../dev-journal/2025-12-16-backup-script-troubleshooting.md) - Shell parsing issues, 6 approaches tested, 45 minutes
- [2025-12-16: Singapore Database Migration](../dev-journal/2025-12-16-singapore-database-migration.md) - Connection string format, URL encoding

**Architecture decisions**:
- [ADR-0001: Supabase Singapore Migration](../adr/0001-supabase-singapore-migration.md) - Context for regional performance

---

## Protocol Sources

This protocol is based on 2025 industry best practices from:

- [Google SRE - Effective Troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
- [Graphite Debugging Best Practices Guide](https://graphite.dev/guides/debugging-best-practices-guide)
- [Systematic Debugging Approach](https://ntietz.com/blog/how-i-debug-2023/)
- [Comprehensive Guide to Loading Environment Variables in Bash](https://ithy.com/article/bash-script-load-env-variables-einnyloz)
- [PostgreSQL Connection String Format](https://www.squash.io/how-to-format-the-postgresql-connection-string-url/)
- Georgetown project experience (2024-2025)

---

**Last Updated**: 2025-12-16
**Status**: Active protocol - use for all complex debugging
**Maintained by**: Georgetown development team
