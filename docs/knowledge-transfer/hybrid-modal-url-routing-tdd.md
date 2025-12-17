# Technical Design Document: Hybrid Modal + URL Routing Architecture

**Document Type:** Technical Design Document (TDD)
**Version:** 1.0
**Date:** 2025-12-17
**Author:** Georgetown Development Team
**Target Audience:** CTOs, Technical Leads, Senior Engineers
**Status:** Proposed for Georgetown, HuaQiao, BrandMine

---

## Executive Summary

This document proposes migrating from a **modal-only architecture** to a **hybrid modal + URL routing architecture** for card detail views across our React applications. This approach maintains the superior UX of modal overlays while gaining the technical benefits of URL-based routing: shareable links, browser history integration, bookmarking, and deep linking.

**Business Impact:**
- ✅ Improved team collaboration (shareable links to specific items)
- ✅ Better cross-device workflows (bookmark on laptop, open on phone)
- ✅ Professional client experience (expected in modern web apps)
- ✅ Enhanced analytics capabilities (track views per item)
- ✅ SEO benefits for public-facing content

**Technical Impact:**
- ✅ Browser back/forward buttons work intuitively
- ✅ Deep linking from external apps (Slack, email, docs)
- ✅ Tab management for power users (compare multiple items)
- ✅ URL-based state management (reduces complexity)

**Implementation Effort:** ~15-20 hours per application
**Risk Level:** Low (incremental changes, no breaking changes)

---

## Problem Statement

### Current Architecture: Modal-Only

**How it works:**
```typescript
// Current: Component-based state management
const [isModalOpen, setIsModalOpen] = useState(false)

<SpeakerCard onClick={() => setIsModalOpen(true)} />
{isModalOpen && <SpeakerDetailModal onClose={() => setIsModalOpen(false)} />}
```

**URL behavior:**
```
User action:           URL state:
Board view          → /speakers
Click speaker card  → /speakers  (unchanged!)
Modal opens         → /speakers  (still unchanged)
Close modal         → /speakers
```

### Problems with Modal-Only

| Problem | User Impact | Business Impact |
|---------|-------------|-----------------|
| **No shareable URLs** | Can't send link to specific speaker | Team collaboration friction |
| **Back button breaks** | Back button exits app instead of closing modal | Violates user expectations |
| **No bookmarking** | Can't bookmark specific items | Reduced productivity |
| **No deep linking** | External apps can't link to specific items | Integration limitations |
| **No tab management** | Can't open multiple items in tabs | Power user friction |
| **No analytics per item** | Can't track which items are viewed most | Missing business insights |

### Real-World Example

**Scenario:** Rotary club committee meeting (5 people)

**Current (Modal-Only):**
```
Chair: "Let's review the Water Well Project"
Action: Chair opens modal on screen
Problem: Others must manually search for project on their screens
Time lost: ~30 seconds per person × 5 people = 2.5 minutes
Frustration: High ("which project?", "I can't find it", "how do you spell it?")
```

**Desired (Hybrid):**
```
Chair: "Review this: [pastes link in chat]"
Action: Committee members click link
Result: Everyone's screen shows Water Well Project modal immediately
Time saved: 2+ minutes per meeting
Experience: Professional, seamless
```

---

## Proposed Solution: Hybrid Modal + URL Routing

### Architecture Overview

**Hybrid approach** combines:
1. **Visual UX of modals** (overlay, dimmed background, smooth animations)
2. **Technical benefits of pages** (URLs, history, bookmarking, deep linking)

### How It Works

**URL behavior:**
```
User action:           URL state:
Board view          → /speakers
Click speaker card  → /speakers/sarah-chen-456  (URL updates!)
Modal opens         → /speakers/sarah-chen-456  (URL matches modal state)
Close modal         → /speakers                  (URL returns to board)
```

**Visual experience:** Identical to modal-only (no UX changes!)
**Technical experience:** URL now represents application state

### Code Architecture

```typescript
// Router configuration (App.tsx)
<Routes>
  <Route path="/speakers" element={<SpeakersPage />}>
    {/* Nested route renders as modal over parent */}
    <Route path=":speakerId" element={<SpeakerDetailRoute />} />
  </Route>
</Routes>

// SpeakerCard.tsx - Navigate instead of state
const navigate = useNavigate()
<SpeakerCard onClick={() => navigate(`/speakers/${speaker.id}`)} />

// SpeakersPage.tsx - Parent route renders board + outlet for modal
export default function SpeakersPage() {
  return (
    <div>
      <KanbanBoard />  {/* Always visible */}
      <Outlet />       {/* Modal renders here when URL matches */}
    </div>
  )
}

// SpeakerDetailRoute.tsx - Child route loads data and renders modal
export function SpeakerDetailRoute() {
  const { speakerId } = useParams()
  const navigate = useNavigate()
  const [speaker, setSpeaker] = useState(null)

  useEffect(() => {
    loadSpeaker(speakerId).then(setSpeaker)
  }, [speakerId])

  return (
    <SpeakerDetailModal
      speaker={speaker}
      onClose={() => navigate('/speakers')}  // Navigate back
    />
  )
}
```

