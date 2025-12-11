# Implementation Plan: Robustness Audit Fixes
**Date**: October 17, 2025
**Source**: Robustness Audit Report (October 17, 2025)
**Total Issues**: 12 (3 High, 5 Medium, 4 Low)
**Estimated Total Time**: 17.5 hours

---

## Overview

This plan addresses all issues identified in the comprehensive robustness audit, organized by priority. Each issue includes implementation steps, code examples, testing criteria, and time estimates.

**Timeline Recommendation:**
- **Phase 1 (Pre-Launch)**: High-Priority Issues #1-3 → 3.5 hours
- **Phase 2 (Week 1 Post-Launch)**: Medium-Priority Issues #4-8 → 6 hours
- **Phase 3 (Week 2-4 Post-Launch)**: Low-Priority Issues #9-12 → 6 hours

---

## Phase 1: High-Priority Issues (Pre-Launch)

**Total Time**: 3.5 hours
**Deadline**: Before production deployment
**Impact**: Critical for production stability and performance

---

### Issue #1: Add Error Boundary [HIGH]

**Priority**: HIGH
**Time Estimate**: 1 hour
**Impact**: Prevents entire app crash on component errors
**Severity**: Production stability

#### Problem
No error boundary exists to catch React component errors. If any component throws an error, the entire app crashes with a blank white screen, requiring a full page refresh.

#### Solution
Implement a top-level ErrorBoundary component with fallback UI.

#### Implementation Steps

**Step 1: Create ErrorBoundary Component** (20 minutes)

Create file: `src/components/ErrorBoundary.tsx`

```typescript
import { Component, ErrorInfo, ReactNode } from 'react'
import { AlertCircle, RefreshCw, Home } from 'lucide-react'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
  errorInfo: ErrorInfo | null
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    }
  }

  static getDerivedStateFromError(error: Error): State {
    // Update state so the next render will show the fallback UI
    return {
      hasError: true,
      error,
      errorInfo: null,
    }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log error to console in development
    if (import.meta.env.DEV) {
      console.error('Error caught by boundary:', error, errorInfo)
    }

    // Update state with error details
    this.setState({
      error,
      errorInfo,
    })

    // TODO: Log to error tracking service (Sentry, LogRocket, etc.)
    // logErrorToService(error, errorInfo)
  }

  handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    })
  }

  handleGoHome = () => {
    window.location.href = '/'
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
          <div className="max-w-lg w-full bg-white rounded-lg shadow-lg p-8">
            {/* Error Icon */}
            <div className="flex justify-center mb-4">
              <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center">
                <AlertCircle className="w-10 h-10 text-red-600" />
              </div>
            </div>

            {/* Error Title */}
            <h1 className="text-2xl font-bold text-gray-900 text-center mb-2">
              Oops! Something went wrong
            </h1>

            {/* Error Message */}
            <p className="text-gray-600 text-center mb-6">
              We're sorry, but something unexpected happened. Don't worry, your data is safe.
            </p>

            {/* Error Details (Development Only) */}
            {import.meta.env.DEV && this.state.error && (
              <div className="mb-6 p-4 bg-gray-100 rounded border border-gray-200 overflow-auto max-h-48">
                <p className="text-sm font-mono text-red-600 mb-2">
                  {this.state.error.toString()}
                </p>
                {this.state.errorInfo && (
                  <pre className="text-xs text-gray-700 overflow-auto">
                    {this.state.errorInfo.componentStack}
                  </pre>
                )}
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex gap-3">
              <button
                onClick={this.handleReset}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-[#005daa] text-white rounded-lg hover:bg-[#004a8a] transition-colors font-medium"
              >
                <RefreshCw size={18} />
                <span>Try Again</span>
              </button>
              <button
                onClick={this.handleGoHome}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-medium"
              >
                <Home size={18} />
                <span>Go Home</span>
              </button>
            </div>

            {/* Help Text */}
            <p className="text-sm text-gray-500 text-center mt-6">
              If this problem persists, please contact your club administrator.
            </p>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
```

**Step 2: Wrap App in ErrorBoundary** (10 minutes)

Edit file: `src/App.tsx`

```typescript
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import ErrorBoundary from './components/ErrorBoundary'
import Dashboard from './components/Dashboard'
// ... other imports

function App() {
  return (
    <ErrorBoundary>
      <Router>
        <div className="flex flex-col min-h-screen">
          <div className="flex-1">
            <Routes>
              {/* Dashboard - Home page */}
              <Route path="/" element={<Dashboard />} />
              {/* ... rest of routes */}
            </Routes>
          </div>
          <Footer />
        </div>
      </Router>
    </ErrorBoundary>
  )
}

export default App
```

**Step 3: Test Error Boundary** (30 minutes)

Create a test component to trigger errors:

```typescript
// src/components/ErrorTest.tsx (temporary, for testing only)
import { useState } from 'react'

export default function ErrorTest() {
  const [shouldThrow, setShouldThrow] = useState(false)

  if (shouldThrow) {
    throw new Error('Test error - Error boundary working!')
  }

  return (
    <div className="p-4">
      <button
        onClick={() => setShouldThrow(true)}
        className="px-4 py-2 bg-red-600 text-white rounded"
      >
        Trigger Error
      </button>
    </div>
  )
}
```

Add test route in App.tsx (development only):
```typescript
{import.meta.env.DEV && <Route path="/error-test" element={<ErrorTest />} />}
```

**Testing Checklist:**
- [ ] Visit `/error-test` and click "Trigger Error" button
- [ ] Error boundary fallback UI appears with error message
- [ ] "Try Again" button resets the error state
- [ ] "Go Home" button navigates to home page
- [ ] In production build, error details are hidden
- [ ] Error is logged to console in development

**Success Criteria:**
- ✅ Error boundary catches component errors
- ✅ Fallback UI is user-friendly and branded
- ✅ User can recover without full page refresh
- ✅ Error details shown only in development

**Files Changed:**
- `src/components/ErrorBoundary.tsx` (new)
- `src/App.tsx` (modified)

---

### Issue #2: Implement Code Splitting [HIGH]

**Priority**: HIGH
**Time Estimate**: 2 hours
**Impact**: Reduces initial bundle by ~50% (847KB → 400KB)
**Severity**: Performance optimization

#### Problem
All components are bundled into a single 847KB JavaScript file, causing slower initial page loads, especially on 3G networks. Users must download the entire app even if they only visit one page.

#### Solution
Implement route-based code splitting using React.lazy() and Suspense.

#### Implementation Steps

**Step 1: Create Loading Component** (15 minutes)

Create file: `src/components/LoadingFallback.tsx`

```typescript
import { Loader2 } from 'lucide-react'

export default function LoadingFallback() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-16 h-16 mb-4">
          <Loader2 className="animate-spin h-12 w-12 text-[#005daa]" />
        </div>
        <div className="text-lg text-gray-600">Loading...</div>
      </div>
    </div>
  )
}
```

**Step 2: Implement Lazy Loading in App.tsx** (45 minutes)

Edit file: `src/App.tsx`

