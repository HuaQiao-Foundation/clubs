# Rotary Brand Guide for Georgetown Club Applications

**Version:** 2.0  
**Last Updated:** 2025-12-18  
**Maintained By:** CTO

---

## Brand Overview

Georgetown Rotary Club applications must reflect Rotary International's professional standards and community standing. This guide ensures visual consistency with Rotary's global brand identity.

**Scope:** This guide covers Georgetown Rotary Club applications only. For HuaQiao Foundation and HuaQiao Bridge, see the separate HuaQiao Brand Guide.

---

## Part 1: Brand Asset Protection (MANDATORY)

### Official Logo Protection — NO EXCEPTIONS

**ROTARY INTERNATIONAL LOGOS:**
- ❌ **NEVER** modify, compress, or alter official Rotary logos
- ❌ **NEVER** change colors, proportions, or design elements
- ❌ **NEVER** create "optimized" or "simplified" versions
- ✅ **ALWAYS** use original files EXACTLY as provided by Rotary International
- ✅ **ALWAYS** preserve trademark integrity and legal compliance

**Legal Requirements:**
- Official Rotary logos are protected intellectual property
- Georgetown Rotary has usage rights but NOT modification rights
- Trademark violations can result in loss of usage rights
- Any changes require Rotary International approval

**Protected Files:**
- All files with "Rotary" in the name
- Rotary Mark of Excellence logos (RotaryMoE-*.svg)
- Rotary Brand Standard logos (RotaryMBS-*.svg)
- Georgetown Rotary Club official logos

**Storage & Handling:**
- Store in `/public/assets/images/logos/` as read-only
- NEVER apply compression or optimization
- Backup original files before system changes
- Document source and approval chain

---

## Part 2: Color Palette

### Primary Colors (Use These Most)

| Color | Name | Hex | PMS | Usage |
|-------|------|-----|-----|-------|
| **Primary Blue** | Rotary Azure | #0067C8 | 2175C | Headers, navigation, primary UI |
| **Primary Gold** | Rotary Gold | #F7A81B | 130C | CTAs, highlights, success states |
| **White** | White | #FFFFFF | — | Backgrounds, text on dark |
| **Black** | Black | #000000 | — | Body text, high contrast |

### Secondary Blues

| Color | Name | Hex | Usage |
|-------|------|-----|-------|
| Royal Blue | Rotary Royal Blue | #17458F | Executive/leadership emphasis |
| Sky Blue | Interact Blue | #00A2E0 | Youth contexts, modern feel |
| Dark Blue | Legacy Dark Blue | #004A8A | System compatibility |

### Secondary Accent Colors

| Color | Name | Hex | Usage |
|-------|------|-----|-------|
| Cranberry | Rotaract | #D41367 | Holiday events, special occasions |
| Turquoise | Service | #00ADBB | Service projects, community focus |
| Violet | Events | #901F93 | Club events, celebrations |
| Orange | Energy | #FF7600 | Alerts, warnings, energy |
| Cardinal | End Polio Now | #E02927 | Health initiatives |
| Grass Green | Environment | #009739 | Environmental themes |

### Areas of Focus Colors

Official colors for Rotary's seven Areas of Focus (Source: Rotary International Areas of Focus Visual Guidelines, Jan 2021):

| Area of Focus | Color Name | Hex | RGB |
|---------------|------------|-----|-----|
| Peacebuilding & Conflict Prevention | Azure | #0067C8 | 0, 105, 200 |
| Disease Prevention & Treatment | Cardinal | #E02927 | 224, 41, 39 |
| Water, Sanitation & Hygiene | Sky Blue | #00A2E0 | 0, 162, 224 |
| Maternal & Child Health | Violet | #901F93 | 144, 31, 147 |
| Basic Education & Literacy | Orange | #FF7600 | 255, 118, 0 |
| Community Economic Development | Turquoise | #00ADBB | 0, 173, 187 |
| Supporting the Environment | Grass Green | #009739 | 0, 151, 57 |

