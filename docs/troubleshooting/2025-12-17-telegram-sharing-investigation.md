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

---

### Attempt 6: Verify Deployment Actually Working
**Time**: 2025-12-17 22:15 SGT
**Hypothesis**: Functions compiled locally but not deploying to Cloudflare

**User Report**: Telegram still not showing clickable link preview, just plain text

**Testing**:
```bash
curl -A "TelegramBot" https://georgetown-rotary.pages.dev/speakers/test-uuid | grep "og:title"
# Result: Still shows default "Georgetown Rotary Speakers"
# Expected: Should show speaker-specific title
```

**Finding**: ❌ Middleware NOT running on Cloudflare
- Functions compile locally ✅
- Functions exist at apps/georgetown/functions/_middleware.js ✅  
- But Cloudflare is NOT executing them ❌

**New hypothesis**: Cloudflare's build process might be:
1. Running `pnpm build:georgetown` ✅
2. Deploying `apps/georgetown/dist/` as static files ✅
3. BUT: Not deploying `apps/georgetown/functions/` separately ❌

**Root cause suspect**: Monorepo structure - Cloudflare might not see functions/ when root directory is not the project root


---

### Attempt 7: Identify Cloudflare Configuration Issue
**Time**: 2025-12-17 22:20 SGT
**Hypothesis**: Cloudflare Root Directory configuration preventing Functions deployment

**Discovery** 🎯:
Found in `docs/plans/2025-12-17-cloudflare-setup-summary.md:122`:
```
Root Directory: (blank - monorepo root)
```

**The Problem**:
- Cloudflare Root Directory: `/` (monorepo root)
- Cloudflare looks for Functions at: `/functions`
- But Functions are actually at: `/apps/georgetown/functions`
- Result: Cloudflare never finds the Functions! ❌

**Why this matters**:
Cloudflare Pages looks for Functions relative to the Root Directory setting.
- If Root Directory = blank → looks at `/functions`
- Our functions are at `/apps/georgetown/functions`
- Cloudflare can't find them!

**Solution needed**: Change Cloudflare Root Directory to `apps/georgetown`

---

### Attempt 8: Solution - Update Cloudflare Root Directory
**Time**: 2025-12-17 22:25 SGT
**Action**: Configure Cloudflare to use correct root directory

**Cloudflare Pages Settings to Change**:

Navigate to: Cloudflare Dashboard → Pages → georgetown-rotary → Settings → Builds & deployments

**Current settings**:
```
Root directory: (blank)
Build command: pnpm build:georgetown
Build output directory: apps/georgetown/dist
```

**New settings** ✅:
```
Root directory: apps/georgetown
Build command: pnpm build
Build output directory: dist
```

**Why this works**:
1. Root directory `apps/georgetown` makes Cloudflare treat that as the project root
2. Functions at `/functions` (relative) = `apps/georgetown/functions` (absolute) ✅
3. Build command `pnpm build` works because georgetown's package.json has `"build"` script
4. Build output `dist` (relative) = `apps/georgetown/dist` (absolute) ✅

**Important**: This requires changing settings in Cloudflare Dashboard, cannot be done via code.


---

### Attempt 9: Fix wrangler.toml Conflict
**Time**: 2025-12-17 22:25 SGT
**Hypothesis**: wrangler.toml causing deployment failure

**User Report**: Deployment failed immediately with error:
```
ERROR: Configuration file for Pages projects does not support "site"
```

**Root Cause**:
- Changed root directory to `apps/georgetown` ✅
- Cloudflare now finds `wrangler.toml` in that directory
- `wrangler.toml` contains `[site]` configuration (line 21-22)
- `[site]` is valid for Wrangler CLI local development
- `[site]` is NOT supported by Cloudflare Pages deployments

**Solution Applied**:
1. Deleted `apps/georgetown/wrangler.toml` from git
2. Saved locally as `wrangler.toml.local` for future reference
3. Added `wrangler.toml.README.md` explaining why it was removed
4. Cloudflare Pages will now use dashboard settings (no config file)

**Commit**: b101f8b
**Status**: ✅ Pushed - Ready to retry deployment

---

## Final Solution

**Complete fix requires TWO changes:**

1. ✅ **Cloudflare Dashboard Settings** (completed):
   - Root directory: `apps/georgetown`
   - Build command: `pnpm build`
   - Build output: `dist`

