# CTO Handoff: Social Meta Tags Implementation

**Date**: 2025-12-18
**From**: COO (Claude Console)
**To**: CTO (Claude Code)
**Priority**: Phase 1 (Pre-Customer Discovery)
**Estimated Effort**: 4-5 hours

---

## Executive Summary

Implement Open Graph, Twitter Cards, and China-optimized social meta tags to ensure professional link previews when Brandmine URLs are shared on social platforms. This directly supports the "stories attract, signals convert" model—every shared link becomes a mini pitch.

**Platforms Covered**:
- LinkedIn (primary B2B channel)
- Facebook
- Twitter/X
- WhatsApp
- Weibo (China)
- WeChat (fallback optimization only—no JSSDK)
- Slack, Discord, SMS previews

---

## Business Context

Without proper OG tags:
- Social platforms guess content, often incorrectly
- Images may be wrong or missing
- Links look unprofessional and untrustworthy

With proper OG tags:
- Controlled title, description, image
- Consistent appearance across platforms
- Every shared brand/founder profile becomes a credibility signal

**Strategic Note**: WeChat JSSDK integration (for full control) is deferred. It requires a WeChat Official Account and backend signature generation. Current implementation uses fallback optimization that works reasonably well without backend changes.

---

## Deliverables

| # | Deliverable | Location |
|---|-------------|----------|
| 1 | Social meta partial | `layouts/partials/head/social-meta.html` |
| 2 | Base template integration | `layouts/_default/baseof.html` |
| 3 | WeChat fallback image element | `layouts/_default/baseof.html` |
| 4 | Default OG image | `assets/images/brandmine-og-default.jpg` |
| 5 | Documentation update | `CLAUDE.md` (new section) |

---

## Technical Specifications

### Image Specifications

| Purpose | Dimensions | Format | Quality |
|---------|------------|--------|---------|
| Primary OG image | 1200×630px | JPG | 85% |
| Secondary OG image | 1200×630px | WebP | 85% |
| WeChat fallback | 400×400px | JPG | 80% |
| Default fallback | 1200×630px | JPG | 85% |

**Aspect Ratio Note**: Our hero images are 3:2 (per existing templates). Hugo's `.Fill "1200x630 Center"` crops to 1.91:1 from center. This is safe because our hero image templates already require "negative space for text overlay," keeping important content centered.

### Locale Mapping

```go-html-template
{{ $localeMap := dict "en" "en_US" "ru" "ru_RU" "zh" "zh_CN" }}
```

### Content-Type Logic

| Content Type | og:type | Title Pattern | Description Source | Image Source |
|--------------|---------|---------------|-------------------|--------------|
| Brand Profile | `website` | `{Brand} \| Brandmine` | `cardHook` or `description` | `heroImage` |
| Founder Profile | `profile` | `{Name} - {Role} \| Brandmine` | `description` | `image` (portrait) |
| Sector Deep Dive | `article` | As-is | `description` | `heroImage` |
| Insight Article | `article` | As-is | `summary` or `description` | `heroImage` |
| Taxonomy Page | `website` | `{Term} Brands \| Brandmine` | i18n string | Default |
| Homepage | `website` | Site title | Site description | Default |

---

## Implementation Details

### 1. Create Social Meta Partial

**File**: `layouts/partials/head/social-meta.html`