---

## Technical Architecture

### URL Structure

| Entity Type | Board URL | Detail URL | Edit URL |
|-------------|-----------|------------|----------|
| Speakers | `/speakers` | `/speakers/:id` | `/speakers/:id/edit` |
| Service Projects | `/projects` | `/projects/:id` | `/projects/:id/edit` |
| Members | `/members` | `/members/:id` | `/members/:id/edit` |
| Partners | `/partners` | `/partners/:id` | `/partners/:id/edit` |
| Events | `/calendar` | `/calendar/events/:id` | `/calendar/events/:id/edit` |
| Holidays | `/calendar` | `/calendar/holidays/:id` | `/calendar/holidays/:id/edit` |

### React Router Pattern: Nested Routes

```typescript
// Nested route structure
<Route path="/speakers" element={<SpeakersPage />}>
  {/* Detail view modal */}
  <Route path=":speakerId" element={<SpeakerDetailRoute />} />

  {/* Edit mode modal */}
  <Route path=":speakerId/edit" element={<SpeakerEditRoute />} />
</Route>
```

**Key insight:** Child routes render through `<Outlet />` in parent component
**Visual result:** Modal appears "on top of" parent (board remains visible, dimmed)

### Navigation Flow

```typescript
// 1. Card click → Navigate to detail URL
<SpeakerCard onClick={() => navigate(`/speakers/${speaker.id}`)} />

// 2. Router matches nested route
// Renders: SpeakersPage (parent) + SpeakerDetailRoute (child via Outlet)

// 3. Detail modal renders
<SpeakerDetailModal
  speaker={speaker}
  onClose={() => navigate('/speakers')}  // Back to parent
/>

// 4. Edit button → Navigate to edit URL
<button onClick={() => navigate(`/speakers/${speaker.id}/edit`)}>
  Edit
</button>

// 5. Router matches edit route
// Renders: SpeakersPage + SpeakerEditRoute (via Outlet)

// 6. Save → Navigate back to detail
await updateSpeaker(data)
navigate(`/speakers/${speaker.id}`)

// 7. Close → Navigate back to board
navigate('/speakers')
```

### Browser History Integration

```typescript
// Browser history tracks each navigation
History stack:
[0] /speakers                    (initial)
[1] /speakers/sarah-chen-456     (opened detail)
[2] /speakers/sarah-chen-456/edit (clicked edit)
[3] /speakers/sarah-chen-456     (saved changes)

// Back button navigates through history
User presses Back → history[2] (/speakers/sarah-chen-456)
User presses Back → history[1] (/speakers)
User presses Back → history[0] (previous page)
```

### State Management

**Before (Modal-Only):**
```typescript
// Component state manages modal visibility
const [selectedSpeaker, setSelectedSpeaker] = useState<Speaker | null>(null)
const [isEditMode, setIsEditMode] = useState(false)

// Multiple state variables to track modal state
// State lost on page refresh
// Can't share or bookmark current view
```

**After (Hybrid):**
```typescript
// URL is the source of truth
const { speakerId } = useParams()  // From URL
const location = useLocation()      // Current route

// URL determines what to render
// State persists through refresh (URL survives)
// Shareable, bookmarkable state
```

---

## User Experience

### Mobile Experience

**Visual behavior:**
```
Modal presentation:
- Slides up from bottom (native feel)
- Takes 80-100% of viewport height
- Small drag handle at top
- Dimmed background (board barely visible)
- Smooth animations (same as before)
```

**Interaction patterns:**
```
Open modal:     Tap card → URL updates → Modal slides up
Close modal:    Swipe down OR tap X OR press Back → URL updates → Modal slides down
Share:          Tap Share button → Copies URL with speaker ID
Back gesture:   Swipes from edge → Modal closes (URL navigation)
```

**Example flow (iPhone):**
```
1. User opens Georgetown on iPhone
   URL: georgetown.app/speakers
   Screen: [Kanban board]

2. User taps "Dr. Sarah Chen" card
   URL: georgetown.app/speakers/sarah-chen-456  ✅ Updates
   Screen: [Modal slides up from bottom]

3. User swipes down to close
   URL: georgetown.app/speakers  ✅ Returns
   Screen: [Modal slides down, board reappears]

4. User taps iOS Share button
   Action: Share sheet opens with URL
   URL shared: georgetown.app/speakers/sarah-chen-456  ✅ Correct URL

5. Colleague receives link, taps it
   Result: Georgetown opens → Modal opens automatically for Dr. Chen  ✅
```

### Desktop/Laptop Experience

**Visual behavior:**
```
Modal presentation:
- Centered overlay (max-width: 672px)
- Dimmed background (board clearly visible)
- Smooth fade-in animation (same as before)
- Focus trap (keyboard navigation contained)
```