### Colorblind Safety Notes

| Pair | Safety | Notes |
|------|--------|-------|
| Azure ↔ Cardinal | ✅ Safe | Blue vs red, distinct |
| Azure ↔ Orange | ✅ Safe | Blue vs orange, distinct |
| Azure ↔ Turquoise | ⚠️ Caution | Both blue family for CVD users |
| Cardinal ↔ Orange | ⚠️ Caution | Both warm, may merge for protanopia |
| Grass Green ↔ Cardinal | ⚠️ Caution | Red-green problematic |
| Violet ↔ Azure | ⚠️ Caution | May appear similar for some CVD |

**Rule:** When using Areas of Focus colors together, always include icon shapes or labels — never rely on color alone.

### Neutral Background

For image backgrounds and surfaces, use:

| Role | Color | Hex | Notes |
|------|-------|-----|-------|
| Primary background | Platinum | #E4DFDA | Warm, grounded, editorial feel |
| Secondary background | White | #FFFFFF | Clean, high contrast |

---

## Part 3: Design Tokens

### CSS Variables

```css
:root {
  /* Primary */
  --rotary-azure: #0067C8;
  --rotary-gold: #F7A81B;
  
  /* Secondary Blues */
  --rotary-royal-blue: #17458F;
  --rotary-sky-blue: #00A2E0;
  --rotary-dark-blue: #004A8A;
  
  /* Accent Colors */
  --rotary-cranberry: #D41367;
  --rotary-turquoise: #00ADBB;
  --rotary-violet: #901F93;
  --rotary-orange: #FF7600;
  --rotary-cardinal: #E02927;
  --rotary-grass-green: #009739;
  
  /* Neutrals */
  --rotary-platinum: #E4DFDA;
  --rotary-white: #FFFFFF;
  --rotary-black: #000000;
  
  /* Semantic */
  --rotary-primary: var(--rotary-azure);
  --rotary-accent: var(--rotary-gold);
  --rotary-surface: var(--rotary-platinum);
  --rotary-text: var(--rotary-black);
}
```

### Tailwind Configuration

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        rotary: {
          // Primary
          azure: '#0067C8',
          gold: '#F7A81B',
          
          // Secondary Blues
          'royal-blue': '#17458F',
          'sky-blue': '#00A2E0',
          'dark-blue': '#004A8A',
          
          // Accents
          cranberry: '#D41367',
          turquoise: '#00ADBB',
          violet: '#901F93',
          orange: '#FF7600',
          cardinal: '#E02927',
          'grass-green': '#009739',
          
          // Neutrals
          platinum: '#E4DFDA',
          
          // Semantic
          primary: '#0067C8',
          accent: '#F7A81B',
          surface: '#E4DFDA',
        },
      },
    },
  },
};
```

---

## Part 4: Typography

### Font Hierarchy

| Level | Font | Weight | Style | Usage |
|-------|------|--------|-------|-------|
| Headlines | Open Sans Condensed | 700 | ALL CAPS | Major headings |
| Subheads | Open Sans | 600 | Sentence case | Section headers, nav |
| Body | Open Sans | 400 | Sentence case | Paragraphs, content |
| Captions | Open Sans | 400 | Sentence case | Metadata, labels |

### Implementation Requirements

- **Self-hosted fonts:** No external CDN dependencies (Google Fonts blocked)
- **Font loading:** Preload critical font files for performance
- **Fallback strategy:** Graceful degradation to system fonts

**Fallback Stack:**
```css
font-family: 'Open Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
```

### Typography Scale

```css
/* Display */
font-size: 2.5rem; /* 40px */
font-weight: 700;
text-transform: uppercase;
letter-spacing: 0.5px;

/* Headlines */
font-size: 2rem; /* 32px */
font-weight: 700;
text-transform: uppercase;
letter-spacing: 0.5px;

/* Subheadings */
font-size: 1.25rem; /* 20px */
font-weight: 600;

