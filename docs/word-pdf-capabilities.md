# Word & PDF Capabilities — What's Installed

A reference artifact describing every tool installed in the clubs monorepo for
**creating, editing, converting, and inspecting Word documents and PDFs**.

> Operational how-to (recipes, venv re-create) lives in
> [`docs/document-toolchain.md`](document-toolchain.md). This file is the
> *capability inventory* — what each tool can do and why it's here.

---

## At a glance

| Capability | Tool | Version | Where |
|---|---|---|---|
| Create / edit `.docx` programmatically | **python-docx** | 1.2.0 | root `.venv` |
| `.docx → .pdf` (primary) | **LibreOffice** (`soffice`) headless | 26.2.4.2 | system (Homebrew) |
| `.docx → .pdf` (fallback) | **docx2pdf** | installed | root `.venv` |
| `.md ↔ .docx` (and many formats) | **pandoc** | 3.8 | system (Homebrew) |
| Read / inspect / verify `.docx` | **python-docx** (read mode) | 1.2.0 | root `.venv` |
| Runtime for all Python tooling | **Python** | 3.14.0 | root `.venv` |

The Python tools live in a **shared virtual environment** at the monorepo root
(`/Users/randaleastman/dev/clubs/.venv`, gitignored). The system tools (pandoc,
LibreOffice) were already present via Homebrew.

---

## 1. python-docx — programmatic Word authoring & editing

The core library. Builds `.docx` files from code with full control over styling.

**What it can do:**
- Create documents from scratch or open & modify existing `.docx`
- **Tables** — rows/columns, cell shading, borders, margins, column widths,
  vertical alignment, row heights (the backbone of the RC Georgetown forms)
- **Text styling** — font family, size, bold/italic, colour (RGB), per-run control
- **Layout** — page margins, section properties, paragraph spacing & line height
- **Low-level XML access** (`oxml`) for anything the high-level API doesn't expose —
  e.g. cell background fills, custom borders, soft line breaks inside a cell
- **Read mode** — extract text, count/walk tables, pull cell contents for QA

**In use here:** [`apps/georgetown/docs/templates/build-project-summary-forms.py`](../apps/georgetown/docs/templates/build-project-summary-forms.py)
renders the RC Georgetown house style — azure header block, gold accent text,
azure section bars, thin grey grid, label/answer field rows — entirely from a
`prefill` dict, so a form is generated, never hand-typed.

**Strength:** pixel-level control and reproducibility — the document is a *build
artifact* of code, so it never drifts from its source.
**Limit:** it's a builder library, not a converter — it can't render to PDF on its own.

---

## 2. LibreOffice (headless) — the reliable `.docx → .pdf` path

`soffice --headless` converts Word documents to PDF with no GUI and **no Microsoft
Office required**. This is the **primary** PDF path on macOS.

**What it can do:**
- `.docx → .pdf` (also `.odt`, `.html`, `.rtf`, and back)
- Batch-convert a whole folder
- Renders the *real* Word layout — tables, colours, fonts — faithfully, identically
  on any machine

**Why it's preferred over docx2pdf on macOS:** docx2pdf drives Microsoft Word via
AppleScript, so it needs Word installed and can pop dialogs. LibreOffice headless
has neither dependency — it just works in scripts and CI.

**Strength:** zero-dependency, deterministic, server-friendly.
**Limit:** very exotic Word features can render with minor differences (rare for
form-style documents).

---

## 3. docx2pdf — convenience `.docx → .pdf` (fallback)

