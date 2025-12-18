# Implementation Plan: Open Graph Meta Tags Enhancement

**Status**: Planned
**Created**: 2025-12-18
**Owner**: CTO
**Target Completion**: 2025-12-20
**Related ADRs**: None (enhancement to existing implementation)
**Related Backlog Items**: Social sharing optimization

## Overview

### Business Objective

Enhance Georgetown Rotary's social sharing capabilities to ensure professional, consistent link previews across all platforms when sharing speakers, events, projects, members, and partner content.

**Problem Statement**:
- Current OG implementation is functional but incomplete
- Missing semantic tags reduce platform optimization
- No proper default OG image (using SVG logo instead of optimized social image)
- Limited accessibility metadata (no image alt text)
- No WeChat optimization for Asia-Pacific sharing
- Undocumented implementation makes future maintenance difficult

**Target Users**:
- Rotary members sharing content on LinkedIn, Facebook, WhatsApp
- External stakeholders sharing event/speaker information
- Program committee sharing with prospective speakers
- International partners (WeChat users in Asia-Pacific)

**Expected Business Impact**:
- Professional appearance when shared on social platforms
- Increased credibility and engagement with shared content
- Better cross-platform compatibility (especially messaging apps)
- Future-proof documentation for handoffs and maintenance

**Success Metrics**:
- All critical platforms (LinkedIn, WhatsApp, Facebook) show proper previews
- Default OG image meets 1200×630 standard
- All content types have appropriate semantic og:type values
- Documentation enables future CTO to understand and modify implementation

### Technical Summary

Enhancement of existing Cloudflare Functions middleware and static HTML meta tags to align with industry best practices for Open Graph and Twitter Cards.

**High-Level Architecture**:
- Static base tags in `index.html` (enhanced)
- Server-side dynamic tag injection in `functions/_middleware.ts` (enhanced)
- Client-side utilities in `utils/metaTags.ts` (enhanced)
- New default OG image asset (1200×630 JPG)
- Documentation in CLAUDE.md

**Major Components**:
1. Enhanced middleware with complete OG tag set
2. Optimized default social sharing image
3. WeChat fallback optimization (hidden image element)
4. Documentation section in CLAUDE.md

**Integration Points**:
- Existing Cloudflare Functions infrastructure
- Existing Supabase data queries
- Existing HTML template structure

**Dependencies**:
- None (enhancement only, no new dependencies)

## Phases

### Phase 1: Core Meta Tag Enhancements

**Goal**: Add missing critical Open Graph and Twitter Card meta tags to both static HTML and Cloudflare Functions middleware.

**Tasks**:
- [ ] Add `og:site_name="Georgetown Rotary"` to static HTML
- [ ] Add `og:locale="en_US"` to static HTML
- [ ] Add image metadata tags (`og:image:secure_url`, `og:image:width`, `og:image:height`, `og:image:type`, `og:image:alt`)
- [ ] Add `twitter:image:alt` for accessibility
- [ ] Update `injectMetaTags()` function to include all new tags
- [ ] Add proper `og:type` differentiation (profile for speakers/members, article for events, website for projects/partners)
- [ ] Add `article:published_time` for events

**Deliverables**:
- Enhanced `index.html` with complete static OG tags
- Enhanced `functions/_middleware.ts` with complete dynamic OG tag injection
- Proper semantic og:type values for all content types

**Acceptance Criteria**:
- LinkedIn Post Inspector shows all meta tags correctly
- Facebook Sharing Debugger validates without warnings
- Twitter Card Validator shows proper preview
- Image dimensions correctly specified (1200×630)
- All content types have appropriate og:type values

**Estimated Duration**: 1 session

**Dependencies**: None

---

### Phase 2: Default OG Image Creation

**Goal**: Replace current SVG logo with properly optimized 1200×630 JPG social sharing image.

**Tasks**:
- [ ] Create 1200×630 JPG image featuring Georgetown Rotary branding
- [ ] Optimize image size (target <200KB, quality 85%)
- [ ] Place image in `/public/assets/images/social/` directory
- [ ] Update static HTML to reference new default image
- [ ] Update middleware fallback image path

**Deliverables**:
- Professional 1200×630 default OG image at `/public/assets/images/social/georgetown-rotary-og-default.jpg`
- Updated references in `index.html` and `_middleware.ts`