/* Body text */
font-size: 1rem; /* 16px */
font-weight: 400;
line-height: 1.6;

/* Small/Captions */
font-size: 0.875rem; /* 14px */
font-weight: 400;
```

---

## Part 5: Visual Design Principles

### Mobile-First Design Standards

- **Primary Experience:** Design for mobile phones (320px-414px) first
- **Touch Interface:** Minimum 44px touch targets, thumb-friendly navigation
- **Meeting Context:** Usable during Rotary meetings with one-handed operation
- **Desktop Enhancement:** Desktop provides expanded functionality but mobile drives core UX
- **Progressive Enhancement:** Features scale up from mobile baseline

### Professional Standards

- **Clean layouts:** Generous white space, clear visual hierarchy
- **Modern interface:** Contemporary design patterns appropriate for 2024+
- **Rotary-appropriate:** Reflects community leadership and service excellence
- **Accessibility:** WCAG 2.1 AA compliance minimum

### Component Styling

| Component | Specification |
|-----------|--------------|
| Cards | Subtle shadows, 4-8px rounded corners |
| Buttons | Clear primary/secondary distinction, Azure primary, Gold accent |
| Forms | Professional appearance, proper validation states |
| Navigation | Intuitive structure, Azure headers |

---

## Part 6: Image Generation — Refined Line Art with Color Fields

### Style Overview

For AI-generated imagery in Georgetown Rotary applications, use the **Refined Line Art with Color Fields** style. This approach creates professional, editorial-quality illustrations that complement Rotary's brand without competing with official logos.

**Visual Characteristics:**
- Simple continuous line drawings (not detailed or fussy)
- Paired with solid geometric color blocks using Rotary palette
- Balance of illustration and abstraction
- Editorial quality (professional publication aesthetic)
- Generous white space

**Why This Style for Rotary:**
1. **Professional credibility:** Matches the senior professional audience (business leaders, community members)
2. **Brand-safe:** Abstract imagery doesn't compete with official Rotary logos or icons
3. **Versatile:** Works across all seven Areas of Focus
4. **Accessible:** Simple forms render well at all sizes and for colorblind users

### Image Palette for Rotary

| Image Role | Color Options | Hex |
|------------|---------------|-----|
| Line art | Black or Dark Blue | #000000 or #004A8A |
| Color field (primary) | Rotary Azure | #0067C8 |
| Color field (by Area of Focus) | See Areas of Focus table | Various |
| Accent shape | Rotary Gold | #F7A81B |
| Background | Platinum | #E4DFDA |

### Color Field Selection by Area of Focus

| Area of Focus | Color Field | Accent |
|---------------|-------------|--------|
| Peacebuilding | Azure #0067C8 | Gold |
| Disease Prevention | Cardinal #E02927 | Gold |
| Water & Sanitation | Sky Blue #00A2E0 | Gold |
| Maternal & Child Health | Violet #901F93 | Gold |
| Education & Literacy | Orange #FF7600 | Gold or none |
| Economic Development | Turquoise #00ADBB | Gold |
| Environment | Grass Green #009739 | Gold |

### Line Art Subject Vocabulary

| Subject | Best For | Meaning |
|---------|----------|---------|
| Concentric ripples | Water, spreading impact | Expansion, reach |
| Rising spiral | Education, growth | Progress, learning |
| Two paths converging | Peace, partnerships | Coming together |
| Branching upward form | Environment, development | Organic growth |
| Protective arc | Health, maternal/child | Shelter, care |
| Interlocking circles | Community, collaboration | Connection |
| Ascending stepped form | Economic development | Progress, building |

### Accent Shape Vocabulary

| Shape | Suggests | Use With |
|-------|----------|----------|
| Circle | Completeness, unity | Rotary wheel echo, origins |
| Arc/crescent | Movement, progress | Ascending forms |
| Small dots (2-3) | Spread, reach | Ripples, branching |
| None | Restraint, simplicity | When color field is enough |

---

## Part 7: PBS Image Generation Templates

### What is PBS?

**Phrase Block Structure (PBS)** is the standard for AI image prompts. Short, high-signal phrases grouped into labeled sections produce more consistent, higher-quality results than narrative paragraphs.

### Template: Generic Rotary/Georgetown Image

```
SUBJECT:
organization: Georgetown Rotary Club
narrative focus: service above self, community leadership, fellowship
values: professional, community-focused, action-oriented

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, warm, community-focused
confident and welcoming tone

