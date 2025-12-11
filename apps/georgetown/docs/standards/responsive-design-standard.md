# Georgetown Rotary Responsive Design Standard - Cards View Only

**Status:** Official Project Standard (Adopted October 13, 2025)
**Authority:** CEO Approved
**Applies To:** Cards views and gallery layouts ONLY (NOT kanban boards)
**See Also:** [docs/kanban-design-standards.md](./kanban-design-standards.md) for kanban board design

---

## ⚠️ IMPORTANT: Cards View vs Kanban View

**This document applies ONLY to CARDS views (grid-based card galleries).**

**For KANBAN boards, see: [docs/kanban-design-standards.md](./kanban-design-standards.md)**

**Key Differences:**
- **Cards View:** Grid layout with wrapping columns (this document)
- **Kanban View:** Horizontal scroll with fixed-width columns (see kanban-design-standards.md)

---

## Executive Summary

Georgetown Rotary uses **CSS Grid with mobile-first responsive breakpoints** for **Cards views and gallery layouts ONLY**.

**Key Principle:** Simplicity over complexity. Use CSS Grid for cards, horizontal scroll for kanban.

---

## Standard Implementation Pattern

### Kanban Views (6-column workflow)

```tsx
<div className={`grid gap-4 px-4 pb-4 ${
  showDropped
    ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6'
    : 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5'
}`}>
  {columns.map((column) => (
    <Column key={column.id} {...columnProps}>
      {/* Column content */}
    </Column>
  ))}
</div>
```

### Card Views (4-column layout)

```tsx
<div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
  {items.map((item) => (
    <Card key={item.id} {...item} />
  ))}
</div>
```

---

## Responsive Breakpoints

| Breakpoint | Min Width | Grid Columns (Kanban) | Grid Columns (Cards) | Use Case |
|------------|-----------|----------------------|---------------------|----------|
| **Mobile** | 0px | 1 column | 1-2 columns | Phones (320px-767px) |
| **Tablet** | 768px (`md:`) | 2 columns | 2-3 columns | iPads, tablets |
| **Laptop** | 1024px (`lg:`) | 3 columns | 3 columns | Small laptops |
| **Desktop** | 1280px (`xl:`) | 5-6 columns | 4 columns | Large screens |

---

## Design Rationale

### Why Grid Over Swipe Navigation?

**Business Context (from CLAUDE.md):**
> "Mobile-first design (members primarily use phones during meetings)"

Rotary officers need to **see the big picture quickly** during meetings. Grid approach provides:

1. **Context Awareness:** Multiple columns visible at once, even on mobile
2. **Faster Navigation:** Scroll vertically (natural mobile pattern) vs. swiping between hidden columns
3. **Better Drag-and-Drop:** Drop targets always visible (no need to swipe while dragging)
4. **Simpler Code:** ~150 fewer lines of code, single unified codebase
5. **Accessibility:** Works with keyboard, mouse, trackpad, and assistive devices

### Comparison: Grid vs. Swipe

| Aspect | Grid (Standard) | Swipe (Deprecated) |
|--------|----------------|-------------------|
| Code Complexity | ✅ Low (~20 lines) | ❌ High (~150 lines) |
| Maintenance | ✅ Single codebase | ❌ Separate mobile/desktop paths |
| Context Awareness | ✅ See multiple columns | ❌ One column at a time |
| Drag-and-Drop UX | ✅ Visible drop targets | ⚠️ Complex cross-column |
| Performance | ✅ CSS-only | ⚠️ JS re-renders on touch |

---

## Implementation Checklist

When creating a new multi-column layout:

