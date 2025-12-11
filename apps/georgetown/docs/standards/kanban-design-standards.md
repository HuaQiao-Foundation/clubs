# Georgetown Rotary Kanban Board Design Standards

**Status:** Official Project Standard (Adopted October 13, 2025)
**Authority:** CEO Approved
**Applies To:** All kanban board views (Speakers, Projects)
**Research Date:** October 2025 (Industry best practices from Trello, Asana, Jira, Monday.com)

---

## Executive Summary

Georgetown Rotary kanban boards follow **industry-standard horizontal scrolling patterns** used by Trello, Asana, Jira, and other leading kanban tools.

**Key Principle:** Horizontal scroll for columns, vertical scroll within columns. One prominent column + partial next column visible on mobile.

---

## Industry Standard Pattern

### The Trello/Asana Model

All major kanban tools use this pattern:

- ✅ **Horizontal scrolling** for navigating between columns (workflow stages)
- ✅ **Vertical scrolling** within each column (browsing cards/items)
- ✅ **Snap-to-column behavior** for smooth mobile experience
- ✅ **Partial next column visible** as visual hint to scroll
- ✅ **Touch-optimized** swipe gestures on mobile

---

## Mobile-First Implementation

### Layout Specifications

| Screen Size | Columns Visible | Column Width | Scroll Behavior |
|-------------|----------------|--------------|-----------------|
| **Mobile (320-767px)** | 1 full + 15% next | 85-90% viewport width | Horizontal scroll with snap |
| **Tablet (768-1023px)** | 2-3 columns | Fluid (40-50% viewport) | Horizontal scroll with snap |
| **Desktop (1024px+)** | All columns | Fixed 280-320px | Horizontal scroll if needed |

### Visual Design Requirements

**Mobile:**
- Show 85% of current column + 15% of next column (visual scroll hint)
- Snap to column on scroll complete
- Shadow/gradient fade on right edge indicating more content
- Touch-friendly swipe gestures

**Desktop:**
- Show all columns side-by-side if space allows
- Horizontal scroll bar if more columns than fit
- Full drag-and-drop between visible columns
- Auto-scroll when dragging near board edges

---

## Technical Implementation

### CSS Architecture

```css
/* Board Container - Horizontal Scroll Only */
.board-container {
  display: flex;
  overflow-x: auto;          /* Enable horizontal scrolling */
  overflow-y: hidden;        /* Prevent vertical scroll on board */
  scroll-snap-type: x mandatory;  /* Snap to columns */
  gap: 1rem;                 /* Space between columns */
  -webkit-overflow-scrolling: touch;  /* Smooth iOS scrolling */
}

/* Individual Column - Vertical Scroll Only */
.column {
  flex: 0 0 auto;           /* Don't grow/shrink */
  min-width: 85vw;          /* Mobile: 85% viewport width */
  width: 85vw;              /* Mobile: 85% viewport width */
  scroll-snap-align: start;  /* Snap alignment point */
  overflow-y: auto;         /* Enable vertical scroll within column */
  overflow-x: hidden;       /* No horizontal scroll within column */
  display: flex;
  flex-direction: column;
}

/* Desktop: Fixed Width Columns */
@media (min-width: 768px) {
  .column {
    min-width: 320px;
    width: 320px;
  }
}
```

### Tailwind CSS Classes

```tsx
{/* Board Container */}
<div className="flex gap-4 overflow-x-auto overflow-y-hidden snap-x snap-mandatory px-4 pb-4">

  {/* Column */}
  <div className="flex-none w-[85vw] md:w-80 snap-start flex flex-col overflow-y-auto">
    {/* Column header */}
    {/* Cards (vertically scrollable) */}
  </div>

</div>
```

---

## Scroll Conflict Prevention

### Problem: Touch Gesture Conflicts

> "When you scroll down on a particular column, the column is switched to a different one instead of just letting you scroll vertically" - Common UX Issue

### Solution: Proper Overflow Management

```css
/* Board: Only horizontal touch gestures */
.board-container {
  touch-action: pan-x;  /* Allow horizontal pan only */
  overflow-x: auto;
  overflow-y: hidden;
}

/* Column: Only vertical touch gestures */
.column {
  touch-action: pan-y;  /* Allow vertical pan only */
  overflow-y: auto;
  overflow-x: hidden;
}
```

**Result:**
- Vertical swipe on column = scroll cards within column
- Horizontal swipe on board = scroll between columns
- No diagonal scroll conflicts

---

## Drag-and-Drop Behavior

### Desktop Implementation

- Full drag-and-drop between all visible columns
- Auto-scroll board when dragging near left/right edge
- Visual drop zone indicators

### Mobile Implementation

- **Activation Delay:** 200ms press before drag starts (prevents conflict with scroll)
- **Auto-scroll:** Board scrolls when dragging near edges
- **Haptic Feedback:** Vibration on successful drop (if supported)
- **Visual Feedback:** Larger drag preview for touch targets

### Code Pattern