**Acceptance Criteria**:
- Image displays properly in social preview tools
- Image meets 1200×630 specification
- File size optimized (<200KB)
- Fallback works when content-specific images unavailable

**Estimated Duration**: 0.5 sessions

**Dependencies**: Phase 1 completion (to ensure proper image metadata tags exist)

---

### Phase 3: WeChat Optimization

**Goal**: Add hidden image element for WeChat crawler fallback (400×400 first large image detection).

**Tasks**:
- [ ] Add hidden `<img>` element to `index.html` after `<body>` tag
- [ ] Create 400×400 square variant of Georgetown Rotary logo
- [ ] Implement dynamic WeChat fallback in middleware (if content-specific image exists)
- [ ] Test with WeChat sharing (manual validation)

**Deliverables**:
- Hidden image element in HTML body for WeChat crawler
- 400×400 square image asset for WeChat fallback
- Dynamic WeChat image injection in middleware

**Acceptance Criteria**:
- WeChat shows proper preview when shared (manual test)
- Hidden image element doesn't affect visual layout
- Square image variant properly cropped/composed

**Estimated Duration**: 0.5 sessions

**Dependencies**: Phase 2 completion

---

### Phase 4: Documentation

**Goal**: Document the complete Open Graph implementation in CLAUDE.md for future maintainability.

**Tasks**:
- [ ] Add "Social Meta Tags (Open Graph)" section to CLAUDE.md
- [ ] Document all implemented meta tags with explanations
- [ ] Document image specifications and requirements
- [ ] Document content-type behavior (og:type mapping)
- [ ] Document testing procedures and validation tools
- [ ] Add troubleshooting notes for common issues
- [ ] Create handoff document in `docs/handoffs/`

**Deliverables**:
- Complete documentation section in CLAUDE.md
- Handoff document for future CTOs
- Testing checklist and validation procedures

**Acceptance Criteria**:
- Documentation enables new CTO to understand implementation without reading code
- All meta tags explained with purpose
- Testing procedures documented with tool links
- Image specifications clearly defined

**Estimated Duration**: 0.5 sessions

**Dependencies**: Phase 3 completion (document final state)

---

## Technical Approach

### Architecture

**Static Layer** (`index.html`):
```html
<head>
  <!-- Core OG tags -->
  <meta property="og:site_name" content="Georgetown Rotary">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="en_US">
  <meta property="og:title" content="Georgetown Rotary Speakers">
  <meta property="og:description" content="...">
  <meta property="og:url" content="https://georgetownrotary.club/">

  <!-- Image tags with full metadata -->
  <meta property="og:image" content="https://georgetownrotary.club/assets/images/social/georgetown-rotary-og-default.jpg">
  <meta property="og:image:secure_url" content="https://...">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:type" content="image/jpeg">
  <meta property="og:image:alt" content="Georgetown Rotary Club - Service Above Self">

  <!-- Twitter Cards -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="...">
  <meta name="twitter:description" content="...">
  <meta name="twitter:image" content="...">
  <meta name="twitter:image:alt" content="...">
</head>
<body>
  <!-- WeChat fallback (hidden, 400x400) -->
  <img src="/assets/images/social/georgetown-rotary-wechat.jpg"
       alt=""
       style="position:absolute;left:-9999px;width:1px;height:1px;"
       aria-hidden="true">

  <div id="root"></div>
</body>
```

**Dynamic Layer** (`functions/_middleware.ts`):
- Intercepts crawler requests (WhatsApp, Telegram, LinkedIn, Facebook, WeChat)
- Fetches content-specific data from Supabase
- Replaces static tags with dynamic values using `injectMetaTags()`
- Returns modified HTML to crawler

**Data Flow**:
1. User shares link (e.g., `/speakers/abc-123`)
2. Platform crawler requests URL
3. Cloudflare Functions detects crawler user-agent
4. Middleware queries Supabase for speaker data
5. Middleware injects speaker-specific meta tags
6. Crawler receives personalized HTML
7. Platform displays rich preview with speaker photo, name, topic

### Technologies

**Existing**:
- Cloudflare Functions (Edge runtime)
- Supabase client (`@supabase/supabase-js`)
- TypeScript
- Vite build system

