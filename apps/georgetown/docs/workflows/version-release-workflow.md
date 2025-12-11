# Version & Release Workflow

## Overview
Georgetown Rotary uses Semantic Versioning (SemVer) with automatic version display in the app footer.

## Version Format: MAJOR.MINOR.PATCH

- **PATCH** (1.0.0 → 1.0.1): Bug fixes only
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **MAJOR** (1.0.0 → 2.0.0): Breaking changes

## Versioning Commands

```bash
npm version patch   # Bug fixes: 1.0.0 → 1.0.1
npm version minor   # New features: 1.0.0 → 1.1.0
npm version major   # Breaking changes: 1.0.0 → 2.0.0
```

**What these commands do:**
1. Auto-increment version in `package.json`
2. Create git commit with version number
3. Create git tag (e.g., `v1.1.0`)

## When to Bump Version

**Do Bump Version:**
- ✅ Before deploying a release to production
- ✅ After completing a major feature (timeline, photos, partners)
- ✅ After fixing critical bugs ready for deployment

**Don't Bump Version:**
- ❌ For every commit during development
- ❌ For work-in-progress features
- ❌ For local testing

## Typical Release Workflow

```bash
# 1. Complete feature/bug fixes
git add .
git commit -m "Complete timeline feature"

# 2. Test locally
npm run build
npm run preview

# 3. Bump version (choose appropriate level)
npm version minor   # For new features

# 4. Push to repository (includes tags)
git push origin main --tags

# 5. Deploy to production
npm run build
# Deploy to Cloudflare Pages
```

## Version Display

Version automatically displays in app footer:
```
v1.1.0 • Built by Brandmine.io with ♡ for HuaQiao.asia • 2025
```

**Auto-updated from:** `package.json` version field via Vite build-time injection

## Version History

View release history:
```bash
git tag               # List all version tags
git log --oneline     # See commit history with versions
```

## Best Practices

1. **Update before deployment** - Not after every commit
2. **Use git tags** - Allows rollback to specific versions
3. **Document changes** - Reference version in dev journals
4. **Follow SemVer** - Makes version numbers meaningful

## Example Version Timeline

- **v1.0.0** - Initial speaker kanban system (current)
- **v1.1.0** - Added timeline feature (next minor release)
- **v1.2.0** - Added photo gallery (future minor release)
- **v1.2.1** - Fixed photo upload bug (future patch)
- **v2.0.0** - Major redesign with breaking changes (hypothetical)