```typescript
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { lazy, Suspense } from 'react'
import ErrorBoundary from './components/ErrorBoundary'
import LoadingFallback from './components/LoadingFallback'
import Footer from './components/Footer'
import './App.css'

// Eager load only the landing page for instant display
import Dashboard from './components/Dashboard'
import AboutPage from './components/AboutPage'

// Lazy load all other pages (loaded on demand)
const KanbanBoard = lazy(() => import('./components/KanbanBoard'))
const MemberDirectory = lazy(() => import('./components/MemberDirectory'))
const ServiceProjectsPage = lazy(() => import('./components/ServiceProjectsPage'))
const PartnersPage = lazy(() => import('./components/PartnersPage'))
const TimelineView = lazy(() => import('./components/TimelineView'))
const PhotoGallery = lazy(() => import('./components/PhotoGallery'))
const ImpactPage = lazy(() => import('./components/ImpactPage'))
const SpeakerBureauView = lazy(() => import('./components/SpeakerBureauView'))
const CalendarView = lazy(() => import('./components/CalendarView'))
const EventsListView = lazy(() => import('./components/EventsListView'))
const Availability = lazy(() => import('./components/Availability'))

function App() {
  return (
    <ErrorBoundary>
      <Router>
        <div className="flex flex-col min-h-screen">
          <div className="flex-1">
            <Suspense fallback={<LoadingFallback />}>
              <Routes>
                {/* Dashboard - Home page (eager loaded) */}
                <Route path="/" element={<Dashboard />} />
                <Route path="/about" element={<AboutPage />} />

                {/* Primary Sections (lazy loaded) */}
                <Route path="/members" element={<MemberDirectory />} />
                <Route path="/calendar" element={<CalendarView />} />
                <Route path="/projects" element={<ServiceProjectsPage />} />
                <Route path="/speakers" element={<KanbanBoard />} />
                <Route path="/timeline" element={<TimelineView />} />
                <Route path="/photos" element={<PhotoGallery />} />

                {/* Secondary Sections (lazy loaded) */}
                <Route path="/partners" element={<PartnersPage />} />
                <Route path="/impact" element={<ImpactPage />} />

                {/* Legacy/Other Routes (lazy loaded) */}
                <Route path="/speakers-bureau" element={<SpeakerBureauView />} />
                <Route path="/events-list" element={<EventsListView />} />
                <Route path="/availability" element={<Availability />} />

                {/* Redirects for backwards compatibility */}
                <Route path="/service-projects" element={<Navigate to="/projects" replace />} />
                <Route path="/speaker-bureau" element={<Navigate to="/speakers-bureau" replace />} />
              </Routes>
            </Suspense>
          </div>
          <Footer />
        </div>
      </Router>
    </ErrorBoundary>
  )
}

export default App
```

**Step 3: Verify Vite Configuration** (15 minutes)

Ensure `vite.config.ts` supports code splitting (should work by default):

```typescript
// vite.config.ts - No changes needed, but verify this section exists
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: undefined, // Let Vite handle automatic chunking
      },
    },
  },
})
```

**Step 4: Build and Verify Code Splitting** (45 minutes)

```bash
# Clean previous build
rm -rf dist/

# Build with code splitting
npm run build
```

Expected output should show multiple chunks:
```
dist/assets/index-ABC123.css        56.80 kB │ gzip:   9.82 kB
dist/assets/index-DEF456.js        400.00 kB │ gzip: 105.00 kB  (main bundle)
dist/assets/KanbanBoard-GHI789.js  150.00 kB │ gzip:  38.00 kB  (lazy chunk)
dist/assets/MemberDirectory-JKL.js 120.00 kB │ gzip:  30.00 kB  (lazy chunk)
dist/assets/TimelineView-MNO.js    100.00 kB │ gzip:  25.00 kB  (lazy chunk)
... (additional chunks for other routes)
```

**Testing Checklist:**
- [ ] `npm run build` succeeds without errors
- [ ] Build output shows multiple JavaScript chunks (not one large bundle)
- [ ] Main bundle is ~400KB (down from 847KB)
- [ ] Visit `/` - Dashboard loads immediately (no loading spinner)
- [ ] Navigate to `/speakers` - Brief loading spinner appears, then page loads
- [ ] Navigate to `/members` - Loading spinner appears, then page loads
- [ ] Navigate back to `/` - Instant (already loaded)
- [ ] Browser Network tab shows chunks loading on demand
- [ ] No console errors in production build (`npm run preview`)

**Performance Verification:**
```bash
# Start preview server
npm run preview

# Open http://localhost:4173 in Chrome
# Open DevTools → Network tab → Disable cache → Reload
# Verify:
# - Initial load: ~400KB JS (not 847KB)
# - Navigate to /speakers: Additional ~150KB chunk loads
# - Navigate to /members: Additional ~120KB chunk loads
```

**Success Criteria:**
- ✅ Main bundle reduced by 50% (847KB → ~400KB)
- ✅ Route chunks load on demand
- ✅ Loading fallback appears briefly during chunk loading
- ✅ No performance regression on subsequent navigations
- ✅ Lighthouse Performance score increases by 5-10 points

**Files Changed:**
- `src/components/LoadingFallback.tsx` (new)
- `src/App.tsx` (modified - lazy imports)

**Expected Impact:**
- Initial page load: **400-500ms faster** on 4G
- Initial page load: **1-2 seconds faster** on 3G
- Lighthouse Performance: **82 → 90+**

---

### Issue #3: Verify RLS Policies [HIGH] (CEO Task)

**Priority**: HIGH
**Time Estimate**: 30 minutes
**Impact**: Critical security verification
**Severity**: Data security
**Owner**: CEO (requires Supabase dashboard access)

#### Problem
CTO cannot verify that Row-Level Security (RLS) policies are properly configured in Supabase. Without RLS, users could potentially access or modify data they shouldn't.

#### Solution
CEO must verify RLS policies are enabled and correctly configured for all tables.

#### Implementation Steps (CEO Only)

**Step 1: Access Supabase Dashboard** (5 minutes)

1. Log in to Supabase: https://app.supabase.com
2. Select Georgetown Rotary project
3. Navigate to **Authentication** → **Policies**

**Step 2: Verify RLS Enabled on All Tables** (10 minutes)

Check these tables have **RLS enabled**:

**Critical Tables:**
- [ ] `speakers` - RLS enabled
- [ ] `members` - RLS enabled
- [ ] `partners` - RLS enabled
- [ ] `service_projects` - RLS enabled
- [ ] `photos` - RLS enabled
- [ ] `club_events` - RLS enabled
- [ ] `rotary_years` - RLS enabled
- [ ] `locations` - RLS enabled

**How to verify:**
- Click on table name
- Look for "Row Level Security" toggle
- Should show "Enabled" in green

**If RLS is disabled:**
```sql
-- Enable RLS on each table
ALTER TABLE speakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotary_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
```

**Step 3: Verify Read Policies (Public Access)** (10 minutes)

Each table should have a **SELECT (read) policy** allowing public access:

```sql
-- Example: speakers table read policy
CREATE POLICY "Public can view speakers"
ON speakers
FOR SELECT
USING (true);  -- Allow all users to read

-- Repeat for all tables:
-- members, partners, service_projects, photos (approved only),
-- club_events, rotary_years, locations
```

**For photos table**, restrict to approved only:
```sql
CREATE POLICY "Public can view approved photos"
ON photos
FOR SELECT
USING (approval_status = 'approved');
```

**Step 4: Verify Write Policies (Officers/Chairs Only)** (5 minutes)

Each table should have **INSERT, UPDATE, DELETE policies** restricting to authenticated officers/chairs:

```sql
-- Example: speakers table write policies
CREATE POLICY "Officers and chairs can insert speakers"
ON speakers
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM members
    WHERE email = auth.jwt() ->> 'email'
    AND roles && ARRAY[
      'President', 'President-Elect', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair',
      'International Service Chair', 'Membership Chair',
      'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

CREATE POLICY "Officers and chairs can update speakers"
ON speakers
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM members
    WHERE email = auth.jwt() ->> 'email'
    AND roles && ARRAY[
      'President', 'President-Elect', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair',
      'International Service Chair', 'Membership Chair',
      'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

CREATE POLICY "Officers and chairs can delete speakers"
ON speakers
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM members
    WHERE email = auth.jwt() ->> 'email'
    AND roles && ARRAY[
      'President', 'President-Elect', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair',
      'International Service Chair', 'Membership Chair',
      'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);
```

