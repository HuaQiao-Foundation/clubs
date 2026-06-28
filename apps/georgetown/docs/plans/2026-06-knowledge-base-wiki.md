# Georgetown Knowledge Base / Wiki — Shape Up Pitch

**Status**: APPROVED 2026-06-29 — ready to execute (CEO bet: keep BlockNote, overriding R5's TipTap reshape)
**App**: Georgetown
**Owner**: CTO
**Appetite**: Small batch (~1–1.5 days, 2–3 sessions)
**Parent**: BACKLOG (new item)

> **Bet decisions (CEO, 2026-06-29):** (1) Editor: **BlockNote** — R5 advised reshaping to TipTap; CEO overrode to keep block-grade authoring. (2) Visibility: **three-state enum** (`draft`/`members`/`public`), author-selectable per page. (3) Write roles: **admin · officer · chair** can author/edit; delete = admin only. (4) Image upload: **in scope** — build the `wiki-images` bucket + RLS in the 074 migration.

---

## Problem

Georgetown Rotary has institutional knowledge — general club info, club history, and the details/descriptions of service projects — that currently lives nowhere durable. It's scattered across people's heads, old emails, and ad-hoc docs. New and prospective members have no single place to read "what is this club, what has it done, what is it working on now," and officers have no place to author that content. The club also wants a small public face: a few pages a non-member can read without logging in.

## Appetite

Small batch — roughly **1–1.5 days** across 2–3 sessions. The heavy lifting (a Notion-like editor + a publish workflow + public rendering) is already solved and shipped in Pitchmasters; this is a **port and adapt**, not a greenfield build. *R2 reckoning:* component reuse is ~90% (verified), but the appetite's true cost sits in the parts that **don't** port — Georgetown's first role-differentiated RLS, a new `wiki-images` storage bucket + RLS, the PWA cache-cap fix, the `usePermissions()` auth rewrite, and ~80 lines of re-fonted BlockNote CSS. Stacked, these justify the 1.5-day ceiling. **The reshape lever if it grows: cut public-facing rendering and image upload to a follow-up** — that drops the bucket, the public-route/RLS branch, and holds a clean 1 day.

## Solution

Port the proven Pitchmasters BlockNote CMS into Georgetown and adapt it to Georgetown's single-club schema and role model. Result: officers/admins author rich wiki pages inside the app; published pages render to members and (for a chosen subset) to the public with no auth.

### Why BlockNote (not settled by Pitchmasters — earned here)

Georgetown already ships **TipTap** ([RichTextEditor.tsx](../../src/components/RichTextEditor.tsx)) for small embedded rich fields (currently the event Meeting Agenda field). That's the right tool for a *bounded field*. The claim for the wiki is that it's a different job — a full Notion-like **page canvas** where the value is the block UX: slash (`/`) menu, drag-to-reorder handles, block hover controls, image upload/resize. TipTap is headless and ships none of that UI; BlockNote ships all of it, and PM's BlockNote code is ~90% component-reusable.

**R3 challenge (must answer before betting):** the BlockNote choice was *inherited* from Pitchmasters, not derived from Georgetown's need. PM's constraints aren't Georgetown's. For ~50 members and 2–3 officer-authors writing club-history prose, the 80/20 alternative is **reuse Georgetown's existing TipTap** — add a `gt_wiki_pages` table and render long-form pages with the editor Georgetown already bundles and styles. That eliminates the entire `@blocknote`+`@mantine` dependency add, the scoped-CSS re-font, the PWA cache-cap fix, and the China-constraint re-verification — i.e. most of what R1/R2 flagged as the real cost. The block UX is worse (no slash menu/drag handles), but **is Notion-grade authoring load-bearing for occasional long-form club prose, or imported because PM happened to build it?** The bet should not proceed until this is answered against Georgetown's actual authoring needs (long-form prose · images · headings · maybe tables) — if TipTap StarterKit + an image extension covers them, BlockNote is over-engineering; if officers genuinely need block authoring, it's justified. **This is the pitch's most load-bearing assumption.**

### Breadboard

```
  ADMIN/OFFICER                              MEMBER / PUBLIC
  ┌─────────────────────┐                    ┌──────────────────────┐
  │ /wiki  (PagesList)  │                    │ /wiki  (published     │
  │  • General Knowledge│   publish ───────▶ │   pages, grouped)     │
  │  • Club History     │                    │                       │
  │  • Projects (1/page)│                    │ /wiki/:slug  (read)   │
  │  [+ New page]       │                    │   public OR member    │
  └─────────┬───────────┘                    │   gated per page      │
            │ edit                           └──────────────────────┘
            ▼
  ┌─────────────────────┐
  │ /wiki/:slug/edit    │   BlockNote editor
  │  title + slug       │   Save Draft / Publish / (admin) Delete
  │  visibility: public │
  │   | member | draft  │
  └─────────────────────┘
```

### Element list (port surface from Pitchmasters)

| Pitchmasters source | Georgetown target | Adaptation |
|---|---|---|
| `pm_public_pages` table + RLS (`008-public-pages.sql` + `015-page-visibility.sql`) | new `docs/database/074-knowledge-base.sql` (074 is the verified-clean next number) | Drop `club_id` (Georgetown is single-club, no `get_current_user_club_id()`); keep slug-unique, `content` JSONB `default '[]'`, three-state `visibility` (`draft`/`members`/`public`), `author_id`. **PM dropped `published` in 015 — do not carry it; use `visibility` only.** |
| `usePublicPages.ts` hook (PM's `club_id` coupling lives **here**, not in the 4 components) | `useWikiPages.ts` | This is the real port surface — strip `club_id`, point at Georgetown's Supabase client. The four components carry zero `club_id` logic. |
| `015-page-visibility.sql` three-state visibility | same | `public` / `member` / `draft` — Georgetown needs the public-vs-member distinction explicitly |
| `cms/PageEditor.tsx` | `wiki/WikiPageEditor.tsx` | BlockNote editor wrapper; Save Draft / Publish / Delete |
| `cms/PublicPageView.tsx` | `wiki/WikiPageView.tsx` | read-only BlockNote renderer |
| `cms/PagesList.tsx` | `wiki/WikiPagesList.tsx` | role-gated list; group by category (General / History / Projects) |
| `cms/cmsSchema.tsx` | `wiki/wikiSchema.tsx` | BlockNote custom-block schema (carry as-is unless trimming) |
| 4 routes in `App.tsx` | add `/wiki`, `/wiki/new`, `/wiki/:slug/edit`, `/wiki/:slug` | **Georgetown already has public routes** — `/about` and `/join-us` render via `PublicLayout` with no auth. Follow that exact pattern for public `/wiki` + `/wiki/:slug`; wrap edit/list in `ProtectedRoute`. This is reuse, not new infrastructure. Define routes before the `*`→`/about` catch-all. |
| "Pages" nav link | "Wiki" nav entry | **Not one nav, three surfaces** (R2): authenticated nav is the `ALL_NAV_ITEMS` registry in `useBottomNavConfig.ts` behind a `MAX_NAV_ITEMS = 5` cap (defaults already full) — Wiki either displaces a default or lives only in the picker + a Dashboard card; the public top bar/footer in `PublicLayout.tsx` is separate. Surface placement depends on the public-vs-member decision below. |
| PM `uploadImage` helper (`PageEditor.tsx:19-37`, uploads to `cms-images` bucket) | port the **function**, new bucket | **Unlisted deliverable (R2).** Georgetown has no `cms-images` bucket; PM's base64 fallback means missing-bucket ships *silently* (images inline as data URLs, bloating rows). Create a `wiki-images` storage bucket + public-read/officer-write RLS **in the 074 migration**. Port PM's standalone `uploadImage` function — not Georgetown's `ImageUpload` *component* (wrong signature for BlockNote's `uploadFile`). |
| PM workbox cache cap (`pitchmasters/vite.config.ts:67`) | `georgetown/vite.config.ts` workbox block | **Unlisted deliverable (R2).** BlockNote bloats the bundle past Workbox's 2MB precache default; PM sets `maximumFileSizeToCacheInBytes: 4 * 1024 * 1024`. Georgetown's config omits it → PWA silently fails to precache the editor chunk. One line, but invisible if forgotten. |
| PM `currentUser: User` / `.role` prop | `usePermissions()` + `useAuth()` | **Auth-surface rewrite (R2).** Georgetown has no `User.role`; role lives in a separate `userRole` object and the idiomatic gate is `usePermissions()` (`isOfficer`/`isAdmin`) + `useAuth().user.id` for `author_id`. Every ported component needs this translation (role union is 5 values, not PM's 3). |

### Content types → how they live

- **General knowledge** → free-form wiki pages.
- **Club history** → free-form wiki page(s), long-form + images.
- **Club projects** → **standalone wiki pages, one per project** (per CEO decision). The wiki is the authoring home for project detail/description prose. Georgetown's existing `/projects` DB feature is *not* coupled to this in v1 — projects-as-pages stand on their own. (See Rabbit holes for how to avoid drift.)

**One decision drives three sections (R2): what is the wiki's default visibility?** Public-vs-member is not independent — it determines the nav surface (public top bar vs. the `ALL_NAV_ITEMS` bottom-nav registry), the route wrapper (`PublicLayout` vs. `ProtectedRoute`), and the page/bucket RLS shape. Decide once with CEO; everything downstream follows. The pitch's intent (projects public-readable, drafts gated) implies a *mixed* default — confirm the per-page default and who can flip it.

### New dependencies

`@blocknote/core`, `@blocknote/react`, `@blocknote/mantine` (pin **0.47.x** to match PM), plus peers `@mantine/core@^8.3`, `@mantine/hooks@^8.3`, `@floating-ui/dom`. Per Georgetown's China-friendly constraint, confirm these bundle locally (they do — pure npm, no external CDN/font calls at runtime, **as long as Mantine's global CSS is never imported** — see Mantine rabbit hole). Mantine CSS scoped to wiki components only.

## Rabbit holes

- **Mantine ↔ Tailwind collision — over-rated; the real task is scoped typography CSS (R2).** Verification shows PM **never imports Mantine's global reset** (`@mantine/core/styles.css` appears nowhere) — only the component-level `@blocknote/mantine/style.css`. So there is no global-reset-vs-Tailwind-preflight fight to fear. The actual work is ~80 lines of scoped `.bn-editor` typography overrides (PM has these at `pitchmasters/src/index.css:162-240`, all namespaced + `!important`) that must be ported and **re-fonted to Open Sans** (Georgetown's self-hosted font, per the China constraint). Keep the component-level CSS import; add a `.gt-page-view .bn-editor` override block. Verify base layout unchanged on a non-wiki route before shipping.
- **Mantine version pin.** BlockNote 0.47.x peers against `@mantine/core@^8.3.11` — install Mantine **8.x, not 9.x**. Getting this wrong produces opaque peer-dep/runtime errors.
- **RLS is net-new, not a rewrite — this is the pitch's deepest risk.** Pitchmasters' policies key off `club_id` + `get_current_user_club_id()`; Georgetown has neither. But the subtler trap (verified against migration 072, Georgetown's latest RLS): **Georgetown's production RLS does not gate by specific role** — its write policies use `EXISTS (SELECT 1 FROM gt_user_roles WHERE user_id = auth.uid())`, i.e. "any user with any role row." So this pitch isn't porting a role-differentiated RLS pattern — **it's authoring Georgetown's first one** (public-read · member-read · officer/admin-write · admin-only-delete). Budget it as new work. Build the write policy on the `gt_user_roles … auth.uid()` shape (table is prefixed `gt_user_roles`); do **not** rely on the `get_user_role()` function from migration 054 without confirming it resolves post-069 table rename. **Write-role set is decided (CEO bet): write = role IN (`admin`,`officer`,`chair`); delete = `admin` only.** Read: public = `visibility = 'public'` (unauthenticated OK); member = authenticated.
- **Projects drift.** Projects-as-wiki-pages can diverge from the `/projects` DB records (a project described in two places). v1 accepts this; mitigate by linking the wiki project page to its `/projects/:id` (and vice-versa) rather than duplicating structured data. Flag a future pitch if the club wants them merged.
- **Public exposure of drafts.** A page set to `member` or `draft` must never be reachable by an unauthenticated `/wiki/:slug` request. This is an **RLS** guarantee (deny at the row level), not just a UI guard — test it by hitting the URL logged out.
- **Migration tooling.** Per Georgetown CLAUDE.md, run schema via `psql "$DIRECT_URL"` against the Singapore Supabase project (`aws-1-ap-southeast-1`); SQL file is `docs/database/074-knowledge-base.sql` (074 verified clean — folder has historical collisions at 015/055/056, so don't guess the number). Do not ask CEO to run SQL by hand.
- **Visibility scope vs. stated need (R3).** Three-state `visibility` + per-page public RLS is the general mechanism; the stated public need is "a few pages." If that stays true, a single `is_public` boolean is simpler and cheaper. Carry the three-state enum only if the CEO wants member-vs-public to be a routine per-page author choice; otherwise drop to a boolean. Decide at the visibility-decision gate above.
- **Content-format lock-in (R3).** Whichever editor wins, authored pages are stored in *that* editor's content format (BlockNote block-JSON or TipTap HTML/JSON). After officers author real club history, switching editors means a content migration. This is the one genuinely hard-to-reverse commitment — it raises the stakes on the BlockNote-vs-TipTap decision and argues for deciding it deliberately now, not defaulting to "what PM used."
- **Two-editor maintenance surface (R3).** Adopting BlockNote adds Mantine + a second rich-text stack to an app that had only TipTap. When BlockNote/Mantine ship breaking changes, that's now Georgetown's upkeep too. Acceptable if the block UX is genuinely needed; pure cost if it isn't.
- **Cache-cap timing (R4).** The `maximumFileSizeToCacheInBytes: 4MB` workbox fix only bites at *production build* time, not in dev — so a builder who only tests `pnpm dev` won't see the broken PWA precache until after deploy. Set it when the dep is added, and confirm a production `pnpm build:georgetown` precaches the editor chunk before shipping.

## Success criterion (R4)

v1 is done — and only done — when: **an officer can create → save draft → publish a wiki page, and a logged-out visitor can read a `public` page but cannot reach a `draft` or `member` page (verified by hitting the URL logged out).** Category coverage (General / History / Projects populated) is *content work, not build work* — it does not gate "done." This criterion is editor-agnostic, so it survives the BlockNote-vs-TipTap decision.

## No-gos

- **Editor decision: resolved → BlockNote.** R5 advised TipTap; CEO bet kept BlockNote for block-grade authoring. The first code step (`pnpm add @blocknote/* @mantine/*` at the pinned 0.47.x/8.x) is now unblocked. (R5's disproof — TipTap already covers the feature set — stands on record; if block authoring proves unused in practice, the TipTap reshape is the cheap fallback.)
- **Three-state visibility: in scope (CEO bet).** Carry PM's `draft`/`members`/`public` enum, author-selectable per page — not the `is_public` boolean. Build the per-page RLS branch accordingly.
- **No relational-database / kanban / calendar views.** This is a page wiki, not a Notion workspace. Structured project data stays in `/projects`.
- **No real-time co-editing, comments, or @-mentions.** Explicit-save model (Save Draft / Publish), single editor at a time — matches Pitchmasters' deliberate "no auto-save" decision. (BlockNote *can* do collab via Yjs later; out of scope now.)
- **No version history in v1.** If officers want it, it's a cheap follow-up (snapshot `content` JSONB to a `wiki_page_revisions` table). Not in this appetite.
- **No cross-page full-text search in v1.** Listing + categories only. DB-level search is a later add.
- **No migration of existing `/projects` records into the wiki.** Projects-as-pages are authored fresh; the `/projects` feature is left untouched.
- **No ripping out TipTap.** Georgetown's existing `RichTextEditor` stays for its current uses. The two editors serve different jobs.

---

## Hardening log

- **R1 (consistency)** — The pitch frames the RLS as a "rewrite" of PM's role-based policies, but verification (migration 072) shows Georgetown has **no role-differentiated RLS** — production gates on mere `gt_user_roles` row existence. The real work is *authoring* Georgetown's first role-differentiated RLS, hidden behind a "port" framing. → Rewrote the RLS rabbit hole to name it as net-new work; corrected three verified premises (public routes already exist via `/about`+`PublicLayout`; `club_id` coupling lives in `usePublicPages.ts` hook, not the 4 components; migration number is `074`, `published` was dropped in PM's 015). Named the write-role set (`chair?`) as the one open CEO decision.
- **R2 (coverage)** — Two **silent-failure** deliverables were entirely absent and both ship broken *without erroring*: the `wiki-images` storage bucket + RLS (PM's base64 fallback masks the missing bucket) and the `maximumFileSizeToCacheInBytes: 4MB` workbox cap (PWA precache silently breaks on the oversized BlockNote chunk). Also surfaced: nav is 3 surfaces behind a 5-item cap (not "desktop+mobile"), the auth surface needs a `usePermissions()` rewrite, and the Mantine collision is over-rated (real task = ~80 lines of re-fonted scoped CSS). → Added all four as explicit in-scope deliverables in the element list; reframed the Mantine rabbit hole; named the public-vs-member visibility decision as the single fork that drives nav + routing + RLS. **In-scope / deferred split:** all four land in-scope; appetite raised to 1–1.5 days with "cut public rendering + image upload" named as the reshape lever to hold 1 day.
- **R3 (red-team)** — The BlockNote choice was **inherited from Pitchmasters, never derived from Georgetown's need**. The 80/20 alternative — reuse Georgetown's existing TipTap for long-form pages — eliminates most of what R1/R2 flagged as the real cost (deps, scoped CSS, PWA cap, China re-verify). The pitch's "Why BlockNote (settled)" argued BlockNote-vs-TipTap-Pro UX but skipped the prior question: *does a ~50-member club's wiki need block-grade UX at all?* → Rewrote the section to "earned here, not settled by PM" with an explicit pre-bet test (check TipTap StarterKit + image extension against actual authoring needs). Added rabbit holes for visibility over-engineering, content-format lock-in (the one hard-to-reverse commitment), and the two-editor maintenance surface. **Most load-bearing assumption: the wiki requires BlockNote — test cheaply before betting.**
- **R4 (pre-mortem)** — Converged with R3 (mid-sequence): the root assumption all rounds return to is the BlockNote-vs-TipTap choice. The root is **verified against the pitch text** (the "Why BlockNote" section demonstrably argues UX, never Georgetown's need) — so R4 did not re-argue it; it pivoted to build-reality. → Added a sharp, editor-agnostic **success criterion** (create→draft→publish + logged-out visitor sees public / cannot reach draft); added two No-go gates (no `pnpm add` before the editor decision; no three-state visibility without the CEO decision); flagged the cache-cap as a *production-build-only* failure a dev-only test won't catch; noted a content-export script as the uncaptured follow-up tail. **Root finding handed to R5 as a falsifiable proposition:** *"Georgetown's wiki requires BlockNote's block UX; its existing TipTap cannot serve the actual authoring need"* — disprove by checking TipTap StarterKit + `@tiptap/extension-image` against the real authoring needs (prose · images · headings · tables). If TipTap covers them, reshape to a TipTap wiki and the dependency add is unjustified.
- **R5 (independent, 2026-06-29)** — Ran the disproof cold against the code: **the root is FALSE.** TipTap is already installed *and styled* (`@tiptap/* 3.22.3`, a working `RichTextEditor` with toolbar + `tiptap.css`); StarterKit 3.22.3 already bundles links; image/table are version-aligned first-party adds (`@tiptap/extension-image`/`-table`, same lockfile line). So the wiki's full feature set = present StarterKit + ≤2 official extensions — zero new engines. BlockNote is *strictly dominated*: it costs a second editor + Mantine + scoped CSS + PWA cap + China re-verify to buy block affordances 2–3 occasional officer-authors don't need. **What four rounds missed:** the rounds kept the editor choice framed as a CEO toss-up, but the code already settles it — and the word "**port**" smuggled BlockNote into the framing when the goal (durable knowledge readable by new members) is editor-indifferent. **Verdict: RESHAPE → reuse TipTap** (keep all editor-agnostic hardening: data/RLS/routing/nav/visibility/success criterion; keep image upload in scope — TipTap makes it cheap).
- **Bet (CEO, 2026-06-29)** — **Override R5: keep BlockNote.** CEO accepts the second-editor/Mantine cost for block-grade authoring; R5's disproof stands on record as the cheap fallback if block UX proves unused. Open decisions resolved at the bet: three-state visibility (in), write roles admin/officer/chair (delete admin-only), image upload + `wiki-images` bucket (in). → Status flipped to APPROVED. Hardening converged: every R1–R4 finding (net-new RLS, bucket, PWA cap, auth rewrite, scoped CSS) is folded in regardless of editor, so the BlockNote build now ships the parts the original draft would have shipped broken.

---

End of pitch.