**Interaction patterns:**
```
Open modal:     Click card → URL updates → Modal fades in
Close modal:    Click X OR press Escape OR click backdrop → URL updates → Modal fades out
Share:          Cmd+L (select URL) → Cmd+C (copy) → Paste in Slack/email
Back button:    Browser back → Modal closes (URL navigation)
Bookmark:       Cmd+D → Bookmarks modal view (not just board)
New tab:        Cmd+Click card → Opens modal in new tab
```

**Example flow (MacBook):**
```
1. User opens Georgetown on MacBook
   URL: georgetown.app/projects
   Screen: [Kanban board with 4 columns]

2. User clicks "Water Well Project" card
   URL: georgetown.app/projects/water-well-789  ✅ Updates
   Screen: [Modal appears centered, board dimmed behind]
   Address bar: Shows new URL

3. User presses browser Back button
   URL: georgetown.app/projects  ✅ Returns
   Screen: [Modal closes, board comes into focus]

4. User Cmd+Clicks "School Renovation" card
   Result: Opens in new tab
   Tab 1: Water Well (original)
   Tab 2: School Renovation  ✅

5. User compares projects by switching tabs
   Action: Cmd+1, Cmd+2 to switch tabs
   Result: Fast comparison between projects  ✅

6. User copies URL from address bar
   URL copied: georgetown.app/projects/water-well-789
   Pastes in Slack: "Review this project: [link]"

7. Committee members click link
   Result: Everyone sees Water Well modal immediately  ✅
```

### Key UX Principle

**Visual experience is identical to modal-only approach**
- Same animations
- Same positioning
- Same styling
- Same interactions

**Technical experience is enhanced**
- URLs update (transparent to user)
- Browser history works (expected behavior)
- Sharing works (modern expectation)

---

## Implementation Details

### Phase 1: Router Setup

**File:** `src/App.tsx`

```typescript
// Before: Flat route structure
<Routes>
  <Route path="/speakers" element={<KanbanBoard />} />
  <Route path="/projects" element={<ServiceProjectsPage />} />
</Routes>

// After: Nested route structure
<Routes>
  <Route path="/speakers" element={<SpeakersPage />}>
    <Route path=":speakerId" element={<SpeakerDetailRoute />} />
    <Route path=":speakerId/edit" element={<SpeakerEditRoute />} />
  </Route>

  <Route path="/projects" element={<ProjectsPage />}>
    <Route path=":projectId" element={<ProjectDetailRoute />} />
    <Route path=":projectId/edit" element={<ProjectEditRoute />} />
  </Route>
</Routes>
```

### Phase 2: Page Component (Parent Route)

**File:** `src/components/SpeakersPage.tsx` (new or refactored from KanbanBoard)

```typescript
import { Outlet } from 'react-router-dom'
import KanbanBoard from './KanbanBoard'

export default function SpeakersPage() {
  return (
    <>
      {/* Board - always rendered */}
      <KanbanBoard />

      {/* Modal outlet - renders child routes */}
      <Outlet />
    </>
  )
}
```

**Note:** `KanbanBoard` remains largely unchanged (just wrapped in page component)

### Phase 3: Detail Route Component (Child Route)

**File:** `src/routes/SpeakerDetailRoute.tsx` (new)

```typescript
import { useParams, useNavigate } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import SpeakerDetailModal from '../components/SpeakerDetailModal'
import type { Speaker } from '../types/database'

export default function SpeakerDetailRoute() {
  const { speakerId } = useParams<{ speakerId: string }>()
  const navigate = useNavigate()
  const [speaker, setSpeaker] = useState<Speaker | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadSpeaker()
  }, [speakerId])

  const loadSpeaker = async () => {
    if (!speakerId) return

    setLoading(true)
    const { data, error } = await supabase
      .from('speakers')
      .select('*')
      .eq('id', speakerId)
      .single()

    if (error) {
      console.error('Error loading speaker:', error)
      // Speaker not found - redirect to board
      navigate('/speakers')
    } else {
      setSpeaker(data)
    }
    setLoading(false)
  }

  const handleClose = () => {
    navigate('/speakers')
  }

  const handleEdit = () => {
    navigate(`/speakers/${speakerId}/edit`)
  }

  if (loading) {
    return <LoadingModal />
  }

  if (!speaker) {
    return null
  }

  return (
    <SpeakerDetailModal
      speaker={speaker}
      onClose={handleClose}
      onEdit={handleEdit}
    />
  )
}
```

### Phase 4: Edit Route Component (Child Route)

**File:** `src/routes/SpeakerEditRoute.tsx` (new)

```typescript
import { useParams, useNavigate } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import SpeakerModal from '../components/SpeakerModal'
import type { Speaker } from '../types/database'

export default function SpeakerEditRoute() {
  const { speakerId } = useParams<{ speakerId: string }>()
  const navigate = useNavigate()
  const [speaker, setSpeaker] = useState<Speaker | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadSpeaker()
  }, [speakerId])

  const loadSpeaker = async () => {
    if (!speakerId) return

    setLoading(true)
    const { data, error } = await supabase
      .from('speakers')
      .select('*')
      .eq('id', speakerId)
      .single()

    if (error) {
      console.error('Error loading speaker:', error)
      navigate('/speakers')
    } else {
      setSpeaker(data)
    }
    setLoading(false)
  }

  const handleClose = () => {
    // Return to detail view (not board)
    navigate(`/speakers/${speakerId}`)
  }

  const handleSave = async () => {
    // After save, return to detail view
    navigate(`/speakers/${speakerId}`)
  }

  if (loading) {
    return <LoadingModal />
  }

  if (!speaker) {
    return null
  }

  return (
    <SpeakerModal
      speaker={speaker}
      onClose={handleClose}
      onSave={handleSave}
    />
  )
}
```

