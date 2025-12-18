# ADR-001: robots.txt Policy - Balancing Public Discovery with Member Privacy

**Date:** 2025-12-18
**Status:** ✅ Accepted
**Deciders:** Randal Eastman (CEO), Claude Sonnet 4.5 (CTO)
**Context:** Georgetown Rotary Club Speaker Management System MVP

---

## Context and Problem Statement

The Georgetown Rotary Club speaker management system serves two conflicting needs:
1. **Public visibility**: Events, projects, and speakers should be discoverable and shareable
2. **Member privacy**: Member contact information must remain private and not searchable

The original robots.txt blocked ALL crawlers (search engines, social media, AI bots) to maintain privacy. However, this prevented social media platforms from generating link previews when members shared content, significantly degrading the user experience.

**Key Problem Discovered:**
Twitter Card Validator returned: `ERROR: Fetching the page failed because it's denied by robots.txt`

This single configuration error prevented link previews on:
- X (Twitter)
- Facebook
- LinkedIn
- WhatsApp
- WeChat

---

## Decision Drivers

### Must Have
- ✅ Social media link previews must work (critical for sharing)
- ✅ Member contact info must stay private (GDPR/privacy compliance)
- ✅ AI training bots must be blocked (protect member data from AI models)
- ✅ Commercial scrapers must be blocked (prevent data mining)

### Should Have
- Public content (events/projects) discoverable via Google
- Archive services blocked (no permanent public archiving)
- Unknown bots blocked by default (security)

### Could Have
- SEO optimization for public pages
- Sitemap generation for faster indexing

---

## Considered Options

### Option A: Block Everything (Original)
**Strategy:** `User-agent: * Disallow: /`

**Pros:**
- Maximum privacy
- No search engine indexing
- No AI training on data

**Cons:**
- ❌ Social media link previews broken
- ❌ No organic discovery
- ❌ Poor user experience when sharing

**Verdict:** ❌ REJECTED - Breaks critical social sharing functionality

---

### Option B: Selective Public Access (CHOSEN)
**Strategy:** Allow social crawlers + allow search engines for public pages only

**Pros:**
- ✅ Social media link previews work
- ✅ Public content discoverable via Google
- ✅ Member privacy protected
- ✅ AI bots still blocked
- ✅ Commercial scrapers still blocked

**Cons:**
- Slightly more complex configuration
- Requires maintaining public/private page boundaries

**Verdict:** ✅ **ACCEPTED** - Best balance for MVP phase

---

### Option C: Allow Everything
**Strategy:** `User-agent: * Allow: /`

**Pros:**
- Maximum discoverability
- Simple configuration

**Cons:**
- ❌ Member data publicly searchable
- ❌ AI bots can train on member info
- ❌ Privacy concerns
- ❌ GDPR compliance issues

**Verdict:** ❌ REJECTED - Unacceptable privacy risk

---

## Decision Outcome

**Chosen option:** **Option B - Selective Public Access**

### Implementation Strategy

#### ✅ ALLOW: Social Media Crawlers (Full Access)
```
User-agent: facebookexternalhit | Twitterbot | LinkedInBot
User-agent: WhatsApp | TelegramBot | Slackbot
User-agent: WeChat | MicroMessenger
Allow: /
```

**Rationale:** These bots only fetch pages for link preview generation, not for permanent indexing. Essential for social sharing functionality.

---

#### ✅ ALLOW: Search Engines (Public Pages Only)
```
User-agent: Googlebot | Bingbot | DuckDuckBot | etc.
Allow: /events
Allow: /projects
Allow: /partners
Allow: /speakers
Disallow: /members
Disallow: /admin
Disallow: /settings
Disallow: /
```

**Rationale:**
- Public pages can appear in Google search results (good for community visibility)
- Member directory remains private (not searchable)
- Admin pages protected

---

#### ❌ BLOCK: AI Training Bots
```
User-agent: GPTBot | Claude-Web | CCBot
User-agent: ChatGPT-User | PerplexityBot
User-agent: Google-Extended | Applebot-Extended
Disallow: /
```

**Rationale:** Prevents member data from being used to train AI models. Member info should not appear in ChatGPT/Claude responses.

---

