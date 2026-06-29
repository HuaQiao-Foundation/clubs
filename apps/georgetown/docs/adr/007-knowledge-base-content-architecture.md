# ADR 007: Knowledge Base / Wiki Content Architecture

**Status**: Accepted
**Date**: 2026-06-29
**Deciders**: CEO (Randal), CTO (Claude Code)
**Related ADRs**: [0001](0001-supabase-singapore-migration.md) (Supabase region)
**Related work**: GEO-006 wiki pitch (`docs/plans/2026-06-knowledge-base-wiki.md`)

## Context

The club is building a knowledge base / wiki (GEO-006) and is assembling a large
body of reference material: Rotary manuals and PDFs on the CEO's computer, club
history and records in the club's Google Drive, images, scans, and documents that
members will eventually read and download.

The question: **where does each kind of material live** — in the git repo, outside
it, in a gitignored area, or in app storage? And how do we serve downloads without
bloating the repo or coupling the live site to fragile external links?

Key constraints:
- The core site is tracked on **GitHub** and must stay lean (currently ~43 MB git).
  Binary reference blobs (PDFs, scans, images) in git history are an anti-pattern —
  they bloat the repo permanently, can't be diffed, and don't share the *code's*
  lifecycle.
- The club already keeps its reference corpus in **Google Drive** (shared, backed up).
  A `deno "google"` Drive sync task already exists in the repo.
- GEO-006 already chose **Supabase** for wiki page content + a `wiki-images` bucket,
  with a public / members / draft RLS visibility model.
- Reference material is **not one thing** — it spans private raw research, published
  page content, and member-downloadable documents, which have different homes.

## Decision

We classify all "reference material" into **three kinds**, each with a distinct home.
The rule of thumb: *git is for code and the small text that configures it — not for
binary content or app data.*

| Kind | Examples | Home | In git? |
|---|---|---|---|
| **1. Raw research corpus** | Rotary manuals, PDFs, scans, Drive exports — material we *author from* | **Google Drive** (source of truth) | No |
| **2. Published wiki content** | Page text: club history, project descriptions — authored *in the app* | **Supabase** (`wiki_pages` table + `wiki-images` bucket) | No (app data) |
| **3. Downloadable documents** | Bylaws, minutes archives, logo packs members click to download | **Supabase storage** (`wiki-docs` bucket) served via URL | No (app data) |

Concretely:

- **Raw corpus → Google Drive**, not a gitignored repo folder. Drive is already
  where the material is, already shared with the club, and already backed up by
  Google. The corpus is a **club asset that must outlive any one laptop**; a
  gitignored `research/` folder would make it invisible to everyone but the author
  and absent from GitHub. We pull files from Drive (via the existing `deno google`
  task) only while authoring a page.

  **Drive sharing = two folders (CEO, 2026-06-29).** Google Drive enforces access at
  the *folder* level, so the corpus is organized into exactly two shared top-level
  folders, matching Drive's two natural share groups:

  ```
  📁 Board   → shared with officers/board only   (member-master, attendance,
  │                                                suppliers, membership, archives)
  📁 Club    → shared with all club members       (meetings, service projects,
                                                   photos, logos, directory…)
       └── group by category inside: Meetings / Documents / Assets
  ```

  This is simpler than tagging every folder with a wiki tier — Drive only has two
  share levels anyway, so two folders is the right grain *for Drive*. The finer
  public/members/board distinction is a **wiki concern, enforced by RLS — not a Drive
  concern.**

  **The wiki's distinctive job is the `public` tier.** Drive does `Board` and `Club`
  (two member-only share groups) well. What Drive *cannot* gracefully do is "anyone on
  the internet, no Google login" — a genuinely public page. That is precisely what the
  wiki adds. So the wiki isn't only an easier-UX restatement of Drive; it provides the
  **public front door Drive structurally lacks**, on top of the members/board tiers.

  **Interim vs. destination (CEO, 2026-06-29):** Drive is *cheap and good* and is the
  **interim** member-facing home *until the wiki exists*. But for members, a
  **dedicated site is easier** than navigating a Drive folder — so once the wiki is
  working well, the wiki becomes the **member-facing destination** and Drive recedes
  to a pure back-of-house *source/archive* layer (where we author from, and from which
  we **selectively** publish to the wiki). The migration is gradual and selective: we
  do not bulk-dump Drive into the wiki; we publish materials to the wiki as they earn
  a place there. This makes the architecture forward-compatible — nothing changes about
  the three-layer split; only *which layer members look at* shifts from Drive to the
  wiki over time.