### Phase 5: Card Component Updates

**File:** `src/components/SpeakerCard.tsx`

```typescript
// Before: Component state
const [isViewModalOpen, setIsViewModalOpen] = useState(false)

const handleCardClick = () => {
  setIsViewModalOpen(true)
}

return (
  <>
    <div onClick={handleCardClick}>
      {/* Card UI */}
    </div>

    {isViewModalOpen && (
      <SpeakerDetailModal
        speaker={speaker}
        onClose={() => setIsViewModalOpen(false)}
      />
    )}
  </>
)

// After: Router navigation
import { useNavigate } from 'react-router-dom'

const navigate = useNavigate()

const handleCardClick = () => {
  navigate(`/speakers/${speaker.id}`)
}

return (
  <div onClick={handleCardClick}>
    {/* Card UI - unchanged */}
  </div>
  // Note: Modal no longer rendered here
)
```

### Phase 6: Modal Component Updates

**File:** `src/components/SpeakerDetailModal.tsx`

**Changes:** Minimal (mostly unchanged)

```typescript
// Before: onClose prop closes modal via state
interface Props {
  speaker: Speaker
  onClose: () => void
}

export default function SpeakerDetailModal({ speaker, onClose }: Props) {
  return (
    <div className="modal-backdrop">
      <div className="modal-content">
        <button onClick={onClose}>✕</button>
        {/* Modal UI */}
      </div>
    </div>
  )
}

// After: Same interface, onClose now triggers navigation (handled by route)
// Component remains identical - no changes needed!
```

---

## Data Loading Strategy

### Option A: Load in Route (Recommended)

**Pros:**
- Centralized data loading
- Easy to show loading state
- URL is source of truth
- Can handle errors (404, unauthorized)

**Cons:**
- Slight delay before modal appears (data loading)

```typescript
// SpeakerDetailRoute.tsx
const { speakerId } = useParams()
const [speaker, setSpeaker] = useState(null)

useEffect(() => {
  loadSpeaker(speakerId).then(setSpeaker)
}, [speakerId])

if (!speaker) return <LoadingModal />

return <SpeakerDetailModal speaker={speaker} />
```

### Option B: Load in Card, Pass via Router State

**Pros:**
- Instant modal open (data already loaded)
- Optimistic UX

**Cons:**
- Data stale on direct URL access (requires refetch)
- More complex state management

```typescript
// SpeakerCard.tsx
const handleCardClick = () => {
  navigate(`/speakers/${speaker.id}`, {
    state: { speaker }  // Pass data via router state
  })
}

// SpeakerDetailRoute.tsx
const location = useLocation()
const routerSpeaker = location.state?.speaker
const [speaker, setSpeaker] = useState(routerSpeaker)

useEffect(() => {
  // Load from database if not in router state (direct URL access)
  if (!speaker) {
    loadSpeaker(speakerId).then(setSpeaker)
  }
}, [])
```

**Recommendation:** Start with Option A (simpler), optimize to Option B if needed

---

## Browser History Management

### Default Behavior (Recommended)

```typescript
// Each navigation adds history entry
navigate(`/speakers/${speakerId}`)
// Browser history: [..., /speakers, /speakers/123]

// Back button works naturally
User presses Back → Browser navigates to previous entry
```

### Replace Mode (Alternative for Edit Flow)

```typescript
// Don't add history entry for edit transition
navigate(`/speakers/${speakerId}/edit`, { replace: true })
// Browser history: [..., /speakers] (replaced last entry)

// Use case: Detail → Edit → Save should feel like one "visit"
// Back button goes to board (skips detail view)
```

**Recommendation:** Use default for most cases, use replace sparingly

---

## SEO Considerations (If Public-Facing)

### Meta Tags per Route

```typescript
// SpeakerDetailRoute.tsx
useEffect(() => {
  if (speaker) {
    document.title = `${speaker.name} - Georgetown Speakers`

    // Open Graph tags for social sharing
    updateMetaTag('og:title', speaker.name)
    updateMetaTag('og:description', speaker.topic || '')
    updateMetaTag('og:image', speaker.portrait_url || '')
    updateMetaTag('og:url', `https://georgetown.app/speakers/${speaker.id}`)
  }
}, [speaker])
```

### Sitemap Generation

```xml
<!-- sitemap.xml -->
<url>
  <loc>https://georgetown.app/speakers/sarah-chen-456</loc>
  <lastmod>2025-01-15</lastmod>
  <priority>0.8</priority>
