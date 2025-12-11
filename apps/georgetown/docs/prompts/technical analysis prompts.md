# Technical Analysis Commands for Service Club Manager

Quick reference for analyzing Georgetown Rotary codebase health, performance, and quality metrics.

---

## Code Quality & Type Safety

**Check for TypeScript errors across entire codebase:**
```bash
npx tsc --noEmit
```

**Count TypeScript errors by severity:**
```bash
npx tsc --noEmit 2>&1 | grep -E "error TS" | wc -l
```

**Find all TODO/FIXME comments in code:**
```bash
grep -r "TODO\|FIXME\|HACK\|XXX" src/ --include="*.ts" --include="*.tsx" -n
```

**Check for console.log statements (should use logger utility):**
```bash
grep -r "console\." src/ --include="*.ts" --include="*.tsx" -n | grep -v "logger.ts"
```

**Check for hardcoded "Georgetown" or "Rotary" references (should use config/env):**
```bash
grep -r "Georgetown\|Rotary Club of Georgetown" src/ --include="*.ts" --include="*.tsx" -n | grep -v "example\|demo"
```

---

## Bundle Size & Performance

**Build and analyze bundle size:**
```bash
npm run build
```

**Check bundle sizes after build:**
```bash
ls -lh dist/assets/*.js | awk '{print $5, $9}'
```

**Count lazy-loaded chunks:**
```bash
ls dist/assets/*.js | grep -v "index" | wc -l
```

**Analyze source map to find largest modules (requires source-map-explorer):**
```bash
npx source-map-explorer dist/assets/*.js --html dist/bundle-analysis.html
```

---

## Dependencies & Security

**Check for outdated packages:**
```bash
npm outdated
```

**Check for security vulnerabilities:**
```bash
npm audit
```

**View dependency tree depth:**
```bash
npm list --depth=0
```

**Find duplicate dependencies:**
```bash
npm dedupe --dry-run
```

**Check bundle size of dependencies:**
```bash
npx vite-bundle-visualizer
```

---

## Code Structure & Metrics

**Count components:**
```bash
find src/components -name "*.tsx" | wc -l
```

**Count total lines of code:**
```bash
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1
```

**Find largest files (potential refactor candidates):**
```bash
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -10
```

**Count files by directory:**
```bash
find src -type f -name "*.tsx" | cut -d/ -f2 | sort | uniq -c
```

**Find components without error boundaries:**
```bash
grep -L "ErrorBoundary\|componentDidCatch" src/components/*.tsx
```

---

## Database & Schema Analysis

**Count database migrations:**
```bash
ls docs/database/*.sql 2>/dev/null | wc -l
```

**Check for pending migrations (files not documented):**
```bash
ls docs/database/*.sql 2>/dev/null | tail -5
```

**Verify database types are up to date:**
```bash
grep -r "Database\[" src/types/ --include="*.ts"
```

---

## Git & Project Health

**Recent commit activity:**
```bash
git log --oneline --since="1 month ago" | wc -l
```

**Files changed most frequently (hotspots):**
```bash
git log --format=format: --name-only --since="3 months ago" | grep -v "^$" | sort | uniq -c | sort -rn | head -10
```

**Largest files in repo:**
```bash
git ls-files | xargs ls -lh | sort -k5 -hr | head -10
```

**Find uncommitted changes:**
```bash
git status --short
```

**Check branch divergence from main:**
```bash
git log --oneline main..HEAD
```

---

## Documentation Coverage

**Count documentation files:**
```bash
find docs -name "*.md" | wc -l
```

**List recent dev journals:**
```bash
ls -lt docs/dev-journals/*.md | head -5
```

**Find components without props documentation:**
```bash
find src/components -name "*.tsx" -exec sh -c 'grep -L "interface.*Props" "$1"' _ {} \;
```

**Check for outdated documentation references:**
```bash
grep -r "TODO\|OUTDATED\|DEPRECATED" docs/ --include="*.md"
```

---

## Mobile & Accessibility

**Find hardcoded pixel values (should use responsive units):**
```bash
grep -r "px" src/ --include="*.css" --include="*.tsx" | grep -v "min-width\|max-width\|media" | wc -l
```

**Check for accessibility attributes:**
```bash
grep -r "aria-\|role=" src/components --include="*.tsx" | wc -l
```

**Find touch target violations (< 44px):**
```bash
grep -rE "width.*:[[:space:]]*[0-3]?[0-9]px|height.*:[[:space:]]*[0-3]?[0-9]px" src/ --include="*.css"
```

---

## PWA & Mobile-First Analysis

**Check if manifest.json is properly configured:**
```bash
cat public/manifest.json | jq '.name, .short_name, .theme_color, .icons'
```

**Verify service worker registration (if implemented):**
```bash
grep -r "serviceWorker" src/ --include="*.ts" --include="*.tsx"
```

**Check for mobile-first breakpoints (should use Tailwind responsive classes):**
```bash
grep -rE "@media.*min-width|@media.*max-width" src/ --include="*.css" --include="*.tsx" | wc -l
```

**Find components that might not be mobile-optimized:**
```bash
grep -r "overflow-x-auto\|whitespace-nowrap\|flex-nowrap" src/ --include="*.tsx"
```

---

## Service Club Platform Analysis

**Check for hardcoded service club references (should be configurable):**
```bash
grep -rE "Rotary|Kiwanis|Lions" src/ --include="*.ts" --include="*.tsx" -n | grep -v "example\|demo\|comment"
```

**Verify i18n coverage (for multilingual support):**
```bash
find src/i18n/locales -name "*.json" 2>/dev/null | wc -l
```

**Check translation key usage:**
```bash
grep -r "useTranslation\|t(" src/ --include="*.tsx" | wc -l
```

---

## Single Comprehensive Analysis Command

**Run all quality checks in sequence:**
```bash
echo "=== TypeScript Errors ===" && \
npx tsc --noEmit 2>&1 | grep -c "error TS" && \
echo "=== Bundle Analysis ===" && \
npm run build && \
ls -lh dist/assets/*.js | awk '{print $5, $9}' && \
echo "=== Security Audit ===" && \
npm audit --audit-level=moderate && \
echo "=== Outdated Packages ===" && \
npm outdated && \
echo "=== Component Count ===" && \
find src/components -name "*.tsx" | wc -l && \
echo "=== Code Lines ===" && \
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1 && \
echo "=== Hardcoded References ===" && \
grep -r "Georgetown" src/ --include="*.tsx" | grep -v "example" | wc -l && \
echo "=== Recent Commits ===" && \
git log --oneline -10
```

---

## Usage Notes

### Before Phase 1 (Current Georgetown State)
- Run to establish baseline metrics
- Document current TypeScript errors, bundle size, hardcoded references

### After Phase 1 (Service Club Manager Transition)
- Verify all "Georgetown" references removed (except demo data)
- Confirm theme/branding is configurable
- Check bundle size hasn't increased significantly

### Before Launch (Phase 7)
- Zero TypeScript errors (strict mode)
- Bundle size < 500 KB (main chunk)
- All accessibility checks passing
- PWA manifest properly configured

---

## Quick Reference Table

| Check | Command | Good Result |
|-------|---------|-------------|
| TypeScript Errors | `npx tsc --noEmit` | 0 errors |
| Bundle Size | `ls -lh dist/assets/index-*.js` | < 500 KB |
| Security Issues | `npm audit` | 0 vulnerabilities |
| Code Coverage | `npm run test:coverage` | > 80% |
| Accessibility | `grep -r "aria-" src/` | 100+ uses |
| Mobile Breakpoints | `grep -r "md:" src/` | 500+ uses |