- **Published content → Supabase** (per GEO-006): `wiki_pages` rows for text,
  `wiki-images` bucket for inline images.

- **Downloadable documents → a new `wiki-docs` Supabase bucket**, access-controlled
  by RLS mirroring the page-visibility model: a `public/` prefix anyone can download
  and a `members/` prefix requiring auth. A wiki page renders a download link to the
  bucket URL. **The live site never links directly to Google Drive for downloads** —
  that couples the site to Drive sharing settings, which expire, break, and leak.

The three-layer split:

```
  GOOGLE DRIVE                    SUPABASE (app data)              GITHUB
  raw Rotary corpus    author     wiki_pages (text)       code     React app
  manuals, scans,    ─────────▶   wiki-images bucket    ◀──────    schema
  Drive exports        pull via   wiki-docs bucket        serves   fill/sync
  = SOURCE (shared,    deno         ├ public/  (RLS)               scripts
    backed up)         google       └ members/ (RLS)             = the build
                                  = PUBLISHED + DOWNLOAD
   you read & write from          members read & download         only code in git
```

This is the same source-vs-artifact discipline already used elsewhere in the repo
(form templates tracked in `docs/templates/`, generated forms gitignored in `forms/`).

## Consequences

### Positive

- Repo stays lean — no binary reference blobs in git history, ever.
- Club reference corpus stays in Drive: shared, backed up, survives any laptop, and
  is already populated and tooled (`deno google`).
- Downloads are served by the app under our own access control (RLS), not by fragile
  external share links.
- Extends GEO-006 by exactly one new artifact — a `wiki-docs` bucket — reusing the
  visibility/RLS model already designed for pages and images.

### Negative