</url>
```

**Note:** Only relevant if speaker/project pages are public-facing

---

## Analytics Integration

### Track Modal Views

```typescript
// SpeakerDetailRoute.tsx
useEffect(() => {
  if (speaker) {
    // Google Analytics
    gtag('event', 'view_speaker', {
      speaker_id: speaker.id,
      speaker_name: speaker.name,
      page_path: `/speakers/${speaker.id}`,
    })

    // Or custom analytics
    analytics.track('Speaker Viewed', {
      speakerId: speaker.id,
      speakerName: speaker.name,
      source: document.referrer,
    })
  }
}, [speaker])
```

### Benefits

- Track most-viewed speakers/projects
- Understand user navigation patterns
- A/B test modal layouts
- Funnel analysis (view → edit → save)

---

## Error Handling

### 404 - Speaker Not Found

```typescript
// SpeakerDetailRoute.tsx
const loadSpeaker = async () => {
  const { data, error } = await supabase
    .from('speakers')
    .select('*')
    .eq('id', speakerId)
    .single()

  if (error || !data) {
    // Speaker not found - redirect to board
    navigate('/speakers', {
      state: {
        error: 'Speaker not found'
      }
    })
    return
  }

  setSpeaker(data)
}
```

### Unauthorized Access

```typescript
// Check permissions before rendering modal
if (!speaker) return null
if (!canViewSpeaker(speaker, currentUser)) {
  navigate('/speakers', {
    state: {
      error: 'You do not have permission to view this speaker'
    }
  })
  return null
}
```

### Network Errors

```typescript
const [error, setError] = useState(null)

const loadSpeaker = async () => {
  try {
    const { data, error } = await supabase
      .from('speakers')
      .select('*')
      .eq('id', speakerId)
      .single()

    if (error) throw error
    setSpeaker(data)
  } catch (err) {
    setError(err.message)
  }
}

if (error) {
  return <ErrorModal message={error} onClose={() => navigate('/speakers')} />
}
```

---

## Testing Strategy

### Unit Tests

```typescript
// SpeakerDetailRoute.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import SpeakerDetailRoute from './SpeakerDetailRoute'

test('loads speaker and renders modal', async () => {
  // Mock API response
  mockSupabase.from().select().eq().single.mockResolvedValue({
    data: { id: '123', name: 'Dr. Sarah Chen' },
    error: null,
  })

  render(
    <MemoryRouter initialEntries={['/speakers/123']}>
      <Routes>
        <Route path="/speakers/:speakerId" element={<SpeakerDetailRoute />} />
      </Routes>
    </MemoryRouter>
  )

  await waitFor(() => {
    expect(screen.getByText('Dr. Sarah Chen')).toBeInTheDocument()
  })
})

test('redirects to board if speaker not found', async () => {
  mockSupabase.from().select().eq().single.mockResolvedValue({
    data: null,
    error: { message: 'Not found' },
  })

  const navigate = jest.fn()
  jest.mock('react-router-dom', () => ({
    ...jest.requireActual('react-router-dom'),
    useNavigate: () => navigate,
  }))

  render(
    <MemoryRouter initialEntries={['/speakers/999']}>
      <Routes>
        <Route path="/speakers/:speakerId" element={<SpeakerDetailRoute />} />
      </Routes>
    </MemoryRouter>
  )

  await waitFor(() => {
    expect(navigate).toHaveBeenCalledWith('/speakers')
  })
})
```

### Integration Tests

```typescript
// SpeakersFlow.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import App from './App'

