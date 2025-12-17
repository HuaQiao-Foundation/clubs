# Telegram Sharing Issue - Troubleshooting Log

**Date**: 2025-12-17
**Issue**: Telegram shows speaker name but no clickable link when sharing
**Status**: 🔍 INVESTIGATING

---

## Problem Statement

When sharing Georgetown speaker pages via Telegram:
- **Telegram**: Shows title but no clickable link
- **Messages app**: Shows full link correctly (baseline working)

**Expected behavior**: Telegram should show Open Graph preview with clickable link
**Actual behavior**: Title appears but link is not clickable

---

## Investigation Plan

### Phase 1: Information Gathering
1. ✅ Check current Open Graph meta tags in index.html
2. ✅ Examine dynamic meta tag injection (React Router/Vite)
3. ✅ Review deployed site HTML source
4. ⏳ Test Telegram bot cache/scraper

### Phase 2: Root Cause Analysis
1. Identify missing/incorrect OG tags
2. Compare with Telegram's requirements
3. Check if issue is caching or meta tag configuration

### Phase 3: Solution Implementation
1. Fix meta tags as needed
2. Test locally
3. Deploy and verify
4. Clear Telegram cache if needed

---

## Investigation Log

### Attempt 1: Check Current Meta Tags
**Time**: 2025-12-17 [START]
**Hypothesis**: Missing or incomplete Open Graph meta tags

**Action**: Read index.html and check for OG tags

**Results**:
✅ Found Open Graph tags in `apps/georgetown/index.html:15-23`
✅ Found dynamic meta tag utility in `apps/georgetown/src/utils/metaTags.ts`
✅ Meta tags ARE being updated dynamically via JavaScript

**Key Finding** 🎯:
```
Line 7-9 of metaTags.ts contains this comment:
"LIMITATION: Only works for platforms that execute JavaScript (Twitter, LinkedIn)
WhatsApp, Telegram, iMessage use static HTML and won't see dynamic updates
For those platforms, we would need SSR/prerendering"
```

**Root Cause Identified**:
- Telegram bots scrape **static HTML** only
- Current implementation updates meta tags via **JavaScript after page load**
- Telegram bot sees empty `og:url` and `og:image` from index.html:19-20
- Dynamic updates in `SpeakerDetailRoute.tsx:55-56` never reach Telegram

**Why Messages app works**: Messages may execute JS or uses different scraping behavior

**Status**: ✅ ROOT CAUSE CONFIRMED - Need server-side solution

---

### Attempt 2: Explore Server-Side Solutions
**Time**: 2025-12-17
**Hypothesis**: Need SSR, prerendering, or edge function to inject meta tags

**Action**: Evaluate options for Cloudflare Pages deployment

**Results**:
✅ **SOLUTION ALREADY IMPLEMENTED!**

Found existing Cloudflare Pages Function: `apps/georgetown/functions/_middleware.ts`

**What it does**:
1. Intercepts requests to `/speakers/:uuid`
2. Detects crawler user agents (WhatsApp, Telegram, Slack, Facebook, Twitter, LinkedIn)
3. Fetches speaker data from Supabase
4. Injects Open Graph meta tags server-side
5. Returns modified HTML to crawler

**Key code** (lines 49-62):
```typescript
const isCrawler =
  userAgent.includes('WhatsApp') ||
  userAgent.includes('Telegram') ||
  userAgent.includes('Slack') ||
  userAgent.includes('facebookexternalhit') ||
  userAgent.includes('Twitterbot') ||
  userAgent.includes('LinkedInBot')

if (!isCrawler) {
  return next()
}
```

**Status**: Solution exists, need to verify deployment and test

---

### Attempt 3: Verify Deployment
**Time**: 2025-12-17
**Hypothesis**: Function may not be deployed or not working as expected

**Action**: Check if functions are in dist/ and verify deployment