```go-html-template
{{/* ===========================================
    SOCIAL META TAGS
    Universal Open Graph + Twitter Cards + China Optimization
    
    Covers: LinkedIn, Facebook, Twitter, WhatsApp, Weibo, WeChat (fallback)
    
    Last Updated: 2025-12-18
    =========================================== */}}

{{/* --- LOCALE SETUP --- */}}
{{ $localeMap := dict "en" "en_US" "ru" "ru_RU" "zh" "zh_CN" }}
{{ $currentLocale := index $localeMap .Lang | default "en_US" }}

{{/* --- TITLE CONSTRUCTION --- */}}
{{ $ogTitle := .Title }}
{{ if eq .Section "brands" }}
  {{ $ogTitle = printf "%s | Brandmine" .Title }}
{{ else if eq .Section "founders" }}
  {{ with .Params.role }}
    {{ $ogTitle = printf "%s - %s | Brandmine" $.Title . }}
  {{ else }}
    {{ $ogTitle = printf "%s | Brandmine" $.Title }}
  {{ end }}
{{ else if .IsHome }}
  {{ $ogTitle = site.Title }}
{{ end }}

{{/* --- DESCRIPTION RESOLUTION --- */}}
{{ $ogDescription := "" }}
{{ if .Params.cardHook }}
  {{ $ogDescription = .Params.cardHook }}
{{ else if .Params.summary }}
  {{ $ogDescription = .Params.summary }}
{{ else if .Params.description }}
  {{ $ogDescription = .Params.description }}
{{ else if .Summary }}
  {{ $ogDescription = .Summary | plainify | truncate 160 }}
{{ else }}
  {{ $ogDescription = site.Params.description | default "Discover exceptional founder-led brands from emerging markets." }}
{{ end }}
{{ $ogDescription = $ogDescription | plainify | truncate 200 }}

{{/* --- IMAGE RESOLUTION --- */}}
{{ $ogImageJpg := false }}
{{ $ogImageWebp := false }}
{{ $imagePath := "" }}

{{/* Resolve image path based on content type */}}
{{ if .Params.heroImage }}
  {{/* Insights, Updates, Sector Deep Dives */}}
  {{ $slug := path.Base .File.Dir }}
  {{ $imagePath = printf "images/%s/%s/originals/%s" .Section $slug .Params.heroImage }}
{{ else if and (eq .Section "founders") .Params.image }}
  {{/* Founder portraits */}}
  {{ $founderSlug := path.Base .File.Dir }}
  {{ $imagePath = printf "images/founders/%s/originals/%s" $founderSlug .Params.image }}
{{ else if and (eq .Section "brands") .Params.heroImage }}
  {{/* Brand hero images */}}
  {{ $brandSlug := path.Base .File.Dir }}
  {{ $imagePath = printf "images/brands/%s/originals/%s" $brandSlug .Params.heroImage }}
{{ end }}

{{/* Process image if path found */}}
{{ if $imagePath }}
  {{ $sourceImage := resources.Get $imagePath }}
  {{ if $sourceImage }}
    {{ $ogImageJpg = $sourceImage.Fill "1200x630 Center jpg q85" }}
    {{ $ogImageWebp = $sourceImage.Fill "1200x630 Center webp q85" }}
  {{ end }}
{{ end }}

{{/* Fallback to site default */}}
{{ if not $ogImageJpg }}
  {{ $defaultImage := resources.Get "images/brandmine-og-default.jpg" }}
  {{ if $defaultImage }}
    {{ $ogImageJpg = $defaultImage }}
  {{ end }}
{{ end }}

{{/* --- CORE OPEN GRAPH TAGS --- */}}
<meta property="og:site_name" content="Brandmine">
<meta property="og:title" content="{{ $ogTitle }}">
<meta property="og:description" content="{{ $ogDescription }}">
<meta property="og:url" content="{{ .Permalink }}">
<meta property="og:type" content="{{ cond (or (eq .Section "insights") (eq .Section "updates")) "article" "website" }}">

{{/* --- LOCALE TAGS --- */}}
<meta property="og:locale" content="{{ $currentLocale }}">
{{ range .Translations }}
<meta property="og:locale:alternate" content="{{ index $localeMap .Lang }}">
{{ end }}

{{/* --- IMAGE TAGS --- */}}
{{ with $ogImageJpg }}
<meta property="og:image" content="{{ .Permalink }}">
<meta property="og:image:secure_url" content="{{ .Permalink }}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:type" content="image/jpeg">
<meta property="og:image:alt" content="{{ $ogTitle }}">
{{ end }}

{{/* Secondary WebP for WhatsApp and modern platforms */}}
{{ with $ogImageWebp }}
<meta property="og:image" content="{{ .Permalink }}">
<meta property="og:image:type" content="image/webp">
{{ end }}

{{/* --- TWITTER CARDS --- */}}
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{{ $ogTitle }}">
<meta name="twitter:description" content="{{ $ogDescription }}">
{{ with $ogImageJpg }}
<meta name="twitter:image" content="{{ .Permalink }}">
<meta name="twitter:image:alt" content="{{ $ogTitle }}">
{{ end }}

{{/* --- ARTICLE METADATA (for Insights/Updates) --- */}}
{{ if or (eq .Section "insights") (eq .Section "updates") }}
<meta property="article:published_time" content="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">
{{ with .Lastmod }}
<meta property="article:modified_time" content="{{ .Format "2006-01-02T15:04:05Z07:00" }}">
{{ end }}
<meta property="article:author" content="Brandmine Research Team">
{{ range .Params.sectors }}
<meta property="article:tag" content="{{ . }}">
{{ end }}
{{ range .Params.markets }}
<meta property="article:tag" content="{{ . }}">
{{ end }}
{{ end }}
```

