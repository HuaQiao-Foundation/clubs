# ADR 002: Social Sharing & Open Graph Limitations for SPAs

**Status:** Active
**Date:** 2025-12-17
**Decision:** Use dynamic meta tags with acknowledged limitations; SSR/prerendering deferred

## Context

Georgetown Rotary uses a Single Page Application (SPA) built with React + Vite. When users share speaker links (e.g., `/speakers/abc-123`) via messaging apps, the preview shows "Private System" instead of the speaker's name.

**Root Cause:** Static HTML meta tags in `index.html` set for privacy:
```html
<meta property="og:title" content="Private System" />
```

**Problem:** Messaging apps don't execute JavaScript, so they can't see dynamically updated meta tags.

## Decision

Implement **dynamic meta tag updates** with clear documentation of limitations:

1. ✅ **Works for:** Twitter, LinkedIn, Facebook crawler (they execute JavaScript)
2. ❌ **Doesn't work for:** WhatsApp, Telegram, iMessage, Slack (static HTML only)
3. 📋 **Future solution:** Server-Side Rendering (SSR) or prerendering when needed

## Implementation

### Phase 1: Dynamic Meta Tags (Current)

**File:** `src/utils/metaTags.ts`

```typescript
export function updateMetaTags(options: MetaTagOptions): void {
  document.title = `${title} - Georgetown Rotary`
  updateMetaTag('og:title', title, 'property')
  updateMetaTag('og:description', description, 'property')
  // ... etc
}
```

**Usage:** Called when speaker route loads

```typescript
// SpeakerDetailRoute.tsx
setSpeaker(data)
const metaTags = getSpeakerMetaTags(data)
updateMetaTags(metaTags)
```

### Phase 2: SSR/Prerendering (Future)

**Options considered:**

| Solution | Pros | Cons | Cost |
|----------|------|------|------|
| **Vite SSR** | Full control, fast | Complex setup, requires Node server | Dev time |
| **Cloudflare Pages + Edge SSR** | Serverless, CDN-backed | CF Pages doesn't support full SSR yet | None |
| **Prerender.io** | Works with existing deployment | External dependency, $$ | $39/month |
| **Netlify Prerendering** | Automatic, easy setup | Requires Netlify (we use CF Pages) | None on Netlify |
| **Static prerendering (vite-plugin-ssr)** | Works with CF Pages | Need to pre-generate all speaker URLs | Dev time |

**Recommendation:** Wait until SSR/prerendering becomes a business requirement (e.g., external recruiting, public speaker bureau marketing).

## Consequences

### Positive

- ✅ Links work correctly (hybrid routing)
- ✅ Browser sharing shows correct info (for JS-enabled platforms)
- ✅ SEO improves (Google executes JavaScript)
- ✅ Twitter/LinkedIn/Facebook show speaker names

### Negative

- ❌ WhatsApp/Telegram/iMessage still show "Private System"
- ❌ Slack link previews won't show speaker details
- ❌ Requires SSR/prerendering for complete solution

### Neutral

- 📋 Documented limitation for stakeholders
- 📋 Future migration path identified
- 📋 Can implement SSR when business need justifies investment

## Workarounds

For now, users can:

1. **Share with context:** "Check out Dr. Baskaran Gobala: [link]"
2. **Use Twitter/LinkedIn:** These platforms execute JS and show correct previews
3. **Screenshot and share:** Take screenshot of modal, share image + link

## When to Implement SSR

Implement when:
- External recruiting becomes priority
- Public speaker bureau launches
- Messaging app previews become critical for adoption
- Team spends >2 hours/month explaining workarounds

**Trigger metric:** If >10% of shared links require manual context, implement SSR.

## Related Files

- `index.html` - Static "Private System" meta tags
- `src/utils/metaTags.ts` - Dynamic meta tag updates
- `src/routes/SpeakerDetailRoute.tsx` - Calls updateMetaTags()
- `apps/georgetown/docs/adr/002-social-sharing-open-graph-limitations.md` - This document

## References

- [Open Graph Protocol](https://ogp.me/)
- [WhatsApp Link Preview](https://faq.whatsapp.com/general/how-to-link-previews-work)
- [Vite SSR Guide](https://vitejs.dev/guide/ssr.html)
- [Cloudflare Pages Functions](https://developers.cloudflare.com/pages/platform/functions/)

## Update Log

- **2025-12-17:** Initial decision - dynamic meta tags with limitations
- **Future:** Will update when SSR implemented
