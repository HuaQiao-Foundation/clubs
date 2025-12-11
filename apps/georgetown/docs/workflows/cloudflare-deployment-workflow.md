# Cloudflare Pages Deployment Workflow

**Purpose**: Standard process for deploying Georgetown Rotary Speaker Management application to production via Cloudflare Pages.

**Why Cloudflare Pages**: Vercel is blocked in China. Cloudflare Pages provides global accessibility including China through Cloudflare's worldwide network.

**Participants**: CTO (execution), CEO (approval for production deploys)

---

## Deployment Environments

### Production
- **URL**: https://georgetown-rotary.pages.dev (or custom domain)
- **Branch**: `main`
- **Auto-deploy**: ✅ Enabled (deploys on push to main)
- **Environment**: Production Supabase instance
- **China Accessible**: ✅ Yes

### Preview
- **URL**: [branch-name].georgetown-rotary.pages.dev
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

**Cloudflare Pages Dashboard:**

1. Navigate to https://dash.cloudflare.com
2. Select "Workers & Pages" from sidebar
3. Select Georgetown Rotary project
4. View deployment progress in "Deployments" tab

**Build steps:**
- ⏳ Initializing...
- ⏳ Building... (1-3 minutes, typically faster than Vercel)
- ⏳ Deploying to Cloudflare network...
- ✅ Deployment successful

**If build fails:**
- Click deployment to view build logs
- Identify error (usually TypeScript or build config)
- Fix locally, commit, push again

---

### 4. Post-Deployment Verification

**Production smoke tests:**

```bash
# Open production URL
open https://georgetown-rotary.pages.dev
```

**Manual verification:**
- ✅ Homepage loads without errors
- ✅ Speaker kanban displays correctly
- ✅ Drag-and-drop functionality works
- ✅ Data loads from Supabase
- ✅ Real-time updates functioning
- ✅ Mobile responsive (test on phone)
- ✅ No console errors in browser DevTools
- ✅ **China accessibility** (use VPN or ask China-based contact to verify)

**Test critical paths:**
1. Create new speaker
2. Update speaker status (drag between columns)
3. Edit speaker details
4. Delete speaker
5. Navigate between pages

---

## Environment Variables

### Required Variables

Set in Cloudflare Pages Dashboard → Settings → Environment Variables:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://[project].supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# Optional: Analytics, monitoring, etc.
# (Add as needed)
```

### Adding/Updating Variables

1. Cloudflare Dashboard → Workers & Pages → Georgetown Rotary
2. Settings → Environment Variables
3. Click "Add variable" or edit existing
4. Select environment (Production or Preview)
5. Click "Save"
6. **Redeploy required** for changes to take effect

**Redeploy after variable changes:**

```bash
# Option 1: Push empty commit
git commit --allow-empty -m "chore: trigger redeploy for env var changes"
git push origin main

# Option 2: Use Cloudflare Dashboard
# Deployments → View build → "Retry deployment" button
```

---

## Special Deployment Scenarios

### Emergency Rollback

**If production deployment breaks:**

1. **Quick rollback via Cloudflare:**
   - Deployments tab → Find last working deployment
   - Click "Rollback to this deployment" button
   - Confirm rollback

**Rollback time:** ~1-2 minutes (Cloudflare rollbacks are instant, just network propagation)

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

**Cloudflare Pages automatically:**
- Detects new branch
- Creates preview deployment
- Preview URL: feature-speaker-search.georgetown-rotary.pages.dev

**Review preview:**
- Click preview URL in Cloudflare dashboard
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

### Cloudflare Pages Settings

**Build Configuration:**
- **Framework preset**: Vite (auto-detected)
- **Build command**: `npm run build`
- **Build output directory**: `dist`
- **Root directory**: (leave blank - project root)
- **Node version**: 18 or later

**Environment Variables:**
- Set in Cloudflare dashboard (Settings → Environment Variables)
- Separate values for Production and Preview environments
- Variables starting with `VITE_` are exposed to client code

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
- Optimized for Cloudflare's edge network

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
- ✅ Cloudflare build completed successfully
- ✅ Build logs reviewed (no warnings)

### Post-Deployment
- ✅ Production URL loads correctly
- ✅ Critical paths tested (create, read, update, delete)
- ✅ Real-time features functioning
- ✅ Mobile tested on actual device
- ✅ No console errors in browser DevTools
- ✅ Performance acceptable (< 3s initial load)
- ✅ **China accessibility verified** (critical requirement)

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
# Solution: Verify Cloudflare environment variables
# Must start with VITE_ for Vite to expose to client
# Redeploy after adding/updating variables
```