### 2. Integrate into Base Template

**File**: `layouts/_default/baseof.html`

Add inside `<head>`, after existing meta tags but before CSS:

```go-html-template
{{/* Social Meta Tags */}}
{{ partial "head/social-meta.html" . }}
```

### 3. Add WeChat Fallback Image Element

**File**: `layouts/_default/baseof.html`

Add immediately after opening `<body>` tag:

```go-html-template
{{/* WeChat Fallback Image
     WeChat's crawler looks for the first large image (>300px) on the page.
     This hidden element ensures it finds our preferred image.
     400x400 works well for WeChat's circular chat thumbnails. */}}
{{ $wcImagePath := "" }}
{{ if .Params.heroImage }}
  {{ $slug := path.Base .File.Dir }}
  {{ $wcImagePath = printf "images/%s/%s/originals/%s" .Section $slug .Params.heroImage }}
{{ else if and (eq .Section "founders") .Params.image }}
  {{ $founderSlug := path.Base .File.Dir }}
  {{ $wcImagePath = printf "images/founders/%s/originals/%s" $founderSlug .Params.image }}
{{ else if and (eq .Section "brands") .Params.heroImage }}
  {{ $brandSlug := path.Base .File.Dir }}
  {{ $wcImagePath = printf "images/brands/%s/originals/%s" $brandSlug .Params.heroImage }}
{{ end }}
{{ if $wcImagePath }}
  {{ $wcSource := resources.Get $wcImagePath }}
  {{ if $wcSource }}
    {{ $wcImg := $wcSource.Fill "400x400 Center jpg q80" }}
    <img src="{{ $wcImg.Permalink }}" alt="" style="position:absolute;left:-9999px;width:1px;height:1px;" aria-hidden="true">
  {{ end }}
{{ end }}
```

### 4. Create Default OG Image

**File**: `assets/images/brandmine-og-default.jpg`

**Specifications**:
- Dimensions: 1200×630px
- Content: Brandmine logo centered, tagline below
- Background: Brand colors (Teal primary)
- No text that would be illegible at small sizes

**Generation**: CEO to create via ChatGPT image generation with prompt:

```
Create a professional Open Graph social sharing image for Brandmine.

Specifications:
- Dimensions: 1200x630 pixels (1.91:1 aspect ratio)
- Style: Clean, minimal, professional
- Background: Solid teal (#0D9488) or gradient from teal to darker teal
- Content: 
  - "Brandmine" wordmark centered (white text, clean sans-serif font)
  - Subtle tagline below: "Discover Exceptional Brands" (smaller, white/light)
  - Optional: Abstract geometric pattern or subtle texture
- No photography, no complex graphics
- Must be legible as a small thumbnail

This image will appear when Brandmine links are shared on LinkedIn, Facebook, Twitter, WhatsApp, etc.
```

### 5. Documentation Update

**File**: `CLAUDE.md`

Add new section after "Database (Supabase)" section:

