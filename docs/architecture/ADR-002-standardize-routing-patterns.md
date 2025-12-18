# ADR-002: Standardize on Path-Based Routing for Detail Views

**Date:** 2025-12-18
**Status:** ✅ Accepted
**Deciders:** Randal Eastman (CEO), Claude Sonnet 4.5 (CTO)
**Context:** Georgetown Rotary Club Speaker Management System MVP

---

## Context and Problem Statement

The Georgetown Rotary application currently uses **inconsistent routing patterns** for similar functionality:

**Speakers** (RESTful path parameters):
```
URL: /speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3
Pattern: /speakers/:speakerId
```

**Projects** (Query parameters):
```
URL: /projects?id=c55d2a29-c27c-4500-9221-26f9bbda4805
Pattern: /projects?id=:projectId
```

This inconsistency creates:
- Confusion for developers maintaining the codebase
- Suboptimal SEO (search engines prefer path-based URLs)
- Inconsistent user experience (URL patterns don't follow a standard)
- Duplicate patterns in middleware and routing logic

**Key Question:** Should we standardize on a single routing pattern for all detail views?

---

## Decision Drivers

### Must Have
- ✅ **Consistency**: Single routing pattern easier to understand and maintain
- ✅ **SEO optimization**: Search engines prefer path-based URLs over query parameters
- ✅ **User experience**: Cleaner, more intuitive URLs
- ✅ **Backwards compatibility**: Existing shared URLs must continue to work

### Should Have
- Developer experience: Easier to reason about routing patterns
- Code simplicity: Single pattern reduces middleware complexity
- Future scalability: Easy to extend to new resource types

### Could Have
- URL aesthetics: Cleaner appearance in social shares
- Bookmark reliability: Path-based URLs more stable over time

---

## Considered Options

### Option A: Keep Query Parameters (Current Projects Pattern)
**Strategy:** Migrate speakers to use query parameters to match projects

**Example URLs:**
```
/speakers?id=b22acb96-df4b-40bc-aca9-a1f5c20305e3
/projects?id=c55d2a29-c27c-4500-9221-26f9bbda4805
```

**Pros:**
- ✅ Simpler route configuration (no nested routes)
- ✅ Query params familiar from web forms
- ✅ Easy to add multiple filters later

**Cons:**
- ❌ Poor SEO (search engines see query params as less important)
- ❌ Less RESTful (doesn't follow resource hierarchy conventions)
- ❌ Speakers already implemented with path params (would break existing shares)
- ❌ Middleware regex matching more complex for query params

**Verdict:** ❌ REJECTED - SEO disadvantages and would break existing speaker URLs

---

### Option B: Path-Based Parameters for All Resources (CHOSEN)
**Strategy:** Migrate projects to use path parameters to match speakers

**Example URLs:**
```
/speakers/b22acb96-df4b-40bc-aca9-a1f5c20305e3
/projects/c55d2a29-c27c-4500-9221-26f9bbda4805
/partners/12ad3db5-30a0-4fc8-a7fc-2b3c0d293838
/members/3d3b80d2-96c9-40ea-ad6e-d63437bc9b41
/events/be5c4f24-4745-465e-bc0f-fb15f9c51ffa
```

**Pros:**
- ✅ **SEO optimized**: Path-based URLs rank better in search results
- ✅ **RESTful**: Follows standard REST API conventions
- ✅ **Consistent**: Single pattern across all resources
- ✅ **Maintainable**: Easier to understand and extend
- ✅ **Minimal migration**: Only projects need updating (speakers already done)
- ✅ **Clean URLs**: More professional appearance when shared

**Cons:**
- ⚠️ Small refactor needed for projects (estimated < 2 hours)
- ⚠️ Requires backwards compatibility redirect for old project URLs

**Verdict:** ✅ **ACCEPTED** - Best balance for MVP and future scalability

---

### Option C: Keep Mixed Patterns (Status Quo)
**Strategy:** Accept the inconsistency and document it

**Pros:**
- ✅ No migration work needed
- ✅ Both patterns already tested

**Cons:**
- ❌ Ongoing confusion for developers
- ❌ Duplicate middleware logic
- ❌ Poor developer experience
- ❌ Harder to extend to new resources (which pattern to use?)

**Verdict:** ❌ REJECTED - Technical debt will compound over time

---

## Decision Outcome

**Chosen option:** **Option B - Path-Based Parameters for All Resources**

### Implementation Strategy

#### Pattern Standard (All Resources)
```
Resource Type    URL Pattern
-------------    -------------------------------------
Speakers         /speakers/:speakerId
Projects         /projects/:projectId
Partners         /partners/:partnerId
Members          /members/:memberId
Events           /events/:eventId
```

#### URL Parameter Format
- Use UUID v4 format (validated via regex)
- Lowercase hexadecimal with hyphens
- Example: `c55d2a29-c27c-4500-9221-26f9bbda4805`

#### Route Configuration Pattern
```tsx
// Nested routes for detail modals
<Route path="/projects" element={<ServiceProjectsPage />}>
  <Route path=":projectId" element={<ProjectDetailRoute />} />
</Route>
```

#### Middleware Pattern Matching
```typescript
// Path-based regex matching
const projectMatch = url.pathname.match(/^\/projects\/([^/]+)$/)
if (projectMatch) {
  const projectId = projectMatch[1]
  if (UUID_REGEX.test(projectId)) {
    // Handle project detail Open Graph tags
  }
}
```

#### Backwards Compatibility
```tsx
// Redirect old query-based URLs to new path-based URLs
function ProjectQueryRedirect() {
  const [searchParams] = useSearchParams()
  const projectId = searchParams.get('id')

  if (projectId) {
    return <Navigate to={`/projects/${projectId}`} replace />
  }

  return <ServiceProjectsPage />
}
```

---

## Consequences

### Positive

✅ **SEO Improvement**
- Path-based URLs rank higher in search results
- Better crawlability for search engines
- More meaningful URLs in search result snippets

✅ **Consistency Across Application**
- Single routing pattern for all resources
- Easier onboarding for new developers
- Predictable URL structure

✅ **Maintainability**
- Reduced middleware complexity
- Single pattern to test and document
- Easier to extend to new resources

✅ **User Experience**
- Cleaner URLs when sharing on social media
- More professional appearance
- Easier to remember and type

✅ **Developer Experience**
- Clear conventions to follow
- Less cognitive overhead
- Follows React Router best practices

### Negative

⚠️ **Migration Effort**
- Projects need refactoring (estimated < 2 hours)
- Testing required for backwards compatibility
- Documentation updates needed

⚠️ **Backwards Compatibility Required**
- Must support old `/projects?id=uuid` URLs
- Redirect logic adds small complexity
- Social media caches may show old URLs temporarily

### Neutral

📋 **Future Considerations**
- New resources (partners, events, members) should use this pattern
- Document pattern in CLAUDE.md for reference
- Consider sitemap generation with path-based URLs

---

## Implementation Plan

### Migration Timeline
1. **Phase 1**: Create ADR and handoff document ✅ COMPLETE
2. **Phase 2**: Implement projects routing refactor (next session)
3. **Phase 3**: Test and deploy
4. **Phase 4**: Monitor for issues, update documentation

### Files to Modify
1. `apps/georgetown/src/App.tsx` - Update route config
2. `apps/georgetown/src/components/ProjectDetailRoute.tsx` - NEW file
3. `apps/georgetown/src/components/ServiceProjectsPage.tsx` - Remove query param handling
4. `apps/georgetown/src/utils/shareHelpers.ts` - Update URL generation
5. `apps/georgetown/functions/_middleware.ts` - Update pattern matching
6. `apps/georgetown/src/components/ProjectQueryRedirect.tsx` - NEW file (backwards compat)

### Testing Requirements
- ✅ Direct URL access works (`/projects/:uuid`)
- ✅ Navigation from grid updates URL correctly
- ✅ Backwards compatibility (`/projects?id=uuid` redirects)
- ✅ Share button generates new URL format
- ✅ Social media previews work with new URLs
- ✅ Middleware serves correct Open Graph tags

---

## Compliance and Best Practices

### REST API Design
✅ **Resource hierarchy**: Path segments represent resource hierarchy
✅ **Identifiers in path**: Resource IDs belong in the path, not query string
✅ **Query for filtering**: Reserve query parameters for filtering/sorting collections

### SEO Best Practices
✅ **Clean URLs**: Path-based URLs rank better than query parameters
✅ **Semantic structure**: URL structure reflects information architecture
✅ **Shareable URLs**: Path-based URLs more stable for bookmarking

### React Router Conventions
✅ **Nested routes**: Match UI hierarchy with route hierarchy
✅ **URL parameters**: Use `:param` syntax for dynamic segments
✅ **Backwards compat**: Use `<Navigate>` for redirects

---

## Success Criteria

### Technical Success
- [x] ADR documented and approved
- [ ] All resources use path-based routing consistently
- [ ] Backwards compatibility working for old URLs
- [ ] All tests passing (manual and automated)
- [ ] Social sharing working with new URLs

### User Experience Success
- [ ] No broken links from old shares
- [ ] Social media previews show correctly
- [ ] URL structure intuitive and predictable
- [ ] No user-facing errors during migration

### Developer Success
- [ ] Single routing pattern documented
- [ ] Clear examples for future resources
- [ ] Reduced middleware complexity
- [ ] Easier to reason about routing logic

---

## Verification

### Test Commands

```bash
# Test new project URL format
curl -A "Twitterbot/1.0" \
  "https://georgetown-rotary.pages.dev/projects/c55d2a29-c27c-4500-9221-26f9bbda4805" \
  | grep 'og:title'

# Test backwards compatibility redirect
curl -I "https://georgetown-rotary.pages.dev/projects?id=c55d2a29-c27c-4500-9221-26f9bbda4805"
# Expected: 301 redirect to /projects/c55d2a29-c27c-4500-9221-26f9bbda4805

# Test pattern consistency across resources
echo "/speakers/UUID" && \
echo "/projects/UUID" && \
echo "/partners/UUID" && \
echo "/events/UUID" && \
echo "/members/UUID"
# All follow same pattern
```

---

## Risk Assessment

### Low Risk
- ✅ Small number of existing project URLs (few projects in system)
- ✅ Backwards compatibility redirect mitigates broken links
- ✅ Speakers already working as reference implementation
- ✅ Estimated < 2 hours implementation time

### Mitigation Strategies
- **Old URLs**: Redirect to new format (no broken links)
- **Social cache**: Clear Facebook/Twitter/LinkedIn caches manually
- **Testing**: Manual verification on all platforms before marking complete
- **Rollback**: Keep old code in git history, easy to revert if needed

---

## Revision History

| Date | Version | Changes | Reason |
|------|---------|---------|--------|
| 2025-12-18 | 1.0 | Initial ADR - Option B adopted | Standardize routing patterns across app |

---

## Related Documents

- **Implementation Guide**: [docs/handoffs/2025-12-18-refactor-projects-routing.md](../handoffs/2025-12-18-refactor-projects-routing.md)
- **Related ADR**: [docs/architecture/ADR-001-robots-txt-policy.md](ADR-001-robots-txt-policy.md)
- **Reference Implementation**: [apps/georgetown/src/components/SpeakerDetailRoute.tsx](../../apps/georgetown/src/components/SpeakerDetailRoute.tsx)

---

## Notes

This decision aligns with industry best practices and React Router conventions. The path-based routing pattern provides better SEO, cleaner URLs, and a more maintainable codebase.

**Key Learning:** Consistency in routing patterns pays dividends in maintainability. The small upfront migration cost is far less than the ongoing cost of maintaining dual patterns.

**Implementation Note:** The handoff document provides step-by-step implementation details. This ADR captures the "why" - the handoff captures the "how."

---

**Ready for implementation!**
**Next Session:** Follow the implementation guide in the handoff document.
