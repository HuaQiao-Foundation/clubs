# Telegram Link Preview Diagnostic Guide

**Issue**: Telegram shows speaker name but no clickable link
**Messages App**: Works correctly with full link

---

## Quick Diagnostic Checklist

### 1. ✅ Are you testing the deployed URL?

**Telegram CANNOT access localhost URLs**

- ❌ Won't work: `http://localhost:5180/speakers/...`
- ✅ Will work: `https://georgetown-rotary.pages.dev/speakers/...`

**Action**: Get your actual Cloudflare Pages URL and test with that.

---

### 2. ✅ Is the Cloudflare Function deployed?

Check Cloudflare Pages deployment logs for:
```
dist/functions/_middleware.js ✓
dist/functions/package.json ✓
```

**Action**: Verify latest deployment includes functions directory.

---

### 3. ✅ Is Telegram caching the old preview?

Telegram caches link previews **very aggressively** and doesn't refresh easily.

**How to clear Telegram cache**:

#### Option A: Use Telegram's Web Preview Tool
1. Go to: https://telegram.me/preview
2. Paste your speaker URL
3. See what Telegram's bot sees

#### Option B: Force refresh in Telegram app
1. Delete the message with the link
2. Clear Telegram cache (Settings → Data and Storage → Storage Usage → Clear Cache)
3. Restart Telegram
4. Share the link again

#### Option C: Test with different URL (add query param)
```
Original: https://georgetown-rotary.pages.dev/speakers/abc-123
Test with: https://georgetown-rotary.pages.dev/speakers/abc-123?v=2
```
The query parameter makes Telegram think it's a new URL.

---

### 4. ✅ Are the meta tags correct?

Test what the Cloudflare Function is actually serving:

```bash
# Simulate Telegram's bot
curl -H "User-Agent: TelegramBot" https://georgetown-rotary.pages.dev/speakers/YOUR_SPEAKER_ID | grep -A1 "og:url"
```

**Expected output**:
```html
<meta property="og:url" content="https://georgetown-rotary.pages.dev/speakers/YOUR_SPEAKER_ID" />
```

---

## Root Cause Analysis

### Why Messages App Works but Telegram Doesn't

**Messages App** (iMessage):
- Uses standard Open Graph tags
- No aggressive caching
- Shows the `og:url` as a clickable link

**Telegram**:
- Uses Open Graph tags BUT has special requirements
- Caches previews permanently on their servers
- Might need additional meta tags

---

## Telegram-Specific Requirements

Telegram looks for these meta tags (in priority order):

### Must Have
```html
<meta property="og:title" content="Speaker Name" />
<meta property="og:description" content="Topic or organization" />
<meta property="og:url" content="https://georgetown-rotary.pages.dev/speakers/abc-123" />
```

### Recommended
```html
<meta property="og:type" content="website" />
<meta property="og:image" content="https://example.com/image.jpg" />
<meta property="og:site_name" content="Georgetown Rotary" />
```

### Current Implementation Status
- ✅ og:title (line 114)
- ✅ og:description (line 118)
- ✅ og:url (line 122)
- ✅ og:image (line 137 - if available)
- ❌ og:type (MISSING)
- ❌ og:site_name (MISSING)

---

## Testing Workflow

### Step 1: Verify Deployment
```bash
# Get your Cloudflare Pages URL
# Go to Cloudflare Dashboard → Pages → georgetown-rotary → Deployments
# Copy the production URL (e.g., https://abc123.pages.dev)
```

### Step 2: Test with curl (Simulate Telegram)
```bash
# Replace with your actual URL
curl -H "User-Agent: TelegramBot" \
  https://georgetown-rotary.pages.dev/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3 \
  | grep -E "(og:title|og:url|og:description)"
```

**Expected output**:
```html
<meta property="og:title" content="[Speaker Name]" />
<meta property="og:description" content="[Topic]" />
<meta property="og:url" content="https://georgetown-rotary.pages.dev/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3" />
```

### Step 3: Test with Telegram Web Preview
1. Go to: https://telegram.me/preview
2. Paste your deployed URL
3. Check if link appears

### Step 4: Test in Telegram App
1. Clear Telegram cache
2. Share link in a private chat with yourself
3. Check preview

---

## Common Issues & Solutions

### Issue: "Link shows in Messages but not Telegram"

**Cause**: Telegram requires ALL required meta tags, Messages is more forgiving.

**Solution**: Ensure og:type and og:site_name are present.

---

### Issue: "Preview shows old/incorrect info"

**Cause**: Telegram's aggressive caching.

**Solution**:
1. Add query parameter: `?v=2`
2. Wait 24 hours for cache to expire
3. Use Telegram web preview tool to test

---

### Issue: "No preview at all"

**Cause**: One of:
- Testing localhost URL (Telegram can't access)
- Cloudflare Function not deployed
- Meta tags missing or malformed

**Solution**:
1. Verify using deployed URL
2. Check Cloudflare deployment logs
3. Test with curl to see actual HTML

---

### Issue: "Title shows but URL is not clickable"

**Cause**: This is the current issue. Possible reasons:
1. Telegram cache showing old version without og:url
2. og:url meta tag not in correct format
3. Missing og:type="website"

**Solution**:
1. Verify og:url is absolute URL (not relative)
2. Add og:type="website" meta tag
3. Clear Telegram cache and retest

---

## Recommended Fix

Add missing Telegram-required meta tags:

### File: `apps/georgetown/functions/_middleware.ts`

Add to `injectMetaTags` function around line 131:

```typescript
// Add og:type
modifiedHtml = modifiedHtml.replace(
  /<meta property="og:type" content="[^"]*" \/>/,
  `<meta property="og:type" content="website" />`
)

// Add og:site_name
modifiedHtml = modifiedHtml.replace(
  /<meta property="og:site_name" content="[^"]*" \/>/,
  `<meta property="og:site_name" content="Georgetown Rotary Club" />`
)
```

---

## Next Steps

1. **Get your deployed URL** from Cloudflare Pages
2. **Test with curl** to verify meta tags
3. **Test with Telegram web preview** tool
4. **If still not working**, add og:type and og:site_name tags
5. **Clear Telegram cache** and retest

---

## Reference Links

- Telegram Web Preview: https://telegram.me/preview
- Open Graph Protocol: https://ogp.me/
- Telegram Bot Documentation: https://core.telegram.org/bots/webapps#initializing-web-apps

---

**Status**: Ready for testing with deployed URL
**Next**: Verify with actual Cloudflare Pages URL, not localhost
