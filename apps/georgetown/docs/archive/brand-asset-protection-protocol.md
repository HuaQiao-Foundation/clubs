# Georgetown Rotary - Brand Asset Protection Protocol

## MANDATORY REQUIREMENTS - NO EXCEPTIONS

### Official Brand Assets Protection

**ROTARY INTERNATIONAL LOGOS**
- ❌ **NEVER modify, simplify, compress, or alter official Rotary logos**
- ❌ **NEVER change colors, proportions, design elements, or vectorize paths**
- ❌ **NEVER create "optimized" or "simplified" versions of trademark assets**
- ✅ **ALWAYS use original files EXACTLY as provided by Rotary International**
- ✅ **ALWAYS preserve official branding integrity and legal compliance**

### Trademark Compliance Requirements

**Legal Protection:**
- Official Rotary logos are protected intellectual property
- Georgetown Rotary Club has usage rights but NOT modification rights
- Any changes to official logos require Rotary International approval
- Trademark violations can result in loss of usage rights

**Brand Standards:**
- Rotary Mark of Excellence logos MUST remain unmodified
- Official Azure blue color (#1873c3) MUST be preserved exactly
- Reverse/white versions MUST only be used on dark backgrounds
- Proportions, spacing, and design elements are legally protected

## Asset Classification System

### Class 1: PROTECTED BRAND ASSETS (NO MODIFICATION ALLOWED)
**Files that MUST NEVER be modified:**
- `RotaryMBS-Simple_Azure-CMYK-C.svg` - Main Brand Standard (Azure)
- `RotaryMBS-Simple_REV.svg` - Main Brand Standard (Reverse)
- `RotaryMoE-R_Azure-CMYK-C.svg` - Mark of Excellence (Azure)
- `RotaryMoE-R_REV.svg` - Mark of Excellence (Reverse)
- Any file with "Rotary" in the name
- Any official Georgetown Rotary Club logos

**Protection Measures:**
- Store in `/public/assets/images/logos/` as read-only reference files
- NEVER apply compression, optimization, or SVG processing
- Create favicon by COMBINING original files, not modifying them
- Document original source and date received from leadership

### Class 2: OPTIMIZABLE CONTENT
**Files that CAN be optimized:**
- Photographs (speakers, events, meetings)
- Background graphics and patterns
- Icons created specifically for this application
- Non-branded imagery and graphics

**Optimization Rules:**
- Compress for web performance (JPG 75%, WebP 80%)
- Resize for responsive delivery
- Apply lazy loading and modern formats
- Maintain visual quality for professional appearance

## Implementation Requirements

### Favicon Implementation Standards
**REQUIRED APPROACH - SVG with Original Assets:**
```html
<!-- PRIMARY: SVG favicon using EXACT official logo content -->
<link rel="icon" type="image/svg+xml" href="/assets/images/icons/favicon.svg">

<!-- FALLBACK: PNG for legacy browsers only -->
<link rel="icon" type="image/png" sizes="32x32" href="/assets/images/icons/favicon-32x32.png">
```

**SVG Structure (MANDATORY):**
```svg
<svg viewBox="0 0 335.97333 336" xmlns="http://www.w3.org/2000/svg">
  <style>
    .azure-version { display: block; }
    .reverse-version { display: none; }
    @media (prefers-color-scheme: dark) {
      .azure-version { display: none; }
      .reverse-version { display: block; }
    }
  </style>
  <!-- EXACT CONTENT from RotaryMoE-R_Azure-CMYK-C.svg -->
  <g class="azure-version">[ORIGINAL PATHS ONLY]</g>
  <!-- EXACT CONTENT from RotaryMoE-R_REV.svg -->
  <g class="reverse-version">[ORIGINAL PATHS ONLY]</g>
</svg>
```

### File Management Protocol

**Brand Asset Storage:**
- Official logos in `/public/assets/images/logos/`
- Generated favicon in `/public/assets/images/icons/favicon.svg`
- Never overwrite or replace original trademark files
- Backup original files before any system changes

**Version Control:**
- Commit brand assets with clear documentation
- Tag versions when updating from official sources
- Never merge changes that modify protected assets
- Review all image commits for trademark compliance

## Quality Assurance Checklist

### Before ANY Image Implementation:

**1. Brand Asset Verification:**
- [ ] Is this an official Rotary International logo?
- [ ] Does this file contain trademark or copyright material?
- [ ] Will any processing affect brand compliance?
- [ ] Have I preserved original files exactly as provided?

**2. Legal Compliance Check:**
- [ ] Are colors and proportions preserved exactly?
- [ ] Would Rotary International approve this implementation?
- [ ] Does this meet Georgetown Rotary's professional standards?
- [ ] Have I documented the source and approval chain?

**3. Technical Implementation:**
- [ ] Are original assets preserved in source folder?
- [ ] Does favicon combine (not modify) original designs?
- [ ] Have I tested dark/light mode switching?
- [ ] Does the final result accurately represent official branding?

## Violation Prevention

### Development Guidelines
**Code Reviews MUST verify:**
- No modifications to files in `/assets/images/logos/`
- No compression applied to official brand assets
- No color changes or design alterations to trademark files
- Proper documentation of asset sources and approvals

**Image Processing Rules:**
- Use separate folders for optimizable vs. protected assets
- Configure build tools to exclude brand asset folders from processing
- Test final output against original files for accuracy
- Document any technical limitations requiring workarounds

### Incident Response
**If Brand Violation Detected:**
1. **STOP** - Immediately halt deployment/publication
2. **RESTORE** - Revert to original, unmodified assets
3. **DOCUMENT** - Record what was changed and why
4. **APPROVE** - Get explicit CEO approval before proceeding
5. **IMPLEMENT** - Use compliant approach only

## Georgetown Rotary Professional Standards

**Community Reputation:**
- Accurate branding demonstrates respect for Rotary International
- Professional implementation reflects club's attention to detail
- Trademark compliance protects club from legal issues
- Quality standards worthy of Georgetown's business community

**Expected Outcomes:**
- Favicon displays official Rotary Mark of Excellence accurately
- Dark/light mode switching preserves brand integrity
- File organization maintains legal compliance
- Digital presence reflects official Rotary standards

---

**CRITICAL REMINDER:** When in doubt about any brand asset modification, PRESERVE THE ORIGINAL and seek CEO approval. Georgetown Rotary's reputation and legal standing depend on maintaining trademark compliance.

**Last Updated:** September 2025
**Next Review:** December 2025
**Contact:** Georgetown Rotary CEO for brand asset questions