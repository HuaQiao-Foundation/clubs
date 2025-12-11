# Rotary Brand Guide for Georgetown Club Applications

## Brand Overview

Georgetown Rotary Club applications must reflect Rotary International's professional standards and community standing. This guide ensures visual consistency with Rotary's global brand identity.

## ⚠️ Brand Asset Protection (MANDATORY)

### Official Logo Protection - NO EXCEPTIONS

**ROTARY INTERNATIONAL LOGOS:**
- ❌ **NEVER modify, compress, or alter official Rotary logos**
- ❌ **NEVER change colors, proportions, or design elements**
- ❌ **NEVER create "optimized" or "simplified" versions**
- ✅ **ALWAYS use original files EXACTLY as provided by Rotary International**
- ✅ **ALWAYS preserve trademark integrity and legal compliance**

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

## Color Palette (Official Rotary International)

### Primary Colors (Use These Most)
* **Rotary Azure** (PMS 2175C): `#0067c8` - Primary interface elements
* **Rotary Gold** (PMS 130C): `#f7a81b` - Call-to-action buttons, highlights
* **White**: `#ffffff`
* **Black**: `#000000`

### Secondary Blues (Official Rotary)
* **Rotary Royal Blue**: `#17458f` - Executive/leadership emphasis
* **Azure** (one-color): `#0067c8` - Alternative primary blue
* **Sky Blue** (Interact): `#00a2e0` - Youth/modern contexts
* **Legacy Dark Blue**: `#004a8a` - System compatibility

### Secondary Accent Colors (Official Rotary)
* **Cranberry** (Rotaract): `#d41367` - Holiday events, special occasions
* **Turquoise**: `#00adbb` - Service projects, community focus
* **Violet**: `#901f93` - Club events, celebrations
* **Orange**: `#ff7600` - Alerts, warnings, energy

### Additional Official Colors
* **Cardinal** (End Polio Now): `#e02927` - Health initiatives
* **Grass Green**: `#009739` - Environmental/growth themes

## Rotary Areas of Focus Colors

Official colors for Rotary's seven Areas of Focus, used for cause-specific content and project categorization (extracted from official Rotary EPS files):

| Area of Focus | Color Name | PMS | HEX | RGB |
|--------------|------------|-----|-----|-----|
| Peacebuilding & Conflict Prevention | Azure | PANTONE 2175 C | `#0067C8` | 0, 103, 200 |
| Disease Prevention & Treatment | Cardinal | PANTONE 485 C | `#E02927` | 224, 41, 39 |
| Water, Sanitation & Hygiene | Turquoise | PANTONE 7466 C | `#00ADBB` | 0, 173, 187 |
| Maternal & Child Health | Orange | PANTONE 2018 C | `#FF7600` | 255, 118, 0 |
| Basic Education & Literacy | Sky Blue | PANTONE 2202 C | `#00A2E0` | 0, 162, 224 |
| Community Economic Development | Grass Green | PANTONE 355 C | `#009739` | 1, 151, 57 |
| Supporting the Environment | Violet | PANTONE 2070 C | `#901F93` | 144, 31, 147 |

### Usage Guidelines for Areas of Focus
- Use official colors to categorize service projects by focus area
- Maintain color consistency when displaying project portfolios
- Icons and colors available from [Rotary Brand Center](https://brandcenter.rotary.org/en-us/our-brand/brand-elements/logos-and-graphics/areas-of-focus-icons)
- Color values sourced from official Rotary International EPS files (see `docs/reference-data/rotary_areas_of_focus_colors.csv`)
- Note: Peacebuilding uses Azure `#0067C8` (same as primary brand color)

### Color Usage Guidelines
- **Azure Blue (#0067c8)**: Primary interface elements, headers, navigation
- **Gold (#f7a81b)**: Call-to-action buttons, highlights, success states
- **Secondary colors**: Only for data visualization or special emphasis
- **High contrast**: Ensure WCAG 2.1 AA compliance for accessibility

## Typography

### Font Hierarchy
- **Headlines**: Open Sans Condensed (bold, ALL CAPS for major headings)
- **Navigation/Subheads**: Open Sans (semi-bold, sentence case)
- **Body Text**: Open Sans (regular weight)
- **System Fallbacks**: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif

### Implementation Requirements
- **Self-hosted fonts**: No external CDN dependencies (Google Fonts blocked)
- **Font loading**: Preload critical font files for performance
- **Fallback strategy**: Graceful degradation to system fonts

### Typography Scale
```css
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
```

## Visual Design Principles

### Mobile-First Design Standards
- **Primary Experience**: Design for mobile phones (320px-414px) first
- **Touch Interface**: Minimum 44px touch targets, thumb-friendly navigation
- **Meeting Context**: Usable during Rotary meetings with one-handed operation
- **Desktop Enhancement**: Desktop provides expanded functionality but mobile drives core UX
- **Progressive Enhancement**: Features scale up from mobile baseline

### Professional Standards
- **Clean layouts**: Generous white space, clear visual hierarchy
- **Modern interface**: Contemporary design patterns appropriate for 2024+
- **Rotary-appropriate**: Reflects community leadership and service excellence
- **Accessibility**: WCAG 2.1 AA compliance minimum

### Component Styling
- **Cards**: Subtle shadows, rounded corners (4-8px radius)
- **Buttons**: Clear primary/secondary distinction using brand colors
- **Forms**: Professional appearance with proper validation states
- **Navigation**: Intuitive structure reflecting Rotary's organizational clarity

## Voice & Messaging

### Communication Style
- **"We" language**: Collective focus, not individual achievement
- **Action-oriented**: Clear calls-to-action and next steps
- **Community-focused**: Emphasize service and collaboration
- **Professional tone**: Appropriate for business leaders and community members

### Content Guidelines
- **Inspiring messaging**: Reflect Rotary's mission of service above self
- **Clear instructions**: Volunteer-friendly language for non-technical users
- **Inclusive language**: Welcome all community members and potential Rotarians

## Georgetown Rotary Context

### Local Adaptations
- **Community standing**: Interface quality worthy of Georgetown's professional community
- **Member demographics**: Business leaders, professionals, community volunteers
- **Usage context**: Often accessed during meetings on mobile devices
- **Growth orientation**: Design supports club expansion and member engagement

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

## Implementation Checklist

### Design Validation
- [ ] Primary colors (Azure/Gold) prominently featured
- [ ] Typography hierarchy clear and readable
- [ ] Professional appearance worthy of Rotary leadership
- [ ] Mobile responsive design (320px to 1920px)
- [ ] Accessibility compliance verified

### Technical Validation
- [ ] Self-hosted Open Sans fonts loading correctly
- [ ] Color contrast ratios meet WCAG standards
- [ ] Performance optimized (sub-3-second load times)
- [ ] Cross-browser compatibility tested

### Brand Compliance
- [ ] No unauthorized color modifications
- [ ] Typography follows established hierarchy
- [ ] Visual style reflects Rotary's professional standards
- [ ] Messaging uses appropriate community-focused language

---

**Bottom Line**: Every Georgetown Rotary application should reflect the club's position as a leader in the Georgetown community while maintaining consistency with Rotary International's global brand standards. Professional appearance and accessibility are non-negotiable requirements.