```markdown
---

## Social Meta Tags (Open Graph)

### Overview

Brandmine implements Open Graph, Twitter Cards, and China-optimized meta tags for professional social sharing previews across LinkedIn, Facebook, Twitter, WhatsApp, Weibo, and WeChat.

### Implementation

**Partial**: `layouts/partials/head/social-meta.html`
**Fallback Image**: `layouts/_default/baseof.html` (hidden WeChat element)
**Default Image**: `assets/images/brandmine-og-default.jpg`

### Image Processing

Hugo automatically generates social images from hero images:

| Output | Dimensions | Format | Usage |
|--------|------------|--------|-------|
| Primary OG | 1200×630 | JPG | Facebook, LinkedIn, Weibo |
| Secondary OG | 1200×630 | WebP | WhatsApp, modern platforms |
| WeChat fallback | 400×400 | JPG | WeChat chat thumbnails |

**Source images**: Existing 3:2 hero images are center-cropped to 1.91:1.

### Content-Type Behavior

| Section | og:type | Title Pattern | Image Source |
|---------|---------|---------------|--------------|
| brands | website | `{Brand} \| Brandmine` | heroImage |
| founders | profile | `{Name} - {Role} \| Brandmine` | image (portrait) |
| insights | article | As-is | heroImage |
| updates | article | As-is | heroImage |
| taxonomy | website | `{Term} Brands \| Brandmine` | Default |
| homepage | website | Site title | Default |

### Locale Support

Trilingual locale tags automatically generated:
- English → `og:locale="en_US"`
- Russian → `og:locale="ru_RU"`
- Chinese → `og:locale="zh_CN"`

Alternate locales included for translated pages.

### WeChat Notes

Full WeChat JSSDK integration is not implemented (requires Official Account + backend). Current implementation uses fallback optimization:
- Hidden 400×400 image element for WeChat crawler
- Standard OG tags (WeChat partially respects these)
- Results are functional but not fully controllable

### Testing

Validate social previews with:
- [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/)
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- Manual WhatsApp/WeChat share tests
```

---

## Testing Checklist

### Pre-Deployment

- [ ] `hugo server` runs without errors
- [ ] View page source on sample pages, verify OG tags present
- [ ] Verify image URLs are absolute (full https:// paths)
- [ ] Check all content types: brand, founder, insight, update, taxonomy, homepage

### Post-Deployment

- [ ] Test brand profile URL in LinkedIn Post Inspector
- [ ] Test founder profile URL in LinkedIn Post Inspector
- [ ] Test insight article URL in LinkedIn Post Inspector
- [ ] Manual WhatsApp share test (any page)
- [ ] Manual WeChat share test (if accessible)
- [ ] Verify images display correctly (not cropped badly)

### Sample Test URLs

After deployment, test these representative pages:
```
https://brandmine.io/brands/[any-brand]/
https://brandmine.io/founders/[any-founder]/
https://brandmine.io/insights/[any-insight]/
https://brandmine.io/
https://brandmine.io/ru/brands/[any-brand]/
https://brandmine.io/zh/brands/[any-brand]/
```

---

## Acceptance Criteria

1. **OG tags render correctly** on all content types (brands, founders, insights, updates, taxonomy pages, homepage)

2. **Images process correctly** from existing hero images to 1200×630 OG format

3. **Trilingual support works** with correct locale tags and alternate locales

4. **LinkedIn Post Inspector** shows clean preview with correct title, description, image

5. **No build errors** or performance regression

6. **Documentation complete** in CLAUDE.md

---

## Out of Scope

The following are explicitly NOT part of this implementation:

- WeChat JSSDK integration (requires Official Account)
- Facebook App ID (`fb:app_id`)
- Custom OG images per page (uses existing hero images)
- Pinterest-specific tags
- Schema.org structured data (separate initiative)

---

## Questions / Clarifications

If any questions arise during implementation, the key constraints are:

1. **No backend changes** — Hugo static site only
2. **Use existing hero images** — no new image assets required except default fallback
3. **Center crop is acceptable** — our hero images have centered compositions
4. **WebP is supported** — modern platforms handle it well

---

## Sign-Off

**COO Review**: Strategic alignment confirmed. Implementation supports customer discovery phase by ensuring professional presentation on social channels.

**CEO Approval**: Proceed with implementation.

---

*Handoff document prepared by COO (Claude Console) — 2025-12-18*
