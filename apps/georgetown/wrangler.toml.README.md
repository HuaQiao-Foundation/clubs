# wrangler.toml - Local Development Only

**File**: `wrangler.toml.local` (renamed from `wrangler.toml`)

## Why Renamed?

Cloudflare Pages **automatically looks for and uses** `wrangler.toml` when found in the root directory. However, our `wrangler.toml` contains a `[site]` configuration that is:
- ✅ Valid for local Wrangler CLI development
- ❌ Invalid for Cloudflare Pages deployments

**Error when present:**
```
ERROR: Configuration file for Pages projects does not support "site"
```

## Solution

Renamed to `wrangler.toml.local` so:
- ✅ Cloudflare Pages ignores it during deployment
- ✅ Still available for local development (rename back temporarily if needed)
- ✅ Cloudflare Pages uses dashboard settings instead

## For Local Development

If you need to test with Wrangler CLI locally:
```bash
# Temporarily rename back
mv wrangler.toml.local wrangler.toml

# Run local development
npx wrangler pages dev dist

# Rename back before committing
mv wrangler.toml wrangler.toml.local
```

## Cloudflare Pages Configuration

Production deployments use **dashboard settings**, not this file:
- Root directory: `apps/georgetown`
- Build command: `pnpm build`
- Build output: `dist`
- Functions: Automatically detected at `/functions`

---

**Date**: 2025-12-17
**Reason**: Fixed Cloudflare Pages deployment error
**Related**: Telegram sharing Functions deployment