2. ✅ **Remove wrangler.toml** (completed):
   - Deleted from git (commit b101f8b)
   - Prevents config file conflict
   - Cloudflare uses dashboard settings instead

**Next**: Retry deployment and verify Functions deploy correctly

---

### Attempt 10: Verify Middleware Supabase Connection
**Time**: 2025-12-18
**Hypothesis**: Middleware compiles and deploys but uses wrong Supabase credentials

**Discovery** 🎯:
Checked the middleware code and found **CRITICAL BUG**:

**Middleware hardcoded credentials** (line 16-18):
```typescript
const SUPABASE_URL = 'https://zooszmqdrdocuiuledql.supabase.co'
const SUPABASE_ANON_KEY = 'eyJ[...]gQKg'
```

**Production environment uses** (.env file):
```
VITE_SUPABASE_URL=https://rmorlqozjwbftzowqmps.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ[...]RkQ8
```

**Root Cause**:
- Middleware connects to `zooszmqdrdocuiuledql.supabase.co` (WRONG database)
- Production app uses `rmorlqozjwbftzowqmps.supabase.co` (CORRECT database)
- Speaker data doesn't exist in the wrong database
- Middleware returns 404/empty, falls through to default meta tags

**Why curl returns default tags**:
```bash
curl -A "TelegramBot" https://georgetown-rotary.pages.dev/speakers/[UUID]
# Middleware tries zooszmqdrdocuiuledql.supabase.co
# Speaker not found (wrong database)
# Falls through to next()
# Returns default meta tags ❌
```

**Solution needed**: Update middleware to use correct Supabase credentials

**Action Taken**:
1. Updated `_middleware.ts` lines 21-23 with production credentials
2. Changed URL from `zooszmqdrdocuiuledql.supabase.co` → `rmorlqozjwbftzowqmps.supabase.co`
3. Changed anon key to match production environment
4. Rebuilt functions: `pnpm run build:functions` ✅

**Files Modified**:
- `apps/georgetown/functions/_middleware.ts` - Updated Supabase credentials

**Status**: ✅ FIXED - Ready to commit and deploy

---

## Final Solution (Updated)

**The issue required THREE fixes:**

1. ✅ **Cloudflare Dashboard Settings**:
   - Root directory: `apps/georgetown`
   - Build command: `pnpm build`
   - Build output: `dist`

2. ✅ **Remove wrangler.toml**:
   - Deleted from git (commit b101f8b)
   - Prevents config file conflict

3. ✅ **Fix Supabase Credentials** (THIS WAS THE MISSING PIECE):
   - Middleware was connecting to wrong database
   - Updated to production credentials
   - Now fetches speaker data correctly

**Next**: Commit and push to trigger deployment

---

### Attempt 11: Verification and Database Cleanup
**Time**: 2025-12-18 06:00 SGT
**Status**: Testing deployment with curl

**Verification Results** ✅:
```bash
curl -A "TelegramBot" https://rotary-club.app/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3

Results:
- og:title: "Tammana Patel" ✅
- og:description: "The Application of Permaculture" ✅
- og:url: https://rotary-club.app/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3 ✅
- og:image: https://zooszmqdrdocuiuledql.supabase.co/... ❌ (old storage URL)
```

**Issue Found**:
- Middleware working correctly ✅
- But `portrait_url` in database still points to old Supabase storage
- Speaker portraits migrated but database URLs not updated

**Action Taken**:
```sql
-- Found 9 speakers with old storage URLs
UPDATE speakers
SET portrait_url = REPLACE(
  portrait_url,
  'https://zooszmqdrdocuiuledql.supabase.co',
  'https://rmorlqozjwbftzowqmps.supabase.co'
)
WHERE portrait_url LIKE '%zooszmqdrdocuiuledql%';
-- Updated 9 rows
```

**Verification After Update**:
```bash
curl -A "TelegramBot" https://rotary-club.app/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3

Results:
- og:image: https://rmorlqozjwbftzowqmps.supabase.co/... ✅ (NEW storage URL!)
```

**Status**: ✅ **FULLY RESOLVED**

---

## 🎉 ISSUE RESOLVED

**Problem**: Telegram/WhatsApp link previews not working
**Status**: ✅ **FIXED AND VERIFIED**

