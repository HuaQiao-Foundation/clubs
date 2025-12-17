# Cloudflare Pages Deployment Checklist

This checklist ensures Georgetown Rotary's hybrid routing and social sharing features work correctly in production.

## Pre-Deployment Checklist

### ✅ Code Changes
- [ ] All changes committed to git
- [ ] Build succeeds locally (`pnpm run build:georgetown`)
- [ ] No TypeScript errors
- [ ] No console errors in browser

### ✅ Functions Directory
- [ ] `functions/_middleware.ts` exists
- [ ] `functions/package.json` exists
- [ ] `functions/node_modules/` is gitignored (already in `.gitignore`)
- [ ] Functions dependencies installed (`cd functions && npm install`)

### ✅ Hybrid Routing
- [ ] Test locally: `/speakers/:id` opens modal
- [ ] Test locally: Browser back button closes modal
- [ ] Test locally: Share button copies clean URL (not query param)

### ✅ Meta Tags
- [ ] `index.html` has updated OG tags ("Georgetown Rotary Speakers" not "Private System")
- [ ] `SpeakerDetailRoute.tsx` calls `updateMetaTags()`
- [ ] Browser tab title updates when viewing speaker

## Deployment Steps

### 1. Push to Git

```bash
# From monorepo root
git add .
git commit -m "feat(georgetown): implement hybrid routing and social sharing"
git push origin main
```

### 2. Cloudflare Pages Auto-Deploy

Cloudflare automatically:
- ✅ Detects new commit
- ✅ Runs build (`pnpm build:georgetown`)
- ✅ Deploys to production
- ✅ Installs function dependencies
- ✅ Deploys edge function

**Monitor:** https://dash.cloudflare.com/[account]/pages/georgetown-rotary

### 3. Verify Build Success

Check Cloudflare Dashboard:
- [ ] Build status: ✅ Success
- [ ] Build time: ~2-3 minutes
- [ ] Functions deployed: `_middleware.ts`
- [ ] Assets uploaded: ~140 files

## Post-Deployment Testing

### Test 1: Direct URL Access

```bash
# Replace with actual speaker UUID
curl https://georgetown-rotary.pages.dev/speakers/[uuid]
```

**Expected:**
- Status: 200 OK
- HTML contains speaker data
- Modal opens over board

### Test 2: Browser Back Button

1. Open https://georgetown-rotary.pages.dev/speakers
2. Click any speaker card
3. URL changes to `/speakers/[uuid]`
4. Press browser back button
5. **Expected:** URL returns to `/speakers`, modal closes

### Test 3: Share URL (Clean Format)

1. Open speaker modal
2. Click share button
3. Check copied URL
4. **Expected:** `https://georgetown-rotary.pages.dev/speakers/[uuid]` (no `?id=`)

### Test 4: WhatsApp Preview (Critical!)

**Option A: Using WhatsApp Web**
1. Copy speaker URL
2. Open WhatsApp Web
3. Paste URL in any chat
4. **Expected:** Preview shows speaker name + topic (not "Private System")

**Option B: Using curl to simulate WhatsApp**
```bash
curl -H "User-Agent: WhatsApp/2.0" https://georgetown-rotary.pages.dev/speakers/[uuid] | grep "og:title"
```

**Expected output:**
```html
<meta property="og:title" content="Dr. Baskaran Gobala" />
```

### Test 5: Telegram Preview

1. Copy speaker URL
2. Open Telegram
3. Paste URL in any chat
4. **Expected:** Preview shows speaker name + topic

### Test 6: Function Logs

1. Go to Cloudflare Dashboard
2. Pages → Georgetown Rotary → Functions
3. View real-time logs
4. Share a URL in WhatsApp
5. **Expected:** Log entry showing WhatsApp user-agent and function execution

## Rollback Plan

If something goes wrong:

### Option 1: Revert Git Commit
```bash
git revert HEAD
git push origin main
```
Cloudflare auto-deploys previous version (~2 min)

### Option 2: Rollback in Cloudflare Dashboard
1. Go to Cloudflare Pages
2. Select Georgetown project
3. Click "Deployments" tab
4. Find previous successful deployment
5. Click "Rollback" button

## Common Issues

### Issue: WhatsApp still shows "Private System"

**Solution:**
1. Clear WhatsApp cache (delete chat, re-share)
2. Test with curl first to verify function works
3. Check Cloudflare Function logs for errors
4. Verify Supabase connection in function

### Issue: Functions not deploying

**Solution:**
1. Check `functions/` directory is committed to git
2. Verify `functions/package.json` exists
3. Check Cloudflare build logs for errors
4. Try manual deploy in dashboard

### Issue: Build fails in Cloudflare

**Solution:**
1. Check build logs for specific error
2. Verify build works locally (`pnpm run build:georgetown`)
3. Check Node version matches (see `.nvmrc` or `package.json`)
4. Ensure all dependencies in `package.json`

### Issue: Speaker URLs return 404

**Solution:**
1. Verify React Router routes in `App.tsx`
2. Check `_redirects` file (if exists)
3. Ensure Cloudflare Pages build output is `dist/`
4. Test locally with `pnpm preview`

## Performance Monitoring

### Metrics to Track

**Cloudflare Analytics:**
- [ ] Page load time: <2s (target)
- [ ] Function execution time: <50ms (target <10ms)
- [ ] Cache hit rate: >80% (after warm-up)

**Supabase Dashboard:**
- [ ] API requests: Should see spike from functions
- [ ] Database queries: Monitor for slow queries (>100ms)

### Performance Targets

| Metric | Target | Acceptable | Action if Exceeded |
|--------|--------|------------|-------------------|
| Function execution | <10ms | <50ms | Add caching |
| Page load (mobile) | <2s | <3s | Optimize images |
| Database query | <50ms | <100ms | Add index |
| API requests/min | <1000 | <5000 | Add rate limiting |

## Security Checklist

- [ ] Supabase anon key is read-only (RLS enforced)
- [ ] No secrets in function code
- [ ] Speaker data is public (intended to be shared)
- [ ] Function only reads data (no writes)
- [ ] Rate limiting in place (Cloudflare default)

## Success Criteria

Deployment is successful when:

✅ **Functional:**
- Speaker URLs load correctly
- Browser back button works
- Share URLs are clean (no query params)
- WhatsApp/Telegram show speaker names

✅ **Performance:**
- Page loads in <3s on mobile
- Function executes in <50ms
- No console errors

✅ **User Experience:**
- Visual UX unchanged (modals identical)
- No breaking changes
- All features working as before

## Maintenance

### Weekly
- [ ] Check function execution logs for errors
- [ ] Monitor Supabase API usage
- [ ] Review Cloudflare Analytics

### Monthly
- [ ] Review function performance metrics
- [ ] Update dependencies if needed
- [ ] Check for Cloudflare platform updates

## Related Documentation

- [functions/README.md](../functions/README.md) - Functions architecture
- [docs/adr/002-social-sharing-open-graph-limitations.md](../adr/002-social-sharing-open-graph-limitations.md) - Decision record
- [docs/knowledge-transfer/hybrid-modal-url-routing-tdd.md](../knowledge-transfer/hybrid-modal-url-routing-tdd.md) - Routing design
- [docs/plans/hybrid-modal-routing-implementation-plan.md](../plans/hybrid-modal-routing-implementation-plan.md) - Implementation plan

---

**Last Updated:** 2025-12-17
**Next Review:** After first production deployment