**Note**: Repeat similar policies for all tables.

**Step 5: Verify Storage Bucket Policies** (5 minutes)

Navigate to **Storage** → **club-photos** bucket:

- [ ] **Public read access** enabled (users can view photos)
- [ ] **Authenticated write access** restricted to officers/chairs

**Testing Checklist (CEO):**
- [ ] All 8 tables have RLS enabled
- [ ] Public can read all data (test by viewing app while logged out)
- [ ] Non-officers cannot create/edit/delete (test with non-officer account)
- [ ] Officers/chairs can create/edit/delete (test with officer account)
- [ ] Storage bucket allows public read, authenticated write
- [ ] No SQL errors in Supabase logs

**Success Criteria:**
- ✅ All tables have RLS enabled
- ✅ Read policies allow public access (appropriate for club directory)
- ✅ Write policies restrict to authenticated officers/chairs
- ✅ Storage bucket configured correctly

**Documentation:**
CEO should take screenshots of:
1. RLS enabled on all tables
2. Example policy for one table
3. Storage bucket permissions

**Files Changed:**
- None (database-only configuration)

**Deliverable:**
CEO confirms in writing: "RLS policies verified and enabled on all tables"

---

## Phase 2: Medium-Priority Issues (Post-Launch Week 1)

**Total Time**: 6 hours
**Deadline**: 1 week after production deployment
**Impact**: User experience improvements

---

### Issue #4: Add Offline Mode Detection [MEDIUM]

**Priority**: MEDIUM
**Time Estimate**: 1 hour
**Impact**: Better UX during network outages
**Severity**: User experience

#### Problem
App doesn't detect or respond to offline state. Users see infinite loading spinners when offline, with no indication that the issue is their network connection.

#### Solution
Detect network status and show friendly offline message.

#### Implementation Steps

**Step 1: Create useNetworkStatus Hook** (20 minutes)

Create file: `src/hooks/useNetworkStatus.ts`

```typescript
import { useState, useEffect } from 'react'

export function useNetworkStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine)
  const [wasOffline, setWasOffline] = useState(false)

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true)
      // Track if we were offline (for "back online" message)
      if (wasOffline) {
        setTimeout(() => setWasOffline(false), 3000) // Clear after 3s
      }
    }

    const handleOffline = () => {
      setIsOnline(false)
      setWasOffline(true)
    }

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [wasOffline])

  return { isOnline, wasOffline }
}
```

**Step 2: Create OfflineBanner Component** (20 minutes)

Create file: `src/components/OfflineBanner.tsx`

```typescript
import { WifiOff, Wifi } from 'lucide-react'
import { useNetworkStatus } from '../hooks/useNetworkStatus'

export default function OfflineBanner() {
  const { isOnline, wasOffline } = useNetworkStatus()

  // Show "back online" message briefly
  if (isOnline && wasOffline) {
    return (
      <div className="fixed top-0 left-0 right-0 z-50 bg-green-600 text-white py-3 px-4 text-center shadow-lg animate-in slide-in-from-top">
        <div className="flex items-center justify-center gap-2">
          <Wifi size={20} />
          <span className="font-medium">Back online!</span>
        </div>
      </div>
    )
  }

  // Show offline message
  if (!isOnline) {
    return (
      <div className="fixed top-0 left-0 right-0 z-50 bg-amber-600 text-white py-3 px-4 text-center shadow-lg">
        <div className="flex items-center justify-center gap-2">
          <WifiOff size={20} />
          <span className="font-medium">
            You're offline. Some features may not work until you reconnect.
          </span>
        </div>
      </div>
    )
  }

  return null
}
```

**Step 3: Add to AppLayout** (10 minutes)

Edit file: `src/components/AppLayout.tsx`

```typescript
import OfflineBanner from './OfflineBanner'

export default function AppLayout({ ... }) {
  return (
    <div className="flex flex-col min-h-screen bg-gray-50">
      {/* Offline Banner */}
      <OfflineBanner />

      {/* Skip to main content link */}
      <a href="#main-content" ...>
        Skip to main content
      </a>

      {/* Rest of layout */}
      ...
    </div>
  )
}
```

**Step 4: Add Offline State to API Calls** (10 minutes)

Create file: `src/lib/supabase-with-offline.ts`

```typescript
import { supabase } from './supabase'

// Wrapper to show better error messages when offline
export async function fetchWithOfflineCheck<T>(
  queryFn: () => Promise<{ data: T | null; error: any }>
) {
  if (!navigator.onLine) {
    return {
      data: null,
      error: {
        message: 'You are currently offline. Please check your internet connection.',
        code: 'OFFLINE',
      },
    }
  }

  try {
    return await queryFn()
  } catch (error: any) {
    // Network error (fetch failed)
    if (error.message?.includes('fetch')) {
      return {
        data: null,
        error: {
          message: 'Network error. Please check your connection and try again.',
          code: 'NETWORK_ERROR',
        },
      }
    }
    throw error
  }
}
```

**Testing Checklist:**
- [ ] Turn on airplane mode (or disconnect WiFi)
- [ ] Offline banner appears at top of screen
- [ ] Banner shows "You're offline..." message with WiFi icon
- [ ] Turn off airplane mode (reconnect WiFi)
- [ ] "Back online!" banner appears briefly (3 seconds)
- [ ] Banner disappears after 3 seconds
- [ ] App works normally after reconnection

**Success Criteria:**
- ✅ Offline banner appears immediately when network disconnects
- ✅ "Back online" message appears when reconnected
- ✅ Banner doesn't block important content (fixed position)
- ✅ Better error messages for API calls when offline

**Files Changed:**
- `src/hooks/useNetworkStatus.ts` (new)
- `src/components/OfflineBanner.tsx` (new)
- `src/components/AppLayout.tsx` (modified)
- `src/lib/supabase-with-offline.ts` (new, optional)

---

### Issue #5: Implement Retry Logic for Failed API Calls [MEDIUM]

**Priority**: MEDIUM
**Time Estimate**: 2 hours
**Impact**: Better resilience to temporary network issues
**Severity**: User experience

#### Problem
If an API call fails, users must refresh the page. No automatic retry mechanism for temporary failures.

#### Solution
Add exponential backoff retry logic for failed Supabase queries.

#### Implementation Steps

**Step 1: Create Retry Utility** (30 minutes)

Create file: `src/lib/retry-with-backoff.ts`

```typescript
interface RetryOptions {
  maxRetries?: number
  initialDelay?: number
  maxDelay?: number
  backoffMultiplier?: number
  shouldRetry?: (error: any) => boolean
}

const defaultOptions: Required<RetryOptions> = {
  maxRetries: 3,
  initialDelay: 1000, // 1 second
  maxDelay: 10000, // 10 seconds
  backoffMultiplier: 2,
  shouldRetry: (error) => {
    // Retry on network errors, not on auth/permission errors
    const code = error?.code || error?.status
    return (
      code === 'NETWORK_ERROR' ||
      code === 'PGRST301' || // Supabase timeout
      code === 503 || // Service unavailable
      code === 502 // Bad gateway
    )
  },
}

export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const opts = { ...defaultOptions, ...options }
  let lastError: any
  let delay = opts.initialDelay

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error: any) {
      lastError = error

      // Don't retry if we shouldn't (e.g., auth errors)
      if (!opts.shouldRetry(error)) {
        throw error
      }

      // Don't retry if we've exhausted attempts
      if (attempt === opts.maxRetries) {
        break
      }

      // Log retry attempt in development
      if (import.meta.env.DEV) {
        console.log(`Retry attempt ${attempt + 1}/${opts.maxRetries} after ${delay}ms`)
      }

      // Wait before retrying
      await new Promise((resolve) => setTimeout(resolve, delay))

      // Exponential backoff with max cap
      delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelay)
    }
  }

  // All retries failed
  throw lastError
}
```