test('full speaker flow: board → detail → edit → save → detail → board', async () => {
  render(<App />, { wrapper: MemoryRouter })

  // 1. Navigate to speakers board
  fireEvent.click(screen.getByText('Speakers'))
  expect(window.location.pathname).toBe('/speakers')

  // 2. Click speaker card
  fireEvent.click(screen.getByText('Dr. Sarah Chen'))
  expect(window.location.pathname).toMatch(/\/speakers\/\d+/)
  expect(screen.getByRole('dialog')).toBeInTheDocument()

  // 3. Click edit button
  fireEvent.click(screen.getByText('Edit'))
  expect(window.location.pathname).toMatch(/\/speakers\/\d+\/edit/)

  // 4. Save changes
  fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'Dr. Sarah Chen Updated' } })
  fireEvent.click(screen.getByText('Save'))
  expect(window.location.pathname).toMatch(/\/speakers\/\d+/)
  expect(screen.getByText('Dr. Sarah Chen Updated')).toBeInTheDocument()

  // 5. Close modal
  fireEvent.click(screen.getByLabelText('Close'))
  expect(window.location.pathname).toBe('/speakers')
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
```

### E2E Tests (Cypress/Playwright)

```typescript
// speakers.spec.ts
describe('Speaker Modal Routing', () => {
  it('opens speaker modal via direct URL', () => {
    cy.visit('/speakers/sarah-chen-456')
    cy.get('[role="dialog"]').should('be.visible')
    cy.contains('Dr. Sarah Chen').should('be.visible')
  })

  it('back button closes modal', () => {
    cy.visit('/speakers')
    cy.contains('Dr. Sarah Chen').click()
    cy.url().should('include', '/speakers/sarah-chen-456')

    cy.go('back')
    cy.url().should('eq', Cypress.config().baseUrl + '/speakers')
    cy.get('[role="dialog"]').should('not.exist')
  })

  it('shareable URL opens correct modal', () => {
    // Simulate sharing link
    const url = '/speakers/sarah-chen-456'

    // Open in new tab (simulating colleague clicking shared link)
    cy.visit(url)

    cy.get('[role="dialog"]').should('be.visible')
    cy.contains('Dr. Sarah Chen').should('be.visible')
  })
})
```

---

## Migration Strategy

### Phase 1: Speakers (Pilot)

**Goal:** Prove pattern works, identify issues
**Effort:** 4-5 hours
**Files to create/modify:**
- Create `src/routes/SpeakerDetailRoute.tsx`
- Create `src/routes/SpeakerEditRoute.tsx`
- Create `src/components/SpeakersPage.tsx` (wrapper)
- Modify `src/App.tsx` (add nested routes)
- Modify `src/components/SpeakerCard.tsx` (use navigate)
- Test thoroughly

**Success criteria:**
- ✅ Direct URLs work (`/speakers/123`)
- ✅ Back button closes modal
- ✅ Browser bookmarks work
- ✅ Share button copies correct URL
- ✅ No visual changes (UX identical)

### Phase 2: Service Projects

**Goal:** Replicate pattern for second entity type
**Effort:** 3-4 hours
**Files to create/modify:**
- Create `src/routes/ProjectDetailRoute.tsx`
- Create `src/routes/ProjectEditRoute.tsx`
- Create `src/components/ProjectsPage.tsx`
- Modify `src/App.tsx`
- Modify `src/components/ServiceProjectCard.tsx`

### Phase 3: Members, Partners

**Goal:** Complete pattern for all major entities
**Effort:** 2-3 hours each (pattern established)

### Phase 4: Events, Holidays (Calendar modals)

**Goal:** Apply to calendar-based modals
**Effort:** 3-4 hours
**Special considerations:**
- Calendar is one page (`/calendar`)
- Events and holidays share the page
- URLs: `/calendar/events/123`, `/calendar/holidays/456`

### Phase 5: Testing & Polish

**Goal:** Ensure all scenarios work
**Effort:** 3-4 hours
- Test direct URL access
- Test browser history (back/forward)
- Test bookmarks
- Test sharing (copy URL)
- Test mobile (back gesture)
- Test keyboard navigation (Escape key)

**Total effort:** ~18-20 hours

---

## Rollback Plan

### If Issues Arise

**Rollback is simple:** Each entity is independent

```bash
# Rollback speakers only (keep projects, members unchanged)
git revert <commit-hash>
```

**Worst case:** Full rollback takes ~30 minutes
- Revert router changes
- Revert card component changes
- Restore modal state management

**Risk mitigation:**
- Implement one entity at a time
- Test thoroughly before next entity
- Keep PRs small (one entity per PR)
- Feature flag (if needed): `if (useHybridRouting) { ... }`

---

## Performance Considerations

### Bundle Size

**Impact:** Minimal (React Router already in use)
- No new dependencies
- ~500 bytes per route component
- Total increase: <5 KB

### Runtime Performance

**Comparison:**

| Operation | Modal-Only | Hybrid | Impact |
|-----------|-----------|---------|---------|
| Open modal (cached) | Instant | Instant | None |
| Open modal (fresh) | Instant | +50ms (route render) | Negligible |
| Close modal | Instant | Instant | None |
| Browser back | N/A | Instant | Better |
| Direct URL access | N/A | +200ms (data load) | Expected |

**Optimization:** Use router state to pass data for instant opens

```typescript
// Card passes data via state
navigate(`/speakers/${speaker.id}`, { state: { speaker } })

// Route uses cached data if available
const routerSpeaker = location.state?.speaker
const [speaker, setSpeaker] = useState(routerSpeaker || null)
```

### Server Load

**Impact:** Negligible
- Same database queries
- No additional API calls
- Same data fetching logic

---

## Accessibility

### Focus Management

```typescript
// SpeakerDetailModal.tsx
import { useEffect, useRef } from 'react'

export default function SpeakerDetailModal({ speaker, onClose }: Props) {
  const modalRef = useRef<HTMLDivElement>(null)
  const previousFocusRef = useRef<HTMLElement | null>(null)

  useEffect(() => {
    // Store previous focus
    previousFocusRef.current = document.activeElement as HTMLElement

    // Focus modal
    modalRef.current?.focus()

    return () => {
      // Restore focus on unmount
      previousFocusRef.current?.focus()
    }
  }, [])

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
    >
      {/* Modal content */}
    </div>
  )
}
```

### Keyboard Navigation

```typescript
// Handle Escape key to close
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose()  // This triggers navigate('/speakers')
    }
  }

  window.addEventListener('keydown', handleKeyDown)
  return () => window.removeEventListener('keydown', handleKeyDown)
}, [onClose])
```

### Screen Readers

```tsx
<div
  role="dialog"
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
  aria-modal="true"
