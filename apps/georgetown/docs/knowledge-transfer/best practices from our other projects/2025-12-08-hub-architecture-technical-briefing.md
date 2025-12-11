# Hub Architecture Technical Briefing

**Date**: 2025-12-08
**Purpose**: Technical reference for building React + Supabase applications
**Audience**: CTO (for Rotary Club and similar projects)
**Project**: Brandmine Hub (hub.brandmine.io)

---

## Executive Summary

Brandmine Hub is a production React 19 + Supabase CRM built with modern best practices. This document captures architectural decisions, lessons learned, and key principles that apply to similar React + Supabase projects.

**Tech Stack**:
- React 19.1.0 + TypeScript 5.8
- Vite 7 (dev + build)
- Supabase (PostgreSQL + Realtime + Auth + Edge Functions)
- Tailwind CSS 4 + shadcn/ui
- React Admin (ra-core, ra-supabase)
- dnd-kit (drag-and-drop)

**Production Status**: ✅ Deployed at hub.brandmine.io (Cloudflare Pages)
**Deployment History**: 40+ migrations, 30+ ADRs, 2 years development

---

## Table of Contents

1. [Architecture Principles](#architecture-principles)
2. [Database as Single Source of Truth](#database-as-single-source-of-truth)
3. [Supabase Integration](#supabase-integration)
4. [Authentication Strategy](#authentication-strategy)
5. [Migration Philosophy](#migration-philosophy)
6. [React Admin Patterns](#react-admin-patterns)
7. [Drag-and-Drop Implementation](#drag-and-drop-implementation)
8. [Full-Text Search](#full-text-search)
9. [PWA Implementation](#pwa-implementation)
10. [Performance Optimizations](#performance-optimizations)
11. [Circular Debugging Prevention](#circular-debugging-prevention)
12. [Code Quality Lessons](#code-quality-lessons)
13. [Decision Documentation](#decision-documentation)
14. [Key Takeaways](#key-takeaways)

---

## Architecture Principles

### 1. Database as Single Source of Truth (ADR-0002)

**Critical Decision**: Supabase database is the business asset, not the UI layer.

```
┌─────────────────────────────────────────┐
│   SUPABASE (Single Source of Truth)     │
│   • brands, founders, insights          │
│   • contacts, companies, deals, tasks   │
│   • Full schema, all relationships      │
│   THIS IS THE BUSINESS ASSET            │
└─────────────────────────────────────────┘
         │
         ├──► Hub (React Admin) - Data management UI
         ├──► Hugo Site - Presentation layer (read-only)
         └──► CLI Tools - Data sync, content generation
```

**Why This Matters**:
- ✅ UI frameworks are replaceable (React → Next.js → whatever)
- ✅ Database schema is stable, queryable, analyzable
- ✅ Backup strategy focuses on database, not UI state
- ✅ Multiple frontends can query same data

**Rotary Club Implication**: Design database schema first. UI is secondary.

---

### 2. Field Ownership Prevents Conflicts

**Problem**: Multiple systems modifying same data → conflicts, data loss

**Solution**: Explicit field ownership

| Field Group | Owner | Tool | Notes |
|-------------|-------|------|-------|
| **Content fields** | CTO | Markdown files → sync | name, description, strategic_narrative |
| **BD fields** | Team | Hub | relationship_status, contact_notes |
| **Metadata** | System | Auto-generated | created_at, updated_at, search_vector |

**Sync Script Logic**:
```typescript
// sync-to-supabase.js
const updateData = {
  // CTO-owned fields (from markdown)
  name: frontMatter.title,
  description: frontMatter.description,

  // NEVER overwrite Hub-owned fields
  // relationship_status: DO NOT SYNC
  // contact_notes: DO NOT SYNC
}
```

**Rotary Club Implication**: Define clear field ownership if multiple people edit data.

---

### 3. Migrations Are Single Source of Truth

**Philosophy**: Database schema lives in migration files, not documentation.

```
hub/supabase/migrations/
├── 20240730075029_init_db.sql              # Initial schema
├── 20251128093359_dimensions.sql           # Taxonomy system
├── 20251206_convert_brands_taxonomy_to_arrays.sql  # Major refactor
├── 20251207_add_brands_search_vector.sql   # Search capability
└── 20251207_create_passkey_credentials.sql # Auth enhancement
```

**Key Rules**:
1. **Never edit committed migrations** - always create new migration
2. **Migration filenames = timestamp + description** (YYYYMMDD format)
3. **Each migration is idempotent** (uses `IF NOT EXISTS`, `IF EXISTS`)
4. **Test migrations locally before production** (apply to local Supabase)

**Example Idempotent Migration**:
```sql
-- Migration: Add search capability
-- GOOD: Idempotent (safe to run multiple times)
ALTER TABLE brands ADD COLUMN IF NOT EXISTS search_vector tsvector;
CREATE INDEX IF NOT EXISTS idx_brands_search_vector ON brands USING GIN (search_vector);

-- BAD: Not idempotent (fails on second run)
ALTER TABLE brands ADD COLUMN search_vector tsvector;
```

**Rotary Club Implication**: Write every schema change as a migration file from day 1.

---

## Supabase Integration

### 1. Connection Pattern

**Production (Hub)**: Uses Singapore pooler for connection pooling

```typescript
// .env.local
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ... (public, safe to expose)

// PostgreSQL connection (for psql/migrations)
DATABASE_URL=postgresql://postgres.xxx@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres
```

**Client Initialization**:
```typescript
// src/providers/dataProvider.ts
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

**Key Lesson**: Use pooler endpoint for production, direct endpoint for local dev.

---

### 2. Row-Level Security (RLS)

**Every table must have RLS policies**. This is NOT optional.

```sql
-- Migration: 20251127000001_secure_rls_policies.sql

-- 1. Enable RLS
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;

-- 2. Authenticated users can read all brands
CREATE POLICY "Authenticated users can read brands"
  ON brands FOR SELECT
  TO authenticated
  USING (true);

-- 3. Authenticated users can insert brands
CREATE POLICY "Authenticated users can insert brands"
  ON brands FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- 4. Authenticated users can update their own brands
CREATE POLICY "Authenticated users can update brands"
  ON brands FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 5. Service role has full access (for Edge Functions)
CREATE POLICY "Service role has full access"
  ON brands FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
```

**Critical Patterns**:
- `TO authenticated` - Only logged-in users (uses Supabase auth)
- `TO service_role` - Backend functions (uses service key, not anon key)
- `USING (true)` - Read permission (SELECT, UPDATE, DELETE checks this)
- `WITH CHECK (true)` - Write permission (INSERT, UPDATE checks this)

**Debugging RLS**:
```sql
-- Check which policies exist
SELECT * FROM pg_policies WHERE tablename = 'brands';

-- Test query as authenticated user (via Supabase client)
-- If query returns 0 rows when data exists → RLS blocking
```

**Rotary Club Implication**: Add RLS policies from day 1. Default-deny is safer.

---

### 3. Database Views for Performance

**Problem**: React Admin queries can be slow with joins.

**Solution**: Create materialized views or regular views.

```sql
-- Migration: Create optimized card view
CREATE OR REPLACE VIEW brands_card_view AS
SELECT
  b.id,
  b.slug,
  b.name,
  b.country_code,
  b.founded,
  b.relationship_status,
  b.in_pipeline,           -- ⚠️ CRITICAL: Include filterable columns in view
  b.content_tier,
  b.markets,               -- Array field
  b.sectors,               -- Array field
  b.created_at,
  b.updated_at,
  f.name AS founder_name,  -- Join founder
  f.id AS founder_id
FROM brands b
LEFT JOIN founders f ON b.founder_id = f.id;

-- Grant permissions
GRANT SELECT ON brands_card_view TO authenticated;
GRANT SELECT ON brands_card_view TO service_role;
```

**Critical Lesson (ADR-0020 Phase 3)**:

React Admin queries **database views**, not base tables. If you filter by a column that's missing from the view, React Admin won't error—it will **silently return empty results**.

```typescript
// React Admin code
const { data } = useGetList('brands_card_view', {
  filter: { in_pipeline: true }  // ⚠️ Requires in_pipeline in VIEW
})
```

**How We Debugged This**:
1. Brands appeared to save to database (`in_pipeline: true` written)
2. UI showed brands immediately (optimistic update)
3. After refresh, brands disappeared (server-side filter failed)
4. Root cause: `brands_card_view` missing `in_pipeline` column
5. Fix: Added column to view → UI instantly worked

**Verification Query**:
```sql
-- Check view includes required columns
SELECT column_name FROM information_schema.columns
WHERE table_name = 'brands_card_view';
```

**Rotary Club Implication**: Always include filterable/sortable columns in database views.

---

## Authentication Strategy

### 1. WebAuthn Passkeys (ADR-0030)

**Decision**: Use WebAuthn passkeys as primary auth for internal tools.

**Why**:
- ✅ **99%+ phishing resistance** (vs 20-50% for OTP, 60-80% for TOTP)
- ✅ **Solves iOS PWA session isolation** (magic links open Safari, not PWA)
- ✅ **One-tap biometric auth** (3 seconds vs 2 minutes for email OTP)
- ✅ **2025 industry standard** (Apple, Google, Microsoft all pushing passkeys)
- ✅ **Perfect for internal tools** (small team, modern devices)

**Implementation Stack**:
- Frontend: `@simplewebauthn/browser` v13+
- Backend: Supabase Edge Functions with `@simplewebauthn/server` v13+
- Database: PostgreSQL `bytea` column for COSE public keys

**Database Schema**:
```sql
CREATE TABLE passkey_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  credential_id TEXT NOT NULL UNIQUE,        -- Base64URL from browser
  public_key BYTEA NOT NULL,                 -- COSE public key (binary)
  counter BIGINT NOT NULL DEFAULT 0,         -- Replay attack prevention
  transports TEXT[],                         -- usb, nfc, ble, internal
  device_name TEXT,                          -- User-friendly name
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ
);
```

---

### 2. Binary Data Handling (CRITICAL LESSON)

**Problem**: Storing WebAuthn COSE public keys (Uint8Array) in PostgreSQL `bytea` columns.

**Root Cause**: Supabase-js does NOT automatically handle binary data—it JSON-serializes everything.

**❌ What DOES NOT Work**:
```typescript
// WRONG: Uint8Array gets JSON-serialized as {"0":165,"1":1,...}
const publicKey = new Uint8Array([165, 1, 2, 3, ...])
await supabase.from('passkey_credentials').insert({ public_key: publicKey })
// Stored as: UTF-8 text bytes, not binary

// WRONG: ArrayBuffer gets serialized as {}
await supabase.from('passkey_credentials').insert({ public_key: publicKey.buffer })
// Stored as: 2 bytes \x7b7d (hex for `{}`)
```

**✅ What DOES Work**: PostgreSQL hex format (`\x` prefix)

```typescript
/**
 * Convert Uint8Array to PostgreSQL hex format for bytea storage
 * Source: https://github.com/orgs/supabase/discussions/2441
 */
function uint8ArrayToHex(bytes: Uint8Array): string {
  return '\\x' + Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

// Registration: Store public key
const verification = await verifyRegistrationResponse({...});
const publicKeyHex = uint8ArrayToHex(verification.registrationInfo.credentialPublicKey);

await supabase.from('passkey_credentials').insert({
  public_key: publicKeyHex,  // ✅ "\xa5010203..." format
});

// Authentication: Retrieve public key
const { data } = await supabase.from('passkey_credentials').select('*').single();
const publicKey = hexToUint8Array(data.public_key);  // Convert back to Uint8Array

function hexToUint8Array(hex: string): Uint8Array {
  const clean = hex.replace(/^\\x/, '');
  const bytes = clean.match(/.{1,2}/g);
  if (!bytes) throw new Error('Invalid hex format');
  return new Uint8Array(bytes.map(byte => parseInt(byte, 16)));
}
```

**Verification Checklist**:
```sql
-- Check actual stored data
SELECT octet_length(public_key), encode(public_key, 'hex')
FROM passkey_credentials;

-- Should see:
-- octet_length: 77 (typical COSE key)
-- encode: a5010203... (valid CBOR/COSE bytes)

-- NOT:
-- octet_length: 639 (JSON text stored as bytes)
-- octet_length: 2 (empty object {})
```

**Reference**: [docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md](/Users/randaleastman/dev/brandmine-hugo/docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md)

**Rotary Club Implication**: If storing binary data in Supabase, ALWAYS use PostgreSQL hex format.

---

### 3. Session Creation Pattern

**Problem**: Supabase v2 has no direct `admin.createSession(userId)` method.

**Solution**: Two-step pattern using magic link internals (without email delivery)

```typescript
// Edge Function: webauthn-auth-verify/index.ts

// Step 1: Generate magic link (server-side only, NOT sent to user)
const { data: linkData } = await supabaseAdmin.auth.admin.generateLink({
  type: 'magiclink',
  email: userData.user.email,
});

// Step 2: Verify OTP to create session
const { data: sessionData } = await supabaseAdmin.auth.verifyOtp({
  token_hash: linkData.properties.hashed_token,
  type: 'email',
});

// Step 3: Return session tokens to client
return new Response(JSON.stringify({
  verified: true,
  accessToken: sessionData.session.access_token,
  refreshToken: sessionData.session.refresh_token,
}));
```

**Key Points**:
- This is NOT a magic link auth flow (no email sent)
- Hashed token generated and verified server-side
- Passkey biometric auth is the user-facing method
- This pattern works around Supabase v2 API limitations

**Source**: [Supabase Discussion #11854](https://github.com/orgs/supabase/discussions/11854)

**Rotary Club Implication**: For custom auth flows, use `generateLink()` + `verifyOtp()` pattern.

---

## Migration Philosophy

### No Backwards Compatibility During Migrations

**Principle**: Clean architecture > legacy compatibility.

**Example from Hub**:
```typescript
// OLD (Jekyll-style): snake_case, scattered fields
country_code: "ru"
social_linkedin: "username"
social_instagram: "username"

// NEW (Hugo-style): camelCase, consolidated
countryCode: "ru"
socialMedia: { linkedin: "username", instagram: "username" }
```

**Why We Did This**:
- Backwards compatibility creates technical debt
- Slows future development (always checking "will this break old code?")
- Hugo migration was opportunity to fix bad patterns from Jekyll

**Rotary Club Implication**: If migrating from old system, don't preserve bad patterns. Fresh start is better.

---

## React Admin Patterns

### 1. Cache Invalidation After Mutations

**Problem**: React Admin caches queries. After mutation, UI doesn't update until manual refresh.

**Solution**: Explicit cache invalidation + refetch

```typescript
import { useQueryClient } from '@tanstack/react-query';
import { useDataProvider } from 'react-admin';

const BrandRelationshipKanban = () => {
  const queryClient = useQueryClient();
  const dataProvider = useDataProvider();
  const { data: brands, refetch } = useGetList('brands_card_view', {
    filter: { in_pipeline: true }
  });

  const handleRemoveFromPipeline = async (brand: Brand) => {
    try {
      // Update via Supabase directly (not React Admin update)
      const { error } = await supabase
        .from('brands')
        .update({ in_pipeline: false, relationship_status: null })
        .eq('id', brand.id);

      if (error) throw error;

      // Invalidate cache + refetch
      queryClient.invalidateQueries({ queryKey: ['brands'] });
      await refetch();

      notify('Brand removed from pipeline', { type: 'success' });
    } catch (error) {
      notify('Failed to remove brand', { type: 'error' });
      refetch(); // Revert optimistic update
    }
  };
};
```

**When to Use**:
- ✅ After adding/removing items from filtered list
- ✅ After bulk operations
- ✅ After drag-and-drop reordering
- ✅ When updating fields used in server-side filters

**ADR Reference**: ADR-0020 Phase 4 (Brand Kanban UX fixes)

---

### 2. Database Views vs Base Tables

**Key Lesson**: React Admin queries whatever resource name you give it.

```typescript
// BrandList.tsx
<List resource="brands_card_view">  {/* Queries VIEW, not table */}
  <DatagridConfigurable>...</DatagridConfigurable>
</List>
```

**Debugging Pattern**:
```typescript
// 1. Check what React Admin is querying
const { data, isLoading } = useGetList('brands_card_view', {
  filter: { in_pipeline: true },
  sort: { field: 'created_at', order: 'DESC' }
});

console.log('Data:', data);  // Empty array? Check view columns

// 2. Check database view includes required columns
// SQL:
SELECT column_name FROM information_schema.columns
WHERE table_name = 'brands_card_view';
```

---

## Drag-and-Drop Implementation

### Migration from react-beautiful-dnd to dnd-kit (ADR-0020)

**Context**: React 19 broke `@hello-pangea/dnd` (react-beautiful-dnd fork)

**Decision**: Migrate to `dnd-kit` (modern, React 19-compatible)

**Scope**:
- ✅ Story Production Kanban (3-column board)
- ✅ Brand Relationship Kanban (5-column board)
- ✅ Deal Pipeline Kanban (6-column board with complex reordering)
- ✅ Table column reordering (contacts, companies, deals)
- ✅ Task list reordering (incomplete tasks only)

**Result**:
- Bundle reduction: **37 KB gzipped** (441 KB → 404 KB = 8.4% smaller)
- @hello-pangea/dnd completely removed
- All drag-and-drop now on dnd-kit

---

### Critical Pattern: overContainer State

**Problem**: dnd-kit's `useDroppable().isOver` only triggers when hovering over droppable container itself, NOT when hovering over sortable items within.

**Solution**: Track `overContainer` state in `handleDragOver`

```typescript
const [activeId, setActiveId] = useState<string | null>(null);
const [overContainer, setOverContainer] = useState<string | null>(null); // ⚠️ REQUIRED

const handleDragOver = (event: DragOverEvent) => {
  const { over } = event;
  if (!over) {
    setOverContainer(null);
    return;
  }

  // Find which container this item belongs to
  const container = findContainer(over.id as string) || (over.id as string);
  setOverContainer(container);
};

const findContainer = useCallback((id: string): string | null => {
  if (!stages) return null;

  // Check if id is already a stage/container ID
  if (stages.some(stage => stage.value === id)) {
    return id;
  }

  // Search items in each container
  for (const [stage, items] of Object.entries(itemsByStage)) {
    if (items.some(item => String(item.id) === String(id))) {
      return stage;
    }
  }
  return null;
}, [stages, itemsByStage]);
```

**Column Component** (dual condition):
```typescript
<Column
  isDragging={activeId !== null}
  isOverThisColumn={overContainer === stage.value}  // ⚠️ Uses overContainer state
/>

// In Column component:
const { isOver, setNodeRef } = useDroppable({ id: stage });

className={`... ${
  isOver || isOverThisColumn  // Both conditions needed
    ? "bg-primary/10 ring-2 ring-primary/50"
    : isDragging
    ? "bg-muted/30 ring-1 ring-dashed"
    : "bg-muted/30"
}`}
```

**Why This Matters**:
- `isOver` alone doesn't work reliably in multi-item columns
- `overContainer` provides accurate highlighting during drag
- Without this pattern, column highlighting flickers or doesn't work

**Rotary Club Implication**: Use `overContainer` pattern for all multi-container drag-and-drop.

---

## Full-Text Search

### PostgreSQL tsvector + GIN Index Pattern

**Implementation** (Migration 20251207_add_brands_search_vector.sql):

```sql
-- 1. Add tsvector column
ALTER TABLE brands ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- 2. Create GIN index for fast queries
CREATE INDEX IF NOT EXISTS idx_brands_search_vector
  ON brands USING GIN (search_vector);

-- 3. Populate from existing data
-- Weight hierarchy: A (highest) = name, B = slug, C = narrative, D = description
UPDATE brands SET search_vector =
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(slug, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(strategic_narrative, '')), 'C') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'D');

-- 4. Create auto-update function
CREATE OR REPLACE FUNCTION brands_search_vector_update() RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.slug, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.strategic_narrative, '')), 'C') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'D');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Create trigger
CREATE TRIGGER brands_search_vector_update_trigger
  BEFORE INSERT OR UPDATE ON brands
  FOR EACH ROW
  EXECUTE FUNCTION brands_search_vector_update();
```

**Query Pattern**:
```sql
-- Basic search
SELECT slug, name FROM brands
WHERE search_vector @@ to_tsquery('english', 'wine');

-- Phrase search
SELECT slug, name FROM brands
WHERE search_vector @@ to_tsquery('english', 'sparkling & wine');

-- Ranked search (ordered by relevance)
SELECT slug, name, ts_rank(search_vector, query) AS rank
FROM brands, to_tsquery('english', 'wine') query
WHERE search_vector @@ query
ORDER BY rank DESC;
```

**Performance**:
- GIN index makes searches sub-millisecond
- Weight hierarchy ensures name matches rank higher than description matches
- Auto-update trigger keeps search_vector synchronized

**Rotary Club Implication**: Use PostgreSQL full-text search for internal tools (no need for Algolia/ElasticSearch).

---

## PWA Implementation

### Minimal PWA Strategy (ADR-0025)

**Decision**: PWA for offline capability, NOT native app features.

**Configuration**:
```typescript
// vite.config.ts
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    VitePWA({
      registerType: 'prompt',          // User-controlled updates
      strategies: 'generateSW',        // Automatic Workbox config
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/.*\.supabase\.co\/rest\/v1\/.*/,
            handler: 'NetworkFirst',   // Always try network first
            options: {
              cacheName: 'supabase-api-cache',
              expiration: { maxAgeSeconds: 60 * 5 }, // 5 min cache
              networkTimeoutSeconds: 10,
            },
          },
        ],
      },
    }),
  ],
});
```

**Key Decisions**:
- ✅ **NetworkFirst** for API (always fresh data when online)
- ✅ **CacheFirst** for static assets (fast loading)
- ✅ **5-minute cache** for reads (balance freshness + offline)
- ✅ **No cache** for auth endpoints or mutations (security)
- ✅ **User-controlled updates** (no forced refresh during work)

**Development Commands**:
```bash
npm run dev          # PWA disabled (HMR works)
npm run dev:pwa      # PWA enabled (test service worker)
npm run preview:pwa  # Test production PWA build
npm run lighthouse   # Audit PWA compliance
```

**Why PWA Disabled by Default in Dev**:
- Service workers cache files → conflicts with HMR
- Developers need live reload, not offline capability
- Only enable PWA in dev when testing service worker behavior

**Rotary Club Implication**: Add PWA from day 1 for offline capability, but keep it simple.

---

## Circular Debugging Prevention

### Protocol (ADR-0026)

**Purpose**: Stop wasting time repeating failed debugging approaches.

**When to Create Technical Reference Doc**:
- ✅ Second failed approach to same problem
- ✅ Multiple possible solutions (3+ approaches)
- ✅ Integration between unfamiliar libraries/systems
- ✅ Behavior contradicts documentation
- ✅ Issue requires web research

**Process**:
1. **Recognize complexity** - Trigger on second failed attempt
2. **Create technical reference doc** - `docs/dev-journal/YYYY-MM-DD-[problem]-reference.md`
3. **Document ALL attempts** - Failed and successful, with timestamps
4. **Link from handoff prompts** - Force reading reference before changes
5. **Research before attempting** - Check docs, GitHub issues, Stack Overflow

**Required Sections**:
- ❌ **What DOES NOT Work** - All failed approaches with evidence
- ✅ **What DOES Work** - Proven solution with code
- **Timeline of Attempts** - Chronological log
- **Research Sources** - Links to official docs, discussions
- **Verification Checklist** - How to confirm it works

**Example**: [WebAuthn Supabase Binary Data Reference](/Users/randaleastman/dev/brandmine-hugo/docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md)

**Rotary Club Implication**: Document complex debugging sessions IMMEDIATELY, not later.

---

## Code Quality Lessons

### 1. Shared Components Reduce Duplication

**Problem**: 5 nearly identical CSV import dialogs (~2,400 lines total)

**Solution** (deferred to backlog):
```typescript
// Generic CSV import dialog
<CSVImportDialog
  resource="brands"
  fields={[
    { key: 'name', label: 'Brand Name', required: true },
    { key: 'country_code', label: 'Country', required: true },
    { key: 'founded', label: 'Founded Year', type: 'number' },
  ]}
  onImport={async (data) => {
    await supabase.from('brands').insert(data);
  }}
/>
```

**Identified Duplication**:
- CSV import dialogs: ~2,400 lines (5 resources)
- Table view components: ~2,000 lines (4 resources)
- Filter modals: ~800 lines (3 resources)

**Total Potential Reduction**: ~5,200 lines → ~1,000 lines (80% reduction)

**Lesson**: Build shared components early, not after duplication exists.

---

### 2. TypeScript Strictness

**Current State**: 972 `any` type usages in Hub codebase

**Key Offenders**:
- `filter-form.tsx` - 200+ `any` usages
- `dataProvider.ts` - 150+ `any` usages
- CSV import dialogs - 100+ `any` usages per file

**Recommendation**:
1. Enable `noImplicitAny: true` in tsconfig
2. Fix existing `any` usages incrementally (file by file)
3. Enforce strict typing in code review

**Rotary Club Implication**: Enable TypeScript strict mode from day 1.

---

### 3. Disabled Features Should Be Fixed or Removed

**Found in Hub**:
```typescript
// dataProvider.ts:396-431
// Full-text search implementation - CURRENTLY DISABLED
if (params.filter?.q) {
  // TODO: Implement full-text search
  return params;  // Returns unchanged (search does nothing)
}
```

**Better Approach**:
```typescript
// Either implement it:
if (params.filter?.q) {
  filters.push(`search_vector @@ to_tsquery('${params.filter.q}')`);
}

// Or remove it and document why:
// Full-text search removed - use Supabase dashboard for admin searches
```

**Lesson**: Don't ship half-implemented features. Finish or remove.

---

## Decision Documentation

### Architecture Decision Records (ADRs)

**Location**: `docs/adr/` (30 ADRs total)

**Naming Convention**: `0000-descriptive-kebab-case-name.md`

**Template**:
```markdown
# ADR-XXXX: Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Context**: What problem are we solving?
**Decision Maker**: Who made this call?

## Context
What's the situation? What constraints exist?

## Decision
What are we doing?

## Alternatives Considered
What else did we evaluate? Why rejected?

## Consequences
### Positive
What benefits does this bring?

### Negative
What downsides or risks?

### Neutral
What changes but isn't good or bad?

## Implementation
How do we do this?

## Monitoring
How do we know it's working?
```

**Examples from Hub**:
- [ADR-0002: Hub as Single Source of Truth](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)
- [ADR-0020: dnd-kit Migration for React 19](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0020-dnd-kit-migration-for-react-19.md)
- [ADR-0030: WebAuthn Passkeys Primary Authentication](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0030-webauthn-passkeys-primary-authentication.md)

**When to Write ADR**:
- ✅ Technology choice (React Admin vs custom, dnd-kit vs alternatives)
- ✅ Architecture pattern (SSOT, field ownership, migration philosophy)
- ✅ Security decision (passkeys vs magic links)
- ✅ Performance trade-off (bundle size vs features)

**Rotary Club Implication**: Document big decisions as ADRs from day 1. Future you will thank you.

---

## Key Takeaways

### For React + Supabase Projects

1. **Database First**: Design schema before building UI. Database is the business asset.

2. **Row-Level Security**: Enable RLS on every table. Write policies before inserting data.

3. **Migration Philosophy**: Every schema change = migration file. Idempotent migrations only.

4. **Binary Data**: Use PostgreSQL hex format (`\x...`) for Supabase-js binary storage.

5. **Cache Invalidation**: React Admin doesn't auto-refresh. Explicit `invalidateQueries()` + `refetch()`.

6. **Database Views**: Always include filterable columns in views. React Admin queries views, not tables.

7. **Full-Text Search**: Use PostgreSQL `tsvector` + GIN index for internal tools. No need for Algolia.

8. **Drag-and-Drop**: Use `overContainer` state pattern for multi-container dnd-kit boards.

9. **PWA**: Simple strategy (offline-first for static, network-first for API). User-controlled updates.

10. **WebAuthn**: Best auth for internal tools. Hex format for binary keys, `generateLink()` + `verifyOtp()` for sessions.

11. **Circular Debugging**: Document complex debugging IMMEDIATELY. Save future time.

12. **TypeScript Strict**: Enable strict mode from day 1. Fix `any` usages incrementally.

13. **ADRs**: Document big decisions. Future developers (including you) need context.

14. **Shared Components**: Build generic components early, not after duplication exists.

15. **Field Ownership**: Explicit ownership prevents conflicts when multiple systems edit data.

---

## References

### Hub Documentation
- [Hub README](/Users/randaleastman/dev/brandmine-hugo/hub/README.md)
- [Database README](/Users/randaleastman/dev/brandmine-hugo/docs/database/README.md)
- [ADRs Index](/Users/randaleastman/dev/brandmine-hugo/docs/adr/README.md)

### Technical References
- [WebAuthn Binary Data Reference](/Users/randaleastman/dev/brandmine-hugo/docs/dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md)
- [ADR-0002: SSOT](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0002-hub-as-single-source-of-truth.md)
- [ADR-0020: dnd-kit Migration](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0020-dnd-kit-migration-for-react-19.md)
- [ADR-0030: WebAuthn](/Users/randaleastman/dev/brandmine-hugo/docs/adr/0030-webauthn-passkeys-primary-authentication.md)

### External Resources
- [Supabase Binary Data Discussion](https://github.com/orgs/supabase/discussions/2441)
- [Supabase Session Creation Pattern](https://github.com/orgs/supabase/discussions/11854)
- [SimpleWebAuthn Documentation](https://simplewebauthn.dev/)
- [dnd-kit Documentation](https://docs.dndkit.com/)
- [React Admin Documentation](https://marmelab.com/react-admin/)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-08
**Author**: CTO (Claude Code)
**Next Review**: 2026-01-08 (1 month)

**Status**: ✅ Production-ready reference for similar projects