**Step 2: Create Supabase Wrapper with Retry** (45 minutes)

Create file: `src/lib/supabase-queries.ts`

```typescript
import { supabase } from './supabase'
import { retryWithBackoff } from './retry-with-backoff'

// Wrapper for SELECT queries with retry
export async function fetchWithRetry<T>(
  queryFn: () => Promise<{ data: T | null; error: any }>
) {
  return retryWithBackoff(async () => {
    const { data, error } = await queryFn()
    if (error) throw error
    return data
  })
}

// Example usage for common queries
export const queries = {
  // Fetch all speakers
  fetchSpeakers: () =>
    fetchWithRetry(() =>
      supabase
        .from('speakers')
        .select('*')
        .order('position', { ascending: true })
    ),

  // Fetch all members
  fetchMembers: () =>
    fetchWithRetry(() =>
      supabase
        .from('members')
        .select('*')
        .order('name', { ascending: true })
    ),

  // Fetch service projects
  fetchProjects: () =>
    fetchWithRetry(() =>
      supabase
        .from('service_projects')
        .select('*')
        .order('start_date', { ascending: false })
    ),

  // Fetch rotary years
  fetchRotaryYears: () =>
    fetchWithRetry(() =>
      supabase
        .from('rotary_years')
        .select('*')
        .order('rotary_year', { ascending: false })
    ),

  // Fetch photos
  fetchPhotos: (rotaryYearId?: string) =>
    fetchWithRetry(() => {
      let query = supabase
        .from('photos')
        .select('*')
        .eq('approval_status', 'approved')

      if (rotaryYearId) {
        query = query.eq('rotary_year_id', rotaryYearId)
      }

      return query.order('photo_date', { ascending: false })
    }),
}

// For mutations (INSERT, UPDATE, DELETE), use retry sparingly
export async function mutateWithRetry<T>(
  mutateFn: () => Promise<{ data: T | null; error: any }>,
  options?: { maxRetries?: number }
) {
  return retryWithBackoff(
    async () => {
      const { data, error } = await mutateFn()
      if (error) throw error
      return data
    },
    { ...options, maxRetries: options?.maxRetries ?? 1 } // Only 1 retry for mutations
  )
}
```

**Step 3: Update KanbanBoard to Use Retry** (30 minutes)

Edit file: `src/components/KanbanBoard.tsx`

```typescript
import { queries } from '../lib/supabase-queries'

export default function KanbanBoard() {
  // ... existing code

  const fetchSpeakers = async () => {
    try {
      setLoading(true)
      const data = await queries.fetchSpeakers()
      setSpeakers(data || [])
    } catch (error) {
      console.error('Error fetching speakers:', error)
      // Show user-friendly error message
      // TODO: Add toast notification or error banner
    } finally {
      setLoading(false)
    }
  }

  // ... rest of component
}
```

**Step 4: Add Toast Notifications for Errors** (15 minutes)

Create file: `src/components/Toast.tsx`

```typescript
import { X, AlertCircle, CheckCircle, Info } from 'lucide-react'
import { useEffect } from 'react'

interface ToastProps {
  type: 'success' | 'error' | 'info'
  message: string
  onClose: () => void
  duration?: number
}

export default function Toast({ type, message, onClose, duration = 5000 }: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(onClose, duration)
    return () => clearTimeout(timer)
  }, [duration, onClose])

  const icons = {
    success: <CheckCircle size={20} className="text-green-600" />,
    error: <AlertCircle size={20} className="text-red-600" />,
    info: <Info size={20} className="text-blue-600" />,
  }

  const backgrounds = {
    success: 'bg-green-50 border-green-200',
    error: 'bg-red-50 border-red-200',
    info: 'bg-blue-50 border-blue-200',
  }

  return (
    <div
      className={`fixed bottom-20 md:bottom-6 right-6 left-6 md:left-auto md:w-96 ${backgrounds[type]} border rounded-lg shadow-lg p-4 flex items-start gap-3 z-50 animate-in slide-in-from-bottom`}
    >
      {icons[type]}
      <p className="flex-1 text-sm text-gray-900">{message}</p>
      <button
        onClick={onClose}
        className="text-gray-400 hover:text-gray-600 transition-colors flex-shrink-0"
      >
        <X size={18} />
      </button>
    </div>
  )
}
```

**Testing Checklist:**
- [ ] Use Chrome DevTools → Network → Throttling → Offline
- [ ] Try to fetch speakers - should retry 3 times (check console logs)
- [ ] After 3 retries, error message appears
- [ ] Reconnect network
- [ ] Try again - fetches successfully
- [ ] Simulate intermittent network (toggle online/offline rapidly)
- [ ] Retries happen automatically without user intervention

**Success Criteria:**
- ✅ Failed API calls retry automatically (up to 3 times)
- ✅ Exponential backoff prevents hammering server
- ✅ User sees friendly error after all retries exhausted
- ✅ Mutations (create/update/delete) retry only once (safer)

**Files Changed:**
- `src/lib/retry-with-backoff.ts` (new)
- `src/lib/supabase-queries.ts` (new)
- `src/components/Toast.tsx` (new)
- `src/components/KanbanBoard.tsx` (modified example)
- Repeat pattern in other components (MemberDirectory, TimelineView, etc.)

---

### Issue #6: Extract Realtime Subscription to Custom Hook [MEDIUM]

**Priority**: MEDIUM
**Time Estimate**: 1 hour
**Impact**: Code maintainability and DRY principle
**Severity**: Code quality

#### Problem
Realtime subscription pattern is duplicated across 5+ components, making it harder to maintain and update.

#### Solution
Create reusable custom hook for Supabase real-time subscriptions.

#### Implementation Steps

**Step 1: Create useRealtimeSubscription Hook** (40 minutes)

Create file: `src/hooks/useRealtimeSubscription.ts`

```typescript
import { useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { RealtimeChannel } from '@supabase/supabase-js'

interface RealtimePayload<T = any> {
  eventType: 'INSERT' | 'UPDATE' | 'DELETE'
  new: T
  old: T
}

interface UseRealtimeSubscriptionOptions<T> {
  table: string
  onInsert?: (record: T) => void
  onUpdate?: (record: T) => void
  onDelete?: (record: T) => void
  filter?: string // e.g., 'status=eq.active'
}

export function useRealtimeSubscription<T = any>({
  table,
  onInsert,
  onUpdate,
  onDelete,
  filter,
}: UseRealtimeSubscriptionOptions<T>) {
  useEffect(() => {
    // Create subscription channel
    const channel = supabase.channel(`${table}-changes`)

    // Configure subscription
    channel.on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table,
        filter,
      },
      (payload: RealtimePayload<T>) => {
        if (import.meta.env.DEV) {
          console.log(`Realtime ${payload.eventType} on ${table}:`, payload)
        }

        switch (payload.eventType) {
          case 'INSERT':
            onInsert?.(payload.new)
            break
          case 'UPDATE':
            onUpdate?.(payload.new)
            break
          case 'DELETE':
            onDelete?.(payload.old)
            break
        }
      }
    )

    // Subscribe
    channel.subscribe()

    // Cleanup on unmount
    return () => {
      channel.unsubscribe()
    }
  }, [table, filter, onInsert, onUpdate, onDelete])
}
```