>
  <h2 id="modal-title">{speaker.name}</h2>
  <div id="modal-description">{speaker.topic}</div>
</div>
```

---

## Security Considerations

### URL Parameter Validation

```typescript
// Validate UUID format
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

const loadSpeaker = async () => {
  if (!speakerId || !UUID_REGEX.test(speakerId)) {
    navigate('/speakers')
    return
  }

  // Proceed with database query
}
```

### Authorization Checks

```typescript
const loadSpeaker = async () => {
  const { data: speaker } = await supabase
    .from('speakers')
    .select('*')
    .eq('id', speakerId)
    .single()

  if (!speaker) {
    navigate('/speakers')
    return
  }

  // Check user permissions
  const canView = await checkPermission(currentUser, 'view', speaker)
  if (!canView) {
    navigate('/speakers', {
      state: { error: 'Unauthorized' }
    })
    return
  }

  setSpeaker(speaker)
}
```

### XSS Prevention

```typescript
// Ensure all user-generated content is escaped (React does this by default)
<div>{speaker.name}</div>  {/* Safe - React escapes */}

// Dangerous: Avoid dangerouslySetInnerHTML without sanitization
<div dangerouslySetInnerHTML={{ __html: speaker.bio }} />  {/* ⚠️ */}

// Safe: Use sanitization library
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(speaker.bio) }} />
```

---

## Real-World Examples

### Trello (Card Details)

**URL Pattern:**
```
Board: https://trello.com/b/abc123/my-board
Card:  https://trello.com/c/xyz789/water-well-project
```

**Behavior:**
- Modal opens over board (board visible, dimmed)
- Back button closes card
- Shareable URLs work
- Bookmarks work

### Linear (Issue Details)

**URL Pattern:**
```
Issues: https://linear.app/team/issues
Issue:  https://linear.app/team/issue/ENG-123
```

**Behavior:**
- Side panel opens (issues list still visible)
- Back button closes panel
- Cmd+K quick switcher uses URLs
- Deep linking from GitHub, Slack

### GitHub Projects (Issue Modal)

**URL Pattern:**
```
Project: https://github.com/orgs/company/projects/5
Issue:   https://github.com/company/repo/issues/42
```

**Behavior:**
- Modal opens over project board
- Browser back closes modal
- Referenced in PRs, code comments
- Bookmarkable issue view

### Notion (Page Modal)

**URL Pattern:**
```
Workspace: https://notion.so/workspace
Page:      https://notion.so/workspace/page-title-abc123
```

**Behavior:**
- Can open as modal (peek) or full page
- Shareable links
- Cmd+Click opens in new tab
- Deep linking from other tools

---

## Benefits Summary

### For Users

| Benefit | Description | Impact |
|---------|-------------|---------|
| **Shareable links** | Send direct link to speaker/project | High |
| **Browser back works** | Intuitive navigation | High |
| **Bookmarking** | Save specific items for later | Medium |
| **Tab management** | Open multiple items for comparison | Medium |
| **Cross-device** | Bookmark on laptop, open on phone | Medium |
| **No UX changes** | Same modal experience | High |

### For Business

| Benefit | Description | Impact |
|---------|-------------|---------|
| **Collaboration** | Teams share links effectively | High |
| **Professionalism** | Modern web app expectations | High |
| **Analytics** | Track item-level views | Medium |
| **SEO** | Discoverability (if public) | Low-High |
| **Integration** | External apps can deep link | Medium |
| **Support** | Users can share exact view | Medium |

### For Developers

| Benefit | Description | Impact |
|---------|-------------|---------|
| **State management** | URL is source of truth | High |
| **Testing** | Easier to test specific views | Medium |
| **Debugging** | Reproducible URLs | High |
| **Maintainability** | Clear routing structure | Medium |
| **Standards** | Follows React Router best practices | Medium |

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **User confusion** | Low | Medium | UX identical - transparent to users |
| **Breaking changes** | Low | High | Incremental rollout, easy rollback |
| **Performance regression** | Low | Low | Negligible impact, can optimize |
| **Testing burden** | Medium | Medium | Start with one entity, reuse pattern |
| **Browser compatibility** | Low | Low | React Router handles cross-browser |
| **Mobile back gesture** | Medium | Medium | Test thoroughly on iOS/Android |

---

## Decision Framework

### Implement Hybrid If:

✅ Multiple users collaborate (share links)
✅ Users work across devices
✅ Professional external communication needed
✅ Analytics per item desired
✅ Future-proofing for growth
✅ You want best-in-class UX

### Keep Modal-Only If:

❌ Single-user app (no collaboration)
❌ No need to share specific items
❌ Development time critical
❌ Temporary/prototype app

---

## Recommendations

### For Georgetown (Rotary Club)
**Recommendation:** ✅ **Strongly recommend implementation**
**Reason:** Club management requires collaboration, professional communication
**Effort:** ~18 hours
**Priority:** High

### For HuaQiao
**Recommendation:** ✅ **Recommend implementation**
**Reason:** Likely similar collaboration needs
**Effort:** ~15 hours (if not built yet: no extra cost)
**Priority:** Medium (after Georgetown proven)

### For BrandMine (Business App)
**Recommendation:** ✅ **Critical - Must implement**
**Reason:** Client collaboration essential, competitive advantage
**Effort:** ~15-20 hours
**Priority:** Critical

---

## Conclusion

The hybrid modal + URL routing architecture provides the best of both worlds:
- ✅ Superior modal UX (fast, context-preserving)
- ✅ Modern web app capabilities (shareable, bookmarkable)
- ✅ Low implementation effort (~15-20 hours)
- ✅ Low risk (incremental, easy rollback)
- ✅ High business value (collaboration, professionalism)

This approach is proven by industry leaders (Trello, Linear, GitHub) and aligns with modern web app expectations. For collaborative business applications like Georgetown, HuaQiao, and BrandMine, this architecture is strongly recommended.

---

## Appendix A: File Structure

```
apps/georgetown/src/
├── App.tsx                          # Router setup (modified)
├── components/
│   ├── SpeakersPage.tsx            # New: Parent route with <Outlet />
│   ├── ProjectsPage.tsx            # New: Parent route
│   ├── MembersPage.tsx             # New: Parent route
│   ├── KanbanBoard.tsx             # Existing: Board UI (minimal changes)
│   ├── ServiceProjectsPage.tsx     # Existing: Projects board
│   ├── MemberDirectory.tsx         # Existing: Members list
│   ├── SpeakerCard.tsx             # Modified: Use navigate() instead of state
│   ├── ServiceProjectCard.tsx      # Modified: Use navigate()
│   ├── MemberCard.tsx              # Modified: Use navigate()
│   ├── SpeakerDetailModal.tsx      # Existing: No changes needed
│   ├── SpeakerModal.tsx            # Existing: No changes needed
│   └── ...
└── routes/
    ├── SpeakerDetailRoute.tsx      # New: Loads speaker, renders detail modal
    ├── SpeakerEditRoute.tsx        # New: Loads speaker, renders edit modal
    ├── ProjectDetailRoute.tsx      # New: Loads project, renders detail modal
    ├── ProjectEditRoute.tsx        # New: Loads project, renders edit modal
    ├── MemberDetailRoute.tsx       # New: Loads member, renders detail modal
    ├── MemberEditRoute.tsx         # New: Loads member, renders edit modal
    └── ...