- Downloadable docs must be *uploaded to Supabase*, a deliberate step (not "drop a
  file in a folder"). This is the cost of serving them properly with access control.
- Two storage buckets to manage (`wiki-images`, `wiki-docs`) plus their RLS.
- The raw corpus living in Drive means authoring a page involves a pull step rather
  than everything being local.

### Neutral

- Google Drive becomes an explicit *source* layer in the content pipeline, not just
  ad-hoc storage. The `deno google` task becomes part of the authoring workflow.

## Alternatives Considered

### Alternative 1: Gitignored `research/` folder in the repo (brandmine pattern)

**Description**: Keep the raw corpus in `apps/georgetown/research/`, gitignored.

**Pros**: Material sits next to the code; mirrors brandmine's `research/` convention.

**Cons**: A gitignored folder is invisible to everyone but the author — not on
GitHub, not backed up by git, not accessible to a future webmaster. Creates a
second, drift-prone copy of material that already lives in Drive.

**Reason for rejection**: brandmine's `research/` is a *solo* working pile; this is a
*shared club archive* that must outlive one laptop. Drive already solves sharing and
backup; a local folder un-solves them.

### Alternative 2: Link wiki downloads out to Google Drive

**Description**: Don't host downloads in the app; wiki pages link to Drive files.

**Pros**: Zero storage setup; no Supabase bucket needed.

**Cons**: Couples the live site to Drive sharing settings, which expire, break, and
can leak access. Downloads leave our domain; access control is Google's, not ours.

**Reason for rejection**: a published club site should serve its own downloads under
its own RLS, not depend on per-file Drive share state.

### Alternative 3: Commit reference PDFs/images to git

**Description**: Track the corpus and downloadable docs in the repo.

**Pros**: Everything in one place; versioned.

**Cons**: Permanently bloats git history with undiffable binaries; couples reference
material to the code lifecycle; repo grows without bound.

**Reason for rejection**: git is for code, not binary content or app data.

## Implementation Notes

- **Visibility tiers (4).** The wiki visibility model is **public · members · board ·
  draft** (extends GEO-006's three-state with a `board` tier added 2026-06-29). Mapping
  to Georgetown roles: `board` = `admin`/`officer`/`chair`; `members` = `member`/
  `readonly`; `public` = unauthenticated; `draft` = author-only. The `board` tier is the
  wiki home for material currently in the Drive `Board` folder.
- Add a **`wiki-docs`** Supabase storage bucket alongside the GEO-006 `wiki-images`
  bucket, created in the same `074-*.sql` migration. RLS prefixes mirror the tiers:
  `public/` → public read; `members/` → authenticated read; `board/` → officer-role
  read; write → `admin`/`officer`/`chair`.
- The wiki page editor needs an "attach downloadable document" action that uploads to
  `wiki-docs` and inserts a download link into the page.
- Keep using the existing `deno google` task to pull corpus files from Drive during
  authoring; do not copy the whole corpus into the repo.
- This ADR governs the *content architecture*; GEO-006 governs the *wiki feature build*.

## References

- GEO-006 wiki pitch: `docs/plans/2026-06-knowledge-base-wiki.md`
- Document toolchain (source-vs-artifact precedent): `docs/document-toolchain.md` (monorepo root)
- Internal discussion: 2026-06-29 knowledge-base architecture session

## Review Schedule

- Next review: when GEO-006 build starts (validate the `wiki-docs` bucket + RLS shape
  against the actual editor implementation).
- Trigger for review: if download volume/size grows enough to warrant a CDN, or if the
  club moves off Google Drive as its corpus home.

## Appendix: Google Drive → Wiki migration map

**Folder rename is sync-safe.** `scripts/google-drive.ts` resolves every Drive object
by **ID, not name/path** (the `aliases` map holds IDs like `1tXvyP8KdLl…`). Google
Drive IDs are stable across rename and move — so renaming `RC Georgetown BOD → Board`
and `RC Georgetown Club → Club`, and moving files between them, does **not** break the
sync. The only thing that breaks it is *deleting and recreating* a synced file (new
file = new ID): never delete-and-recreate `member-master`, `member-directory`, or
`attendance-roster`; rename/move them instead.

Canonical IDs (from `scripts/google-drive.ts`, 2026-06-29):
- `Club` folder (was "RC Georgetown Club") — `1tXvyP8KdLl7gHLBNAf3-JsK5CwRtmYCt`
- `Board` folder (was "RC Georgetown BOD") — `1LmW-VuJM_tmbWRN2olp0sHlEI8V7V05y`
- `member-master.gsheet` (sensitive → Board) — `1GNhFF7syJKFUgonEdxk4hKH4i8dZIfqc5GD-h0Weqo8`
- `member-directory.gsheet` (roster → Club) — `1SVlgSKCQ0oWx0tfOjGTYidltsSYbKLPs_1uVVooNPvw`
- `attendance-roster.gsheet` (→ Board) — `1L2MpF-TN8JW80DJUrSZiqZ_SmErbS52FqTobKS71f2s`

> If the folder display names change in Drive, update only the **comments/labels** in
> `scripts/google-drive.ts` — the IDs (which do the work) stay the same.

The Drive is consolidated into **two shared folders** (the two Drive share groups), and
each item carries a target **wiki tier** for Phase-2 selective publishing. Migration is
"publish item → its wiki tier," never a bulk dump.

```
📁 Board   (shared: officers only)              → wiki tier when published
   georgetown-member-master.gsheet              → board  (SENSITIVE — source of sync-members)
   rcgt-attendance-roster.gsheet                → board
   Membership/                                  → board
   Suppliers/                                   → board
   Archives/                                    → board (or stays Drive-only)

📁 Club    (shared: all members)                → wiki tier when published
   MEETINGS/ 2020-21 … 2025-26                  → members
   DOCUMENTS/Service Projects/                  → public   (the wiki's public core)
   ASSETS/Logos/                                → public   → wiki-docs downloads
   ASSETS/Themes (Brand)/                       → public   → wiki-docs downloads
   ASSETS/Photo Archive/                        → members
   Public Images/                               → public
   georgetown-member-directory.gsheet           → members  (readable roster)
   Past Presidents Roll                         → public/members (one canonical copy)

📁 _SOURCE (not shared; raw working material)   → never published
   Rotary manuals, scans, drafts authored FROM  → corpus only
```

**Cleanups to resolve before/at migration (the "rough" in the current Drive):**

1. **`Past Presidents Roll` exists 3×** — a `.gsheet` in Club, a `.gdoc` in BOD, and a
   `.gsheet` inside MEETINGS. Pick **one canonical** (the BOD `.gdoc` reads as the
   authoritative narrative); delete or alias the others.
2. **`Public Image` appears ~3×** across DOCUMENTS and ASSETS — **merge into one**
   `Club/Public Images/` to stop drift.
3. **MEETINGS gap** — 2020-21, 2021-22, 2022-23, then 2025-26. **2023-24 and 2024-25
   are missing** — backfill or note as lost.
4. **member-master vs member-directory** — keep distinct: *master* is the sensitive
   source-of-truth (`sync-members` reads it) → **Board/board tier**; *directory* is the
   readable roster → **Club/members tier**. The current Drive already separates them
   (master in BOD, directory in Club) — preserve that.
