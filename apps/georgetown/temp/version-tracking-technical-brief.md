# Technical Brief: Version Tracking System
**Project**: Georgetown Rotary Speaker Management
**Author**: CTO (Claude Code)
**Date**: 2025-10-26
**Purpose**: Reference implementation for Claude Console project

---

## Executive Summary

Georgetown Rotary implements a **build-time version injection system** that automatically synchronizes the displayed app version with `package.json` using Vite's global constant replacement feature. This approach eliminates manual version updates across multiple files and provides type-safe version access throughout the application.

**Key Benefits:**
- Single source of truth (package.json)
- Zero runtime overhead (build-time replacement)
- TypeScript type safety
- Automatic inclusion in feedback emails
- No manual version string updates needed

---

## Architecture Overview

### Data Flow
```
package.json → vite.config.ts → __APP_VERSION__ → Footer.tsx → User Display
   (source)      (injection)      (global const)   (component)   (v1.0.0)
```

### Component Breakdown

1. **Source of Truth**: package.json version field
2. **Injection Layer**: Vite build configuration
3. **Type Safety**: TypeScript global declaration
4. **Usage Layer**: React components

---

## Implementation Details

### 1. Package Version (Source)
**File**: `package.json`
```json
{
  "name": "rotary-speakers",
  "version": "1.0.0",
  "type": "module"
}
```

**Notes:**
- Standard npm semver format
- Updated via `npm version patch|minor|major`
- Git tags automatically created with version updates

---

### 2. Build-Time Injection (Vite Configuration)
**File**: `vite.config.ts`
```typescript
import { defineConfig } from 'vite'
import packageJson from './package.json'

export default defineConfig({
  define: {
    __APP_VERSION__: JSON.stringify(packageJson.version)
  },
  plugins: [react()]
})
```

**How It Works:**
- Vite's `define` option performs **global constant replacement** at build time
- All instances of `__APP_VERSION__` in the code are replaced with the literal string `"1.0.0"`
- No runtime lookup or import required
- Tree-shakeable and optimized by bundler

**Important:** Use `JSON.stringify()` to ensure proper string quoting in the output

---

### 3. TypeScript Type Safety
**File**: `src/vite-env.d.ts`
```typescript
/// <reference types="vite/client" />

// Global constants injected by Vite at build time
declare const __APP_VERSION__: string
```

**Benefits:**
- TypeScript recognizes `__APP_VERSION__` as a valid global constant
- Autocomplete support in IDEs
- Compile-time error detection
- Clear documentation of build-time variables

---

### 4. Component Usage
**File**: `src/components/Footer.tsx`
```typescript
// Auto-inject version from package.json at build time
const APP_VERSION = __APP_VERSION__

export default function Footer() {
  return (
    <footer>
      <p>
        v{APP_VERSION} • Built by Brandmine.io
        {/* ... */}
        <a href={`mailto:feedback@example.com?body=Version:%20v${APP_VERSION}`}>
          Feedback
        </a>
      </p>
    </footer>
  )
}
```

**Usage Patterns:**
- Display version in footer: `v{APP_VERSION}`
- Include in feedback emails: Pre-populate version context
- Error reporting: Attach version to bug reports
- Debug logging: Version-stamped console logs

---

## Key Features Implemented

### 1. Visual Display
- Footer shows version: `v1.0.0 • Built by Brandmine.io • 2025`
- Small, unobtrusive text (text-xs, text-gray-600)
- Consistent across all pages (footer component used globally)

### 2. Feedback Email Integration
```typescript
mailto:randal@brandmine.io?subject=Georgetown%20Rotary%20App%20Feedback
&body=Version:%20v${APP_VERSION}%0D%0A%0D%0APage:%20${window.location.pathname}
```

**Auto-populated fields:**
- Version number (v1.0.0)
- Current page path
- Pre-formatted feedback template

**Benefits:**
- Support team knows exact version without asking
- Easier to reproduce bugs with version context
- Automated version tracking in support tickets

---

## Development Workflow

### Updating Version
```bash
# Patch version (1.0.0 → 1.0.1)
npm version patch

# Minor version (1.0.0 → 1.1.0)
npm version minor

# Major version (1.0.0 → 2.0.0)
npm version major
```

**What Happens:**
1. `package.json` version updated
2. Git commit created automatically
3. Git tag created (v1.0.1)
4. Next build automatically uses new version
5. No code changes required

### Build Process
```bash
# Development (version visible)
npm run dev

# Production build (version injected)
npm run build
```

**Verification:**
1. Open browser → Inspect footer
2. Should show: `v1.0.0` (or current version)
3. Check Network tab → No external version file loaded
4. Inspect bundled JS → Version is a literal string (not a variable)

---

## Comparison to Alternative Approaches

| Approach | Pros | Cons | Georgetown Choice |
|----------|------|------|-------------------|
| **Build-time injection** (current) | ✅ Zero runtime overhead<br>✅ Type-safe<br>✅ Single source of truth | ❌ Requires rebuild to update | **✅ CHOSEN** |
| Environment variables | ✅ Easy to change<br>✅ Per-environment versions | ❌ Manual sync with package.json<br>❌ Duplication | ❌ Not used |
| version.json file | ✅ Runtime readable<br>✅ Easy to parse | ❌ Extra HTTP request<br>❌ Manual updates | ❌ Not used |
| Hardcoded strings | ✅ Simple | ❌ Easy to forget updates<br>❌ Multiple locations | ❌ Not used |
| Git commit hash | ✅ Build-specific tracking | ❌ Not user-friendly<br>❌ Requires git access | ❌ Not used |

