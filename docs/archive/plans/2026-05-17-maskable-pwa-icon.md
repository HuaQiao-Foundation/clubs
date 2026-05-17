# Maskable PWA Icon — Shape Up Pitch

**Status**: DONE 2026-05-17
**App**: Georgetown
**Owner**: CTO
**Appetite**: 1 session (~1 hr)
**Parent**: GEO-003 (Add screenshots to PWA manifest)

---

## Problem

The Georgetown PWA currently uses the same `icon-192x192.png` for both icon purposes in the manifest:

```json
{ "src": "icons/icon-192x192.png", "purpose": "any" }
{ "src": "icons/icon-192x192.png", "purpose": "maskable" }
```

The `any` icon is the azure Rotary wheel on a transparent background. It was designed for browser tabs and home screen placement — not for Android's adaptive icon system.

Android's adaptive icon system applies a shape mask (circle, squircle, teardrop — varies by manufacturer) that crops everything outside the central 80% of the image. The current wheel extends to the edges of the canvas, so the gear spokes get clipped. On a Pixel the result is a circle with chopped spokes; on a Samsung it's a squircle with the same problem. First impressions of a "professional club management app" are damaged at the home screen.

## Appetite

One session, roughly 1 hour. The design is fixed (azure background, white wheel, centered). The deliverable is one PNG and a two-line change to `vite.config.ts`. If it takes longer than that, something has gone wrong with the tooling — stop and reshape.

## Solution

**Two assets, one config change.**

1. **`icons/icon-192x192-maskable.png`** — 192×192px:
   - Solid azure background (`#0067C8`) fills the full canvas
   - White Rotary wheel (`rotary-wheel-white.svg`) centered, scaled to ~60% of canvas width (~115px) so the entire wheel sits inside the safe zone
   - Safe zone is a circle with diameter = 80% of canvas = 160px; wheel at 60% gives ~16px margin all around

2. **`icons/icon-512x512-maskable.png`** — 512×512px (same design, larger):
   - Required for Android splash screen quality on high-density displays

3. **`vite.config.ts` manifest update** — split the two purposes:
   ```js
   { src: 'icons/icon-192x192.png',          sizes: '192x192', type: 'image/png', purpose: 'any' },
   { src: 'icons/icon-512x512.png',          sizes: '512x512', type: 'image/png', purpose: 'any' },
   { src: 'icons/icon-192x192-maskable.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
   { src: 'icons/icon-512x512-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
   ```

**Generation approach** (pick one, in order of preference):
- **[maskable.app/editor](https://maskable.app/editor)** — paste in `rotary-wheel-white.svg`, set background to `#0067C8`, export PNG. Zero code.
- **`sharp` one-liner** — composite the white SVG onto an azure canvas programmatically if the online tool doesn't produce clean output.
- **Inkscape export** — open the white wheel SVG, add a background rect, resize canvas, export PNG. Fallback only.

Validate the result at [maskable.app](https://maskable.app) — the preview shows the icon inside each Android shape. All spoke tips should remain visible in every shape.

## Rabbit holes

- **Only 192 and 512 needed.** Android uses 192 for the home screen icon and 512 for the splash screen. Don't generate intermediate sizes.
- **SVG `purpose: maskable` is not reliably supported.** Some Android versions ignore SVG manifest icons entirely. Stick with PNG.
- **Don't adjust the `any` icons.** The existing 192/512 PNGs on transparent background are correct for `any` — don't add backgrounds to those.
- **The maskable.app editor adds padding automatically.** If using the online tool, verify the exported file is exactly 192×192 and hasn't been padded to a different size.

## No-gos

- Don't redesign the icon — the wheel mark stays as-is, only the canvas treatment changes.
- Don't touch Pitchmasters — it has its own icon set and PWA config.
- Don't generate splash screen images — that's a separate task (GEO-003 scope).
- Don't add a `purpose: monochrome` entry — not worth the extra asset without a use case.

---

End of pitch.
