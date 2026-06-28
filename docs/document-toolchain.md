# Document Toolchain (Word / PDF / Markdown)

The monorepo's tooling for generating and converting Word documents — used for
Rotary club forms (project summaries, briefs, approval forms) and any other
`.docx` / `.pdf` deliverables.

## What's installed

| Tool | What it does | How installed |
|---|---|---|
| **python-docx** | Create & edit `.docx` with full styling (tables, colours, fonts, section bars) — the library the form-builder scripts use | `.venv` at monorepo root |
| **docx2pdf** | `.docx → .pdf` (macOS: drives MS Word; prefer LibreOffice below) | `.venv` |
| **pandoc** 3.x | `.md ↔ .docx` (and many other formats) — quick conversions without a build script | Homebrew (system) |
| **LibreOffice** (`soffice`) | Headless `.docx → .pdf` — no MS Office needed, renders identically everywhere | Homebrew (system) |

## The shared venv

A single Python virtual environment lives at the **monorepo root** so any app's
scripts can use it. It is **gitignored** (`.venv/`), so re-create it on a fresh
clone:

```bash
cd /Users/randaleastman/dev/clubs
python3 -m venv .venv
.venv/bin/pip install python-docx docx2pdf
```

Run any document script with the venv's Python (no activation needed):

```bash
.venv/bin/python apps/georgetown/docs/templates/build-project-summary-forms.py
```

## Common recipes

**Build the RC Georgetown project-summary Word forms** (blank template + pre-filled records):
```bash
.venv/bin/python apps/georgetown/docs/templates/build-project-summary-forms.py
# → writes .docx to apps/georgetown/forms/  (and the blank template + aquaponics to docs/templates/)
```

**Convert a `.docx` to PDF** (LibreOffice — the reliable path on macOS):
```bash
soffice --headless --convert-to pdf --outdir <out-dir> <file>.docx
```

**Convert Markdown to Word:**
```bash
pandoc <file>.md -o <file>.docx
```

**Read / inspect / verify a `.docx`** (extract text, count tables, QA a generated form):
```bash
.venv/bin/python -c "from docx import Document; d=Document('<file>.docx'); print(len(d.tables),'tables'); [print(c.text) for t in d.tables for r in t.rows for c in r.cells if c.text.strip()]"
```

## Conventions

- **Source of truth is the build script or the Markdown**, not the `.docx`. The
  `.docx`/`.pdf` are *generated artifacts* — regenerate them rather than hand-editing,
  so the script/MD and the Word file never drift. (Project-summary forms keep a
  companion `.md` in `docs/templates/` as the human-readable source.)
- **Generated forms land in `apps/georgetown/forms/`** (gitignored — see `.gitignore`).
  Templates and build scripts live in `apps/georgetown/docs/templates/` (committed).
- **macOS note:** prefer **LibreOffice** for `docx→pdf`. `docx2pdf` is installed but on
  macOS it automates MS Word via AppleScript, which needs Word present and can prompt;
  LibreOffice headless has neither dependency.