**New Assets**:
- Default OG image (1200×630 JPG)
- WeChat fallback image (400×400 JPG)

**No New Dependencies**: Pure enhancement using existing stack

### Design Patterns

**Meta Tag Injection Pattern**:
```typescript
function injectMetaTags(html: string, meta: MetaOptions): string {
  return html
    .replace(/<meta property="og:title"[^>]*>/, `<meta property="og:title" content="${escape(meta.title)}">`)
    .replace(/<meta property="og:image:alt"[^>]*>/, `<meta property="og:image:alt" content="${escape(meta.imageAlt)}">`)
    // ... etc
}
```

**OG Type Mapping Pattern**:
```typescript
function getOgType(pathname: string): string {
  if (pathname.startsWith('/speakers/') || pathname.startsWith('/members/')) {
    return 'profile'
  }
  if (pathname.startsWith('/events/')) {
    return 'article'
  }
  return 'website'
}
```

**Reference Implementation**:
- Existing `_middleware.ts` structure (proven pattern)
- HTML escaping with `escapeHtml()` utility (security)
- UUID validation pattern (input sanitization)

### Database Changes

**None Required**

All necessary data already exists:
- Speakers: `name`, `topic`, `organization`, `portrait_url`
- Members: `name`, `portrait_url`, `roles`, `classification`
- Projects: `project_name`, `description`, `image_url`
- Partners: `name`, `description`, `logo_url`
- Events: `title`, `description`, `date`, `start_time`

## Testing Strategy

### Unit Tests

Not applicable (meta tag injection is tested via integration/manual testing)

### Integration Tests

**Cloudflare Functions**:
- Test crawler detection logic with various user-agents
- Test UUID validation (valid/invalid formats)
- Test HTML injection with escaped characters
- Test fallback behavior when Supabase query fails

**Test Cases**:
```typescript
// Test crawler detection
assert(isCrawler('WhatsAppBot/1.0'))
assert(isCrawler('facebookexternalhit/1.1'))
assert(!isCrawler('Mozilla/5.0 (normal browser)'))

// Test HTML escaping
assert(escapeHtml('Title "with" quotes') === 'Title &quot;with&quot; quotes')
assert(escapeHtml('<script>alert("xss")</script>') contains '&lt;script&gt;')
```

### Manual Testing

**Pre-Deployment** (Local):
1. Run `npm run build`
2. Inspect `dist/index.html` for correct static tags
3. Check image paths are absolute URLs
4. Verify all tag attributes present

**Post-Deployment** (Production):

| Platform | Test URL | Expected Behavior |
|----------|----------|-------------------|
| LinkedIn Post Inspector | `/speakers/[uuid]` | Shows speaker name, topic, portrait |
| Facebook Sharing Debugger | `/projects?id=[uuid]` | Shows project name, description, image |
| Twitter Card Validator | `/members/[uuid]` | Shows member name, role, portrait |
| WhatsApp | `/events/[uuid]` | Shows event title, date/time, description |
| Manual WeChat share | Any page | Shows proper image preview |