```tsx
const sensors = useSensors(
  useSensor(PointerSensor, {
    activationConstraint: {
      distance: 8,  // Minimum 8px movement to activate drag
      delay: 200,   // Mobile: 200ms delay prevents scroll conflict
      tolerance: 5,
    },
  })
)
```

---

## Visual Indicators

### Required UX Elements

1. **Partial Column Visibility** (Most Important)
   - Mobile: Show 85% of current + 15% of next
   - Creates visual hint that more content exists
   - Industry standard (Trello, Asana, Jira all use this)

2. **Shadow/Gradient Fade** (Optional but Recommended)
   - Right edge shadow indicating more columns
   - Fades when reaching last column

3. **Scroll Indicators** (Optional)
   - Dot indicators showing current column position
   - Chevron buttons for explicit navigation (accessibility)

4. **Scroll Bar** (Hidden by Default on Mobile)
   - Desktop: Show scroll bar
   - Mobile: Hide for cleaner UI (`scrollbar-width: none`)

---

## Responsive Breakpoints

### Mobile (320-767px)

```tsx
<div className="flex gap-3 overflow-x-auto snap-x snap-mandatory">
  <div className="flex-none w-[85vw] snap-start">
    {/* Column content */}
  </div>
</div>
```

**Behavior:**
- 85% viewport width per column
- Snap to column on scroll end
- Touch swipe gestures
- Partial next column visible

### Tablet (768-1023px)

```tsx
<div className="flex gap-4 overflow-x-auto snap-x snap-mandatory">
  <div className="flex-none w-[45vw] md:w-80 snap-start">
    {/* Column content */}
  </div>
</div>
```

**Behavior:**
- 2 columns visible (~45% each)
- Snap to column boundaries
- Touch or mouse scroll

### Desktop (1024px+)

```tsx
<div className="flex gap-4 overflow-x-auto">
  <div className="flex-none w-80 snap-start">
    {/* Column content */}
  </div>
</div>
```

**Behavior:**
- Fixed 320px (w-80) column width
- All columns visible if space allows
- Horizontal scroll if >5-6 columns
- No snap (smooth scroll)

---

## Accessibility

### Keyboard Navigation

- ✅ **Tab:** Move between interactive elements (buttons, cards)
- ✅ **Arrow Keys:** Navigate between cards within column
- ✅ **Shift + Arrow Keys:** Navigate between columns
- ✅ **Enter/Space:** Activate drag-and-drop with keyboard
- ✅ **Escape:** Cancel drag operation

### Screen Reader Support

```tsx
<div
  role="region"
  aria-label="Kanban Board"
  className="flex overflow-x-auto"
>
  <div
    role="list"
    aria-label={`${column.title} column, ${count} items`}
    className="flex-none w-80"
  >
    {/* Cards */}
  </div>
</div>
```

### Focus Management

- Visible focus indicators on all interactive elements
- Focus trap within modals
- Return focus to trigger element after modal close

---

## Performance Considerations

### CSS-Only Scrolling Benefits

- ✅ No JavaScript for scroll position management
- ✅ Native browser smooth scrolling
- ✅ Hardware-accelerated transforms
- ✅ Better battery life on mobile
- ✅ Works without JS enabled

### Optimization Strategies

1. **Virtual Scrolling:** For columns with >100 cards, use virtual scrolling (render only visible cards)
2. **Lazy Loading:** Load card details on-demand
3. **Debounced Updates:** Batch position updates on drag-and-drop
4. **CSS Containment:** Use `contain: layout style` on columns

---

## Anti-Patterns (Do NOT Use)

### ❌ Grid Layout for Kanban Views

```tsx
{/* BAD: Grid wraps columns on mobile, loses kanban mental model */}
<div className="grid grid-cols-1 md:grid-cols-3 gap-4">
  {columns.map(/* ... */)}
</div>
```

**Why It Fails:**
- Breaks horizontal workflow visualization
- No visual continuity between stages
- Requires excessive vertical scrolling on mobile
- Loses "pipeline" mental model of kanban

### ❌ Vertical Stacking on Mobile

```tsx
{/* BAD: Shows one column at a time with no context */}
<div className="md:hidden">
  {columns[currentIndex]}
</div>
```

**Why It Fails:**
- No visual hint that more columns exist
- Requires JS state management
- Doesn't leverage native scroll behavior
- Poor accessibility (no keyboard navigation)

### ❌ Fixed Full-Width Columns on Mobile

```tsx
{/* BAD: Can't see next column, no scroll hint */}
<div className="flex overflow-x-auto">
  <div className="flex-none w-full">
    {/* Full width column */}
  </div>
</div>
```

**Why It Fails:**
- No indication of horizontal scroll
- User doesn't know more columns exist
- Poor discoverability

---

## Testing Requirements

### Visual Testing