**Step 2: Refactor KanbanBoard to Use Hook** (10 minutes)

Edit file: `src/components/KanbanBoard.tsx`

Before:
```typescript
useEffect(() => {
  fetchSpeakers()
  const subscription = supabase
    .channel('speakers-changes')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'speakers' },
      handleRealtimeUpdate
    )
    .subscribe()

  return () => {
    subscription.unsubscribe()
  }
}, [])

const handleRealtimeUpdate = (payload: any) => {
  if (payload.eventType === 'INSERT') {
    setSpeakers((prev) => [...prev, payload.new as Speaker])
  } else if (payload.eventType === 'UPDATE') {
    setSpeakers((prev) =>
      prev.map((speaker) =>
        speaker.id === payload.new.id ? (payload.new as Speaker) : speaker
      )
    )
  } else if (payload.eventType === 'DELETE') {
    setSpeakers((prev) =>
      prev.filter((speaker) => speaker.id !== payload.old.id)
    )
  }
}
```

After:
```typescript
import { useRealtimeSubscription } from '../hooks/useRealtimeSubscription'

// Inside component:
useEffect(() => {
  fetchSpeakers()
}, [])

// Real-time subscription
useRealtimeSubscription<Speaker>({
  table: 'speakers',
  onInsert: (newSpeaker) => {
    setSpeakers((prev) => [...prev, newSpeaker])
  },
  onUpdate: (updatedSpeaker) => {
    setSpeakers((prev) =>
      prev.map((s) => (s.id === updatedSpeaker.id ? updatedSpeaker : s))
    )
  },
  onDelete: (deletedSpeaker) => {
    setSpeakers((prev) => prev.filter((s) => s.id !== deletedSpeaker.id))
  },
})
```

**Step 3: Apply to Other Components** (10 minutes)

Refactor these components to use the hook:
- `MemberDirectory.tsx`
- `TimelineView.tsx`
- `PhotoGallery.tsx`
- `CalendarView.tsx`
- `ServiceProjectsPage.tsx`
- `PartnersPage.tsx`

**Testing Checklist:**
- [ ] Open two browser windows side-by-side
- [ ] Create speaker in Window 1
- [ ] Speaker appears in Window 2 instantly
- [ ] Edit speaker in Window 1
- [ ] Changes appear in Window 2 instantly
- [ ] Delete speaker in Window 1
- [ ] Speaker disappears from Window 2 instantly
- [ ] Repeat for members, projects, photos
- [ ] No console errors or warnings
- [ ] Real-time still works after navigation

**Success Criteria:**
- ✅ Real-time subscriptions work identically to before
- ✅ Code is DRY (no duplication)
- ✅ Hook is reusable across all tables
- ✅ TypeScript types are preserved

**Files Changed:**
- `src/hooks/useRealtimeSubscription.ts` (new)
- `src/components/KanbanBoard.tsx` (refactored)
- `src/components/MemberDirectory.tsx` (refactored)
- `src/components/TimelineView.tsx` (refactored)
- `src/components/PhotoGallery.tsx` (refactored)
- `src/components/CalendarView.tsx` (refactored)
- `src/components/ServiceProjectsPage.tsx` (refactored)
- `src/components/PartnersPage.tsx` (refactored)

---

### Issue #7: Add Memoization for Expensive Computations [MEDIUM]

**Priority**: MEDIUM
**Time Estimate**: 1 hour
**Impact**: Performance improvement for filtering/sorting
**Severity**: Performance

#### Problem
Filtering and sorting operations run on every render, even when dependencies haven't changed. With 100+ records, this can cause performance issues.

#### Solution
Use `useMemo` for filtered/sorted data and `useCallback` for event handlers.

#### Implementation Steps

**Step 1: Add useMemo to KanbanBoard** (20 minutes)

Edit file: `src/components/KanbanBoard.tsx`

Before:
```typescript
// Filter speakers with search and filters (all views)
const filteredSpeakers = speakers.filter(speaker => {
  // ... filtering logic
})

const sortedSpeakers = [...filteredSpeakers].sort((a, b) => {
  // ... sorting logic
})
```

After:
```typescript
import { useMemo, useCallback } from 'react'

// Memoize filtering
const filteredSpeakers = useMemo(() => {
  return speakers.filter(speaker => {
    // Search filter (name, organization, topic, email)
    if (searchTerm) {
      const searchLower = searchTerm.toLowerCase()
      const matchesSearch =
        speaker.name.toLowerCase().includes(searchLower) ||
        speaker.organization?.toLowerCase().includes(searchLower) ||
        speaker.topic?.toLowerCase().includes(searchLower) ||
        speaker.email?.toLowerCase().includes(searchLower)

      if (!matchesSearch) return false
    }

    // ... rest of filters
    return true
  })
}, [
  speakers,
  searchTerm,
  statusFilter,
  rotarianFilter,
  scheduledFilter,
  recommendedFilter,
])

// Memoize sorting
const sortedSpeakers = useMemo(() => {
  return [...filteredSpeakers].sort((a, b) => {
    // List view: Use manual sorting
    if (viewMode === 'spreadsheet') {
      const aValue = a[sortField]
      const bValue = b[sortField]

      if (aValue == null) return 1
      if (bValue == null) return -1

      const comparison = aValue < bValue ? -1 : aValue > bValue ? 1 : 0
      return sortDirection === 'asc' ? comparison : -comparison
    }

    // Cards/Board view: Use status priority sorting
    const aPriority = statusPriority[a.status] || 999
    const bPriority = statusPriority[b.status] || 999

    if (aPriority !== bPriority) {
      return aPriority - bPriority
    }

    if (a.status === 'scheduled' && b.status === 'scheduled' && a.scheduled_date && b.scheduled_date) {
      return new Date(a.scheduled_date).getTime() - new Date(b.scheduled_date).getTime()
    }

    return a.position - b.position
  })
}, [filteredSpeakers, viewMode, sortField, sortDirection])
```

**Step 2: Add useCallback for Event Handlers** (20 minutes)

Still in `src/components/KanbanBoard.tsx`:

```typescript
// Memoize handlers to prevent recreating on every render
const handleSort = useCallback((field: keyof Speaker) => {
  if (sortField === field) {
    setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc')
  } else {
    setSortField(field)
    setSortDirection('asc')
  }
}, [sortField, sortDirection])

const handleAddSpeakerInColumn = useCallback((status: string) => {
  setDefaultStatus(status as Speaker['status'])
  setIsAddModalOpen(true)
}, [])

const handleCloseAddModal = useCallback(() => {
  setIsAddModalOpen(false)
  setDefaultStatus(null)
}, [])
```

**Step 3: Apply to MemberDirectory** (20 minutes)

Edit file: `src/components/MemberDirectory.tsx`

```typescript
// Memoize filtered members
const filteredMembers = useMemo(() => {
  return members.filter(member => {
    if (searchTerm) {
      const searchLower = searchTerm.toLowerCase()
      const matchesSearch =
        member.name.toLowerCase().includes(searchLower) ||
        member.email?.toLowerCase().includes(searchLower) ||
        member.company_name?.toLowerCase().includes(searchLower)

      if (!matchesSearch) return false
    }

    // ... other filters
    return true
  })
}, [members, searchTerm, roleFilter, typeFilter, charterFilter])

// Memoize sorted members
const sortedMembers = useMemo(() => {
  return [...filteredMembers].sort((a, b) => {
    return a.name.localeCompare(b.name)
  })
}, [filteredMembers])
```

