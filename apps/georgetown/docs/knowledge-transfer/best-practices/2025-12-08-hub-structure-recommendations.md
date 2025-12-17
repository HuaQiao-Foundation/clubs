# Hub Structure Recommendations

**Date**: 2025-12-08
**Purpose**: Improve Hub directory structure for long-term maintainability
**Audience**: CEO, CTO
**Context**: Hub currently nested within Hugo project for MVP convenience

---

## Executive Summary

Brandmine Hub is production-ready but lives within `/hub/` subdirectory of the Hugo project. This was acceptable for MVP but creates several structural issues as the system matures. This document proposes a reorganization to improve clarity, maintainability, and deployment efficiency.

**Key Issues**:
1. Hub docs scattered across `/hub/doc/`, `/hub/docs/`, and root `docs/`
2. Nested `hub/hub/` structure from legacy code
3. Unclear separation between Hub and Hugo documentation
4. Supabase migrations mixed with project-level concerns
5. Development tooling duplicated

**Recommendation**: Maintain current structure for now, clean up documentation paths, plan future separation when needed.

---

## Current Structure Analysis

### Root Level (`/hub/`)

```
hub/
├── .env.local                 # ✅ Supabase credentials
├── package.json               # ✅ Hub dependencies
├── vite.config.ts             # ✅ Hub build config
├── index.html                 # ✅ Hub entry point
├── src/                       # ✅ React source code
├── supabase/                  # ✅ Database migrations
├── public/                    # ✅ Static assets
├── dist/                      # ⚠️ Build output (should be gitignored)
├── node_modules/              # ⚠️ Dependencies (gitignored)
├── doc/                       # ❌ PROBLEM: Astro starter docs
├── docs/                      # ❌ PROBLEM: Hub-specific docs
├── hub/                       # ❌ PROBLEM: Nested legacy structure
├── scripts/                   # ✅ Build/deploy utilities
├── test-data/                 # ✅ Development data
└── demo/                      # ✅ Demo configuration
```

### Documentation Confusion

**Three doc locations exist**:

1. **`/hub/doc/`** (Astro starter template - UNUSED)
   - Contains boilerplate from Starlight starter
   - Has its own `package.json`, `astro.config.mjs`
   - Creates confusion (is this documentation site?)
   - **Status**: Legacy, should be removed

2. **`/hub/docs/`** (Hub-specific technical docs)
   - `architecture/` - System design
   - `investigation/` - Research notes
   - `prompts/` - Implementation handoffs
   - `pwa/` - PWA documentation
   - **Status**: Useful, but isolated from main docs

3. **`/docs/database/`** (Project-level database docs)
   - Schema design, migrations, guides
   - Shared by both Hugo and Hub
   - **Status**: Correct location (project-level concern)

### Nested Hub Structure

**Problem**: `/hub/hub/` directory exists

```
hub/
└── hub/
    ├── hub/
    │   └── docs/          # Empty
    └── supabase/
        └── migrations/    # Duplicates /hub/supabase/?
```

**Analysis**: Appears to be legacy structure from repository setup. No active use.

**Recommendation**: Delete `/hub/hub/` entirely.

---

## Issues & Recommendations

### Issue 1: Documentation Fragmentation

**Problem**: Hub documentation scattered across 3 locations makes it difficult to find information.

**Current**:
```
/docs/database/           # Project-level (Hub + Hugo)
/hub/doc/                 # Astro starter (unused)
/hub/docs/                # Hub-specific
/hub/README.md            # Hub overview
```

**Recommendation A** (Maintain Separation):
```
/docs/                    # Project-level documentation
├── database/             # Shared database docs (Hub + Hugo)
├── hub/                  # Hub-specific docs (move from /hub/docs/)
│   ├── architecture/
│   ├── pwa/
│   ├── prompts/
│   └── investigation/
├── hugo/                 # Hugo-specific docs (if needed)
├── workflows/
├── adr/
└── dev-journal/

/hub/
├── README.md             # Hub overview (links to /docs/hub/)
└── [no docs/ directory]
```

**Recommendation B** (Keep Hub Docs Separate):
```
/docs/                    # Project-level only
├── database/             # Shared
├── workflows/
├── adr/
└── dev-journal/

/hub/
├── README.md             # Hub overview
├── docs/                 # Hub-specific (keep here)
│   ├── architecture/
│   ├── pwa/
│   ├── prompts/
│   └── investigation/
└── CONTRIBUTING.md       # Hub development guide
```

