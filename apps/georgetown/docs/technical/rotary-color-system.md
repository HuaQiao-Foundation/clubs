# Rotary Color System — Georgetown

**Status**: Official Standard
**Source**: Rotary International "Your Logos at a Glance" (April 2025)
**Reference file**: `public/brand/rotary-colors.json`

---

## Quick Reference

| Role | Name | Hex | Tailwind Class | Usage |
|------|------|-----|----------------|-------|
| **Primary brand** | Azure | `#0067c8` | `rotary-blue` / `rotary-azure` | Headers, primary buttons, links |
| **Logo word** | Royal Blue | `#17458f` | `rotary-royal` | "Rotary" wordmark, dark backgrounds |
| **Logo accent** | Gold | `#f7a81b` | `rotary-gold` | Wheel, CTAs, accent highlights |
| **Sub-brand** | Sky Blue | `#00a2e0` | `rotary-sky` | Interact logo, secondary accents |
| **Danger / CTA** | Cardinal | `#e02927` | `rotary-cardinal` | Errors, End Polio Now, alerts |
| **Rotaract** | Cranberry | `#d41367` | `rotary-cranberry` | Rotaract contexts only |
| **AoF: water** | Turquoise | `#00adbb` | `rotary-turquoise` | Community Econ Dev AoF |
| **AoF: education** | Orange | `#ff7600` | `rotary-orange` | Education AoF, secondary accent |
| **Body text** | Charcoal | `#54565a` | `rotary-charcoal` | Dark text, icons |
| **Secondary text** | Pewter | `#898a8d` | `rotary-pewter` | Subtext, placeholders |
| **Dividers** | Smoke | `#b1b1b1` | `rotary-smoke` | Borders, disabled states |
| **Subtle bg** | Silver | `#d0cfcd` | `rotary-silver` | Table stripes, subtle backgrounds |

---

## 1. Brand Colors (Logo Reproduction)

These three colors reproduce the Masterbrand Signature and Mark of Excellence. They must appear in their exact values — never screened, tinted, or altered.

### Rotary Gold
**PMS 130C** — The Rotary wheel.

| Format | Value |
|--------|-------|
| Hex | `#f7a81b` |
| RGB | 247, 168, 27 |
| CMYK | C0 M41 Y100 K0 |

### Rotary Royal Blue
**PMS 286C** — The word "Rotary" in the Masterbrand Signature.

| Format | Value |
|--------|-------|
| Hex | `#17458f` |
| RGB | 23, 69, 143 |
| CMYK | C100 M80 Y9 K2 |

> Note: `rotary-colors.json` has a hex/RGB mismatch on this entry — the RGB (23, 69, 143) and the Tailwind value `#17458f` are correct; ignore the `#0c3c7c` hex field in the JSON.

### Azure
**PMS 2175C** — One-color logo usage and primary digital brand color.

| Format | Value |
|--------|-------|
| Hex | `#0067c8` |
| RGB | 0, 103, 200 |
| CMYK | C100 M56 Y0 K0 |

---

## 2. Extended Brand Palette

Official Rotary brand colors beyond the masterbrand. All values from the April 2025 brand guide.

### Blues & Secondaries

| Name | PMS | Hex | RGB | Usage |
|------|-----|-----|-----|-------|
| Sky Blue | 2202C | `#00a2e0` | 0, 162, 224 | Interact sub-brand |
| Powder Blue | 290C | `#b9d9eb` | 185, 217, 235 | Light backgrounds |
| Slate | 2165C | `#657f99` | 101, 127, 153 | Secondary UI elements |

### Reds & Pinks

| Name | PMS | Hex | RGB | Usage |
|------|-----|-----|-----|-------|
| Cardinal | 485C | `#e02927` | 224, 41, 39 | End Polio Now, errors |
| Cranberry | 214C | `#d41367` | 212, 19, 103 | Rotaract sub-brand |

### Greens, Purples & Others

| Name | PMS | Hex | RGB | Usage |
|------|-----|-----|-----|-------|
| Turquoise | 7466C | `#00adbb` | 0, 173, 187 | Community Econ Dev AoF |
| Grass | 355C | `#009739` | 1, 151, 57 | Environment AoF |
| Violet | 2070C | `#901f93` | 144, 31, 147 | Maternal & Child Health AoF |
| Orange | 2018C | `#ff7600` | 255, 118, 0 | Basic Education AoF |

