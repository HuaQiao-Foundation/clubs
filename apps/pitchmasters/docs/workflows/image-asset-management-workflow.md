# Image & Asset Management Workflow

**Purpose**: Operational procedures for managing images and assets in Pitchmasters platform
**For**: Club officers, content administrators, developers
**Reference**: [toastmasters-brand-guide.md](../toastmasters-brand-guide.md) for brand standards

---

## Asset Folder Structure

```
public/
├── assets/
│   ├── images/
│   │   ├── logos/          # Official Toastmasters logos ONLY
│   │   ├── icons/          # Favicons and app icons
│   │   └── backgrounds/    # Background images
│   ├── fonts/              # Self-hosted Montserrat and Source Sans 3
│   └── documents/          # PDFs, guides, etc.
├── favicon.svg             # Main adaptive favicon
└── manifest.json          # PWA configuration
```

---

## Adding/Updating Assets

### 1. Official Toastmasters Logos

**Process**:
1. Download ONLY from: [toastmasters.org/Logos](https://toastmasters.org/Logos)
2. Place in: `/public/assets/images/logos/`
3. Use original filename to maintain traceability
4. **NEVER modify** the downloaded files

**Quality Check**:
- [ ] Downloaded from official Toastmasters source
- [ ] Placed in correct directory (`/logos/`)
- [ ] Original filename preserved
- [ ] No modifications made to file

---

### 2. Content Images (Non-Brand)

**Process**:
1. Choose appropriate folder based on image type:
   - **Backgrounds**: `/public/assets/images/backgrounds/`
   - **Icons**: `/public/assets/images/icons/`
2. Use descriptive, lowercase filenames: `startup-pitch-presentation.jpg`
3. Follow file naming conventions (see below)
4. Ensure content aligns with Toastmasters photography guidelines

**Maximum Sizes**:
- Photos: 1920x1080px
- Icons: As needed (typically 512x512px for app icons)
- Backgrounds: 1920x1080px

**Quality Check**:
- [ ] Placed in correct folder
- [ ] Descriptive filename with hyphens
- [ ] Appropriate size (not oversized)
- [ ] Content aligns with brand guidelines

---

### 3. Self-Hosted Fonts

**Process**:
1. Place font files in: `/public/assets/fonts/`
2. Use WOFF2 (primary) and WOFF (fallback) formats
3. Update CSS with `@font-face` declarations
4. Test font loading with fallbacks

**Required Fonts**:
- Montserrat (headlines, navigation)
- Source Sans 3 (body text)

**Quality Check**:
- [ ] WOFF2 and WOFF formats included
- [ ] Placed in `/public/assets/fonts/`
- [ ] CSS @font-face declarations updated
- [ ] Fallback fonts specified
- [ ] No CDN dependencies (China-friendly)

---

## File Naming Conventions

### Standard Format

**Pattern**: `lowercase-with-hyphens-description.ext`

**Examples**:
- ✅ `toastmasters-meeting-room.jpg`
- ✅ `founder-networking-event.jpg`
- ✅ `speech-contest-presentation.jpg`
- ✅ `club-charter-materials-2025.pdf`
- ❌ `Meeting Room.jpg` (spaces, uppercase)
- ❌ `founder_networking.jpg` (underscores)
- ❌ `IMG_1234.jpg` (non-descriptive)

### Guidelines

- **Use lowercase only**: All characters lowercase
- **Hyphens for spaces**: Replace spaces with hyphens
- **Be descriptive**: Name should indicate content
- **Include dates for versions**: `materials-2025.pdf`
- **No special characters**: Only letters, numbers, hyphens

---

## Using Images in Code

### Correct Implementation

```jsx
// Official Toastmasters logo
<img
  src="/assets/images/logos/toastmasters-logo.svg"
  alt="Toastmasters International"
  style={{ minWidth: '72px' }}
/>

// Content images
<img
  src="/assets/images/backgrounds/startup-meeting.jpg"
  alt="Startup founders in meeting"
/>

// Icons
<img
  src="/assets/images/icons/app-icon-192.png"
  alt="Pitchmasters app icon"
/>
```

### Required Attributes

- **src**: Absolute path from `/public/`
- **alt**: Descriptive alternative text
- **style/className**: Size constraints for logos (min 72px)

### Brand Asset Protection

**✅ Required for Toastmasters Logos**:
- Use original files exactly as downloaded
- Maintain minimum size (72px web, 3/4" print)
- Include proper alt text
- Preserve clear space around logo

**❌ Forbidden for Toastmasters Logos**:
- Modifying, compressing, or optimizing brand assets
- Changing colors, proportions, or design
- Adding effects, shadows, or overlays
- Custom interpretations or variations

---

## Typography Implementation

### Font Reference in Code

```css
/* Headlines */
font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, sans-serif;

/* Body Text */
font-family: 'Source Sans 3', -apple-system, BlinkMacSystemFont, sans-serif;
```

### Loading Strategy

1. **Preload critical fonts** in HTML `<head>`:
   ```html
   <link rel="preload" href="/assets/fonts/montserrat-bold.woff2" as="font" type="font/woff2" crossorigin>
   <link rel="preload" href="/assets/fonts/source-sans-3-regular.woff2" as="font" type="font/woff2" crossorigin>
   ```

2. **Define @font-face** in CSS:
   ```css
   @font-face {
     font-family: 'Montserrat';
     src: url('/assets/fonts/montserrat-bold.woff2') format('woff2'),
          url('/assets/fonts/montserrat-bold.woff') format('woff');
     font-weight: 700;
     font-display: swap;
   }
   ```

3. **Specify fallbacks**: Always include system font stack

---

## Favicon Management

### Toastmasters-Compliant Favicon

**Requirements**:
- Use official Toastmasters Mark of Excellence
- Light mode: Official Toastmasters blue (#004165)
- Dark mode: Official white/reverse version
- SVG format (adaptive to color scheme)

**Implementation**:
```html
<!-- In index.html -->
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/assets/images/icons/apple-touch-icon.png">
```

**Files Needed**:
- `/public/favicon.svg` (main adaptive favicon)
- `/public/assets/images/icons/apple-touch-icon.png` (180x180px)
- `/public/assets/images/icons/favicon-*.png` (various sizes)

---

## Testing & Verification

### Brand Compliance Testing

**Visual Comparison**:
1. Open reference Toastmasters materials
2. Compare logo appearance side-by-side
3. Verify colors match official palette
4. Check minimum size requirements (72px)
5. Confirm clear space around logos

**Color Accuracy**:
```bash
# Use browser DevTools to inspect colors
# Expected values:
# Loyal Blue: #004165
# True Maroon: #772432
# Cool Gray: #A9B2B1
```

**Size Requirements**:
- Logos must be minimum 72px on web
- Check with browser DevTools or design tools

### Performance Testing

**Network Tab**:
1. Open browser DevTools → Network
2. Reload page
3. Check image loading times
4. Verify self-hosted fonts load correctly

**Mobile Testing**:
1. Test on mobile devices (320px-414px)
2. Verify touch targets (44px minimum)
3. Check responsive image behavior
4. Test on 3G network simulation

**Font Loading**:
1. Disable cache in DevTools
2. Reload page
3. Verify fonts load without flashing
4. Check fallback fonts display correctly

**Accessibility**:
1. Use axe DevTools or WAVE
2. Verify alt text on all images
3. Check color contrast ratios (WCAG 2.1 AA)
4. Test with screen readers

---

## Troubleshooting

### Logo Not Displaying

**Check**:
- [ ] File downloaded from official Toastmasters source
- [ ] Filename spelling and path accuracy
- [ ] Browser supports SVG format
- [ ] No file permission issues

**Solution**:
```bash
# Verify file exists
ls -la public/assets/images/logos/

# Check file permissions
chmod 644 public/assets/images/logos/*.svg
```

---

### Font Loading Problems

**Check**:
- [ ] WOFF2/WOFF files in `/public/assets/fonts/`
- [ ] @font-face declarations in CSS correct
- [ ] Font file paths are absolute from `/public/`
- [ ] Fallback fonts specified

**Solution**:
```css
/* Verify font-face declaration */
@font-face {
  font-family: 'Montserrat';
  src: url('/assets/fonts/montserrat-bold.woff2') format('woff2'),
       url('/assets/fonts/montserrat-bold.woff') format('woff');
  font-weight: 700;
  font-display: swap;
}

/* Check font reference */
font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, sans-serif;
```

---

### Brand Compliance Issues

**Check**:
- [ ] Compare against original Toastmasters files
- [ ] Verify color hex values match official palette
- [ ] Confirm minimum size requirements met
- [ ] Check clear space around logos maintained

**Solution**:
1. Re-download from official Toastmasters source
2. Replace modified file with original
3. Update code to use correct hex values
4. Adjust sizing to meet minimum requirements

---

### Image Optimization Issues

**Check**:
- [ ] Only content images optimized (NOT brand assets)
- [ ] Toastmasters logos remain unmodified
- [ ] Image sizes appropriate for use case
- [ ] Formats appropriate (JPG for photos, SVG for logos)

**Solution**:
- Never optimize Toastmasters brand assets
- Use original files exactly as provided
- Optimize only non-brand content images

---

## Quality Assurance Checklist

### Before Deployment

**Brand Compliance**:
- [ ] All logos downloaded from official Toastmasters source
- [ ] No modifications made to brand assets
- [ ] Official colors used (Loyal Blue #004165, etc.)
- [ ] Required disclaimer on all pages
- [ ] Minimum logo sizes maintained (72px)
- [ ] Proper clear space around logos

**Technical Validation**:
- [ ] Self-hosted fonts loading correctly
- [ ] Image paths correct and accessible
- [ ] Performance meets mobile standards (<3s load)
- [ ] Accessibility requirements met (WCAG 2.1 AA)
- [ ] Cross-browser compatibility verified

**Content Standards**:
- [ ] Photography reflects Toastmasters environment
- [ ] Professional quality maintained
- [ ] Startup focus appropriate for audience
- [ ] Multicultural representation included
- [ ] File naming conventions followed

**SEO/Metadata**:
- [ ] Alt text on all images
- [ ] Descriptive filenames used
- [ ] Appropriate image formats (SVG, JPG, PNG)
- [ ] Favicon loads correctly

---

## Maintenance Schedule

### Monthly Review
- [ ] Verify all brand assets unchanged
- [ ] Check for broken image links
- [ ] Review font loading performance
- [ ] Test on latest browser versions

### Quarterly Audit
- [ ] Compare against latest Toastmasters brand guidelines
- [ ] Review image optimization opportunities (content only)
- [ ] Test mobile performance on 3G
- [ ] Accessibility audit with updated tools

### When Toastmasters Updates Brand
- [ ] Download new official logos from toastmasters.org/Logos
- [ ] Replace old logos in `/logos/` directory
- [ ] Test all pages for visual consistency
- [ ] Update brand guide if color palette changes

---

## Support Resources

**Toastmasters Brand**:
- Official Guidelines: Toastmasters International Brand Manual
- Logo Downloads: [toastmasters.org/Logos](https://toastmasters.org/Logos)
- Brand Questions: brand@toastmasters.org
- Trademark Requests: [toastmasters.org/TrademarkUseRequest](https://toastmasters.org/TrademarkUseRequest)

**Technical Reference**:
- Brand Standards: [toastmasters-brand-guide.md](../toastmasters-brand-guide.md)
- Image optimization tools: TinyPNG, ImageOptim (for content only)
- Browser DevTools for testing
- axe DevTools for accessibility

---

**Critical Reminder**: Toastmasters International has strict brand guidelines. Any violation of trademark usage can affect club charter status and legal standing. Always preserve official assets exactly as provided and maintain perfect brand compliance.

---

**Last Updated**: 2025-10-08
**Maintained by**: Claude Code (CTO)
**Status**: ACTIVE - Operational workflow for all asset management