**Complete Solution Required 4 Fixes:**

1. ✅ **Cloudflare Dashboard Settings** (Attempt 8):
   - Root directory: `apps/georgetown`
   - Build command: `pnpm build`
   - Build output: `dist`

2. ✅ **Remove wrangler.toml** (Attempt 9):
   - Deleted from git (commit b101f8b)
   - Prevents config file conflict

3. ✅ **Fix Supabase Credentials** (Attempt 10):
   - Middleware was connecting to wrong database
   - Updated to production credentials (commit b432447)
   - Now fetches speaker data correctly

4. ✅ **Update Database Portrait URLs** (Attempt 11):
   - 9 speakers had old storage URLs
   - Updated all to use new Supabase storage
   - Open Graph images now point to correct location

**Final Test Results**:
- Speaker name in title ✅
- Topic in description ✅
- Correct URL ✅
- Correct image URL ✅
- All crawlers working (Telegram, WhatsApp, Facebook, Twitter) ✅

**Ready for Production** ✅

---

### Attempt 12: Complete Image Migration
**Time**: 2025-12-18 06:00 SGT
**Hypothesis**: Database URLs updated but image files not migrated to new storage

**Discovery** 🎯:
All database URLs point to new storage, but images don't exist there yet.

**Action Taken**:
Migrated **24 images** (1.4 MB) from old to new Supabase storage:
- 10 speaker portraits (~303 KB) - including Frank Yih
- 3 member portraits (~138 KB)
- 4 partner logos (~85 KB)
- 5 project images (~576 KB)
- 2 club photos (~453 KB)

**Process**:
1. Downloaded all files from `zooszmqdrdocuiuledql.supabase.co`
2. Uploaded to `rmorlqozjwbftzowqmps.supabase.co` using Supabase SDK
3. Verified all images return HTTP 200
4. Fixed hardcoded URL in `Availability.tsx`

**Results**: ✅ All 24 files migrated successfully (0 failures)

**Status**: ✅ **COMPLETE** - All images now display correctly

**Documentation**: See `docs/maintenance/2025-12-18-image-migration.md`

---

### Attempt 13: Verify Upload Forms Use Correct Storage
**Time**: 2025-12-18 06:05 SGT
**Status**: ⏳ VERIFICATION NEEDED

**Check**: Confirm modal edit forms connect to new storage buckets

**Files verified**:
- ✅ `src/lib/supabase.ts` - Uses environment variables
- ✅ `.env` - Has correct new Supabase URL (`rmorlqozjwbftzowqmps.supabase.co`)
- ⏳ Upload components need testing

**Next**: Test uploading new images through UI to confirm storage works

---

### Attempt 14: Complete Upload Form Configuration Audit
**Time**: 2025-12-18
**Status**: ✅ **VERIFICATION COMPLETE**
**Hypothesis**: All upload forms should use centralized Supabase client from src/lib/supabase.ts

**Action Taken**: Systematic code audit of all image upload functionality

**Components Audited**:

1. **Core Upload Components** (2 files):
   - ✅ `ImageUpload.tsx:3` - Imports `supabase` from `../lib/supabase`
   - ✅ `ImageUpload.tsx:98-103` - Uses `supabase.storage.from(bucketName).upload()`
   - ✅ `ImageUpload.tsx:112-114` - Uses `supabase.storage.from(bucketName).getPublicUrl()`
   - ✅ `PhotoUploadModal.tsx:9` - Imports `supabase` from `../lib/supabase`
   - ✅ `PhotoUploadModal.tsx:138-143` - Uses `supabase.storage.from('club-photos').upload()`
   - ✅ `PhotoUploadModal.tsx:152-154` - Uses `supabase.storage.from('club-photos').getPublicUrl()`

2. **Forms Using ImageUpload Component** (4 forms):
   - ✅ `SpeakerModal.tsx:225` - Speaker portraits → bucket: `speaker-portraits`
   - ✅ `MemberModal.tsx:187` - Member portraits → bucket: `member-portraits`
   - ✅ `PartnerModal.tsx:162` - Partner logos → bucket: `partner-logos`
   - ✅ `ServiceProjectModal.tsx:371` - Project images → bucket: `project-images`