---

### Runtime Errors

**"Supabase connection failed"**
- Verify VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in Cloudflare
- Check Supabase project is running
- Verify RLS policies allow operations

**"White screen / blank page"**
- Check browser console for errors
- Verify all routes configured correctly
- Check Cloudflare Functions logs for errors

**"Slow performance"**
- Review bundle size in build output
- Implement code splitting if bundles > 500KB
- Optimize images (use WebP, lazy loading)
- Check Supabase query performance

**"Site not accessible in China"**
- Verify deployment is on Cloudflare Pages (not Vercel)
- Check Cloudflare's China network status
- Test with China-based VPN or contact
- Ensure no external dependencies blocked in China (Google Fonts, etc.)

---

## Monitoring & Analytics

### Cloudflare Web Analytics

Enable in Cloudflare Dashboard:
- Analytics → Web Analytics → Enable
- View real user metrics:
  - Page load times
  - Core Web Vitals
  - Geographic distribution (including China traffic)
  - Device breakdown
- **Privacy-friendly** - no cookies, GDPR compliant

### Performance Monitoring

**Cloudflare Pages provides:**
- Build time metrics
- Deployment history
- Edge network performance
- Geographic latency data

---

## Security Considerations

### Environment Variables
- ✅ Never commit secrets to git
- ✅ Use Cloudflare environment variables
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

### Quick Rollback (Cloudflare Dashboard)

1. Cloudflare Dashboard → Workers & Pages → Georgetown Rotary
2. Deployments tab
3. Find last known-good deployment
4. Click "Rollback to this deployment"
5. Confirm rollback
6. Verify rollback successful

**Rollback time:** ~1-2 minutes (instant rollback + network propagation)

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

**Rollback time:** ~2-4 minutes (Cloudflare builds faster than Vercel)

---

## Best Practices

✅ **DO**:
- Deploy during low-traffic hours (if possible)
- Test thoroughly in preview deployments first
- Keep deployment commits focused (single feature/fix)
- Monitor production immediately after deploy
- Document breaking changes or migrations
- Verify China accessibility for every deployment
- Use semantic versioning for major releases

❌ **DON'T**:
- Deploy directly to production without testing
- Skip post-deployment verification (especially China access)
- Deploy database migrations without code coordination
- Force-push to main (breaks deployment history)
- Deploy late Friday afternoon (reduces response time for issues)

---

## Cloudflare Pages vs Vercel

**Why we switched:**

| Feature | Vercel | Cloudflare Pages |
|---------|--------|------------------|
| **China Access** | ❌ Blocked | ✅ Accessible |
| **Build Speed** | ~2-4 min | ~1-3 min (faster) |
| **Free Tier** | 100GB bandwidth | Unlimited bandwidth |
| **Edge Network** | Good | Excellent (208 cities) |
| **Analytics** | Paid | Free & privacy-friendly |
| **Our Use Case** | Blocked by firewall | Perfect for global access |

**Key advantage**: Cloudflare's massive global network (including China-friendly infrastructure) makes it ideal for Georgetown Rotary's international accessibility requirements.

---

**Workflow Owner**: CTO
**Review Frequency**: Update as deployment practices evolve
**Last Updated**: 2025-10-08
**Migration from Vercel**: 2025-10-08
