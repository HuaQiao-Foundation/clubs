# Troubleshooting Protocol - Quick Reference

**Last Updated**: 2025-12-17

---

## 🚨 When to Activate

**Auto-activates after**:
- ❌ 3 failed attempts to fix same issue
- ❌ Circular debugging detected
- ❌ Multiple possible causes (3+)

**Manual activation**:
- Say: "Use troubleshooting protocol"
- Say: "Activate systematic troubleshooting"
- Say: "Start troubleshooting protocol"

---

## 📋 The 6-Phase Process

### Phase 1: Document & Baseline
- [ ] Create troubleshooting log from template
- [ ] Document problem, environment, reproduction steps
- [ ] Gather actual data (not assumptions)

### Phase 2: Reproduce & Gather Data
- [ ] Document exact reproduction steps
- [ ] Query database/check logs/inspect state
- [ ] Test in both apps (monorepo check)
- [ ] Clean build test: `pnpm clean && pnpm install && pnpm build`

### Phase 3: Form Hypotheses
- [ ] List 3+ hypotheses with evidence FOR/AGAINST
- [ ] Prioritize by likelihood + ease of testing
- [ ] Write test plan for each

### Phase 4: Test Systematically
- [ ] Add instrumentation BEFORE changing code
- [ ] Test ONE hypothesis at a time
- [ ] Document result IMMEDIATELY
- [ ] Revert if it doesn't work

### Phase 5: Simplify Before Solving (⚠️ CRITICAL)
- [ ] Does similar working code exist? Search codebase
- [ ] Are we overengineering? What's simplest solution?
- [ ] Can we copy/adapt existing code?
- [ ] What would a beginner do?

### Phase 6: Fix & Verify
- [ ] Document solution and why it works
- [ ] Test in affected app
- [ ] Test production build
- [ ] Clean build verification
- [ ] Remove debug logging
- [ ] Update CLAUDE.md if needed

---

## 🚫 NEVER Do

1. Stack multiple changes
2. Skip documentation
3. Assume without verifying
4. Repeat failed approaches
5. Debug without reproduction
6. Change both apps simultaneously
7. Skip clean build testing

---

## ✅ ALWAYS Do

1. Start with data
2. Form hypothesis BEFORE coding
3. Add instrumentation BEFORE changes
4. Document failures
5. Test smallest change
6. Test in isolation (one app at a time)
7. Check monorepo integrity (`pnpm install`)

---

## 🛠️ Quick Commands

### Monorepo Checks
```bash
pnpm install --frozen-lockfile  # Sync workspace
pnpm list react --depth=0       # Check versions
pnpm clean && pnpm install && pnpm build  # Clean build
```

### Database Inspection
```bash
cd apps/georgetown && source .env.local
psql "$DATABASE_URL" -c "SELECT * FROM table LIMIT 10;"
```

### Build Analysis
```bash
pnpm build:georgetown && pnpm preview:georgetown
pnpm typecheck  # Check TypeScript
pnpm lint       # Check linting
```

---

## 📁 Files

**Template**: `docs/templates/troubleshooting-log-template.md`

**Full Protocol**: `docs/protocols/systematic-troubleshooting.md`

**Save logs to**:
- Monorepo-wide: `docs/dev-journals/YYYY-MM-DD-[problem]-troubleshooting.md`
- Georgetown: `apps/georgetown/docs/dev-journals/YYYY-MM-DD-[problem]-troubleshooting.md`
- Pitchmasters: `apps/pitchmasters/docs/dev-journals/YYYY-MM-DD-[problem]-troubleshooting.md`

---

## 🎯 Success Metrics

**✅ Working when**:
- Each test eliminates possibilities
- Hypotheses get more specific
- Evidence accumulates for one root cause
- Can explain WHY previous attempts failed

**❌ Failing when**:
- Repeating same tests
- Making random changes
- Can't explain failures
- No new data after 3+ attempts

**Recovery**: Stop coding → go back to Phase 2 (gather MORE data)

---

## 📞 Activation Message

When protocol activates, you'll see:

> ⚠️ **TROUBLESHOOTING PROTOCOL ACTIVATED**
>
> Three failed attempts detected. Initiating systematic troubleshooting protocol.
> Creating troubleshooting log: [path]
>
> Following structured process from docs/protocols/systematic-troubleshooting.md

---

**Remember**: The goal is not to never have bugs, but to never debug the same issue twice in the same way.