PALETTE:
#000000 (black) for line art
#0067C8 (rotary azure) large color field
#F7A81B (rotary gold) accent shape
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: interlocking circular forms suggesting connection and community
one large organic azure shape behind line art
one small gold circle as accent suggesting unity
sense of togetherness and purpose

COMPOSITION:
[ASPECT RATIO - e.g., 1200x630 for OG, 3:2 for hero]
main elements centered or slightly offset
azure color field flows behind line art
gold accent at focal point
negative space for potential text overlay

CONSTRAINTS:
no text, no logos, no words
no literal Rotary wheel or official symbols
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
warm, professional, community-focused mood
```

### Template: Area of Focus Project Image

```
SUBJECT:
service project: [specific project description]
area of focus: [one of seven Areas of Focus]
narrative focus: [core impact/meaning]

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, purposeful, impactful
[appropriate tone for area of focus]

PALETTE:
#000000 (black) for line art
#[AREA OF FOCUS COLOR] large color field
#F7A81B (rotary gold) accent shape
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: [SELECT FROM LINE ART VOCABULARY]
one large organic shape in area of focus color behind line art
[SELECT FROM ACCENT VOCABULARY or "no additional accent"]
[energy/movement description]

COMPOSITION:
3:2 horizontal layout
[element positioning]
[color field placement]
negative space [location] for text overlay
[directional flow]

CONSTRAINTS:
no text, no logos, no words
no [literal objects to avoid for this project type]
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
[mood descriptor matching area of focus]
```

---

## Part 8: Example Prompts

### Example 1: Georgetown Rotary Open Graph Image

```
SUBJECT:
organization: Georgetown Rotary Club
narrative focus: community leadership, service above self, professional fellowship
values: trusted, established, action-oriented

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, warm, confident
welcoming and purposeful tone

PALETTE:
#000000 (black) for line art
#0067C8 (rotary azure) large color field
#F7A81B (rotary gold) accent shape
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: interlocking circular forms suggesting connection, community, and the spirit of Rotary
one large organic azure shape behind line art, flowing horizontally
one small gold circle near the intersection of forms suggesting unity and purpose
sense of connection, fellowship, and shared mission

COMPOSITION:
1200x630 pixels (1.9:1 aspect ratio for Open Graph)
circular forms centered with slight rightward flow
azure color field flows behind and supports the forms
gold accent at or near the central intersection
negative space on left for potential text overlay
balanced, welcoming, professional energy

CONSTRAINTS:
no text, no logos, no words
no literal Rotary wheel — suggest connection abstractly
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
warm, trustworthy, community-focused mood
```

### Example 2: Water & Sanitation Project

```
SUBJECT:
service project: clean water well installation for rural community
area of focus: Water, Sanitation & Hygiene
narrative focus: life-giving resource, community health, lasting impact

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, refreshing, hopeful
calm and life-affirming tone

PALETTE:
#000000 (black) for line art
#00A2E0 (sky blue - water area of focus) large color field
#F7A81B (rotary gold) accent shapes
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: concentric ripples expanding outward from center
one large organic water-like shape in sky blue behind line art
small cluster of 2-3 gold dots at outer ripple edges suggesting spread
sense of expansion, reach, and life-giving impact

COMPOSITION:
3:2 horizontal layout
ripple origin slightly left of center
sky blue color field flows behind ripples
gold accents at expanding edges
negative space right third for text overlay
soft expanding motion from center outward

