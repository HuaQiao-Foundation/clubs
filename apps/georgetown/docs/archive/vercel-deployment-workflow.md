# Vercel Deployment Workflow

**Purpose**: Standard process for deploying Georgetown Rotary Speaker Management application to production via Vercel.

**Participants**: CTO (execution), CEO (approval for production deploys)

---

## Deployment Environments

### Production
- **URL**: https://georgetown-rotary.vercel.app (or custom domain)
- **Branch**: `main`
- **Auto-deploy**: ✅ Enabled (deploys on push to main)
- **Environment**: Production Supabase instance

### Preview
- **URL**: Unique URL per pull request/branch
- **Branch**: Any non-main branch
- **Auto-deploy**: ✅ Enabled
- **Environment**: Production Supabase instance (shared)

---

## Standard Deployment Process

### 1. Pre-Deployment Checklist

**Local verification:**

```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Run tests (if applicable)
npm test

# Build production bundle
npm run build

# Preview production build locally
npm run preview
```

**Quality gates:**
- ✅ Build completes without errors
- ✅ No TypeScript errors
- ✅ No console warnings in production mode
- ✅ All features tested in preview mode
- ✅ Mobile responsive (320px-414px tested)
- ✅ Rotary brand colors correct
- ✅ Self-hosted fonts loading

---

### 2. Commit Changes

```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "feat: implement speaker kanban board

Add drag-and-drop kanban interface for speaker pipeline management.
Tested on mobile (320px+) and desktop.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to main (triggers auto-deploy)
git push origin main
```

---

### 3. Monitor Deployment

**Vercel Dashboard:**

1. Navigate to https://vercel.com/dashboard
2. Select Georgetown Rotary project
3. View "Deployments" tab
4. Watch build progress

**Build steps:**
- ⏳ Building... (1-3 minutes)
- ⏳ Assigning domain...
- ✅ Deployment successful

**If build fails:**
- Click deployment to view logs
- Identify error (usually TypeScript or build config)
- Fix locally, commit, push again

---

### 4. Post-Deployment Verification

**Production smoke tests:**

```bash
# Open production URL
open https://georgetown-rotary.vercel.app
```

**Manual verification:**
- ✅ Homepage loads without errors
- ✅ Speaker kanban displays correctly
- ✅ Drag-and-drop functionality works
- ✅ Data loads from Supabase
- ✅ Real-time updates functioning
- ✅ Mobile responsive (test on phone)
- ✅ No console errors in browser DevTools

**Test critical paths:**
1. Create new speaker
2. Update speaker status (drag between columns)
3. Edit speaker details
4. Delete speaker
5. Navigate between pages

---

## Environment Variables

### Required Variables

Set in Vercel Dashboard → Project Settings → Environment Variables:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://[project].supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# Optional: Analytics, monitoring, etc.
# (Add as needed)
```

### Adding/Updating Variables

1. Vercel Dashboard → Georgetown Rotary project
2. Settings → Environment Variables
3. Add or edit variable
4. Select environment (Production, Preview, Development)
5. Click "Save"
6. **Redeploy required** for changes to take effect

**Redeploy after variable changes:**

```bash
# Option 1: Push empty commit
git commit --allow-empty -m "chore: trigger redeploy for env var changes"
git push origin main

# Option 2: Use Vercel Dashboard
# Deployments → Latest → ⋯ Menu → Redeploy
```

---

## Special Deployment Scenarios

### Emergency Rollback

**If production deployment breaks:**

1. **Quick rollback via Vercel:**
   - Deployments → Find last working deployment
   - Click ⋯ menu → "Promote to Production"
   - Confirm rollback

2. **Fix and redeploy:**
   ```bash
   # Revert problematic commit
   git revert HEAD
   git push origin main

   # Or fix issue and commit
   git add .
   git commit -m "fix: resolve production issue"
   git push origin main
   ```

---

### Preview Deployments (Feature Branches)

**Workflow:**

```bash
# Create feature branch
git checkout -b feature/speaker-search

# Make changes and commit
git add .
git commit -m "feat: add speaker search functionality"

# Push to GitHub
git push origin feature/speaker-search
```

**Vercel automatically:**
- Detects new branch
- Creates preview deployment
- Posts preview URL as comment (if GitHub integration enabled)

**Review preview:**
- Click preview URL in Vercel dashboard or GitHub PR
- Test feature in isolation
- Verify no breaking changes
- Share with CEO for approval if needed

**Merge to production:**

```bash
# After approval, merge to main
git checkout main
git merge feature/speaker-search
git push origin main

# Delete feature branch
git branch -d feature/speaker-search
git push origin --delete feature/speaker-search
```

---

### Database Migration Deployments

**When deployment includes database changes:**

1. **Run database migration first** (see database-migration-workflow.md)
2. **Verify migration in Supabase**
3. **Deploy code changes**
4. **Test production immediately**

**Critical:** Database migrations should be backward-compatible or coordinated with code deployment.

**Example sequence:**

```bash
# 1. Run database migration
# (Execute SQL in Supabase Dashboard)

# 2. Verify migration
# (Check table structure, test queries)