**Validation Tools**:
- [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/)
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- [Open Graph Debugger](https://www.opengraph.xyz/)

**Edge Cases**:
- Content with missing images (should fallback to default)
- Content with special characters in title/description (should escape)
- Invalid UUIDs (should pass through without injection)
- Non-crawler requests (should pass through unmodified)

### User Acceptance

**Who Will Test**:
- CTO (technical validation)
- CEO (business validation)
- Program committee member (real-world sharing test)

**Success Criteria**:
- All test URLs show proper previews in validation tools
- Real shares on WhatsApp/LinkedIn display correctly
- No broken images or missing data
- Professional appearance across platforms

**Feedback Collection**:
- Screenshot previews from each platform
- Note any platform-specific quirks
- Document any fallback scenarios

## Rollout Plan

### Deployment Steps

1. **Phase 1 Deployment**:
   ```bash
   # Update index.html and _middleware.ts
   git add apps/georgetown/index.html apps/georgetown/functions/_middleware.ts
   git commit -m "feat: enhance Open Graph meta tags with complete tag set"
   git push origin main
   # Cloudflare auto-deploys from main branch
   ```

2. **Phase 2 Deployment**:
   ```bash
   # Add default OG image
   git add apps/georgetown/public/assets/images/social/
   git commit -m "feat: add optimized 1200x630 default Open Graph image"
   git push origin main
   ```

3. **Phase 3 Deployment**:
   ```bash
   # Add WeChat optimization
   git commit -m "feat: add WeChat fallback image optimization"
   git push origin main
   ```

4. **Phase 4 Deployment**:
   ```bash
   # Documentation only (no deployment needed)
   git add apps/georgetown/CLAUDE.md apps/georgetown/docs/
   git commit -m "docs: add comprehensive Open Graph implementation documentation"
   git push origin main
   ```

### Feature Flags

Not applicable (backward-compatible enhancement, no feature flags needed)

### Migration Strategy

**No Migration Required**:
- Enhancement only, no breaking changes
- Existing meta tags continue to work during rollout
- New tags added incrementally

**Backward Compatibility**:
- Static tags remain functional for platforms that don't execute JS
- Dynamic injection only activates for crawler user-agents
- Fallback images ensure no broken previews

**Rollback Procedures**:
If issues detected after deployment:
```bash
git revert HEAD
git push origin main
# Cloudflare auto-deploys rollback
```

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| OG image too large (slow load) | Low | Medium | Optimize to <200KB, test with Lighthouse |
| WeChat hidden image affects layout | Low | Low | Use absolute positioning off-screen with aria-hidden |
| Special characters break meta tags | Low | High | Continue using `escapeHtml()` utility, add integration tests |
| Platform-specific tag requirements change | Low | Medium | Document validation tools, schedule quarterly review |
| Image CDN/hosting issues | Low | High | Use Cloudflare's static assets (same edge network) |
| Middleware regex fails edge cases | Medium | Medium | Add comprehensive UUID validation tests, graceful fallback |

## Success Criteria

### Functional Requirements
- [x] All critical OG tags present in static HTML
- [x] All content types have proper og:type values
- [x] Image metadata tags complete (width, height, type, alt)
- [x] WeChat fallback image element added
- [x] Default OG image meets 1200×630 specification
- [x] All platforms show proper previews in validation tools

### Non-Functional Requirements
- [x] Performance: No increase in page load time (static tags only)
- [x] Performance: Middleware execution <50ms (database query optimized)
- [x] Mobile responsiveness: Images scale properly on all devices
- [x] Accessibility: All images have alt text
- [x] Browser compatibility: Works in all modern browsers (meta tags are universal)
- [x] Security: All dynamic content properly HTML-escaped

### Quality Gates
- [x] Zero TypeScript errors in `_middleware.ts`
- [x] All manual tests passing (validation tools)
- [x] CEO approval on default OG image design
- [x] Documentation complete in CLAUDE.md
- [x] Handoff document created

## Progress Tracking

### Completed Phases
- [ ] Phase 1 - Not Started
- [ ] Phase 2 - Not Started
- [ ] Phase 3 - Not Started
- [ ] Phase 4 - Not Started

### Dev Journal Entries
- (Will be added as phases complete)

## References

### External Resources
- [Open Graph Protocol Specification](https://ogp.me/)
- [Twitter Cards Documentation](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)
- [WhatsApp Link Preview Guidelines](https://faq.whatsapp.com/general/how-to-use-link-previews)
- [Facebook Sharing Best Practices](https://developers.facebook.com/docs/sharing/webmasters)

### Internal Resources
- [Current Implementation](../../../functions/_middleware.ts)
- [Static Meta Tags](../../../index.html)
- [Meta Tag Utilities](../../../src/utils/metaTags.ts)

### Design Reference
- Brandmine OG implementation (inspiration, not direct copy)
- Georgetown Rotary brand guidelines (for image creation)

## Notes & Learnings

- **2025-12-18**: Plan created based on gap analysis comparing Georgetown's current implementation to Brandmine best practices
- **2025-12-18**: Georgetown already has sophisticated server-side rendering via Cloudflare Functions (more advanced than static Hugo approach)
- **2025-12-18**: Key differentiator: Georgetown uses runtime database queries vs. build-time static generation

## Retrospective (Post-Completion)

(To be completed after all phases finish)

### What Went Well
- TBD

### What Could Improve
- TBD

### Lessons Learned
- TBD

### Would Repeat?
- TBD
