# Pitchmasters Logo Assets & Brand Identity — Shape Up Pitch

**Status**: DONE 2026-05-17
**App**: Pitchmasters
**Owner**: CTO
**Appetite**: 1 session (~2 hrs)
**Parent**: —

---

## Problem

The Pitchmasters app has no Toastmasters visual identity in the UI. The navigation header renders plain text "Pitchmasters" with no logo image. Fifty-plus logo files sourced from Toastmasters International sit unused across three nested subdirectories, plus four old flat files that partially duplicate them. The app's favicon is a generic 32×32 .ico with no SVG fallback and no dark-mode support. The PWA manifest has a bug: the maskable icon entry reuses the same PNG as the standard icon, meaning Android adaptive icons will not render correctly (no safe zone). The app carries Toastmasters branding in its color scheme and name, but shows none of it at the UI level.

## Appetite

One session, roughly 2 hours. The three workstreams are sequential but each is small: flatten assets → fix favicon + PWA icons → add logo to header.

## Solution

**1. Flatten logo assets**

Copy 7 canonical SVGs from the nested subdirectories to a clean flat `public/assets/logos/` directory using kebab-case names:

| Flat filename | Source |
|---|---|
| `tm-logo-color.svg` | `ToastmastersLogo/Color/ToastmastersLogo3Color.svg` |
| `tm-logo-white.svg` | `ToastmastersLogo/White/ToastmastersLogoWhite.svg` |
| `tm-wordmark-color.svg` | `ToastmastersWordmark/Color/ToastmastersWordmarkColor.svg` |
| `tm-wordmark-white.svg` | `ToastmastersWordmark/White/ToastmastersWordmarkWhite.svg` |
| `tm-wordmark-black.svg` | `ToastmastersWordmark/Black/ToastmastersWordmarkBlack.svg` |
| `tm-lockup-color.svg` | `LogoLockups/ColorLogoSince1924/ColorLogoSince1924Navy.svg` |
| `tm-lockup-white.svg` | `LogoLockups/ColorLogoSince1924White/ColorLogoSince1924White.svg` |

Delete the 4 old flat files and the 3 nested subdirectories in full.

**2. SVG favicon + fixed PWA icons**

- Create `public/icons/favicon.svg` from the TM shield mark with a `prefers-color-scheme: dark` media query (white fill on dark, colored on light) — same pattern used for Georgetown.
- Generate two maskable PNG variants using the TM shield at 60% canvas size on a Toastmasters red (`#E31F26`) background, within the Android safe zone: `icon-192x192-maskable.png` and `icon-512x512-maskable.png`.
- Fix `vite.config.ts`: add the two maskable entries pointing to the new files; change the existing entries to `purpose: 'any'` only.

**3. Add logo to app header**

In `Layout.tsx` and `PublicLayout.tsx`, add `tm-logo-white.svg` as an `<img>` beside the "Pitchmasters" text in the nav header (red background). Height ~32px to match the existing text baseline.

## Rabbit holes

- **`tm-logo-color.svg` vs `tm-logo-3color.svg`**: The source directory has both `ToastmastersLogoColor.svg` (2-color) and `ToastmastersLogo3Color.svg` (3-color with dark blue + red + gold). Use the 3-color version as `tm-logo-color.svg` — it's the brand-complete variant. The 2-color version is not needed.
- **cairosvg required for maskable PNG generation**: ImageMagick cannot render complex Toastmasters SVG paths (same issue as Georgetown). Use `cairosvg` via Python. It's already installed from the Georgetown session.
- **Lockup choice**: "Since 1924" is the most neutral and timeless tagline. "Where Leaders Are Made" is Toastmasters International's campaign tagline but may not be appropriate for a club-level app. "With Website" lockup is never appropriate in app UI. Skip both.
- **`PublicLayout.tsx`**: Check whether it has its own header with a logo slot before adding one — avoid duplicating the pattern from `Layout.tsx` without verifying the structure.

## No-gos

- No lockups with "Where Leaders Are Made" or "With Website" — these are marketing/campaign assets, not app UI assets.
- No changes to the PWA icon PNGs used for `purpose: 'any'` — the existing `icon-192x192.png` and `icon-512x512.png` are fine as-is; only the maskable variants are new.
- No changes to Toastmasters brand colors or typography — this pitch is assets only.
- No cleanup of `.jpg` and `.png` duplicates inside the source subdirectories — just delete the whole subdirectory tree; the originals are Toastmasters International's files and don't need to be curated.
- No addition of the Toastmasters wordmark or lockup to the header — the shield mark alone is sufficient for a nav header; wordmarks belong on public/about pages.

---

End of pitch.