# 3. Deploy code
git add .
git commit -m "feat: add speaker presentation dates

Database migration: 006-speaker-presentation-dates.sql
Deployed to Supabase: 2025-10-08"
git push origin main

# 4. Verify production
# (Test UI that uses new database fields)
```

---

## Build Configuration

### Vercel Settings

**Build Command:** `npm run build`
**Output Directory:** `dist`
**Install Command:** `npm install`
**Development Command:** `npm run dev`

**Framework Preset:** Vite
**Node Version:** 18.x (or latest LTS)

---

### Build Optimizations

**Configured in vite.config.ts:**

```typescript
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          supabase: ['@supabase/supabase-js']
        }
      }
    }
  }
});
```

**Benefits:**
- Smaller bundle sizes
- Better caching (vendor code rarely changes)
- Faster subsequent page loads

---

## Deployment Checklist

Use this checklist for every production deployment:

### Pre-Deployment
- ✅ Local build succeeds (`npm run build`)
- ✅ Preview build tested (`npm run preview`)
- ✅ All features tested locally
- ✅ Mobile responsive verified (320px+)
- ✅ Database migrations deployed (if applicable)
- ✅ Environment variables up to date
- ✅ No TypeScript errors
- ✅ No console warnings in production mode

### Deployment
- ✅ Changes committed with descriptive message
- ✅ Pushed to main branch
- ✅ Vercel build completed successfully
- ✅ Build logs reviewed (no warnings)

### Post-Deployment
- ✅ Production URL loads correctly
- ✅ Critical paths tested (create, read, update, delete)
- ✅ Real-time features functioning
- ✅ Mobile tested on actual device
- ✅ No console errors in browser DevTools
- ✅ Performance acceptable (< 3s initial load)

### Communication
- ✅ CEO notified if significant feature deployed
- ✅ Dev journal created (if major implementation)
- ✅ Documentation updated (if workflows changed)

---

## Common Issues

### Build Failures

**"Module not found"**
```bash
# Solution: Clean install
rm -rf node_modules package-lock.json
npm install
npm run build
```

**"TypeScript errors"**
```bash
# Solution: Fix type errors locally
npm run build  # Shows all TS errors
# Fix each error
# Commit and push
```

**"Environment variable undefined"**
```bash
# Solution: Verify Vercel environment variables
# Must start with VITE_ for Vite to expose to client
# Redeploy after adding/updating variables
```

---

### Runtime Errors

**"Supabase connection failed"**
- Verify VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in Vercel
- Check Supabase project is running
- Verify RLS policies allow operations

**"White screen / blank page"**
- Check browser console for errors
- Verify all routes configured correctly
- Check Vercel function logs for server errors

**"Slow performance"**
- Review bundle size in build output
- Implement code splitting if bundles > 500KB
- Optimize images (use WebP, lazy loading)
- Check Supabase query performance

---

## Monitoring & Analytics

### Vercel Analytics (Optional)

Enable in Vercel Dashboard:
- Settings → Analytics → Enable
- View real user metrics:
  - Page load times
  - Core Web Vitals
  - Traffic sources
  - Device breakdown

### Error Tracking (Future)

Consider integrating:
- Sentry (error tracking)
- LogRocket (session replay)
- PostHog (product analytics)

---

## Security Considerations

### Environment Variables
- ✅ Never commit secrets to git
- ✅ Use Vercel environment variables
- ✅ Rotate keys if exposed
- ✅ Use separate Supabase projects for dev/prod (if possible)

### Supabase Keys
- ✅ `ANON_KEY` is safe for client-side (public)
- ❌ Never expose `SERVICE_ROLE_KEY` to client
- ✅ Rely on RLS policies for data security

### Dependencies
```bash
# Regular security audits
npm audit

# Fix vulnerabilities
npm audit fix

# Manual review for high-severity issues
```

---

## Rollback Procedures

### Quick Rollback (Vercel Dashboard)

1. Vercel Dashboard → Deployments
2. Find last known-good deployment
3. Click ⋯ menu → "Promote to Production"
4. Confirm promotion
5. Verify rollback successful

**Rollback time:** ~1 minute

---

### Git Rollback

```bash
# Find commit to revert
git log --oneline -10

# Revert problematic commit
git revert abc123
git push origin main

# Or reset to previous commit (if safe)
git reset --hard HEAD~1
git push origin main --force  # Use with caution
```

**Rollback time:** ~3-5 minutes (includes build)

---

## Best Practices

✅ **DO**:
- Deploy during low-traffic hours (if possible)
- Test thoroughly in preview deployments first
- Keep deployment commits focused (single feature/fix)
- Monitor production immediately after deploy
- Document breaking changes or migrations
- Use semantic versioning for major releases

❌ **DON'T**:
- Deploy directly to production without testing
- Skip post-deployment verification
- Deploy database migrations without code coordination
- Force-push to main (breaks deployment history)
- Deploy late Friday afternoon (reduces response time for issues)

---

**Workflow Owner**: CTO
**Review Frequency**: Update as deployment practices evolve
**Last Updated**: 2025-10-08