CONSTRAINTS:
no text, no logos, no words
no literal wells, pumps, faucets, or plumbing
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
refreshing, hopeful, life-giving mood
```

### Example 3: Education & Literacy Project

```
SUBJECT:
service project: school library and literacy program
area of focus: Basic Education & Literacy
narrative focus: knowledge growing, potential unlocking, futures opening

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, aspirational, energetic
encouraging and forward-looking tone

PALETTE:
#000000 (black) for line art
#FF7600 (orange - education area of focus) large color field
#F7A81B (rotary gold) accent shape
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: rising spiral suggesting growth and upward learning
one large organic vertical shape in orange behind line art
one small gold arc at top suggesting light, opening, or possibility
upward spiraling energy

COMPOSITION:
3:2 horizontal layout
spiral rises from lower center toward upper right
orange color field anchors the base and rises with form
gold accent at the ascending apex
negative space left third for text overlay
diagonal upward flow suggesting aspiration

CONSTRAINTS:
no text, no logos, no words
no literal books, classrooms, or school buildings
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
inspiring, energetic, forward-looking mood
```

### Example 4: Peacebuilding Initiative

```
SUBJECT:
service project: peace fellowship and cross-cultural dialogue program
area of focus: Peacebuilding & Conflict Prevention
narrative focus: separate paths finding common ground, understanding growing

STYLE:
refined continuous line art with color blocks
editorial illustration quality
professional, balanced, dignified
calm strength and harmony tone

PALETTE:
#000000 (black) for line art
#0067C8 (azure - peacebuilding area of focus) large color field
#E4DFDA (platinum) background

VISUAL ELEMENTS:
single continuous line drawing: two curved paths approaching and gently merging into one
one large rounded rectangular shape in azure behind convergence
no additional accent — the meeting point itself is the focal element
sense of coming together without collision

COMPOSITION:
3:2 horizontal layout
convergence point at center
paths enter from opposite sides
azure color field frames the meeting softly
negative space distributed evenly
horizontal balance suggesting stability and peace