**Testing Checklist:**
- [ ] Open KanbanBoard with 100+ speakers
- [ ] Type in search box - no lag
- [ ] Change filters - instant response
- [ ] Toggle sort direction - instant
- [ ] Real-time updates still work
- [ ] No unnecessary re-renders (check React DevTools Profiler)

**Success Criteria:**
- ✅ Filtering/sorting only runs when dependencies change
- ✅ No performance regression
- ✅ React DevTools shows fewer re-renders
- ✅ Smoother UI with large datasets

**Files Changed:**
- `src/components/KanbanBoard.tsx` (add useMemo/useCallback)
- `src/components/MemberDirectory.tsx` (add useMemo)
- `src/components/ServiceProjectsPage.tsx` (add useMemo)

---

### Issue #8: Add URL Validation in Forms [MEDIUM]

**Priority**: MEDIUM
**Time Estimate**: 30 minutes
**Impact**: Prevents broken links from malformed URLs
**Severity**: Data quality

#### Problem
No validation for URL format in speaker/member/partner forms. Users can enter invalid URLs that won't work as links.

#### Solution
Add URL validation helper and apply to all URL input fields.

#### Implementation Steps

**Step 1: Create URL Validation Utility** (10 minutes)

Create file: `src/utils/urlValidation.ts`

```typescript
export function isValidUrl(url: string): boolean {
  if (!url || url.trim() === '') return true // Empty is okay (optional field)

  try {
    const parsed = new URL(url)
    // Only allow http and https protocols
    return ['http:', 'https:'].includes(parsed.protocol)
  } catch {
    return false
  }
}

export function sanitizeUrl(url: string): string {
  const trimmed = url.trim()
  if (!trimmed) return ''

  // Add https:// if no protocol specified
  if (!trimmed.match(/^https?:\/\//i)) {
    return `https://${trimmed}`
  }

  return trimmed
}

export function getUrlError(url: string): string | null {
  if (!url || url.trim() === '') return null

  if (!isValidUrl(url)) {
    return 'Please enter a valid URL (e.g., https://example.com)'
  }

  return null
}
```

**Step 2: Add Validation to SpeakerModal** (10 minutes)

Edit file: `src/components/SpeakerModal.tsx`

```typescript
import { isValidUrl, sanitizeUrl, getUrlError } from '../utils/urlValidation'