**Decision Rationale:**
- Georgetown prioritizes **performance** (no runtime overhead)
- **Type safety** prevents version display bugs
- **Single source of truth** reduces maintenance
- **Standard npm versioning** integrates with release workflow

---

## Edge Cases & Considerations

### 1. Local Development
- Version updates require **server restart** (`npm run dev`)
- Vite config changes always require restart
- Hot module reload (HMR) does NOT pick up version changes

### 2. Production Deployment
- Version is "baked in" at build time
- Cannot change version without rebuilding
- CI/CD pipeline should run `npm version` before build

### 3. Cache Busting
- Version change triggers new bundle hash
- Cloudflare Pages serves new version automatically
- Users may need hard refresh for immediate update

### 4. TypeScript Strict Mode
- Global constant must be declared in `vite-env.d.ts`
- Missing declaration causes TypeScript error
- Helps catch typos (`__APP_VERSOIN__` vs `__APP_VERSION__`)

---

## Potential Enhancements (Not Implemented)

### Build Timestamp
```typescript
// vite.config.ts
define: {
  __APP_VERSION__: JSON.stringify(packageJson.version),
  __BUILD_DATE__: JSON.stringify(new Date().toISOString())
}
```

### Git Commit Hash
```typescript
import { execSync } from 'child_process'

const gitHash = execSync('git rev-parse --short HEAD').toString().trim()

define: {
  __APP_VERSION__: JSON.stringify(`${packageJson.version}+${gitHash}`)
}
```

### Environment-Specific Versions
```typescript
define: {
  __APP_VERSION__: JSON.stringify(
    process.env.NODE_ENV === 'production'
      ? packageJson.version
      : `${packageJson.version}-dev`
  )
}
```

**Why Not Implemented:**
- **Simple is better**: Current approach meets all requirements
- **No business need**: Program committee doesn't need build timestamps
- **Maintenance cost**: Additional complexity without clear benefit

---

## Testing Checklist

- [ ] Version displays correctly in footer (all pages)
- [ ] Version updates when package.json changes (after rebuild)
- [ ] TypeScript compiles without errors
- [ ] Feedback email includes correct version
- [ ] Production build includes version in bundle
- [ ] No console errors related to version display
- [ ] Mobile and desktop display both show version

---

## Migration Guide (For Claude Console)

### Step 1: Install Dependencies
```bash
# Vite already installed in most React projects
# No additional dependencies needed
```

### Step 2: Update vite.config.ts
```typescript
import { defineConfig } from 'vite'
import packageJson from './package.json'

export default defineConfig({
  define: {
    __APP_VERSION__: JSON.stringify(packageJson.version)
  }
  // ... other config
})
```

### Step 3: Add TypeScript Declaration
Create or update `src/vite-env.d.ts`:
```typescript
/// <reference types="vite/client" />

declare const __APP_VERSION__: string
```

### Step 4: Use in Components
```typescript
const APP_VERSION = __APP_VERSION__

// Display in footer
<footer>v{APP_VERSION}</footer>

// Include in analytics
analytics.track('page_view', { version: APP_VERSION })

// Include in error reporting
console.error('Error in v' + APP_VERSION, error)
```

### Step 5: Test
```bash
npm run build
npm run preview
# Check footer displays version correctly
```

---

## Lessons Learned

### What Worked Well
1. **Zero configuration** after initial setup
2. **Developer-friendly**: No manual version updates
3. **Type-safe**: Caught typos during development
4. **Performance**: No runtime cost

### What Could Be Improved
- Documentation could be more prominent in codebase
- Could add version to console.log on app startup
- Could add version to error boundary fallback UI

### Best Practices Established
1. Always use `JSON.stringify()` in Vite define
2. Document global constants in `vite-env.d.ts`
3. Include version in support/feedback mechanisms
4. Test version display after every package.json update

---

## References

**Vite Documentation:**
- [Vite Config: define](https://vitejs.dev/config/shared-options.html#define)
- [Env Variables and Modes](https://vitejs.dev/guide/env-and-mode.html)

**Georgetown Rotary Codebase:**
- [vite.config.ts:5-12](/Users/randaleastman/dev/georgetown/vite.config.ts#L5-L12)
- [vite-env.d.ts:1-5](/Users/randaleastman/dev/georgetown/src/vite-env.d.ts#L1-L5)
- [Footer.tsx:3-12](/Users/randaleastman/dev/georgetown/src/components/Footer.tsx#L3-L12)
- [package.json:2-4](/Users/randaleastman/dev/georgetown/package.json#L2-L4)

**Related Concepts:**
- npm version command
- Semantic versioning (semver)
- Build-time vs runtime configuration
- TypeScript global declarations

---

## Contact

**Questions about this implementation:**
- Technical: CTO (Claude Code)
- Business: CEO (Randal Eastman, randal@brandmine.io)
- Quality Review: COO

**Usage in other projects:**
- This technical brief is freely available under CC BY 4.0
- Reference Georgetown Rotary's implementation as needed
- No attribution required for internal Brandmine projects

---

**Last Updated**: 2025-10-26
**System Version**: Georgetown Rotary v1.0.0
**Status**: Production-ready, battle-tested