CONSTRAINTS:
no text, no logos, no words
no doves, globes, flags, or literal peace symbols
line art simple and continuous (not detailed/fussy)
color blocks solid (no gradients)
professional editorial quality, not cartoony
calm, dignified, hopeful mood
```

---

## Part 9: Voice & Messaging

### Communication Style

- **"We" language:** Collective focus, not individual achievement
- **Action-oriented:** Clear calls-to-action and next steps
- **Community-focused:** Emphasize service and collaboration
- **Professional tone:** Appropriate for business leaders and community members

### Content Guidelines

- **Inspiring messaging:** Reflect Rotary's mission of "Service Above Self"
- **Clear instructions:** Volunteer-friendly language for non-technical users
- **Inclusive language:** Welcome all community members and potential Rotarians

### Sample Phrases

| Context | Example |
|---------|---------|
| CTA | "Join Us" / "Get Involved" / "Support This Project" |
| Welcome | "Welcome to Georgetown Rotary" |
| Mission | "Service Above Self" / "People of Action" |
| Community | "Together, we..." / "Our club..." |

---

## Part 10: Georgetown Rotary Context

### Local Adaptations

- **Community standing:** Interface quality worthy of Georgetown's professional community
- **Member demographics:** Business leaders, professionals, community volunteers
- **Usage context:** Often accessed during meetings on mobile devices
- **Growth orientation:** Design supports club expansion and member engagement

### Application-Specific Requirements

**Speaker Management System:**
- Professional appearance for program committee use
- Clear status tracking (kanban columns)
- Mobile-optimized for meeting usage
- Real-time collaboration capabilities

**Future Club Applications:**
- Consistent brand application across all tools
- Scalable design system for multiple applications
- Professional integration with club communications

---

## Part 11: Quality Control

### Image Checklist

Before publishing any AI-generated image:

**Visual Style**
- [ ] Line art is simple and continuous (not detailed or fussy)
- [ ] Color blocks are solid (no gradients)
- [ ] Maximum 3 colors used (line + field + accent)
- [ ] Editorial quality achieved (not cartoony or generic)
- [ ] Adequate negative space for text overlay if needed

**Brand Compliance**
- [ ] Colors match official Rotary palette exactly
- [ ] No unofficial colors introduced
- [ ] No resemblance to official Rotary wheel logo
- [ ] Background is Platinum (#E4DFDA) or White

**Content Appropriateness**
- [ ] No literal/stereotypical imagery
- [ ] Abstract enough to be culturally neutral
- [ ] Mood matches intended message
- [ ] No text, logos, or labels in image

**Technical Requirements**
- [ ] Correct aspect ratio for intended use
- [ ] Renders clearly at mobile size (320px width)
- [ ] Sufficient contrast for accessibility

### Design Validation Checklist

- [ ] Primary colors (Azure/Gold) prominently featured
- [ ] Typography hierarchy clear and readable
- [ ] Professional appearance worthy of Rotary leadership
- [ ] Mobile responsive design (320px to 1920px)
- [ ] Accessibility compliance verified

### Technical Validation Checklist

- [ ] Self-hosted Open Sans fonts loading correctly
- [ ] Color contrast ratios meet WCAG standards
- [ ] Performance optimized (sub-3-second load times)
- [ ] Cross-browser compatibility tested

### Brand Compliance Checklist

- [ ] No unauthorized modifications to official logos
- [ ] Typography follows established hierarchy
- [ ] Visual style reflects Rotary's professional standards
- [ ] Messaging uses appropriate community-focused language

---

## Part 12: File Organization

### Logos

```
/public/assets/images/logos/
├── RotaryMoE-*.svg          # Mark of Excellence (READ-ONLY)
├── RotaryMBS-*.svg          # Brand Standard logos (READ-ONLY)
├── georgetown-rotary-*.svg   # Club logos (READ-ONLY)
└── README.md                 # Logo usage documentation
```

### Generated Images

```
/public/assets/images/
├── heroes/
│   └── [page-name]/
├── projects/
│   └── [area-of-focus]/
├── social/
│   ├── og/                   # Open Graph images
│   ├── linkedin/
│   └── facebook/
└── speakers/
    └── [speaker-slug]/
```

### Naming Convention

```
[context]-[subject]-[variant].[ext]

Examples:
hero-georgetown-main-01.png
project-water-sanitation-01.png
og-rotary-default.png
social-linkedin-meeting-announcement.png
```

---

## Part 13: Resources

### Official Rotary Resources

- **Rotary Brand Center:** https://brandcenter.rotary.org
- **Areas of Focus Icons:** Available from Brand Center
- **Logo Downloads:** Brand Center (requires Rotary login)
- **Visual Guidelines:** Areas of Focus Visual Guidelines (Jan 2021)

### Related Documentation

- **HuaQiao Brand Guide:** For Foundation and Bridge properties
- **PBS Documentation:** Image prompt methodology

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-18 | Added image generation section (PBS), design tokens, colorblind notes, quality checklists, file organization |
| 1.0 | 2025-12-01 | Initial guide with colors, typography, visual standards |

---

## Summary

**Logo:** Official Rotary International logos only — never modify

**Palette:**
- Azure #0067C8, Gold #F7A81B (primary)
- Seven Areas of Focus colors (secondary)
- Platinum #E4DFDA (background)

**Typography:** Open Sans family, self-hosted

**Image Style:** Refined Line Art with Color Fields
- Black line art
- Area of Focus color fields
- Gold accents
- Platinum backgrounds
- Editorial quality, no literal symbols

**Voice:** "We" language, action-oriented, community-focused, professional

---

*Bottom Line: Every Georgetown Rotary application should reflect the club's position as a leader in the Georgetown community while maintaining consistency with Rotary International's global brand standards. Professional appearance and accessibility are non-negotiable requirements.*

---

*Questions? Contact CTO for technical implementation, Club President for brand decisions.*