- [ ] Use CSS Grid (`grid` class)
- [ ] Define mobile-first breakpoints (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`)
- [ ] Add consistent gap spacing (`gap-4`)
- [ ] Add responsive padding (`px-4 pb-4`)
- [ ] Ensure columns wrap naturally on smaller screens
- [ ] Test at all breakpoints (320px, 768px, 1024px, 1280px+)
- [ ] Verify drag-and-drop works on mobile (if applicable)
- [ ] No JavaScript for layout logic (only for drag-and-drop state)

---

## Anti-Patterns (Do NOT Use)

❌ **Custom Mobile Navigation with State**
```tsx
// BAD: Separate mobile/desktop code paths
<div className="md:hidden">
  <MobileSwipeNavigation />
</div>
<div className="hidden md:flex">
  <DesktopColumns />
</div>
```

❌ **Touch Gesture Handlers for Column Navigation**
```tsx
// BAD: JavaScript for layout navigation
const [mobileColumnIndex, setMobileColumnIndex] = useState(0)
const onTouchStart = (e) => { /* ... */ }
const onTouchEnd = () => { /* ... */ }
```

❌ **Horizontal Scroll with `overflow-x-auto`**
```tsx
// BAD: Forces horizontal scrolling on mobile
<div className="flex overflow-x-auto">
  {columns.map(/* ... */)}
</div>
```

✅ **Use This Instead:**
```tsx
// GOOD: Single unified grid layout
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {columns.map(/* ... */)}
</div>
```

---

## Testing Requirements

Before committing layout changes, verify:

1. **Mobile (320px-767px):** Single column, vertical scroll, all content accessible
2. **Tablet (768px-1023px):** 2 columns, balanced distribution
3. **Laptop (1024px-1279px):** 3 columns, comfortable viewing
4. **Desktop (1280px+):** 5-6 columns (kanban) or 4 columns (cards), full utilization of screen

**Test Commands:**
```bash
npm run dev           # Test at http://localhost:5174
npm run build         # Verify no TypeScript errors
npm run preview       # Test production build
```

**Browser DevTools:**
- Chrome/Safari: Cmd+Option+I → Toggle device toolbar (Cmd+Shift+M)
- Test at: iPhone SE (375px), iPad Mini (768px), Laptop (1024px), Desktop (1440px)

---

## Migration Guide

If you find old swipe-based navigation code:

1. **Identify State Variables:**
   - Remove: `mobileColumnIndex`, `touchStart`, `touchEnd`

2. **Remove Touch Handlers:**
   - Delete: `onTouchStart`, `onTouchMove`, `onTouchEnd` functions

3. **Remove Conditional Rendering:**
   - Delete: `<div className="md:hidden">` and `<div className="hidden md:flex">` wrappers

4. **Replace with Grid:**
   - Add: `<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">`

5. **Remove Unused Imports:**
   - Delete: `ChevronLeft`, `ChevronRight` from lucide-react
   - Delete: `TouchEvent` from React

6. **Test Thoroughly:**
   - Run `npm run build` to verify TypeScript
   - Test drag-and-drop on mobile and desktop
   - Test at all breakpoints

**Example Migration:** See [KanbanBoard.tsx](../src/components/KanbanBoard.tsx) commit on October 13, 2025

---

## Examples in Codebase

**✅ Correct Implementation (Speakers Kanban):**
- File: [src/components/KanbanBoard.tsx](../src/components/KanbanBoard.tsx#L502-L533)
- Lines: 502-533 (Grid layout with responsive breakpoints)

**✅ Correct Implementation (Projects Kanban):**
- File: [src/components/ServiceProjectsPage.tsx](../src/components/ServiceProjectsPage.tsx#L863)
- Line: 863 (Grid layout matching Speakers pattern)

**✅ Correct Implementation (Cards View):**
- File: [src/components/KanbanBoard.tsx](../src/components/KanbanBoard.tsx#L649)
- Line: 649 (4-column card grid)

---

## Mobile-First Principles

From Georgetown's business requirements:

1. **44px Minimum Touch Targets:** All interactive elements (buttons, cards) must be at least 44px tall
2. **Thumb-Friendly Navigation:** Primary actions in lower half of screen on mobile
3. **Vertical Scroll Preferred:** Natural mobile pattern, no horizontal scrolling
4. **Progressive Enhancement:** Start with 1 column, add more columns as screen grows
5. **Test on Real Devices:** iPhone SE (smallest common device), iPad Mini, laptops

---

## Performance Considerations

**Grid Layout Benefits:**
- ✅ No JavaScript execution for layout changes
- ✅ No re-renders on screen resize (CSS handles it)
- ✅ No touch event listeners (reduced battery drain)
- ✅ GPU-accelerated CSS transforms
- ✅ Smaller bundle size (~150 fewer lines of code)

**Tailwind CSS Grid Classes:**
- `grid`: Establishes grid container
- `grid-cols-1`: 1 column on mobile (default)
- `md:grid-cols-2`: 2 columns on tablet (768px+)
- `lg:grid-cols-3`: 3 columns on laptop (1024px+)
- `xl:grid-cols-6`: 6 columns on desktop (1280px+)
- `gap-4`: 1rem (16px) gap between columns

---

## Accessibility

Grid layout ensures:

- ✅ **Keyboard Navigation:** Tab through all columns naturally
- ✅ **Screen Readers:** Announce all columns without JS state
- ✅ **Focus Management:** No hidden columns to lose focus
- ✅ **No Motion Triggers:** Static layout prevents motion sickness
- ✅ **Zoom Support:** Content reflows naturally at 200% zoom

---

## Questions?

**For Implementation Help:**
- Review [KanbanBoard.tsx](../src/components/KanbanBoard.tsx) (Speakers kanban)
- Review [ServiceProjectsPage.tsx](../src/components/ServiceProjectsPage.tsx) (Projects kanban)

**For Design Decisions:**
- See [docs/expert-standards.md](./expert-standards.md) - Full-stack verification requirements
- See [docs/rotary-brand-guide.md](./rotary-brand-guide.md) - Rotary branding standards
- See [CLAUDE.md](../CLAUDE.md) - Business context and constraints

**For Technical Questions:**
- Reference this document in code reviews
- Create dev journal entry if implementing new pattern
- Ask CEO for business clarification on mobile UX priorities

---

**Document Version:** 1.0
**Last Updated:** October 13, 2025
**Next Review:** After 3 months of usage (January 2026)