**Mobile (375px - iPhone SE):**
- [ ] Single column visible at ~85% width
- [ ] Partial next column visible (~15%)
- [ ] Smooth snap-to-column on scroll
- [ ] Vertical scroll within column works
- [ ] Horizontal swipe between columns works
- [ ] No diagonal scroll conflicts

**Tablet (768px - iPad):**
- [ ] 2-3 columns visible
- [ ] Horizontal scroll smooth
- [ ] Snap to column boundaries
- [ ] Both touch and mouse scroll work

**Desktop (1440px):**
- [ ] All 5-6 columns visible if space allows
- [ ] Horizontal scroll if >6 columns
- [ ] Drag-and-drop between columns works
- [ ] Auto-scroll at board edges during drag

### Functional Testing

- [ ] Drag-and-drop works on all devices
- [ ] Cards stay in correct column after page refresh
- [ ] Real-time updates work (Supabase subscriptions)
- [ ] "Show Dropped" toggle adds/removes column dynamically
- [ ] Keyboard navigation works
- [ ] Screen readers announce columns and counts

### Performance Testing

- [ ] 60fps scrolling on mobile
- [ ] No jank when dragging
- [ ] Smooth animations
- [ ] Fast initial page load (<3s)

---

## Georgetown Implementation Notes

### Speakers Kanban

**Columns:** Ideas → Approached → Agreed → Scheduled → Spoken → (Dropped)

**Special Requirements:**
- Scheduled speakers sort by date (ascending - upcoming first)
- "Spoken" speakers auto-link to Rotary year timeline
- Dropped column hidden by default (toggle to show)

**File:** [src/components/KanbanBoard.tsx](../src/components/KanbanBoard.tsx)

### Projects Kanban

**Columns:** Idea → Planning → Approved → Execution → Completed → (Dropped)

**Special Requirements:**
- Color-coded by Area of Focus (Rotary's 7 areas)
- Project value displayed (RM currency)
- Partner organizations linked
- Auto-link to timeline when marked "Completed"

**File:** [src/components/ServiceProjectsPage.tsx](../src/components/ServiceProjectsPage.tsx)

---

## Code Examples

### Complete Kanban Board Structure

```tsx
export default function KanbanBoard() {
  return (
    <div className="bg-gray-50 min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-[#005daa] shadow-md">
        {/* Navigation */}
      </header>

      {/* Main Content - No max-width constraint for full horizontal scroll */}
      <div className="flex-1 overflow-hidden">
        <DndContext
          sensors={sensors}
          collisionDetection={closestCorners}
          onDragStart={handleDragStart}
          onDragEnd={handleDragEnd}
        >
          {/* Toggle */}
          <div className="px-4 pt-4 pb-2 flex justify-end">
            <button onClick={() => setShowDropped(!showDropped)}>
              {showDropped ? 'Hide Dropped' : 'Show Dropped'}
            </button>
          </div>

          {/* Horizontal Scroll Container */}
          <div className="flex gap-4 overflow-x-auto overflow-y-hidden snap-x snap-mandatory px-4 pb-4 h-full">
            {columns.map((column) => (
              <Column
                key={column.id}
                className="flex-none w-[85vw] md:w-80 snap-start"
              >
                {/* Column content with vertical scroll */}
              </Column>
            ))}
          </div>

          <DragOverlay>{/* Drag preview */}</DragOverlay>
        </DndContext>
      </div>
    </div>
  )
}
```

### Column Component

```tsx
function Column({ id, title, color, count, children }: ColumnProps) {
  return (
    <div className="flex-none w-[85vw] md:w-80 snap-start flex flex-col bg-white border-2 rounded-lg shadow-sm">
      {/* Header - Fixed */}
      <div className={`p-3 border-b-2 ${color} flex justify-between items-center`}>
        <h2 className="font-bold text-sm uppercase">{title}</h2>
        <span className="bg-gray-200 px-2 py-1 rounded-full text-xs">{count}</span>
      </div>

      {/* Content - Scrollable */}
      <div className="flex-1 overflow-y-auto p-2 space-y-2">
        {children}
      </div>

      {/* Footer - Fixed */}
      <div className="p-2 border-t">
        <button className="w-full text-left px-3 py-2 text-gray-600 hover:bg-gray-50 rounded">
          + Add Item
        </button>
      </div>
    </div>
  )
}
```

---

## References

**Research Sources:**
- Interaction Design Foundation: "What Are Kanban Boards? (2025)"
- Medium: "Kanban Board UI System Design" by Kanishk Agrawal
- UX Stack Exchange: "UX Patterns for Horizontal Scrolling"
- Trello, Asana, Jira mobile implementations (analyzed October 2025)

**Key Insight:**
> "Horizontal scrolling is a last resort that often leads to frustrating UX, BUT for kanban boards it's the industry standard because it preserves the workflow visualization and pipeline mental model."

---

**Document Version:** 1.0
**Last Updated:** October 13, 2025
**Next Review:** After 3 months of usage (January 2026)
**Supersedes:** docs/responsive-design-standard.md (Grid approach - only for Cards views, NOT kanban)