**Rationale for B**:
- ✅ Hub docs stay with Hub code (locality)
- ✅ Project docs remain project-level
- ✅ Clear boundary between systems
- ✅ Easier to extract Hub as separate repo later

**Action Items**:
1. Delete `/hub/doc/` (Astro starter boilerplate)
2. Keep `/hub/docs/` for Hub-specific documentation
3. Ensure `/hub/README.md` clearly links to relevant docs
4. Update CLAUDE.md to reflect Hub docs location

---

### Issue 2: Nested `/hub/hub/` Structure

**Problem**: Confusing nested directory with no clear purpose.

**Current**:
```
hub/
└── hub/
    ├── hub/
    │   └── docs/          # Empty
    └── supabase/
        └── migrations/    # Appears to duplicate /hub/supabase/
```

**Investigation Needed**:
- Check if `/hub/hub/supabase/` has unique migrations
- Confirm `/hub/hub/docs/` is truly empty
- Verify no code references this path

**Recommendation**:
```bash
# Verify empty/duplicate
ls -la /Users/randaleastman/dev/brandmine-hugo/hub/hub/
ls -la /Users/randaleastman/dev/brandmine-hugo/hub/hub/supabase/migrations/
diff -r /Users/randaleastman/dev/brandmine-hugo/hub/supabase/ /Users/randaleastman/dev/brandmine-hugo/hub/hub/supabase/

# If verified as duplicate/empty, delete
rm -rf /Users/randaleastman/dev/brandmine-hugo/hub/hub/
```

**Risk**: Low (appears to be legacy artifact)

---

### Issue 3: Build Output in Git

**Problem**: `/hub/dist/` contains build output (28 files including assets, screenshots).

**Current**:
```
hub/dist/
├── assets/       # Compiled CSS/JS
├── img/
├── logos/
├── screenshots/
└── index.html
```

**Recommendation**:

**Check `.gitignore`**:
```bash
cat /Users/randaleastman/dev/brandmine-hugo/hub/.gitignore | grep dist
```