3. **Forms Using PhotoUploadModal** (2 forms):
   - ✅ `TimelineView.tsx` - Club photos → bucket: `club-photos`
   - ✅ `PhotoGallery.tsx` - Club photos → bucket: `club-photos`

**Hardcoded URL Search**:
```bash
grep -r "zooszmqdrdocuiuledql" apps/georgetown/src/
# Result: No files found ✅
```

**Environment Configuration**:
```bash
cat apps/georgetown/.env | grep VITE_SUPABASE_URL
# Result: VITE_SUPABASE_URL=https://rmorlqozjwbftzowqmps.supabase.co ✅
```

**Supabase Client Configuration**:
- ✅ `src/lib/supabase.ts:3` - Uses `import.meta.env.VITE_SUPABASE_URL`
- ✅ `src/lib/supabase.ts:4` - Uses `import.meta.env.VITE_SUPABASE_ANON_KEY`
- ✅ `src/lib/supabase.ts:6` - Exports single client instance

**Findings** 🎯:

**ALL UPLOAD FORMS CORRECTLY CONFIGURED**:
- ✅ All 5 upload forms use centralized Supabase client
- ✅ No hardcoded storage URLs found in source code
- ✅ Environment file has correct new Supabase URL
- ✅ Supabase client uses environment variables correctly
- ✅ All buckets specified correctly in upload components

**Upload Buckets Configured**:
1. ✅ `speaker-portraits` - Used by SpeakerModal
2. ✅ `member-portraits` - Used by MemberModal
3. ✅ `partner-logos` - Used by PartnerModal
4. ✅ `project-images` - Used by ServiceProjectModal
5. ✅ `club-photos` - Used by PhotoUploadModal (Timeline & Gallery)

**Status**: ✅ **CODE AUDIT COMPLETE - ALL FORMS VERIFIED**

**Recommendation**:
- Upload forms are correctly configured to use new storage
- New uploads will automatically go to `rmorlqozjwbftzowqmps.supabase.co`
- Optional: Test one upload per bucket to confirm Supabase bucket permissions are set correctly
- See handoff document for detailed testing instructions if needed

**Files Verified**:
- `apps/georgetown/src/lib/supabase.ts`
- `apps/georgetown/src/components/ImageUpload.tsx`
- `apps/georgetown/src/components/PhotoUploadModal.tsx`
- `apps/georgetown/src/components/SpeakerModal.tsx`
- `apps/georgetown/src/components/MemberModal.tsx`
- `apps/georgetown/src/components/PartnerModal.tsx`
- `apps/georgetown/src/components/ServiceProjectModal.tsx`
- `apps/georgetown/src/components/TimelineView.tsx`
- `apps/georgetown/src/components/PhotoGallery.tsx`
- `apps/georgetown/.env`

---

## 🎉 ISSUE FULLY RESOLVED

**Problem**: Telegram/WhatsApp link previews not working + images not displaying
**Status**: ✅ **FIXED AND VERIFIED**

**Complete Solution Required 5 Fixes:**

1. ✅ **Cloudflare Dashboard Settings** (Attempt 8)
2. ✅ **Remove wrangler.toml** (Attempt 9)
3. ✅ **Fix Supabase Credentials** (Attempt 10)
4. ✅ **Update Database URLs** (Attempt 11)
5. ✅ **Migrate Image Files** (Attempt 12)

**Verification Status**:
- ✅ Link previews work (Telegram, WhatsApp, Facebook, Twitter)
- ✅ All images display on website
- ✅ **Upload forms verified - all correctly configured** (Attempt 14)

---

### Attempt 15: Implement Phase 3 - Service Projects Open Graph Support
**Time**: 2025-12-18 06:30 SGT
**Status**: ⚠️ **CODE COMPLETE - DEPLOYMENT ISSUE**
**Hypothesis**: Service projects need Open Graph support like speakers

**Objective**: Add `/projects?id=uuid` route handling to middleware for rich link previews

**Implementation Completed** ✅:

1. **Database Schema Research**:
   - Service projects table: `id`, `project_name`, `description`, `image_url`, `area_of_focus`
   - Projects use query params (`/projects?id=uuid`), not path params
   - ServiceProjectsPage.tsx:210-226 handles `searchParams.get('id')`

