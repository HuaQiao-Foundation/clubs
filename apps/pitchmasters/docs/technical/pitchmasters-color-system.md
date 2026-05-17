# Toastmasters Color System — Pitchmasters

**Status**: Official Standard
**Source**: Toastmasters International Brand Manual v2.0 (Rev. 03/2026)
**Brand contact**: brand@toastmasters.org

---

## Quick Reference

| Role | Name | Hex | Tailwind Class | Usage |
|------|------|-----|----------------|-------|
| **Primary brand** | Loyal Blue | `#004165` | `toastmasters-blue` | Headers, primary buttons, backgrounds |
| **Brand identity** | True Maroon | `#772432` | `toastmasters-maroon` | Wordmark, section headers, accents |
| **Neutral / secondary** | Cool Gray | `#A9B2B1` | `toastmasters-gray` | Backgrounds, secondary text, borders |
| **Accent / highlight** | Happy Yellow | `#F2DF74` | *(not yet in config)* | Highlights, badges, standout elements |
| **White** | White | `#ffffff` | `white` | Text on dark backgrounds |
| **Black** | Black | `#000000` | `black` | Body text on light backgrounds |

---

## 1. Primary Colors

The Toastmasters palette is built on three primary colors — Loyal Blue, True Maroon, and Cool Gray — plus one accent. These colors embody leadership, dedication, and empowerment.

### Loyal Blue
**PMS 302** — Primary brand color. Use for headers and background areas.

| Format | Value |
|--------|-------|
| Hex | `#004165` |
| RGB | 0, 65, 101 |
| CMYK | C100 M43 Y12 K56 |
| Pantone | 302 |

### True Maroon
**PMS 188** — Primary brand color. Use for headers and background areas.

| Format | Value |
|--------|-------|
| Hex | `#772432` |
| RGB | 119, 36, 50 |
| CMYK | C12 M95 Y59 K54 |
| Pantone | 188 |

---

## 2. Secondary Colors

### Cool Gray
**PMS 442** — Primary neutral. Use for backgrounds and secondary text.

| Format | Value |
|--------|-------|
| Hex | `#A9B2B1` |
| RGB | 169, 178, 177 |
| CMYK | C23 M7 Y12 K18 |
| Pantone | 442 |

### Happy Yellow
**PMS 127** — Accent only. Use for highlights and making elements stand out.

| Format | Value |
|--------|-------|
| Hex | `#F2DF74` |
| RGB | 242, 223, 116 |
| CMYK | C0 M5 Y57 K0 |
| Pantone | 127 |

---

## 3. Gradient Extension Colors

Toastmasters uses branded gradients for marketing materials. Each primary color has named gradient endpoints.

### Loyal Blue Gradient
Used for deep blue backgrounds — the brand's signature look (as seen on the Brand Manual cover).

| Name | Hex | Position |
|------|-----|----------|
| Loyal Blue | `#004165` | Edge / corners |
| Blissful Blue | `#006094` | Centre (lighter) |

```css
/* Top to bottom */
background: linear-gradient(180deg, #004165 0%, #006094 100%);

/* Radial (official pattern) */
background: radial-gradient(ellipse at center, #006094 0%, #004165 100%);
```

### True Maroon Gradient

| Name | Hex | Position |
|------|-----|----------|
| Deep Maroon | `#3B0104` | Edge / dark end |
| Rich Maroon | `#781327` | Centre / lighter end |

```css
background: linear-gradient(180deg, #3B0104 0%, #781327 100%);
```

### Cool Gray Gradient

| Name | Hex | Position |
|------|-----|----------|
| Cool Gray | `#A9B2B1` | Dark end |
| Fair Gray | `#F5F5F5` | Light end |

```css
background: linear-gradient(180deg, #A9B2B1 0%, #F5F5F5 100%);
```

> Gradients are primarily for hero sections and marketing materials. App UI components should use solid brand colors for clarity and accessibility.

---

## 4. Color Accessibility

**Contrast rules**:
- White text on Loyal Blue `#004165` ✅
- White text on True Maroon `#772432` ✅
- Black/dark text on Happy Yellow `#F2DF74` ✅
- Black/dark text on Cool Gray `#A9B2B1` ✅ (marginal — verify at small sizes)
- Never white text on Cool Gray (insufficient contrast)
- Never white text on Happy Yellow (insufficient contrast)

**Color blindness**: The Toastmasters palette is generally safe. Blue/maroon combination should be supplemented with icons or labels to distinguish for users with blue-yellow color vision deficiencies.

---

## 5. UI Application

| Context | Color |
|---------|-------|
| Primary button | Loyal Blue `#004165` |
| Primary button hover | Blissful Blue `#006094` |
| Brand accent / emphasis | True Maroon `#772432` |
| Destructive action | True Maroon `#772432` (or system red if distinct needed) |
| Header / nav background | Loyal Blue `#004165` |
| Section header text | True Maroon `#772432` |
| Body text | Black `#000000` or near-black |
| Secondary / meta text | Cool Gray `#A9B2B1` |
| Border / divider | Cool Gray `#A9B2B1` |
| Subtle background | Fair Gray `#F5F5F5` |
| Highlight / badge | Happy Yellow `#F2DF74` |
| White text (on dark bg) | White `#ffffff` |

---

## 6. Where Values Live

| Location | Purpose |
|----------|---------|
| `tailwind.config.js` (`toastmasters.*`) | Primary dev tokens — use `toastmasters-blue`, `toastmasters-maroon`, `toastmasters-gray` |
| `src/index.css` | CSS custom properties / any overrides |

**Note**: Happy Yellow and gradient endpoint colors (`Blissful Blue`, `Deep Maroon`, `Rich Maroon`, `Fair Gray`) are not yet in `tailwind.config.js`. Add them when needed:

```js
// tailwind.config.js — suggested additions
'toastmasters': {
  'blue': '#004165',
  'blissful': '#006094',    // gradient companion to blue
  'maroon': '#772432',
  'deep-maroon': '#3B0104', // gradient companion to maroon
  'rich-maroon': '#781327', // gradient companion to maroon
  'gray': '#A9B2B1',
  'fair-gray': '#F5F5F5',   // gradient companion to gray
  'yellow': '#F2DF74',
}
```

---

## 7. Typography

**Primary font**: Gotham (licensed)
- Free alternative: **Montserrat** (similar geometric sans, approved by Toastmasters)
- Usage: Headlines and subheads

**Current app fonts** (self-hosted, China-safe):
- `font-jakarta` — Plus Jakarta Sans (`tailwind.config.js`)
- `font-source` — Source Sans 3 (`tailwind.config.js`)

**Toastmasters brand note**: All materials must follow brand font guidelines. The licensed Gotham typeface is the official primary; Montserrat is the approved free substitute.

---

## 8. Brand Rules (Key Constraints)

- All Toastmasters materials — even those without the logo — must follow the Brand Manual color, font, and photography guidelines.
- Clubs and districts may not create custom logos, themes, or taglines.
- The logo must not be placed on colors outside the brand color palette.
- Black and white are both permitted for Toastmasters materials.
- Transparencies (opacity overlays) are permitted; maintain sufficient text-to-background contrast.

---

**Last updated**: 2026-05-17
**Owner**: CTO
**Brand source**: Toastmasters International Brand Manual v2.0, Rev. 03/2026