export default function SpeakerModal({ speaker, onClose, defaultStatus }: SpeakerModalProps) {
  // ... existing state
  const [urlError, setUrlError] = useState<string | null>(null)

  const handlePrimaryUrlChange = (value: string) => {
    const sanitized = sanitizeUrl(value)
    setFormData({ ...formData, primary_url: sanitized })
    setUrlError(getUrlError(sanitized))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    // Validate URL before submitting
    if (formData.primary_url && !isValidUrl(formData.primary_url)) {
      setUrlError('Please enter a valid URL')
      return
    }

    // ... rest of submit logic
  }

  return (
    <div className="modal">
      {/* ... other fields */}

      {/* Website URL */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Website
        </label>
        <input
          type="url"
          value={formData.primary_url || ''}
          onChange={(e) => handlePrimaryUrlChange(e.target.value)}
          placeholder="https://example.com"
          className={`w-full px-4 py-3 border ${
            urlError ? 'border-red-300' : 'border-gray-300'
          } rounded-lg focus:ring-2 focus:ring-[#005daa] focus:border-transparent`}
        />
        {urlError && (
          <p className="mt-1 text-sm text-red-600">{urlError}</p>
        )}
        <p className="mt-1 text-xs text-gray-500">
          Enter full URL including https://
        </p>
      </div>

      {/* ... rest of form */}
    </div>
  )
}
```

**Step 3: Apply to Other Forms** (10 minutes)

Apply URL validation to:
- `MemberModal.tsx` (company_url, linkedin)
- `PartnerModal.tsx` (website)
- `ServiceProjectModal.tsx` (if URL fields exist)

**Testing Checklist:**
- [ ] Try to save "notaurl" - validation error appears
- [ ] Try to save "example.com" - auto-adds "https://"
- [ ] Try to save "https://example.com" - accepts
- [ ] Try to save "http://example.com" - accepts
- [ ] Try to save "ftp://example.com" - rejects (only http/https)
- [ ] Empty URL field - accepts (optional)
- [ ] Valid URL saves successfully
- [ ] Link works when clicked on card

**Success Criteria:**
- ✅ Invalid URLs rejected with clear error message
- ✅ Auto-add https:// prefix if missing
- ✅ Error appears in real-time (as user types)
- ✅ All URL fields have validation

**Files Changed:**
- `src/utils/urlValidation.ts` (new)
- `src/components/SpeakerModal.tsx` (modified)
- `src/components/MemberModal.tsx` (modified)
- `src/components/PartnerModal.tsx` (modified)

---

## Phase 3: Low-Priority Issues (Post-Launch Week 2-4)

**Total Time**: 6 hours
**Deadline**: 2-4 weeks after production deployment
**Impact**: Code quality and polish

---

### Issue #9: Remove or Wrap Console Logs [LOW]

**Priority**: LOW
**Time Estimate**: 1 hour
**Impact**: Production polish, minimal performance gain
**Severity**: Code quality

#### Problem
155 console.log/error/warn statements across 28 files. While performance impact is negligible, it's unprofessional to ship debug logs to production.

#### Solution
Wrap console statements in development-only checks.

#### Implementation Steps

**Step 1: Create Logger Utility** (15 minutes)

Create file: `src/utils/logger.ts`

```typescript
// Development-only logger
const isDev = import.meta.env.DEV

export const logger = {
  log: (...args: any[]) => {
    if (isDev) {
      console.log(...args)
    }
  },

  error: (...args: any[]) => {
    if (isDev) {
      console.error(...args)
    }
    // TODO: Send to error tracking service (Sentry, LogRocket, etc.)
  },

  warn: (...args: any[]) => {
    if (isDev) {
      console.warn(...args)
    }
  },

  info: (...args: any[]) => {
    if (isDev) {
      console.info(...args)
    }
  },

  debug: (...args: any[]) => {
    if (isDev) {
      console.debug(...args)
    }
  },
}
```

**Step 2: Replace Console Logs** (45 minutes)

Use find-and-replace across project:

**Find**: `console.log(`
**Replace**: `logger.log(`

**Find**: `console.error(`
**Replace**: `logger.error(`

**Find**: `console.warn(`
**Replace**: `logger.warn(`

Files to update (28 total):
- All files in `src/components/`
- All files in `src/lib/`
- All files in `src/utils/`

Example in `KanbanBoard.tsx`:

Before:
```typescript
console.log('Speaker marked as spoken. Auto-linking to Rotary year:', rotaryYear)
console.error('Error updating speaker status:', error)
```

After:
```typescript
import { logger } from '../utils/logger'

logger.log('Speaker marked as spoken. Auto-linking to Rotary year:', rotaryYear)
logger.error('Error updating speaker status:', error)
```

**Testing Checklist:**
- [ ] Build production: `npm run build`
- [ ] Start preview: `npm run preview`
- [ ] Open browser console
- [ ] Navigate through app
- [ ] No console.log statements appear in production
- [ ] Errors still logged (for debugging)
- [ ] Development mode still shows all logs

**Success Criteria:**
- ✅ Zero console logs in production build
- ✅ Development logs still work
- ✅ Error logs preserved for debugging
- ✅ Ready for error tracking service integration

**Files Changed:**
- `src/utils/logger.ts` (new)
- 28 component/lib files (replace console with logger)

---

### Issue #10: Add Duplicate Detection [LOW]

**Priority**: LOW
**Time Estimate**: 2 hours
**Impact**: Data quality improvement
**Severity**: Data integrity

#### Problem
Users can create duplicate speakers/members with same email, leading to data quality issues.

#### Solution
Check for duplicates before creating new records.

#### Implementation Steps

**Step 1: Create Duplicate Check Utility** (30 minutes)

Create file: `src/lib/duplicate-detection.ts`

```typescript
import { supabase } from './supabase'

export async function checkDuplicateSpeaker(
  email: string | null,
  excludeId?: string
): Promise<{ isDuplicate: boolean; existing: any | null }> {
  if (!email || email.trim() === '') {
    return { isDuplicate: false, existing: null }
  }

  let query = supabase
    .from('speakers')
    .select('id, name, email, organization, status')
    .eq('email', email.trim().toLowerCase())

  if (excludeId) {
    query = query.neq('id', excludeId)
  }

  const { data, error } = await query.maybeSingle()

  if (error) {
    console.error('Error checking duplicate:', error)
    return { isDuplicate: false, existing: null }
  }

  return {
    isDuplicate: !!data,
    existing: data,
  }
}

export async function checkDuplicateMember(
  email: string | null,
  excludeId?: string
): Promise<{ isDuplicate: boolean; existing: any | null }> {
  if (!email || email.trim() === '') {
    return { isDuplicate: false, existing: null }
  }

  let query = supabase
    .from('members')
    .select('id, name, email, roles')
    .eq('email', email.trim().toLowerCase())

  if (excludeId) {
    query = query.neq('id', excludeId)
  }

  const { data, error } = await query.maybeSingle()

  if (error) {
    console.error('Error checking duplicate:', error)
    return { isDuplicate: false, existing: null }
  }

  return {
    isDuplicate: !!data,
    existing: data,
  }
}
```

**Step 2: Add Duplicate Warning to SpeakerModal** (45 minutes)

Edit file: `src/components/SpeakerModal.tsx`

```typescript
import { checkDuplicateSpeaker } from '../lib/duplicate-detection'

export default function SpeakerModal({ speaker, onClose }: SpeakerModalProps) {
  const [duplicateWarning, setDuplicateWarning] = useState<string | null>(null)
  const [showDuplicateConfirm, setShowDuplicateConfirm] = useState(false)

  // Check for duplicates when email changes
  const handleEmailChange = async (email: string) => {
    setFormData({ ...formData, email })
    setDuplicateWarning(null)

    if (email && email.includes('@')) {
      const { isDuplicate, existing } = await checkDuplicateSpeaker(
        email,
        speaker?.id // Exclude current speaker when editing
      )

      if (isDuplicate) {
        setDuplicateWarning(
          `A speaker with this email already exists: ${existing.name} (${existing.organization || 'No org'})`
        )
      }
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    // Check for duplicate before submitting
    if (formData.email) {
      const { isDuplicate, existing } = await checkDuplicateSpeaker(
        formData.email,
        speaker?.id
      )

      if (isDuplicate && !showDuplicateConfirm) {
        setDuplicateWarning(
          `A speaker with this email already exists: ${existing.name}. Are you sure you want to create another?`
        )
        setShowDuplicateConfirm(true)
        return
      }
    }

    // ... proceed with save
  }

  return (
    <div className="modal">
      {/* Email field */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Email
        </label>
        <input
          type="email"
          value={formData.email || ''}
          onChange={(e) => handleEmailChange(e.target.value)}
          placeholder="speaker@example.com"
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#005daa]"
        />
        {duplicateWarning && (
          <div className="mt-2 p-3 bg-amber-50 border border-amber-200 rounded">
            <p className="text-sm text-amber-800">{duplicateWarning}</p>
            {showDuplicateConfirm && (
              <div className="mt-2 flex gap-2">
                <button
                  type="button"
                  onClick={() => setShowDuplicateConfirm(false)}
                  className="px-3 py-1 bg-white border border-amber-300 text-amber-800 rounded text-sm hover:bg-amber-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-3 py-1 bg-amber-600 text-white rounded text-sm hover:bg-amber-700"
                >
                  Create Anyway
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* ... rest of form */}
    </div>
  )
}
```

**Step 3: Apply to MemberModal** (45 minutes)

Similar implementation in `src/components/MemberModal.tsx`.

**Testing Checklist:**
- [ ] Create speaker with email "john@example.com"
- [ ] Try to create another speaker with same email
- [ ] Warning appears showing existing speaker
- [ ] Can choose to cancel or create anyway
- [ ] Edit existing speaker - no duplicate warning
- [ ] Repeat for members
- [ ] Empty email - no warning (optional field)

**Success Criteria:**
- ✅ Duplicate warning appears when matching email found
- ✅ User can see existing record details
- ✅ User can choose to create anyway (intentional duplicate)
- ✅ No false positives when editing existing record

**Files Changed:**
- `src/lib/duplicate-detection.ts` (new)
- `src/components/SpeakerModal.tsx` (modified)
- `src/components/MemberModal.tsx` (modified)

---

### Issue #11: Improve Date Validation [LOW]

**Priority**: LOW
**Time Estimate**: 30 minutes
**Impact**: Prevents impossible dates
**Severity**: Data quality

#### Problem
No validation for impossible dates (e.g., scheduled_date in the past for "Ideas" speakers, or future dates for "Spoken" speakers).

#### Solution
Add date validation based on speaker status.

#### Implementation Steps

**Step 1: Create Date Validation Utility** (10 minutes)

Create file: `src/utils/dateValidation.ts`

```typescript
export function validateScheduledDate(
  date: string | null | undefined,
  status: string
): string | null {
  if (!date) return null // Optional field

  const selected = new Date(date)
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  // For "Spoken" status, date should be in the past
  if (status === 'spoken' && selected > today) {
    return 'Scheduled date should be in the past for speakers who have already spoken'
  }

  // For "Scheduled" status, date should be in the future (or today)
  if (status === 'scheduled' && selected < today) {
    return 'Scheduled date should be today or in the future'
  }

  // For other statuses, any date is okay
  return null
}

export function validateDateRange(
  startDate: string | null,
  endDate: string | null
): string | null {
  if (!startDate || !endDate) return null

  const start = new Date(startDate)
  const end = new Date(endDate)

  if (end < start) {
    return 'End date must be after start date'
  }

  return null
}
```

**Step 2: Add to SpeakerModal** (20 minutes)

Edit file: `src/components/SpeakerModal.tsx`

```typescript
import { validateScheduledDate } from '../utils/dateValidation'

export default function SpeakerModal({ speaker, onClose }: SpeakerModalProps) {
  const [dateError, setDateError] = useState<string | null>(null)

  const handleDateChange = (date: string) => {
    setFormData({ ...formData, scheduled_date: date })
    const error = validateScheduledDate(date, formData.status)
    setDateError(error)
  }

  const handleStatusChange = (status: Speaker['status']) => {
    setFormData({ ...formData, status })
    // Re-validate date with new status
    if (formData.scheduled_date) {
      const error = validateScheduledDate(formData.scheduled_date, status)
      setDateError(error)
    }
  }

  return (
    <div className="modal">
      {/* Scheduled Date */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Scheduled Date
        </label>
        <input
          type="date"
          value={formData.scheduled_date || ''}
          onChange={(e) => handleDateChange(e.target.value)}
          className={`w-full px-4 py-3 border ${
            dateError ? 'border-red-300' : 'border-gray-300'
          } rounded-lg focus:ring-2 focus:ring-[#005daa]`}
        />
        {dateError && (
          <p className="mt-1 text-sm text-red-600">{dateError}</p>
        )}
      </div>

      {/* ... rest of form */}
    </div>
  )
}
```

**Testing Checklist:**
- [ ] Set status to "Spoken", select future date - error appears
- [ ] Set status to "Scheduled", select past date - error appears
- [ ] Set status to "Ideas", select any date - no error
- [ ] Empty date field - no error (optional)
- [ ] Valid date saves successfully

**Success Criteria:**
- ✅ Impossible dates rejected with clear message
- ✅ Validation updates when status changes
- ✅ Doesn't block valid use cases

**Files Changed:**
- `src/utils/dateValidation.ts` (new)
- `src/components/SpeakerModal.tsx` (modified)

---

### Issue #12: Replace `any` Types with Specific Interfaces [LOW]

**Priority**: LOW
**Time Estimate**: 2 hours
**Impact**: Improved type safety
**Severity**: Code quality

#### Problem
9 occurrences of `any` type, reducing type safety benefits of TypeScript.

#### Solution
Create specific TypeScript interfaces for all `any` types.

#### Implementation Steps

**Step 1: Create Supabase Realtime Types** (30 minutes)

Create file: `src/types/supabase-realtime.ts`

```typescript
export interface RealtimePayload<T = any> {
  eventType: 'INSERT' | 'UPDATE' | 'DELETE'
  new: T
  old: T
  schema: string
  table: string
  commit_timestamp: string
}

export type RealtimeCallback<T = any> = (payload: RealtimePayload<T>) => void
```

**Step 2: Replace `any` in Components** (90 minutes)

**File**: `src/components/KanbanBoard.tsx:332`

Before:
```typescript
const handleRealtimeUpdate = (payload: any) => {
```

After:
```typescript
import type { RealtimePayload } from '../types/supabase-realtime'

const handleRealtimeUpdate = (payload: RealtimePayload<Speaker>) => {
  if (payload.eventType === 'INSERT') {
    setSpeakers((prev) => [...prev, payload.new])
  } else if (payload.eventType === 'UPDATE') {
    setSpeakers((prev) =>
      prev.map((speaker) =>
        speaker.id === payload.new.id ? payload.new : speaker
      )
    )
  } else if (payload.eventType === 'DELETE') {
    setSpeakers((prev) =>
      prev.filter((speaker) => speaker.id !== payload.old.id)
    )
  }
}
```

**File**: `src/components/SpeakerModal.tsx:75`

Before:
```typescript
const dbData: any = {
  // ...
}
```

After:
```typescript
import type { Database } from '../types/database'

type SpeakerInsert = Database['public']['Tables']['speakers']['Insert']

const dbData: Partial<SpeakerInsert> = {
  // ...
}
```

**File**: `src/components/FilterBar.tsx:15` and `src/components/AppLayout.tsx:26`

Before:
```typescript
onChange: (value: any) => void
```

After:
```typescript
onChange: (value: string | string[]) => void
```

**File**: `src/components/ServiceProjectModal.tsx:311`

Before:
```typescript
catch (error: any) {
```

After:
```typescript
catch (error: unknown) {
  const errorMessage = error instanceof Error ? error.message : 'Unknown error'
  // ...
}
```

**File**: `src/components/CalendarView.tsx:159`

Before:
```typescript
const handleEventClick = (event: any) => {
```

After:
```typescript
import type { ClubEvent } from '../types/database'

const handleEventClick = (event: ClubEvent) => {
```

**Testing Checklist:**
- [ ] `npm run build` succeeds with no errors
- [ ] TypeScript reports zero errors
- [ ] All functionality works as before
- [ ] IDE autocomplete works better (TypeScript hints)

**Success Criteria:**
- ✅ Zero `any` types remaining (except in rare necessary cases)
- ✅ Full type safety throughout codebase
- ✅ Better IDE support and autocomplete

**Files Changed:**
- `src/types/supabase-realtime.ts` (new)
- 9 component files (replace `any` with specific types)

---

## Testing Strategy

### Pre-Launch Testing (Before Deployment)

**Phase 1 Complete - Test Checklist:**
- [ ] Error boundary catches errors gracefully
- [ ] Code splitting reduces bundle size by 50%
- [ ] RLS policies verified by CEO
- [ ] Build succeeds with no errors
- [ ] Production preview works correctly
- [ ] No console errors in production build

**Testing Time**: 1 hour

---

### Post-Launch Testing (After Each Phase)

**Phase 2 Complete - Test Checklist:**
- [ ] Offline banner appears when network disconnected
- [ ] API calls retry automatically on failure
- [ ] Real-time subscriptions still work
- [ ] Filtering/sorting is faster (no lag with 100+ records)
- [ ] URL validation prevents broken links

**Testing Time**: 1 hour

**Phase 3 Complete - Test Checklist:**
- [ ] No console logs in production
- [ ] Duplicate detection warns before creating duplicates
- [ ] Date validation prevents impossible dates
- [ ] TypeScript compilation has zero errors
- [ ] Type safety improvements visible in IDE

**Testing Time**: 30 minutes

---

## Progress Tracking

### High-Priority Issues

| Issue | Status | Time | Completed |
|-------|--------|------|-----------|
| #1 Error Boundary | ⬜ Not Started | 1h | ___ |
| #2 Code Splitting | ⬜ Not Started | 2h | ___ |
| #3 RLS Verification | ⬜ Not Started | 30m | ___ |

**Phase 1 Total**: 3.5 hours

---

### Medium-Priority Issues

| Issue | Status | Time | Completed |
|-------|--------|------|-----------|
| #4 Offline Detection | ⬜ Not Started | 1h | ___ |
| #5 Retry Logic | ⬜ Not Started | 2h | ___ |
| #6 Realtime Hook | ⬜ Not Started | 1h | ___ |
| #7 Memoization | ⬜ Not Started | 1h | ___ |
| #8 URL Validation | ⬜ Not Started | 30m | ___ |

**Phase 2 Total**: 5.5 hours

---

### Low-Priority Issues

| Issue | Status | Time | Completed |
|-------|--------|------|-----------|
| #9 Console Logs | ⬜ Not Started | 1h | ___ |
| #10 Duplicate Detection | ⬜ Not Started | 2h | ___ |
| #11 Date Validation | ⬜ Not Started | 30m | ___ |
| #12 Replace `any` Types | ⬜ Not Started | 2h | ___ |

**Phase 3 Total**: 5.5 hours

---

## Summary

**Total Implementation Time**: 14.5 hours (rounded to 17.5 with testing)

**Recommended Schedule:**
- **Week 0 (Pre-Launch)**: Issues #1-3 (3.5 hours) - MUST COMPLETE
- **Week 1 (Post-Launch)**: Issues #4-8 (5.5 hours) - HIGH VALUE
- **Week 2-4 (Post-Launch)**: Issues #9-12 (5.5 hours) - POLISH

**Expected Outcomes:**
- ✅ Production-ready deployment (Week 0)
- ✅ Lighthouse Performance score: 90+ (Week 1)
- ✅ World-class code quality (Week 2-4)
- ✅ Zero technical debt

**Success Metrics:**
- Zero critical bugs in production
- Lighthouse scores > 90 across all categories
- User satisfaction with app performance
- Maintainable codebase for future development

---

**Document Version**: 1.0
**Created**: October 17, 2025
**Last Updated**: October 17, 2025
**Next Review**: After Phase 1 completion