### Neutrals

| Name | PMS | Hex | RGB | Usage |
|------|-----|-----|-----|-------|
| Charcoal | Cool Gray 11C | `#54565a` | 84, 86, 90 | Body text |
| Pewter | Cool Gray 8C | `#898a8d` | 137, 138, 141 | Secondary text |
| Smoke | Cool Gray 5C | `#b1b1b1` | 177, 177, 177 | Borders, dividers |
| Silver | Cool Gray 2C | `#d0cfcd` | 208, 207, 205 | Subtle backgrounds |
| White | — | `#ffffff` | 255, 255, 255 | — |
| Black | — | `#000000` | 0, 0, 0 | — |

---

## 3. Areas of Focus Colors

Each of Rotary's seven Areas of Focus has a designated brand color. Use these in AoF-specific UI contexts only.

| Area of Focus | Color | Hex | Color-blind safe? |
|---------------|-------|-----|-------------------|
| Peacebuilding & Conflict Prevention | Azure | `#0067c8` | Yes |
| Disease Prevention & Treatment | Cardinal | `#e02927` | Yes |
| Water, Sanitation & Hygiene | Sky Blue | `#00a2e0` | Yes |
| Maternal & Child Health | Violet | `#901f93` | No — avoid for critical info |
| Basic Education & Literacy | Orange | `#ff7600` | Yes |
| Community Economic Development | Turquoise | `#00adbb` | Yes |
| Supporting the Environment | Grass | `#009739` | No — avoid for critical info |

---

## 4. Color Accessibility

**Safe palette** (WCAG-friendly, color-blind compatible): Azure, Royal Blue, Gold, Sky Blue, Cardinal, Turquoise, Orange, Charcoal.

**Avoid for critical UI**: Grass (`#009739`), Violet (`#901f93`), Cranberry (`#d41367`) — these are problematic for red-green or blue-yellow color vision deficiencies.

**Contrast rules**:
- White text on Azure, Royal Blue, Cardinal, Charcoal ✅
- Black/Charcoal text on Gold, Sky Blue, Powder Blue, Silver ✅
- Never white text on Gold or Smoke (insufficient contrast)

---

## 5. UI Application

| Context | Color |
|---------|-------|
| Primary button | Azure `#0067c8` |
| Primary button hover | Royal Blue `#17458f` |
| Accent / highlight | Gold `#f7a81b` |
| Destructive action | Cardinal `#e02927` |
| Header / nav background | Royal Blue `#17458f` or Azure `#0067c8` |
| Body text | Charcoal `#54565a` or black |
| Secondary text / meta | Pewter `#898a8d` |
| Border / divider | Smoke `#b1b1b1` |
| Subtle background | Silver `#d0cfcd` |
| AoF badge/tag | AoF-specific color (section 3) |

---

## 6. Where Values Live

| Location | Purpose |
|----------|---------|
| `tailwind.config.js` (`rotary.*`) | Primary dev tokens — use `rotary-blue`, `rotary-gold`, etc. |
| `public/brand/rotary-colors.json` | Full reference data with CMYK, Pantone, color-blind metadata |
| `docs/reference/rotary_areas_of_focus_colors.csv` | AoF colors for data-driven rendering |
| `src/index.css` | Any CSS custom property overrides |

---

## 7. Typography

**Primary font**: Open Sans (self-hosted — China-safe, no Google CDN)
- Location: `public/assets/fonts/`
- Tailwind: `font-sans` (configured to Open Sans)
- Free alternative to Rotary's licensed Frutiger LT Std

**Source**: [Rotary Brand Center](https://brandcenter.rotary.org/) (official guidelines require Frutiger; Open Sans is the approved free substitute).

---

## 8. Brand Rules (Key Constraints)

- Colors must be used in **pure form** — never screened, tinted, or modified per Rotary brand guidelines.
- The Rotary wheel logo may not be altered, recolored, or have effects applied.
- Abstract circular forms (to suggest Rotary without the literal wheel) use Gold (`#f7a81b`) as the accent.
- Background wash for generated images: Platinum `#E4DFDA` (warm, colorblind-safe).

---

**Last updated**: 2026-05-17
**Owner**: CTO
**Brand source**: Rotary International "Your Logos at a Glance" April 2025