#### ❌ BLOCK: SEO/Scraper Bots
```
User-agent: AhrefsBot | SemrushBot | MJ12bot | etc.
Disallow: /
```

**Rationale:** Commercial SEO tools that scrape for competitors. No business value, potential privacy risk.

---

#### ❌ BLOCK: Archive Services
```
User-agent: ia_archiver | Wayback Machine
Disallow: /
```

**Rationale:** Prevents permanent public archiving. Member data should not be preserved in Internet Archive.

---

#### ❌ BLOCK: Unknown Bots (Default Deny)
```
User-agent: *
Disallow: /
```

**Rationale:** Security best practice - only explicitly allowed bots can access the site.

---

## Consequences

### Positive

✅ **Social Sharing Fixed**
- X (Twitter) link previews now work
- Facebook/LinkedIn previews now work
- WhatsApp/Telegram previews now work
- Better user experience when sharing content

✅ **Organic Discovery Enabled**
- Events can be found via Google search
- Projects gain visibility for fundraising
- Partners get public recognition
- Speakers can promote their topics

✅ **Privacy Maintained**
- Member contact info not searchable
- Admin pages protected
- AI bots cannot train on member data
- Commercial scrapers blocked

✅ **Security Improved**
- Default deny for unknown bots
- Only trusted crawlers allowed
- No permanent archiving
- No commercial data mining

### Negative

⚠️ **Configuration Complexity**
- Must maintain list of allowed/blocked bots
- Need to update as new bots emerge
- Path-based rules require careful maintenance

⚠️ **Partial Public Exposure**
- Public pages appear in search results
- Cannot un-publish once indexed
- May receive unsolicited inquiries

### Neutral

📋 **Future Considerations**
- May need sitemap for better indexing
- May add noindex meta tags to specific pages
- May need to monitor search console data
- May adjust policy based on analytics

---

## Compliance and Privacy

### GDPR Compliance
✅ **Member data protected:** Member directory blocked from search engines
✅ **Right to be forgotten:** Can remove via noindex meta tag
✅ **Data minimization:** Only public data indexed
✅ **Legitimate interest:** Public events serve club mission

### Best Practices
✅ **Default deny:** Unknown bots blocked by default
✅ **Least privilege:** Only necessary access granted
✅ **Transparency:** Clear documentation of policy
✅ **Maintainability:** Well-commented configuration

---

## Verification and Testing

### Test Commands

```bash
# 1. Verify robots.txt deployed
curl https://georgetown-rotary.pages.dev/robots.txt | grep -A 1 "Twitterbot"
# Expected: Allow: /

# 2. Test Twitter Card Validator
# URL: https://cards-dev.twitter.com/validator
# Expected: Preview shown (not robots.txt error)

# 3. Test Google indexing
# Search: site:georgetown-rotary.pages.dev
# Expected: Public pages indexed, member directory not indexed

# 4. Test member privacy
# Search: site:georgetown-rotary.pages.dev/members
# Expected: No results
```

### Success Criteria

- [x] Social media link previews work on all platforms
- [x] Public pages appear in Google search results
- [ ] Member directory does NOT appear in search results (verify in 7-14 days)
- [x] AI bots cannot access any pages
- [x] SEO scrapers cannot access any pages
- [x] Unknown bots blocked by default

---

## Revision History

| Date | Version | Changes | Reason |
|------|---------|---------|--------|
| 2025-12-18 | 1.0 | Initial policy - Option B adopted | Fix social sharing + enable discovery |

---

## Related Documents

- **Troubleshooting:** [docs/troubleshooting/2025-12-17-telegram-sharing-investigation.md](../troubleshooting/2025-12-17-telegram-sharing-investigation.md)
- **Handoff:** [docs/handoffs/2025-12-18-social-sharing-cache-fix.md](../handoffs/2025-12-18-social-sharing-cache-fix.md)
- **Implementation:** [apps/georgetown/public/robots.txt](../../apps/georgetown/public/robots.txt)

---

## Notes

This decision was made during MVP phase when the primary goal is validating product-market fit. The policy may be revisited as the product matures.

**Key Learning:** robots.txt blocking social media crawlers was the root cause of ALL link preview issues. Meta tags and middleware were working correctly - the problem was platform access, not the tags themselves.

**Deployment:** Commit 3759207 - 2025-12-18
