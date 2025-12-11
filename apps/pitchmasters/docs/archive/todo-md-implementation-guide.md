# Instructions for Claude Code: TODO.md Setup & Cloudflare Migration

## 1. Create TODO.md System

```bash
# In pitchmasters project root
cd ~/dev/pitchmasters

# Create TODO.md
cat > TODO.md << 'EOF'
# Pitchmasters TODO

## Current Sprint: Platform Migration (Sept 30 - Oct 13, 2025)

### In Progress 🚧
- [ ] Migrate from Vercel to Cloudflare Pages @infrastructure #critical
  - Research Cloudflare Pages + Vite best practices
  - Document migration steps
  - Test deployment pipeline
  - Verify Supabase connectivity

### Todo 📋
- [ ] Setup multi-club database schema @database #high
- [ ] Implement Toastmasters brand compliance @frontend #high
- [ ] Create meeting management MVP @feature #medium

## Backlog
- [ ] Member directory with search @feature
- [ ] Role assignment system @feature
- [ ] Smart agenda builder @feature
- [ ] Privacy controls dashboard @feature

## Completed ✅

## Notes
**Migration Priority**: Vercel incompatible with China requirements
**Sprint Goal**: Working Cloudflare deployment with multi-club foundation
**Blockers**: None currently
**Decisions**: Cloudflare Pages chosen for global accessibility + proxy support
EOF

# Commit initial TODO
git add TODO.md
git commit -m "Initialize TODO.md for sprint tracking"
```

## 2. Setup GitHub Actions Sync

```bash
# Create workflow directory
mkdir -p .github/workflows

# Create sync workflow
cat > .github/workflows/todo-sync.yml << 'EOF'
name: TODO Sync
on:
  push:
    paths:
      - 'TODO.md'
  workflow_dispatch:

permissions:
  contents: write
  issues: write
  
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Sync TODO to Issues
        run: |
          grep "^- \[ \]" TODO.md | while read -r line; do
            task=$(echo "$line" | sed 's/^- \[ \] //' | sed 's/ @.*//' | sed 's/ #.*//')
            context=$(echo "$line" | grep -o '@[a-z-]*' | sed 's/@//')
            priority=$(echo "$line" | grep -o '#[a-z]*' | sed 's/#//')
            
            # Check if issue exists
            existing=$(gh issue list --search "$task" --json number --jq '.[0].number')
            
            if [ -z "$existing" ]; then
              gh issue create \
                --title "$task" \
                --body "Context: $context\nFrom TODO.md" \
                --label "todo,${priority:-medium},${context:-general}"
            fi
          done
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

# Commit workflow
git add .github/workflows/todo-sync.yml
git commit -m "Add TODO.md → GitHub Issues sync"
git push
```

## 3. Create Cloudflare Migration Checklist

```bash
# Create migration tracking document
mkdir -p docs/sprints
cat > docs/sprints/sprint-1-cloudflare-migration.md << 'EOF'
# Sprint 1: Cloudflare Migration Checklist

## Phase 1: Cloudflare Setup ⏱️ 20 min
- [ ] Create Cloudflare account (free tier)
- [ ] Create Pages project
- [ ] Connect GitHub repository
- [ ] Configure build settings:
  - Framework: Vite
  - Build: `npm run build`
  - Output: `dist`
- [ ] Add environment variables (Supabase)
- [ ] Test deployment at *.pages.dev URL
- [ ] Verify Supabase connection works

## Phase 2: Custom Domain ⏱️ 15 min
- [ ] Add pitchmasters.app to Pages project
- [ ] Note CNAME target provided
- [ ] Update DNS records
- [ ] Enable SSL (Full mode)
- [ ] Test at custom domain

## Phase 3: Verification ⏱️ 10 min
- [ ] App loads correctly
- [ ] Authentication working
- [ ] Mobile responsive (320px test)
- [ ] Fonts loading (self-hosted)
- [ ] Build time acceptable

## Phase 4: DNS Migration ⏱️ Variable
- [ ] Add huaqiao.asia to Cloudflare
- [ ] Note nameservers
- [ ] Update at domain registrar
- [ ] Wait for propagation (24-48hrs)

## Phase 5: Cleanup ⏱️ 5 min
- [ ] Document new deployment URLs
- [ ] Update project README
- [ ] Remove Vercel project (optional)
- [ ] Create dev journal entry

## Rollback Plan
Keep Vercel active during migration. DNS TTL = 300s for quick revert if needed.

## Success Criteria
- ✅ App accessible from Hong Kong (<3s load)
- ✅ Supabase connection verified
- ✅ Self-hosted fonts working
- ✅ Mobile responsive confirmed
- ✅ Build/deploy pipeline operational
EOF

git add docs/sprints/
git commit -m "Add Cloudflare migration checklist"
git push
```

## 4. Update TODO.md with Migration Details

```bash
# Update TODO.md with detailed migration steps
cat > TODO.md << 'EOF'
# Pitchmasters TODO

## Current Sprint: Platform Migration (Sept 30 - Oct 13, 2025)

### In Progress 🚧
- [ ] Migrate Vercel → Cloudflare Pages @infrastructure #critical
  - **Phase 1**: Cloudflare setup (20 min)
  - **Phase 2**: Custom domain (15 min)
  - **Phase 3**: Verification (10 min)
  - **Phase 4**: DNS migration (24-48hrs)
  - **Phase 5**: Cleanup (5 min)
  - See: docs/sprints/sprint-1-cloudflare-migration.md

### Todo 📋
- [ ] Multi-club database schema @database #high
- [ ] Toastmasters brand implementation @frontend #high
- [ ] Meeting management MVP @feature #medium

## Backlog
- [ ] Member directory search @feature
- [ ] Role assignment system @feature
- [ ] Smart agenda builder @feature
- [ ] Privacy controls @feature

## Completed ✅

## Notes
**Current Focus**: Cloudflare migration (Vercel incompatible)
**Sprint Goal**: Working global deployment + multi-club foundation
**Migration Doc**: docs/sprints/sprint-1-cloudflare-migration.md
**Blockers**: None
EOF

git add TODO.md
git commit -m "Update TODO with migration details"
git push
```

---
