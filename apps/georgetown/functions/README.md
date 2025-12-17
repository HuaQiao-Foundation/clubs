# Cloudflare Pages Functions

This directory contains edge functions that run on Cloudflare's network before serving pages.

## What It Does

The `_middleware.ts` file intercepts requests to speaker URLs and injects speaker-specific Open Graph meta tags **server-side** so that WhatsApp, Telegram, and other messaging apps show the correct speaker name instead of "Private System".

## How It Works

1. **User shares:** `https://georgetown.rotary.com/speakers/abc-123`
2. **WhatsApp bot makes request** with `User-Agent: WhatsApp/2.0`
3. **Cloudflare Function detects** it's a crawler
4. **Function fetches** speaker data from Supabase
5. **Function modifies** HTML to inject speaker name in meta tags
6. **WhatsApp receives** modified HTML with correct preview

## Architecture

```
Request → Cloudflare Edge → _middleware.ts
                              ├── Regular browser? → Pass to React app
                              └── Crawler (WhatsApp)?
                                   ├── Fetch speaker from Supabase
                                   ├── Inject meta tags in HTML
                                   └── Return modified HTML
```

## Files

- **`_middleware.ts`** - Main edge function (runs on every request)
- **`package.json`** - Dependencies (@supabase/supabase-js)
- **`node_modules/`** - Dependencies (gitignored, auto-installed by Cloudflare)

## Deployment

**Automatic!** Cloudflare Pages detects the `functions/` directory and deploys functions automatically.

No configuration needed. Functions run on every deploy.

## Local Development

Functions run on Cloudflare's edge, not locally. To test:

1. **Deploy to preview branch:**
   ```bash
   git push origin feature-branch
   ```

2. **Cloudflare creates preview:**
   ```
   https://abc123.georgetown-rotary.pages.dev
   ```

3. **Test with curl:**
   ```bash
   curl -H "User-Agent: WhatsApp/2.0" https://abc123.georgetown-rotary.pages.dev/speakers/[uuid]
   ```

4. **Check HTML output** for speaker name in `<meta property="og:title">`

## Performance

- **Edge execution:** <5ms overhead
- **Cached at edge:** Subsequent requests even faster
- **No impact on regular users:** Function only runs for crawlers

## Security

The function uses the Supabase **anon key** (public, read-only):
- ✅ Same key already in client-side code
- ✅ Row Level Security (RLS) protects data
- ✅ Cannot modify or delete data

## Monitoring

View function logs in Cloudflare Dashboard:
1. Go to Cloudflare Pages
2. Select Georgetown project
3. Click "Functions" tab
4. View real-time logs

## Troubleshooting

**Function not running?**
- Check `functions/` directory is committed to git
- Verify `_middleware.ts` has no syntax errors
- Check Cloudflare Functions tab for errors

**WhatsApp still shows "Private System"?**
- Clear WhatsApp cache (delete chat and re-share)
- Test with curl first to verify function works
- Check function logs for errors

**Performance issues?**
- Functions run on edge, should be <5ms
- Check Cloudflare Analytics for slow requests
- Consider caching speaker data

## Related Files

- `../src/utils/metaTags.ts` - Client-side meta tag updates
- `../src/routes/SpeakerDetailRoute.tsx` - Calls client-side updates
- `../index.html` - Default meta tags
- `../docs/adr/002-social-sharing-open-graph-limitations.md` - Architecture decision

## Future Enhancements

- Add caching layer (KV storage) for speaker data
- Support project URLs (`/projects/:id`)
- Add structured data (JSON-LD) for rich snippets
- A/B test different preview images