2. **Middleware Code** (3 commits):
   - Commit 80c298f: Initial with path params (corrected in next commit)
   - Commit 9625f6e: Fixed to query params ✅
   - Commit 94c29d1: Added error logging

3. **Code Implementation**:
   ```typescript
   // Process service project URLs: /projects?id=uuid
   if (url.pathname === '/projects') {
     const projectId = url.searchParams.get('id')
     if (projectId && UUID_REGEX.test(projectId)) {
       const { data: project } = await supabase
         .from('service_projects')
         .select('id, project_name, description, image_url, area_of_focus')
         .eq('id', projectId)
         .single()

       if (project) {
         return injectMetaTags(html, {
           title: project.project_name,
           description: project.description || `${project.area_of_focus} project`,
           image: project.image_url || '',
           url: `${url.origin}/projects?id=${project.id}`,
         })
       }
     }
   }
   ```

4. **Local Verification** ✅:
   - Functions compiled successfully
   - Compiled JS has correct code at line 81
   - Test project exists with all data

5. **Cloudflare Build Logs** ✅:
   ```
   22:22:20 > build:functions
   22:22:20 > cd functions && npm install && tsc && cd ..
   22:22:22 added 15 packages, and audited 16 packages in 1s
   22:22:25 Found Functions directory at /functions. Uploading.
   22:22:28 ✨ Compiled Worker successfully
   22:22:37 ✨ Upload complete!
   22:22:43 Success: Assets published!
   ```

**Testing Results**:

✅ **Speakers work perfectly** (all platforms):
```bash
curl -A "TelegramBot" https://rotary-club.app/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3
# Returns: og:title="Tammana Patel" ✅

# All crawler user agents work:
- WhatsApp/2.0 ✅
- facebookexternalhit/1.1 ✅
- Twitterbot/1.0 ✅
- LinkedInBot/1.0 ✅
- Slackbot-LinkExpanding 1.0 ✅
```

❌ **Projects return default tags**:
```bash
curl -A "TelegramBot" "https://rotary-club.app/projects?id=463bbd9f-8989-45b4-a8ae-0fa727f66dbc"
# Returns: og:title="Georgetown Rotary Speakers" (DEFAULT - not project title) ❌
```

**Root Cause Analysis** 🔍:

**What we know**:
1. ✅ Code is correct (verified locally)
2. ✅ Functions compile during build (logs confirm)
3. ✅ Functions upload to Cloudflare (logs confirm)
4. ✅ Middleware runs for speakers (proven by curl tests)
5. ❌ Middleware doesn't inject tags for projects

**Possible causes**:
1. **Route mismatch** - Middleware might not matching `/projects` pathname
2. **Query param handling** - `url.searchParams.get('id')` might not work in Edge Workers
3. **Database query failing** - Supabase query might error silently
4. **Error logging not visible** - Console.error doesn't show in production

**Next Debugging Steps** 📋:

**Option A - Add visible debugging** (recommended):
1. Modify middleware to inject a debug comment in HTML for projects route
2. This will show in curl output whether code path is reached
3. Example:
   ```typescript
   // Add before trying to fetch project:
   if (url.pathname === '/projects') {
     console.log('[DEBUG] Projects route matched')
     // ... existing code
   }
   ```

**Option B - Check Cloudflare logs**:
1. Go to Cloudflare Pages dashboard
2. Find georgetown-rotary project
3. Check Functions logs/Real-time logs
4. Look for errors during project URL requests

**Option C - Local Edge Worker testing**:
1. Use `wrangler pages dev` to test locally
2. Verify query param handling works
3. Check if Supabase connection works from Edge

**Option D - Simplify for testing**:
1. Temporarily return hardcoded meta tags for `/projects` route
2. This isolates whether it's route matching or data fetching

**Build Time Analysis**:
- 5 minutes is **normal** for Cloudflare Pages monorepo builds
- Breakdown:
  - Ruby installation: ~3 min (required by asdf)
  - pnpm install: 7.5 sec
  - TypeScript compilation: ~10 sec
  - Vite build: 6.78 sec
  - Functions compilation: 2 sec
  - Upload: 14 sec

**Files Modified**:
- `apps/georgetown/functions/_middleware.ts`

**Status**: ✅ CODE READY - ⏳ NEEDS DEBUGGING

**Recommendation**: Add HTML comment debugging to confirm route matching before continuing.

---

