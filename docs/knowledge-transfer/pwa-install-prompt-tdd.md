# PWA Install Prompt - Technical Design Document

**Project:** Georgetown Rotary Club App
**Feature:** Progressive Web App (PWA) Installation Prompt
**Date:** 2025-12-18
**Author:** Claude Code
**Purpose:** Knowledge transfer for implementing similar installation prompts in other projects (e.g., Brandmine)

---

## Table of Contents

1. [Overview](#overview)
2. [User Experience](#user-experience)
3. [Technical Architecture](#technical-architecture)
4. [Implementation Details](#implementation-details)
5. [Styling & Animation](#styling--animation)
6. [Integration Pattern](#integration-pattern)
7. [Customization Guide](#customization-guide)
8. [Best Practices](#best-practices)
9. [Testing Checklist](#testing-checklist)

---

## Overview

### Purpose
The PWA Install Prompt guides iOS Safari users to install the web app to their home screen, providing a native app-like experience with offline capabilities, faster load times, and a dedicated icon.

### Key Features
- **iOS Safari Detection**: Only shows to iOS Safari users not in standalone mode
- **Smart Timing**: 3-second delay to avoid overwhelming new users
- **Persistent Dismissal**: Remembers user preference in localStorage
- **Visual Instructions**: Step-by-step guide with icons and numbered steps
- **Accessible**: ARIA labels, keyboard support, and touch-friendly (44px minimum)
- **Branded Styling**: Uses brand colors and app icon

### Technical Stack
- React 19 with TypeScript
- Tailwind CSS for styling
- Lucide React for icons
- CSS animations for smooth transitions

---

## User Experience

### Visibility Conditions
The prompt appears when:
1. User is on iOS (iPad, iPhone, iPod)
2. User is using Safari browser (not Chrome, Firefox, etc.)
3. App is NOT already installed (not in standalone mode)
4. User has NOT previously dismissed the prompt
5. User has been on the page for 3+ seconds

### User Flow
```
┌─────────────────────────────────────┐
│ User visits site on iOS Safari     │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 3-second delay                      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Modal slides up from bottom         │
│ - Shows app icon & instructions     │
│ - Positioned above bottom nav       │
└────────────┬────────────────────────┘
             │
        User chooses:
             │
    ┌────────┴────────┐
    ▼                 ▼
┌────────┐      ┌──────────┐
│ Dismiss│      │ Install  │
└────┬───┘      └────┬─────┘
     │               │
     ▼               ▼
  Saved in     Follows iOS
localStorage    native flow
```

### Visual Design
- **Position**: Fixed at bottom (above bottom navigation)
- **Width**: Responsive with max-width (adapts to screen)
- **Border**: 2px brand-colored border
- **Shadow**: Heavy shadow for prominence
- **Animation**: Smooth slide-up entrance

---

## Technical Architecture

### Component Structure
```
InstallPrompt.tsx (Self-contained component)
├── Detection Logic (useEffect hook)
│   ├── Check localStorage for dismissal
│   ├── Detect iOS device
│   ├── Detect Safari browser
│   ├── Check if already installed
│   └── 3-second delay timer
│
├── State Management
│   └── showPrompt (boolean)
│
├── Event Handlers
│   └── handleDismiss() → Sets localStorage & hides
│
└── UI Structure
    ├── Header (Icon, Title, Close Button)
    ├── Instructions (3-step numbered list)
    ├── Visual Indicator (Share button reference)
    └── Dismiss Link ("Maybe later")
```

### Detection Logic

#### iOS Detection
```typescript
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
```
- Checks user agent string for iOS device identifiers
- Works across all iOS versions

#### Safari Detection
```typescript
const isSafari = /Safari/.test(navigator.userAgent) &&
                 !/CriOS|FxiOS|OPiOS|mercury/.test(navigator.userAgent)
```
- Positive match: Contains "Safari"
- Negative match: Excludes Chrome (CriOS), Firefox (FxiOS), Opera (OPiOS), Mercury
- iOS browsers use Safari's WebKit engine but have different UAs

#### Standalone Mode Detection
```typescript
const isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches
```
- Checks if app is running as installed PWA
- Returns true when launched from home screen icon

#### Dismissal Persistence
```typescript
const dismissed = localStorage.getItem('pwa-install-prompt-dismissed')
```
- Key: `'pwa-install-prompt-dismissed'`
- Value: `'true'` (string, not boolean)
- Persists across sessions
- Cleared only when user clears browser data

---

## Implementation Details

### Core Component Code

#### File Location
```
src/components/InstallPrompt.tsx
```

#### Component Interface
```typescript
export default function InstallPrompt(): JSX.Element | null
```
- No props (self-contained)
- Returns null when hidden
- Returns modal when visible

#### State Management
```typescript
const [showPrompt, setShowPrompt] = useState(false)
```
- Initially hidden (false)
- Set to true after 3s delay (if conditions met)
- Set to false on dismiss

#### Effect Hook
```typescript
useEffect(() => {
  // 1. Check localStorage
  const dismissed = localStorage.getItem('pwa-install-prompt-dismissed')
  if (dismissed === 'true') return

  // 2. Detect device & browser
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
  const isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches
  const isSafari = /Safari/.test(navigator.userAgent) &&
                   !/CriOS|FxiOS|OPiOS|mercury/.test(navigator.userAgent)

  // 3. Show prompt with delay
  if (isIOS && isSafari && !isInStandaloneMode) {
    const timer = setTimeout(() => setShowPrompt(true), 3000)
    return () => clearTimeout(timer)
  }
}, [])
```

#### Dismiss Handler
```typescript
const handleDismiss = () => {
  setShowPrompt(false)
  localStorage.setItem('pwa-install-prompt-dismissed', 'true')
}
```

### Key Dependencies

#### React Imports
```typescript
import { useState, useEffect } from 'react'
```

#### Icon Imports (Lucide React)
```typescript
import { X, Share, Plus } from 'lucide-react'
```
- **X**: Close button icon
- **Share**: iOS share button illustration
- **Plus**: Add to Home Screen illustration

#### Installation
```bash
npm install lucide-react
# or
pnpm add lucide-react
```

---

## Styling & Animation

### CSS Animation

#### Keyframes Definition
Add to `src/index.css`:

```css
/* Install Prompt Animation */
@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slide-up 0.4s ease-out;
}
```

**Animation Details:**
- **Duration**: 0.4s (400ms)
- **Timing**: ease-out (starts fast, ends slow)
- **Effect**: Fades in while sliding up 20px
- **Trigger**: Applied on mount (when showPrompt becomes true)

### Tailwind Classes Breakdown

#### Container
```tsx
<div className="fixed bottom-20 left-4 right-4 z-50 animate-slide-up">
```
- `fixed`: Fixed positioning (stays in place on scroll)
- `bottom-20`: 5rem (80px) from bottom (above bottom nav)
- `left-4 right-4`: 1rem (16px) margins on sides
- `z-50`: High z-index (appears above content)
- `animate-slide-up`: Custom animation class

#### Card
```tsx
<div className="bg-white rounded-lg shadow-2xl border-2 border-[#0067c8] p-4 max-w-md mx-auto">
```
- `bg-white`: White background
- `rounded-lg`: Large border radius (8px)
- `shadow-2xl`: Heavy shadow for prominence
- `border-2 border-[#0067c8]`: 2px Rotary blue border
- `p-4`: 1rem (16px) padding
- `max-w-md mx-auto`: Max width 28rem, centered

#### Touch Targets
```tsx
className="min-w-[44px] min-h-[44px]"
```
- Minimum 44x44px for iOS accessibility
- Ensures easy tapping on mobile devices

### Brand Color Integration

#### Using Tailwind Config
```javascript
// tailwind.config.js
theme: {
  extend: {
    colors: {
      brand: {
        primary: '#0067c8',  // Replace with your brand color
      }
    }
  }
}
```

#### Using Direct Hex Values
```tsx
className="border-[#0067c8]"  // Rotary blue
className="bg-[#0067c8]"       // Rotary blue background
className="text-[#0067c8]"     // Rotary blue text
```

---

## Integration Pattern

### Step 1: Add Component to Layout

#### File: `src/components/AppLayout.tsx`

```typescript
import InstallPrompt from './InstallPrompt'

export default function AppLayout({ children, ...props }) {
  return (
    <div>
      <AppHeader {...headerProps} />
      <FilterBar {...filterProps} />

      {/* Main Content */}
      <main>{children}</main>

      {/* Bottom Navigation */}
      <BottomNav />

      {/* Offline Banner */}
      <OfflineBanner />

      {/* Install Prompt - POSITIONED LAST */}
      <InstallPrompt />
    </div>
  )
}
```

**Important:**
- Place `<InstallPrompt />` at end of layout (highest z-index)
- No props needed (self-contained)
- Renders on every page (checks conditions internally)

### Step 2: Verify PWA Configuration

#### File: `vite.config.ts`

Ensure you have VitePWA plugin configured:

```typescript
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    VitePWA({
      registerType: 'prompt',
      includeAssets: ['favicon.ico', 'robots.txt', 'icons/apple-touch-icon.png'],
      manifest: {
        name: 'Your App Name',
        short_name: 'App',
        description: 'App description',
        theme_color: '#0067c8',
        background_color: '#ffffff',
        display: 'standalone',
        icons: [
          {
            src: 'icons/icon-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'icons/icon-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      }
    })
  ]
})
```

#### File: `public/manifest.webmanifest`

Ensure you have a valid manifest file.

### Step 3: Add Required Icons

```
public/
├── icons/
│   ├── apple-touch-icon.png     (180x180)
│   ├── icon-192x192.png         (192x192)
│   ├── icon-512x512.png         (512x512)
│   ├── favicon-32x32.png        (32x32)
│   └── favicon-16x16.png        (16x16)
└── favicon.ico
```

**Icon Requirements:**
- PNG format
- Square dimensions
- Transparent or solid background
- High contrast for readability

### Step 4: Test Detection

Create a test page to verify detection logic:

```typescript
// src/pages/TestPWA.tsx
export default function TestPWA() {
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
  const isStandalone = window.matchMedia('(display-mode: standalone)').matches
  const isSafari = /Safari/.test(navigator.userAgent) &&
                   !/CriOS|FxiOS|OPiOS|mercury/.test(navigator.userAgent)
  const dismissed = localStorage.getItem('pwa-install-prompt-dismissed')

  return (
    <div className="p-4">
      <h1>PWA Detection Test</h1>
      <ul>
        <li>Is iOS: {isIOS ? '✅' : '❌'}</li>
        <li>Is Safari: {isSafari ? '✅' : '❌'}</li>
        <li>Is Standalone: {isStandalone ? '✅' : '❌'}</li>
        <li>Dismissed: {dismissed || 'No'}</li>
      </ul>
      <button onClick={() => localStorage.removeItem('pwa-install-prompt-dismissed')}>
        Reset Dismissal
      </button>
    </div>
  )
}
```

---

## Customization Guide

### For Brandmine.io (or other projects)

#### 1. Update Brand Colors

Replace all instances of `#0067c8` (Rotary blue):

```typescript
// Find and replace:
border-[#0067c8]  →  border-[#YOUR_COLOR]
bg-[#0067c8]      →  bg-[#YOUR_COLOR]
text-[#0067c8]    →  text-[#YOUR_COLOR]
```

Or use Tailwind config:

```javascript
// tailwind.config.js
colors: {
  brand: {
    primary: '#YOUR_COLOR'
  }
}

// Then use: border-brand-primary, bg-brand-primary, etc.
```

#### 2. Update App Icon

```typescript
// In InstallPrompt.tsx, line 65
<img
  src="/icons/your-app-icon.png"  // Update path
  alt="Your App Name"              // Update alt text
  className="w-6 h-6"
/>
```

#### 3. Update Text Content

```typescript
// Header text (lines 76-80)
<h2>Install Our App</h2>
<p>For the best experience</p>

// Customize to:
<h2>Add to Home Screen</h2>
<p>Access [Your App] faster</p>
```

#### 4. Update Font Family

```typescript
// Line 74
style={{ fontFamily: "'Open Sans', sans-serif" }}

// Change to your brand font:
style={{ fontFamily: "'Your Font', sans-serif" }}
```

#### 5. Adjust Timing

```typescript
// Line 36
setTimeout(() => setShowPrompt(true), 3000)  // 3 seconds

// Make faster/slower:
setTimeout(() => setShowPrompt(true), 5000)  // 5 seconds
setTimeout(() => setShowPrompt(true), 1000)  // 1 second
```

#### 6. Change Position

```typescript
// Line 54
className="fixed bottom-20 left-4 right-4"

// Top of screen:
className="fixed top-20 left-4 right-4"

// Full width (no side margins):
className="fixed bottom-20 left-0 right-0"
```

#### 7. Update localStorage Key

```typescript
// Lines 22, 45
localStorage.getItem('pwa-install-prompt-dismissed')
localStorage.setItem('pwa-install-prompt-dismissed', 'true')

// Change to:
localStorage.getItem('brandmine-install-dismissed')
localStorage.setItem('brandmine-install-dismissed', 'true')
```

---

## Best Practices

### Do's ✅

1. **Use Smart Delays**
   - Wait 3-5 seconds before showing prompt
   - Don't interrupt users immediately on landing

2. **Respect User Choices**
   - Persist dismissal in localStorage
   - Don't show repeatedly if dismissed

3. **Target Specific Browsers**
   - Only show on iOS Safari (where it's useful)
   - Don't show on Android (has built-in install prompt)

4. **Make It Accessible**
   - Use ARIA labels for screen readers
   - Ensure 44x44px minimum touch targets
   - Support keyboard navigation

5. **Brand Consistently**
   - Use app icon and colors
   - Match overall app design language

6. **Test Thoroughly**
   - Test on real iOS devices (simulators may differ)
   - Test dismissal persistence
   - Test standalone mode detection

7. **Position Carefully**
   - Avoid overlapping navigation
   - Keep above fold (visible without scrolling)
   - Use high z-index (z-50+)

### Don'ts ❌

1. **Don't Show Too Early**
   - Avoid showing immediately on page load
   - Let users see content first

2. **Don't Show After Installation**
   - Always check standalone mode
   - Avoid annoying installed users

3. **Don't Block Content**
   - Make dismissal easy (X button + "Maybe later")
   - Don't require action to continue

4. **Don't Show on Non-iOS**
   - Android has native prompt (don't duplicate)
   - Desktop doesn't need home screen install

5. **Don't Use Tiny Tap Targets**
   - Always use minimum 44x44px
   - Leave space between interactive elements

6. **Don't Ignore Dismissals**
   - Respect localStorage flag
   - Never show again after dismissal

7. **Don't Make Instructions Unclear**
   - Use visual icons (Share, Plus)
   - Number steps clearly
   - Keep language simple

---

## Testing Checklist

### Pre-Deployment

- [ ] **Detection Logic**
  - [ ] Shows on iOS Safari
  - [ ] Hides on iOS Chrome/Firefox
  - [ ] Hides on Android
  - [ ] Hides on Desktop
  - [ ] Hides when already installed (standalone mode)
  - [ ] Hides after dismissal (localStorage check)

- [ ] **Timing**
  - [ ] 3-second delay works correctly
  - [ ] Doesn't show on initial render
  - [ ] Timer cleanup on unmount (no memory leaks)

- [ ] **Visual Design**
  - [ ] App icon displays correctly
  - [ ] Brand colors applied
  - [ ] Border visible and correct color
  - [ ] Shadow renders properly
  - [ ] Animation smooth (slide-up)
  - [ ] Responsive on different screen sizes
  - [ ] Doesn't overlap bottom navigation

- [ ] **Interactions**
  - [ ] X button dismisses modal
  - [ ] "Maybe later" button dismisses modal
  - [ ] Dismissal persists on page reload
  - [ ] Tap targets minimum 44x44px

- [ ] **Accessibility**
  - [ ] ARIA labels present
  - [ ] Screen reader announces modal
  - [ ] Keyboard navigation works
  - [ ] Focus management correct

- [ ] **Content**
  - [ ] App name correct
  - [ ] Instructions clear and accurate
  - [ ] Icons display (Share, Plus, X)
  - [ ] Font renders correctly

### Post-Deployment

- [ ] **Real Device Testing**
  - [ ] iPhone (iOS 15+)
  - [ ] iPad (iOS 15+)
  - [ ] iPhone SE (small screen)
  - [ ] iPad Pro (large screen)

- [ ] **Browser Testing**
  - [ ] Safari (iOS)
  - [ ] Chrome (iOS) - should NOT show
  - [ ] Firefox (iOS) - should NOT show

- [ ] **Installation Flow**
  - [ ] Instructions match actual iOS UI
  - [ ] Users can successfully install
  - [ ] App icon appears on home screen
  - [ ] Prompt disappears after installation
  - [ ] App launches in standalone mode

- [ ] **Edge Cases**
  - [ ] Clear localStorage and reload (should show)
  - [ ] Install app, then uninstall (should show again)
  - [ ] Dismiss, clear localStorage (should show again)
  - [ ] Multiple rapid dismissals (no errors)

### Testing Tools

#### Reset Dismissal (for repeated testing)
```javascript
// Run in browser console
localStorage.removeItem('pwa-install-prompt-dismissed')
```

#### Check Detection Values
```javascript
// Run in browser console
console.log({
  isIOS: /iPad|iPhone|iPod/.test(navigator.userAgent),
  isSafari: /Safari/.test(navigator.userAgent) && !/CriOS|FxiOS|OPiOS|mercury/.test(navigator.userAgent),
  isStandalone: window.matchMedia('(display-mode: standalone)').matches,
  dismissed: localStorage.getItem('pwa-install-prompt-dismissed')
})
```

#### Force Show Prompt (for testing)
```typescript
// Temporarily modify component for testing
useEffect(() => {
  // Comment out all checks, always show
  setTimeout(() => setShowPrompt(true), 3000)
}, [])
```

---

## Additional Resources

### iOS PWA Installation
- [Apple - Configuring Web Applications](https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html)
- [MDN - Add to Home Screen](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Add_to_home_screen)

### PWA Manifest
- [MDN - Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)
- [Web.dev - Install Criteria](https://web.dev/install-criteria/)

### Vite PWA Plugin
- [VitePWA Documentation](https://vite-pwa-org.netlify.app/)
- [GitHub - vite-plugin-pwa](https://github.com/vite-pwa/vite-plugin-pwa)

### Accessibility
- [Apple - iOS Accessibility Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [WCAG 2.1 - Touch Target Size](https://www.w3.org/WAI/WCAG21/Understanding/target-size.html)

---

## Version History

| Version | Date       | Changes                                      |
|---------|------------|----------------------------------------------|
| 1.0     | 2025-12-18 | Initial implementation for Georgetown Rotary |

---

## Implementation Example for Brandmine.io

Here's a complete copy-paste implementation customized for Brandmine:

### 1. Create Component

**File:** `src/components/InstallPrompt.tsx`

```typescript
import { useState, useEffect } from 'react'
import { X, Share, Plus } from 'lucide-react'

export default function InstallPrompt() {
  const [showPrompt, setShowPrompt] = useState(false)

  useEffect(() => {
    const dismissed = localStorage.getItem('brandmine-install-dismissed')
    if (dismissed === 'true') return

    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
    const isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches
    const isSafari = /Safari/.test(navigator.userAgent) && !/CriOS|FxiOS|OPiOS|mercury/.test(navigator.userAgent)

    if (isIOS && isSafari && !isInStandaloneMode) {
      const timer = setTimeout(() => setShowPrompt(true), 3000)
      return () => clearTimeout(timer)
    }
  }, [])

  const handleDismiss = () => {
    setShowPrompt(false)
    localStorage.setItem('brandmine-install-dismissed', 'true')
  }

  if (!showPrompt) return null

  return (
    <div
      className="fixed bottom-20 left-4 right-4 z-50 animate-slide-up"
      role="dialog"
      aria-labelledby="install-prompt-title"
      aria-describedby="install-prompt-description"
    >
      <div className="bg-white rounded-lg shadow-2xl border-2 border-[#YOUR_BRAND_COLOR] p-4 max-w-md mx-auto">
        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex items-center gap-2">
            <div className="bg-[#YOUR_BRAND_COLOR] rounded-lg p-2">
              <img
                src="/icons/your-app-icon.png"
                alt="Brandmine"
                className="w-6 h-6"
              />
            </div>
            <div>
              <h2 id="install-prompt-title" className="text-sm font-bold text-gray-900">
                Install Our App
              </h2>
              <p className="text-xs text-gray-600">For faster access</p>
            </div>
          </div>
          <button
            onClick={handleDismiss}
            className="flex-shrink-0 p-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
            aria-label="Dismiss installation prompt"
          >
            <X size={20} className="text-gray-500" />
          </button>
        </div>

        <div id="install-prompt-description" className="space-y-2 text-sm text-gray-700 mb-4">
          <p className="font-medium">To install this app:</p>
          <ol className="space-y-2 pl-1">
            <li className="flex items-start gap-3">
              <span className="flex-shrink-0 w-6 h-6 bg-[#YOUR_BRAND_COLOR] text-white rounded-full flex items-center justify-center text-xs font-bold">1</span>
              <span className="pt-0.5">
                Tap the <Share size={16} className="inline text-[#YOUR_BRAND_COLOR]" /> <strong>Share</strong> button below
              </span>
            </li>
            <li className="flex items-start gap-3">
              <span className="flex-shrink-0 w-6 h-6 bg-[#YOUR_BRAND_COLOR] text-white rounded-full flex items-center justify-center text-xs font-bold">2</span>
              <span className="pt-0.5">
                Scroll down and tap <Plus size={16} className="inline text-[#YOUR_BRAND_COLOR]" /> <strong>"Add to Home Screen"</strong>
              </span>
            </li>
            <li className="flex items-start gap-3">
              <span className="flex-shrink-0 w-6 h-6 bg-[#YOUR_BRAND_COLOR] text-white rounded-full flex items-center justify-center text-xs font-bold">3</span>
              <span className="pt-0.5">Tap <strong>"Add"</strong> to confirm</span>
            </li>
          </ol>
        </div>

        <div className="flex items-center justify-center gap-2 p-3 bg-blue-50 rounded-lg border border-blue-100">
          <Share size={20} className="text-[#YOUR_BRAND_COLOR]" />
          <span className="text-sm text-gray-700">Look for the Share button in your browser</span>
        </div>

        <button
          onClick={handleDismiss}
          className="mt-3 w-full text-center text-sm text-gray-500 hover:text-gray-700 underline min-h-[44px] flex items-center justify-center"
        >
          Maybe later
        </button>
      </div>
    </div>
  )
}
```

### 2. Add Animation to CSS

**File:** `src/index.css`

```css
@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slide-up 0.4s ease-out;
}
```

### 3. Import in Layout

**File:** `src/components/Layout.tsx` (or `App.tsx`)

```typescript
import InstallPrompt from './components/InstallPrompt'

export default function Layout({ children }) {
  return (
    <div>
      {/* Your existing layout */}
      <Header />
      <main>{children}</main>
      <Footer />

      {/* Add at the end */}
      <InstallPrompt />
    </div>
  )
}
```

### 4. Install Dependencies

```bash
pnpm add lucide-react vite-plugin-pwa
```

### 5. Configure Vite PWA

**File:** `vite.config.ts`

```typescript
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    VitePWA({
      registerType: 'prompt',
      manifest: {
        name: 'Brandmine',
        short_name: 'Brandmine',
        description: 'Your app description',
        theme_color: '#YOUR_BRAND_COLOR',
        icons: [
          {
            src: 'icons/icon-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'icons/icon-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      }
    })
  ]
})
```

---

## Support

For questions or issues implementing this pattern:
1. Review this document thoroughly
2. Test detection logic in browser console
3. Verify PWA configuration (manifest, icons)
4. Check browser compatibility (iOS Safari 11.3+)
5. Test on real iOS devices (simulators may differ)

---

**Document End**
