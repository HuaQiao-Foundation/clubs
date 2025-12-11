# Search Engine & AI Bot Blocking Configuration

## Overview
Pitchmasters is a **PRIVATE INTERNAL TOOL** for Toastmasters club members only. This system contains confidential member data and proprietary club information that must not be indexed by search engines or accessed by AI training bots.

## Implementation Layers

### 1. robots.txt (Primary Defense)
**Location**: `/public/robots.txt`

Blocks all crawlers with explicit rules for:
- Major search engines (Google, Bing, DuckDuckGo, Baidu, Yandex)
- Social media crawlers (Facebook, Twitter, LinkedIn)
- AI/ML training bots (GPTBot, Claude, Anthropic, CCBot, Perplexity)
- SEO tools (Ahrefs, Semrush)
- Archive services (Internet Archive, Wayback Machine)

### 2. HTML Meta Tags (Secondary Defense)
**Location**: `/index.html`

Meta tags that instruct browsers and crawlers:
```html
<meta name="robots" content="noindex, nofollow, noarchive, nosnippet, noimageindex, nocache">
<meta name="googlebot" content="noindex, nofollow, noarchive, nosnippet, noimageindex">
<meta name="gptbot" content="noindex, nofollow">
```

### 3. HTTP Headers (Cloudflare Pages)
**Location**: `/public/_headers`

Server-level headers for Cloudflare Pages:
- `X-Robots-Tag`: Prevents indexing at HTTP level
- `Cache-Control`: Private, no-cache directives
- Security headers (X-Frame-Options, CSP)

### 4. Apache Configuration (Fallback)
**Location**: `/public/.htaccess`

For Apache servers (if ever needed):
- Blocks user agents via mod_rewrite
- Returns 403 Forbidden to bots
- Sets privacy headers

## Verification Methods

### Test robots.txt
```bash
# Check if robots.txt is accessible
curl https://your-domain.com/robots.txt

# Verify it shows "Disallow: /"
```

### Test Meta Tags
```bash
# Check HTML headers
curl -I https://your-domain.com

# Look for X-Robots-Tag header
```

### Google Search Console
1. Submit site to Google Search Console
2. Use URL Inspection tool
3. Verify "Indexing: Blocked by robots.txt"

### Online Tools
- [Google robots.txt Tester](https://www.google.com/webmasters/tools/robots-testing-tool)
- [SEO Site Checkup](https://seositecheckup.com/tools/robots-txt-test)
- [Screaming Frog SEO Spider](https://www.screamingfrog.co.uk/seo-spider/) (check crawlability)

## Authentication Layer
In addition to blocking crawlers, the application requires:
1. Supabase authentication for access
2. Member-only data protected by RLS
3. No public-facing content without login

## Maintenance Checklist

### Monthly Review
- [ ] Verify robots.txt is being served correctly
- [ ] Check server logs for unauthorized bot access
- [ ] Review new AI crawlers to add to blocklist
- [ ] Test with online robots.txt validators

### Quarterly Audit
- [ ] Search Google/Bing for "site:your-domain.com"
- [ ] Should return: "No results found"
- [ ] Check Internet Archive for any cached pages
- [ ] Review access logs for crawler patterns

## Emergency Response

### If Site Gets Indexed
1. **Immediate Actions**:
   - Verify robots.txt is properly configured
   - Check HTTP headers are being sent
   - Add authentication requirement if not present

2. **Request Removal**:
   - [Google URL Removal Tool](https://search.google.com/search-console/remove-outdated-content)
   - [Bing Content Removal Tool](https://www.bing.com/webmasters/tools/contentremoval)
   - Contact other search engines directly

3. **Strengthen Protection**:
   - Implement IP-based blocking for known bot IPs
   - Add CAPTCHA for suspicious access patterns
   - Consider password protection at server level

## Important Notes

1. **No Sitemap**: Never create or submit a sitemap.xml
2. **No Social Sharing**: Avoid meta tags for social media (og:, twitter:)
3. **No Public Links**: Never link to this system from public websites
4. **Access Control**: Always require authentication for all pages
5. **Regular Audits**: Check search engines monthly for accidental indexing

## Cloudflare Specific Settings

When deploying to Cloudflare Pages:

1. **Page Rules**:
   ```
   URL: /*
   Setting: Cache Level = Bypass
   Setting: Security Level = High
   ```

2. **Firewall Rules**:
   - Block known bot user agents
   - Challenge suspicious traffic
   - Rate limit aggressive crawlers

3. **Transform Rules**:
   - Add X-Robots-Tag header to all responses
   - Strip any cache headers that might override privacy

## Compliance & Legal

This configuration helps meet:
- GDPR requirements for data privacy
- Toastmasters International data protection policies
- Member confidentiality agreements
- Internal tool usage guidelines

---

**Last Updated**: September 29, 2025
**Maintained by**: Claude Code (CTO)
**Status**: ACTIVE - All blocking measures in place