```

---

## Appendix B: URL Mapping Reference

| Entity | Board URL | Detail URL | Edit URL | Add URL |
|--------|-----------|------------|----------|---------|
| Speakers | `/speakers` | `/speakers/:id` | `/speakers/:id/edit` | `/speakers/new` |
| Projects | `/projects` | `/projects/:id` | `/projects/:id/edit` | `/projects/new` |
| Members | `/members` | `/members/:id` | `/members/:id/edit` | `/members/new` |
| Partners | `/partners` | `/partners/:id` | `/partners/:id/edit` | `/partners/new` |
| Events | `/calendar` | `/calendar/events/:id` | `/calendar/events/:id/edit` | `/calendar/events/new` |
| Holidays | `/calendar` | `/calendar/holidays/:id` | `/calendar/holidays/:id/edit` | `/calendar/holidays/new` |

---

## Appendix C: Browser Compatibility

| Feature | Chrome | Safari | Firefox | Edge | Mobile Safari | Mobile Chrome |
|---------|--------|--------|---------|------|---------------|---------------|
| History API | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| pushState | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| popstate event | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| React Router 6+ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Minimum supported versions:**
- Chrome 50+
- Safari 10+
- Firefox 50+
- Edge 14+
- Mobile browsers (iOS 10+, Android 5+)

---

## Appendix D: Glossary

**Modal:** Overlay UI component that appears on top of page content (dimmed background)

**Hybrid approach:** Combining modal visual UX with URL-based routing

**Nested routes:** Child routes that render inside parent routes (via `<Outlet />`)

**Browser history:** Stack of URLs visited, managed by browser (enables back/forward buttons)

**Deep linking:** Linking directly to specific content (not just homepage)

**URL state:** Using URL parameters/path to represent application state

**Route parameters:** Dynamic segments in URL paths (`:id` in `/speakers/:id`)

**useParams:** React Router hook to access route parameters

**useNavigate:** React Router hook to programmatically navigate

**<Outlet />:** React Router component that renders child routes

---

## Document Control

**Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-17 | Georgetown Dev Team | Initial TDD |

**Review Status:** Draft - Pending CTO approval

**Distribution:**
- Georgetown Development Team
- HuaQiao CTO
- BrandMine CTO

**Next Steps:**
1. Review and approve TDD
2. Review implementation plan
3. Approve Georgetown pilot (Speakers only)
4. Proceed with full implementation

---

**Questions or feedback?** Contact Georgetown Development Team
