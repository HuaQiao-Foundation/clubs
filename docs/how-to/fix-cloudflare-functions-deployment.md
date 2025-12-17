# How to Fix Cloudflare Functions Deployment

**Problem**: Telegram/WhatsApp link previews not working
**Root Cause**: Cloudflare can't find Functions directory
**Build Log Evidence**: `Note: No functions dir at /functions found. Skipping.`

---

## The Issue

Cloudflare Pages is configured with:
- **Root Directory**: `` (blank - monorepo root)
- **Build Command**: `pnpm build:georgetown`
- **Build Output**: `apps/georgetown/dist`

Because Root Directory is blank, Cloudflare looks for Functions at `/functions` (monorepo root), but they're actually at `/apps/georgetown/functions`.

---

## The Solution

Change Cloudflare Pages settings to use the app directory as root.

### Step-by-Step Instructions

1. **Go to Cloudflare Dashboard**
   - Navigate to: https://dash.cloudflare.com/
   - Select your account
   - Click "Workers & Pages"
   - Click "georgetown-rotary" project

2. **Go to Settings**
   - Click "Settings" tab
   - Scroll to "Build & deployments"
   - Click "Edit settings"

3. **Update Build Configuration**

   **Change FROM:**
   ```
   Root directory:         (blank)
   Build command:          pnpm build:georgetown
   Build output directory: apps/georgetown/dist
   ```

   **Change TO:**
   ```
   Root directory:         apps/georgetown
   Build command:          pnpm build
   Build output directory: dist
   ```

4. **Save and Redeploy**
   - Click "Save"
   - Go to "Deployments" tab
   - Click "Retry deployment" on the latest deployment

   OR trigger a new deployment:
   ```bash
   git commit --allow-empty -m "trigger deployment"
   git push
   ```

---

## Why This Works

With `Root directory: apps/georgetown`:

1. ✅ Cloudflare treats `apps/georgetown/` as project root
2. ✅ Looks for Functions at `/functions` → finds `apps/georgetown/functions/` ✅
3. ✅ Build command `pnpm build` works (uses georgetown's package.json)
4. ✅ Build output `dist` → resolves to `apps/georgetown/dist/` ✅
5. ✅ Functions get deployed and execute correctly

---

## Verification

After changing settings and redeploying, check the build log for:

**BEFORE (broken):**
```
Note: No functions dir at /functions found. Skipping.
```

**AFTER (fixed):**
```
Compiling Functions...
Compiled 1 function in X ms
```

Then test with curl:
```bash
curl -A "TelegramBot" https://rotary-club.app/speakers/[UUID] | grep "og:title"
```

Should show speaker name, not default "Georgetown Rotary Speakers".

---

## Additional Notes

### Monorepo Implications

- This approach works well for monorepos where each app is independent
- Each Cloudflare Pages project points to its respective app directory
- Functions remain app-specific (not shared across apps)

### Alternative Approaches

If you needed shared Functions:
1. **Option A**: Put Functions at monorepo root `/functions` and configure accordingly
2. **Option B**: Use Cloudflare Workers (not Pages Functions) for shared logic
3. **Option C**: Copy functions during build (less clean)

### Related Files

- **Functions source**: [apps/georgetown/functions/_middleware.ts](../../apps/georgetown/functions/_middleware.ts)
- **Functions README**: [apps/georgetown/functions/README.md](../../apps/georgetown/functions/README.md)
- **Troubleshooting log**: [docs/troubleshooting/2025-12-17-telegram-sharing-investigation.md](../troubleshooting/2025-12-17-telegram-sharing-investigation.md)

---

## Pitchmasters

Apply the same fix if Pitchmasters needs Functions in the future:

```
Root directory:         apps/pitchmasters
Build command:          pnpm build
Build output directory: dist
```

---

**Last Updated**: 2025-12-17
**Status**: Tested and verified solution