A thin Python wrapper for docx→PDF. Installed for completeness and cross-platform
parity (on Windows it uses Word's COM automation cleanly).

**On macOS:** automates Microsoft Word via AppleScript — **only use if Word is
installed**; otherwise prefer LibreOffice (tool #2).

**Strength:** one-line call from Python (`from docx2pdf import convert`).
**Limit:** depends on MS Word being present on macOS; LibreOffice is the better
default here.

---

## 4. pandoc — universal document converter (`.md ↔ .docx` and beyond)

The Swiss-army converter. Its job here is **Markdown ↔ Word** without writing a
build script.

**What it can do:**
- `.md → .docx` (quick Word version of any Markdown doc)
- `.docx → .md` (pull existing Word content back into Markdown)
- Dozens of other formats (HTML, LaTeX, EPUB, PDF-via-LaTeX, etc.)
- Apply a **reference `.docx`** as a style template so converted output matches
  house styling

**When to reach for it vs. python-docx:** pandoc for *fast, structural* conversions
of prose/Markdown; python-docx (the build script) for *precisely styled* forms where
layout fidelity matters.

**Strength:** instant conversion, enormous format coverage.
**Limit:** less fine-grained styling control than python-docx for bespoke layouts.

---

## How the tools combine — typical pipelines

```
Markdown source ──pandoc──▶ .docx                     (quick conversion)

prefill dict ──python-docx──▶ styled .docx ──LibreOffice──▶ .pdf   (the forms pipeline)

existing .docx ──python-docx (read)──▶ verify / extract text       (QA)
```

**The RC Georgetown forms pipeline (live example):**
1. Facts pulled from Supabase (`gt_service_projects`) →
2. a companion Markdown summary (human-readable source of truth) →
3. `build-project-summary-forms.py` (python-docx) renders the styled `.docx` →
4. LibreOffice converts that `.docx` → `.pdf` →
5. both artifacts land in the gitignored `apps/georgetown/forms/` folder.

---

## Quick command reference

```bash
# Build the project-summary Word forms (python-docx)
.venv/bin/python apps/georgetown/docs/templates/build-project-summary-forms.py

# Word → PDF (LibreOffice — preferred)
soffice --headless --convert-to pdf --outdir <out-dir> <file>.docx

# Markdown → Word (pandoc)
pandoc <file>.md -o <file>.docx

# Word → Markdown (pandoc)
pandoc <file>.docx -o <file>.md

# Inspect a .docx (python-docx read mode)
.venv/bin/python -c "from docx import Document; d=Document('<file>.docx'); print(len(d.tables),'tables')"
```

---

*Installed 2026-06-29. Re-create the venv on a fresh clone per
[`docs/document-toolchain.md`](document-toolchain.md); pandoc and LibreOffice come
from Homebrew (`brew install pandoc libreoffice`).*

---

## Comparison with Brandmine's document toolchain

The sibling **brandmine** repo also generates documents — but made the *opposite*
bet, and deliberately so. The two stacks diverge because the **deliverables** differ:
clubs produces **editable Word forms**; brandmine produces **typeset, print-grade,
trilingual PDFs**. Each picked the right tool for its job — this is not drift.

### Side by side

| Capability | **Clubs** (this repo) | **Brandmine** |
|---|---|---|
| Primary deliverable | Editable `.docx` club forms | Typeset PDF products (Brand/Founder Profiles, Market Maps) |
| PDF engine | **LibreOffice** headless (`docx → pdf`) | **Typst** (native, ~517 refs — the spine) |
| Word `.docx` authoring | **python-docx** (primary) | **None** in the product path |
| pandoc | MD ↔ docx conversion utility | Review-only; its PDF path delegates *back* to Typst |
| LibreOffice / `soffice` | Installed for docx→PDF | **Not used** (zero refs) |
| Typst | Not installed | Core engine + full design system |
| Image pipeline | n/a | ImageMagick + Puppeteer map capture |
| Heavy lifting | Python venv + React apps | Deno / TypeScript |
| Fonts | Calibri / self-hosted Open Sans | PT Serif/Sans, Noto CJK (CMYK-aware) |

> Quirk worth noting: **both repos have `python-docx` sitting in a `.venv`** — but
> brandmine never imports it (incidental), while clubs uses it as the engine. Same
> library, opposite roles.

### Why they diverged (it's the output, not an inconsistency)

- **Clubs** produces fillable/printable **club forms** (e.g. the RC Georgetown
  Project Summary) that officers expect as **hand-editable Word documents**. That
  makes `.docx` a first-class artifact → python-docx is exactly right. A typeset PDF
  would be a beautiful document nobody can edit in Word.
- **Brandmine** sells **typeset, trilingual, print-grade PDFs** needing CMYK colour,
  CJK font control, and pixel-level typography → Typst is exactly right. Word would
  be a downgrade, so brandmine treats `.docx` as at most a throwaway review copy
  (a single `print-review.md` pandoc call).

**Word-editable form ≠ typeset print product.** The divergence is two correct
choices for two different jobs.

### The one real gap — and the reference pattern to close it

The capability clubs **lacks** that brandmine has: **typeset, *non-form* PDFs.**
Clubs' PDF route is "render a Word form to PDF via LibreOffice" — perfect for forms,
but it won't match Typst quality for a *designed* document (an annual report, a
sponsorship prospectus, a polished event programme).

If that need arises, brandmine is a **proven reference to copy, not reinvent**:
- `reports/templates/_design-system/` + `_components/` — modular Typst styling
- the `pre-compile-extract → validate → typst compile → proof` pipeline
- parallel per-language compile subagents

Adding Typst to clubs is a single `brew install typst`, which would give clubs **both
lanes** — Word forms *and* typeset PDFs — combining the strengths of each repo.
(Not installed today; documented here as the next step if a designed-PDF need appears.)

Conversely, the capability **brandmine lacks** — true Word authoring — clubs now has.
Brandmine could borrow clubs' `build-project-summary-forms.py` + shared-venv pattern
if it ever needed a genuinely editable Word deliverable (it currently doesn't).

*Comparison based on a 2026-06-29 audit of the brandmine repo.*
