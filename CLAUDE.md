# Clubs Monorepo

This is a monorepo containing multiple React applications for club management solutions.

## Monorepo Structure

```
clubs/
├── apps/
│   ├── georgetown/      # Rotary speakers and event management app
│   └── pitchmasters/    # Toastmasters club management app
├── package.json         # Root workspace config (npm workspaces)
└── CLAUDE.md           # This file
```

## What Each App Does

### Georgetown ([apps/georgetown](apps/georgetown))
Rotary club speaker and event management system. Handles speaker scheduling, event coordination, member management, and program planning for Rotary clubs.

**Tech Stack**: React 19, TypeScript 5.8, Vite 7, Tailwind CSS, Supabase, React Router 7, TipTap editor, DnD Kit

**Details**: See apps/georgetown/CLAUDE.md

### Pitchmasters ([apps/pitchmasters](apps/pitchmasters))
Toastmasters club management application. Manages club meetings, member roles, speech tracking, and club operations.

**Tech Stack**: React 19, TypeScript 5.7, Vite 7, Tailwind CSS, Supabase, React Router 7, DnD Kit

**Details**: See apps/pitchmasters/CLAUDE.md

## Development Workflow

### Running Applications

```bash
# Run both apps simultaneously
npm run dev

# Run individual apps
npm run dev:georgetown      # Port 5180
npm run dev:pitchmasters    # Port 5190

# Build all apps
npm run build

# Build individual apps
npm run build:georgetown
npm run build:pitchmasters
```

### Code Quality

```bash
# Lint all apps
npm run lint

# Type check all apps
npm run typecheck

# Clean all dependencies and build artifacts
npm run clean
```

## Shared Technologies

Both applications share:
- React 19.x
- TypeScript 5.x
- Vite 7.x
- Tailwind CSS 3.4.x
- Supabase client
- React Router 7.x
- DnD Kit for drag-and-drop

## Monorepo Conventions

### Workspace Management
- Uses npm workspaces (not Yarn or pnpm)
- Dependencies are installed at root with `npm install`
- Each app maintains its own `package.json`
- Shared dependencies are deduplicated automatically

### File Organization
- Each app is self-contained in `apps/<app-name>/`
- App-specific code, configs, and dependencies live within each app directory
- Documentation for shared concerns lives at the root
- App-specific documentation lives in each app's directory

### Environment Variables
- Each app manages its own `.env` files
- Georgetown: Has `.env`, `.env.example`, `.env.local`
- Pitchmasters: Uses `.env.cloudflare.example` as template
- Never commit `.env` files (they're gitignored)

## Deployment

Both apps are deployed to Cloudflare Pages:

### Georgetown
- Build command: `npm run build:georgetown`
- Build output directory: `apps/georgetown/dist`

### Pitchmasters
- Build command: `npm run build:pitchmasters`
- Build output directory: `apps/pitchmasters/dist`

## When Working in This Codebase

1. **Understand the context**: Check which app you're working on and refer to its specific CLAUDE.md
2. **Use workspace commands**: Run commands from the root using the npm scripts
3. **Keep apps independent**: Avoid cross-dependencies between apps unless absolutely necessary
4. **Check app-specific docs**: Each app has its own patterns and conventions documented in its CLAUDE.md
5. **Environment setup**: Ensure the correct `.env` file exists for the app you're working on

## Getting Help

- For Georgetown-specific questions: See apps/georgetown/CLAUDE.md
- For Pitchmasters-specific questions: See apps/pitchmasters/CLAUDE.md
- For monorepo structure questions: Ask about the workspace setup
- For deployment questions: See the deployment section above

## How to Use This Documentation

### For Claude Code (AI Assistant)

When starting work on a specific project, ensure you read:
1. **This file** (root CLAUDE.md) - For monorepo context
2. **Project-specific file** - apps/[project-name]/CLAUDE.md

**Short trigger phrases you can use:**
- "Georgetown context" → I'll read root + Georgetown CLAUDE.md
- "Pitchmasters context" → I'll read root + Pitchmasters CLAUDE.md
- "Monorepo context" → I'll read just the root CLAUDE.md

**Full example**: "I'm working on Georgetown - read the root CLAUDE.md and apps/georgetown/CLAUDE.md before we begin"

### Reading Strategy Options

**Option A - Manual reference** (current setup):
- Keeps root file lightweight
- You mention which files to read when needed
- Example: "Read apps/georgetown/CLAUDE.md for Georgetown context"

**Option B - Auto-load with @ syntax** (alternative):
- Add `@apps/georgetown/CLAUDE.md` to this file
- Loads content immediately when reading root file
- Increases upfront token usage but ensures context is always loaded

The current setup uses **Option A** to keep the root file under 10k words as recommended by best practices.