If `dist/` **is** gitignored:
- ✅ Correct (build output shouldn't be versioned)
- Action: Remove from repository if accidentally committed

If `dist/` **is NOT** gitignored:
- ❌ Problem: Build artifacts being versioned
- Action: Add to `.gitignore` and remove from git

**Recommended `.gitignore` addition**:
```
# Build outputs
dist/
build/
*.map

# Environment
.env.local
.env.production

# Development
node_modules/
.DS_Store
```

---

### Issue 4: Unclear Separation of Concerns

**Problem**: Some files/directories blur the line between Hub and Hugo.

**Examples**:
- `/hub/public/` - Static assets (Hub-only or shared?)
- `/hub/scripts/` - Build scripts (Hub-only or project-level?)
- `/hub/demo/` - Demo configuration (development-only)

**Recommendation**: Add comments/README files to clarify purpose.

**`/hub/public/README.md`**:
```markdown
# Hub Public Assets

Static files served by Vite dev server and copied to `dist/public/` during build.

**Contents**:
- Favicon, app icons
- Static images (logos, placeholders)
- Fonts (if not using CDN)

**Note**: These are Hub-specific assets, not shared with Hugo site.
```

**`/hub/scripts/README.md`**:
```markdown
# Hub Build Scripts

Utility scripts for Hub development and deployment.

**Scripts**:
- `generate-registry.mjs` - Shadcn component registry
- `ghpages-deploy.mjs` - GitHub Pages deployment
- `supabase-remote-init.mjs` - Supabase initialization

**Usage**: See `package.json` scripts section.
```

---

### Issue 5: Environment File Management

**Current**:
```
hub/
├── .env.local                # Active (gitignored)
└── .env.development.backup   # Backup template
```

**Recommendation**: Add `.env.example` for new developers.

**`/hub/.env.example`**:
```bash
# Hub Environment Configuration
# Copy to .env.local and fill in actual values

# Supabase (required)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
DATABASE_URL=postgresql://postgres:password@host:5432/postgres

# Optional: PWA development mode
# VITE_PWA_DEV=true

# Optional: Sentry error tracking
# VITE_SENTRY_DSN=https://...

# Optional: Feature flags
# VITE_ENABLE_FEATURE_X=true
```

**Update `.gitignore`**:
```
# Environment files
.env.local
.env.*.local
.env.production

# Keep template
!.env.example
```

---

## Recommended Directory Structure

### Short-Term (Maintain Current Nesting)

**Keep Hub within Hugo project** but clean up documentation:

```
/brandmine-hugo/
├── docs/                      # Project-level documentation
│   ├── database/              # Shared (Hub + Hugo)
│   ├── workflows/
│   ├── adr/
│   ├── dev-journal/
│   ├── backlog/
│   ├── prompts/
│   └── briefings/
│
├── hub/                       # Hub application
│   ├── README.md              # Overview + links to docs
│   ├── .env.example           # Environment template
│   ├── .env.local             # Actual credentials (gitignored)
│   ├── package.json
│   ├── vite.config.ts
│   ├── index.html
│   │
│   ├── src/                   # React source
│   ├── public/                # Static assets
│   ├── supabase/              # Database migrations
│   │   └── migrations/
│   ├── scripts/               # Build utilities
│   ├── test-data/             # Development data
│   ├── demo/                  # Demo config
│   │
│   ├── docs/                  # Hub-specific docs
│   │   ├── README.md          # Hub docs index
│   │   ├── architecture/
│   │   ├── pwa/
│   │   ├── prompts/
│   │   └── investigation/
│   │
│   └── [BUILD OUTPUTS - GITIGNORED]
│       ├── dist/
│       └── node_modules/
│
├── content/                   # Hugo content
├── layouts/                   # Hugo templates
├── assets/                    # Hugo assets
├── static/                    # Hugo static files
├── scripts/                   # Sync scripts (Hugo ↔ Supabase)
└── hugo.yaml                  # Hugo config
```

---

### Long-Term (Separate Repositories)

**IF** Hub becomes primary product OR needs independent deployment:

```
/brandmine-hub/                # Hub repository
├── README.md
├── .env.example
├── package.json
├── vite.config.ts
├── index.html
│
├── src/
├── public/
├── supabase/
├── scripts/
├── docs/
│   ├── architecture/
│   ├── pwa/
│   └── development/
│
└── tests/

/brandmine-hugo/               # Hugo repository
├── README.md
├── content/
├── layouts/
├── assets/
├── scripts/
│   └── sync-from-hub.js      # Pull from Hub API
├── docs/
│   ├── workflows/
│   └── technical/
│
└── hugo.yaml

/brandmine-shared/             # Shared schemas/types
├── database/
│   └── schema.sql
├── types/
│   ├── brand.ts
│   ├── founder.ts
│   └── insight.ts
└── README.md
```

**When to Separate**:
- ✅ Hub has dedicated developers (not just CTO)
- ✅ Hub deployment independent from Hugo site
- ✅ Hub becomes primary customer-facing product
- ✅ Version control needs differ (Hub: frequent; Hugo: content-driven)

**Don't Separate If**:
- ❌ Still in MVP/validation phase
- ❌ Single developer maintaining both
- ❌ Deployment tightly coupled
- ❌ Database schema changes affect both simultaneously

---

## Migration Plan

### Phase 1: Documentation Cleanup (1 hour)

**Immediate actions**:

1. **Delete unused Astro docs**:
   ```bash
   cd /Users/randaleastman/dev/brandmine-hugo/hub
   rm -rf doc/                    # Astro starter boilerplate
   ```

2. **Verify and delete nested hub structure**:
   ```bash
   # Investigate first
   ls -la hub/hub/
   diff -r supabase/ hub/supabase/  # Check for differences

   # If confirmed duplicate/empty
   rm -rf hub/hub/
   ```

3. **Add Hub docs README**:
   ```bash
   cat > docs/README.md << 'EOF'
   # Hub Documentation

   Hub-specific technical documentation.

   **For project-level docs**, see [/docs/](/Users/randaleastman/dev/brandmine-hugo/docs/)

   ## Contents
   - [Architecture](architecture/) - System design
   - [PWA](pwa/) - Progressive Web App docs
   - [Prompts](prompts/) - Implementation handoffs
   - [Investigation](investigation/) - Research notes
   EOF
   ```

4. **Add environment template**:
   ```bash
   cat > .env.example << 'EOF'
   # Hub Environment Configuration
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key
   DATABASE_URL=postgresql://postgres:password@host:5432/postgres
   EOF
   ```

5. **Update Hub README.md** to link to docs:
   ```markdown
   # Brandmine Hub

   ## Documentation

   - **User docs**: [hub/docs/](docs/)
   - **Database**: [/docs/database/](/Users/randaleastman/dev/brandmine-hugo/docs/database/)
   - **ADRs**: [/docs/adr/](/Users/randaleastman/dev/brandmine-hugo/docs/adr/)
   ```

**Verification**:
```bash
# Ensure no broken imports
npm run build

# Ensure no git references to deleted paths
git status
git diff --cached
```

---

### Phase 2: Gitignore Audit (30 minutes)

**Check current gitignore**:
```bash
cat .gitignore
```

**Ensure these are ignored**:
```
# Build outputs
dist/
build/
*.map

# Dependencies
node_modules/

# Environment
.env.local
.env.*.local
.env.production

# Development
.DS_Store
*.log
.vscode/
.idea/

# Testing
coverage/

# Keep templates
!.env.example
```

**Remove tracked build artifacts**:
```bash
# If dist/ is in git
git rm -r --cached dist/
git commit -m "chore: Remove build artifacts from version control"
```

---

### Phase 3: Structure Documentation (1 hour)

**Create `hub/STRUCTURE.md`**:
```markdown
# Hub Directory Structure

## Source Code (`/src/`)

- `components/` - React components
  - `atomic-crm/` - CRM feature modules
  - `ui/` - shadcn/ui components
  - `admin/` - Admin utilities
  - `supabase/` - Supabase integration
- `contexts/` - React contexts
- `utils/` - Utility functions

## Configuration

- `vite.config.ts` - Vite build config
- `tailwind.config.ts` - Tailwind CSS config
- `tsconfig.json` - TypeScript config
- `eslint.config.js` - ESLint rules
- `.prettierrc.json` - Code formatting

## Database

- `supabase/migrations/` - Database schema changes
- See [/docs/database/](/Users/randaleastman/dev/brandmine-hugo/docs/database/) for full docs

## Development

- `scripts/` - Build/deploy utilities
- `test-data/` - Development data
- `demo/` - Demo configuration
- `public/` - Static assets

## Documentation

- `docs/` - Hub-specific documentation
- See [/docs/](/Users/randaleastman/dev/brandmine-hugo/docs/) for project docs
```

---

## Action Items

### Immediate (Before Next Deployment)

- [ ] Delete `/hub/doc/` (Astro starter)
- [ ] Investigate `/hub/hub/` structure
- [ ] Delete `/hub/hub/` if confirmed duplicate/empty
- [ ] Add `/hub/.env.example`
- [ ] Add `/hub/docs/README.md`
- [ ] Update `/hub/README.md` with doc links
- [ ] Verify `.gitignore` covers build outputs
- [ ] Remove `dist/` from git if present

### Short-Term (Next Sprint)

- [ ] Create `/hub/STRUCTURE.md`
- [ ] Add README files to `/hub/public/`, `/hub/scripts/`
- [ ] Document relationship between Hub and Hugo in root README
- [ ] Update CLAUDE.md to reflect Hub docs location
- [ ] Audit all `/hub/docs/` content for completeness

### Long-Term (6+ Months)

- [ ] Evaluate repository separation (Hub vs Hugo)
- [ ] Consider monorepo tooling if separation happens (Turborepo, Nx)
- [ ] Plan migration strategy for shared database access
- [ ] Document deployment pipeline for separated repos

---

## Rotary Club Implications

**For Rotary Club project**, apply these learnings from day 1:

1. **Clear separation**: Don't mix frontend and backend in confusing ways
2. **Documentation locality**: Keep app docs with app code
3. **Environment templates**: Always include `.env.example`
4. **Gitignore discipline**: Build outputs never committed
5. **README everywhere**: Every major directory has orientation doc
6. **Structure docs early**: Create `STRUCTURE.md` before codebase grows

**Recommended Structure** (Rotary Club):
```
/rotary-club-app/
├── README.md
├── .env.example
├── STRUCTURE.md
│
├── src/
├── public/
├── supabase/
│   └── migrations/
├── docs/
│   ├── architecture/
│   ├── adr/
│   └── development/
│
└── [GITIGNORED]
    ├── dist/
    ├── node_modules/
    └── .env.local
```

---

## References

### Internal Documentation
- [Hub README](/Users/randaleastman/dev/brandmine-hugo/hub/README.md)
- [Database Documentation](/Users/randaleastman/dev/brandmine-hugo/docs/database/README.md)
- [ADR-0002: Hub as SSOT](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)

### External Resources
- [Vite Project Structure](https://vite.dev/guide/#index-html-and-project-root)
- [React Project Organization](https://react.dev/learn/thinking-in-react#step-1-break-the-ui-into-a-component-hierarchy)
- [Monorepo Best Practices](https://monorepo.tools/)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-08
**Author**: CTO (Claude Code)
**Next Review**: 2026-01-08 (1 month)

**Priority**: Medium (cleanup improves maintainability, not blocking)