**Results**:
✅ Functions built locally: `apps/georgetown/dist/functions/_middleware.js` exists
✅ Functions package.json copied correctly

**Testing with curl**:
```bash
# Test 1: TelegramBot user agent
curl -A "TelegramBot" https://georgetown-rotary.pages.dev/speakers/00000000-0000-0000-0000-000000000000

# Test 2: WhatsApp user agent
curl -A "WhatsApp/2.0" https://georgetown-rotary.pages.dev/speakers/00000000-0000-0000-0000-000000000000
```

**Result**: ❌ Middleware NOT intercepting requests
- Returns default meta tags, not modified ones
- Title remains "Georgetown Rotary - Speaker Management"
- og:url remains empty

**Hypothesis**: Functions not deployed to Cloudflare or routing issue

---

### Attempt 4: Investigate Cloudflare Functions Deployment
**Time**: 2025-12-17
**Hypothesis**: Functions folder not being deployed or wrong location

**Action**: Check Cloudflare Pages Functions structure requirements

**Results** 🎯:
✅ **FOUND THE PROBLEM!**

According to Cloudflare docs:
> "Make sure that the `/functions` directory is at the root of your Pages project (and not in the static root, such as `/dist`)."

**Current setup**:
- ✅ Source: `apps/georgetown/functions/_middleware.ts` (CORRECT location)
- ✅ Build compiles to: `apps/georgetown/dist/functions/_middleware.js`
- ❌ **Cloudflare deploys from**: `apps/georgetown/dist/` (build output)
- ❌ **Cloudflare looks for Functions at**: Project root `/functions`, NOT `/dist/functions`

**Why it doesn't work**:
1. Cloudflare build command: `pnpm build:georgetown`
2. Build output: `apps/georgetown/dist/`
3. Cloudflare serves static files from: `apps/georgetown/dist/`
4. Cloudflare looks for Functions at: `apps/georgetown/functions/` (SOURCE directory!)
5. Functions are TypeScript `.ts` files, but Cloudflare needs `.js` files

**The issue**: Cloudflare looks for Functions in source, not build output. We have TypeScript there, but Cloudflare needs compiled JavaScript.

**Solution needed**: Deploy compiled .js files to source functions/ directory OR restructure build

---

### Attempt 5: Fix Functions Deployment Location
**Time**: 2025-12-17
**Hypothesis**: Need to output compiled functions to source directory for Cloudflare to find them

**Action**: Modify build script to compile functions in-place

**Changes made**:

1. **Modified `functions/tsconfig.json:14`**:
   ```json
   "outDir": "."  // Was: "../dist/functions"
   ```

2. **Updated `package.json:10`** - Removed dist copy:
   ```json
   "build:functions": "cd functions && npm install && tsc --project tsconfig.json && cd .."
   // Removed: && cp package.json ../dist/functions/
   ```

3. **Updated `.gitignore`** - Ignore compiled .js files:
   ```
   # Cloudflare Functions (compiled .js files - source is .ts)
   functions/**/*.js
   functions/**/*.js.map
   ```

**Result**: ✅ **BUILD SUCCESSFUL**
- Functions compile to `apps/georgetown/functions/_middleware.js`
- Cloudflare will find Functions at correct location
- .js files gitignored, built fresh on each deploy

**Testing**:
```bash
npm run build:functions
ls functions/
# Shows: _middleware.js ✅ (alongside _middleware.ts)
```

**Next step**: Deploy and test with Telegram

---

## Solution Summary

**Problem**: Telegram link previews not working
**Root Cause**: Cloudflare Functions not deploying (wrong location)
**Fix**: Compile TypeScript functions in-place instead of to dist/

**Files Modified**:
1. `apps/georgetown/functions/tsconfig.json` - Changed outDir to "."
2. `apps/georgetown/package.json` - Simplified build:functions script
3. `apps/georgetown/.gitignore` - Added functions/**/*.js

**Status**: ✅ FIXED LOCALLY - Ready to deploy and test
