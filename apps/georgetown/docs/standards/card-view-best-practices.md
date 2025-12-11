# Card View & Modal Best Practices - 2025 Mobile-First Standards

**Date**: October 14, 2025
**Source**: Industry research (UXPin, UserPilot, UX Movement, Material Design, LogRocket)
**Application**: Georgetown Rotary Speaker Management System

---

## Executive Summary

This document captures industry-standard best practices for card-based UIs and modal interactions, researched in October 2025. These standards guide Georgetown Rotary's unified card view implementation across Speakers, Projects, Partners, and Members sections.

**Key Principle**: Mobile-first design with consistent, accessible patterns that work across all devices.

---

## Part 1: Card UI Design Best Practices

### 1.1 Card Purpose & Benefits

**What Cards Are**:
- Rectangular containers grouping related information
- Individual, scannable units of content
- Touch-friendly interaction surfaces

**Why Use Cards**:
- **Minimalist & User-Friendly**: Reduce cognitive load
- **Scannable**: Easy to understand at a glance
- **Responsive**: Adapt to all screen sizes (mobile, tablet, desktop)
- **Touch-Optimized**: Perfect for mobile-first design
- **Hierarchical**: Clear visual organization

**Source**: UXPin, Eleken Card UI Design Guides 2025

---

### 1.2 Card Action Placement Standards

#### **Top-Right Corner for Action Icons**
- **Why**: Familiar location across apps/websites (Material Design, iOS, Android)
- **What**: Menu icons, edit icons, more actions
- **Size**: 44x44px minimum touch target (WCAG 2.1)
- **Visibility**: Always visible OR easily discoverable (avoid hover-only on mobile)

#### **Bottom Placement for Primary CTAs**
- **Why**: Users scan top-to-bottom (Gutenberg Principle)
- **What**: Primary buttons ("View Details", "Learn More")
- **Timing**: After user has scanned content

#### **Supplemental Actions in Footer**
- **Why**: Keeps card body clean, actions follow content
- **What**: Secondary buttons, icon buttons (like, share, bookmark)
- **Limit**: 1-2 main actions max to avoid clutter

**Source**: Eleken, Halo-Lab, Material Design

---

### 1.3 Card Interaction Patterns

#### **Clickable Cards (Recommended)**
- **Pattern**: Entire card is clickable surface
- **Action**: Opens detailed view (modal or new page)
- **Affordance**: `cursor: pointer`, hover effects (shadow, border, lift)
- **Why**: Industry standard (Google, Trello, Asana, Notion)

#### **Touch Target Guidelines**
- **Minimum**: 48x48dp (WCAG 2.1 Level AAA)
- **Spacing**: Adequate gaps between touch targets
- **Feedback**: Visual response on tap/click (color, shadow, scale)

#### **Hover States** (Desktop Enhancement)
- **Effect**: Shadow increase, border color change, slight lift
- **Transition**: 200-300ms smooth
- **Purpose**: Confirms interactivity before click
- **Note**: NOT required for functionality (mobile has no hover)

**Source**: UXCam Mobile UX Guide, DesignStudioUIUX 2025

---

### 1.4 Card Content Best Practices

#### **Visual Hierarchy**
- **Header**: Most important info (name, title, status)
- **Body**: Supporting details
- **Footer**: Meta info (date, author) and actions

#### **Whitespace**
- **Purpose**: Prevents clutter, aids scanning
- **Amount**: Reasonable padding around all elements
- **Effect**: Clean, organized appearance

#### **Image/Avatar Placement**
- **Top or Left**: Feature images at top (full width)
- **Inline**: Avatars/icons inline with text (left side)
- **Fallback**: Always provide fallback for missing images (initials, colored background)

**Source**: UXPin, Best Practices for Designing UI Cards

---

### 1.5 Mobile-First Card Design

#### **Responsive Grid Patterns**
- **Mobile (320-767px)**: 1 column, full width
- **Tablet (768-1023px)**: 2 columns
- **Desktop (1024px+)**: 3-4 columns
- **CSS**: Use CSS Grid (`grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))`)

#### **Touch Optimization**
- **Tap Targets**: 44x44px minimum
- **Swipe Gestures**: Optional for revealing actions (edit, delete)
- **No Hover Dependencies**: All actions accessible without hover

#### **Performance**
- **Lazy Loading**: Load images as needed
- **Pagination**: Limit initial cards (20-50)
- **Smooth Scrolling**: Hardware-accelerated transitions

**Source**: UXCam, DesignStudioUIUX Mobile Best Practices

---

## Part 2: Modal UX Design Best Practices

### 2.1 Modal Types & When to Use

#### **Blocking Modals**
- **Purpose**: Critical actions requiring full attention
- **Examples**: Confirm delete, account verification, required forms
- **Behavior**: Overlay blocks main content, user must respond
- **Backdrop**: Dark overlay (black 50% opacity)

#### **Non-Blocking Modals**
- **Purpose**: Optional information or quick tasks
- **Examples**: View details, quick settings, info displays
- **Behavior**: User can dismiss easily, doesn't interrupt workflow
- **Backdrop**: Lighter overlay, click-to-close

**When to Use Modals**:
- Quick tasks that don't require new page
- Contextual information display
- Confirmation dialogs
- Multi-step forms (wizards)

**When NOT to Use**:
- Complex forms requiring extensive time
- Content that needs sharing (use dedicated page)
- Multiple consecutive modals (overwhelming)

**Source**: UserPilot, LogRocket Modal UX Guide

---

### 2.2 Modal Structure & Layout

#### **Header (Required)**
- **Elements**: Title, close button (X), optional actions
- **Style**: Colored background OR border-bottom
- **Sticky**: Remains visible when scrolling content
- **Position**: Top of modal, full width

#### **Body (Required)**
- **Content**: Main information, form fields, details
- **Scrolling**: Vertical scroll if content exceeds viewport
- **Padding**: Consistent spacing (24-32px)
- **Max-Height**: 85-90vh to prevent covering entire screen

#### **Footer (Optional)**
- **Elements**: Primary/secondary action buttons
- **Position**: Bottom of modal (NOT sticky for forms)
- **Layout**: Cancel left, Confirm/Save right (Western UX)
- **Sticky**: Only for long content where Save must be visible

**Source**: Material Design, UserPilot Modal Best Practices

---

### 2.3 Modal Button Placement Standards

#### **Action Buttons: Bottom-Right (Default)**
- **Why**: Users fill forms top-to-bottom, eyes end at bottom
- **When**: Edit forms, create forms, multi-step wizards
- **Exception**: Mobile keyboards (see below)

**Evidence**: 95% of web forms use bottom placement (UX Movement research)

#### **Action Buttons: Top-Right (Mobile Exception)**
- **Why**: Avoids keyboard covering buttons
- **When**: Forms with keyboard input on mobile
- **Platform**: iOS standard (Done/Save top-right), Android similar

**Evidence**: iOS Human Interface Guidelines, Android Material Design

#### **Edit Button in View Modals: Top-Right Header**
- **Why**: View modals = non-blocking, quick actions in header
- **When**: View-only modals with optional edit action
- **Always Visible**: Doesn't scroll out of view
- **Semantic**: Header = meta-actions (close, edit), body = content

**Evidence**: UserPilot, StackExchange UX research

---

### 2.4 Modal Accessibility Standards

#### **Keyboard Navigation**
- **Focus Trap**: Tab cycles within modal only
- **ESC Key**: Closes modal (non-blocking only)
- **Enter Key**: Submits form (when appropriate)
- **Initial Focus**: First input field OR close button

#### **Screen Readers**
- **Role**: `role="dialog"` or `role="alertdialog"`
- **Label**: `aria-labelledby` pointing to title
- **Description**: `aria-describedby` for context
- **Live Region**: Announce modal opening

#### **Visual Accessibility**
- **Contrast**: WCAG AA minimum (4.5:1 text, 3:1 UI)
- **Focus Indicators**: Visible outline on focused elements
- **Color Independence**: Don't rely on color alone

**Source**: WCAG 2.1 Guidelines, Material Design Accessibility

---

### 2.5 Modal Best Practices Checklist

✅ **Do**:
- Provide clear close button (X, top-right)
- Limit to 1 modal at a time
- Use dark backdrop (50% black opacity)
- Make modals dismissible (click outside OR ESC key)
- Keep content concise and scannable
- Use appropriate modal width (320px-800px)
- Ensure mobile responsiveness

❌ **Don't**:
- Use multiple modals consecutively
- Make modals too large (>90vh height)
- Hide close button
- Use modals for extensive content (use pages)
- Block users unnecessarily
- Auto-open modals without user intent

**Source**: LogRocket, UserPilot Modal UX 2025

---

## Part 3: Icon Standards & Semantics

### 3.1 Universal Icon Meanings

| Icon | Meaning | When to Use | Color Convention |
|------|---------|-------------|------------------|
| **Pencil (✏️)** | Edit | Modify existing content | Blue/Primary |
| **Plus (+)** | Add/Create | Create new item | Blue/Primary |
| **Trash (🗑️)** | Delete | Remove permanently | Red |
| **X (✕)** | Close/Cancel | Dismiss, cancel action | Gray/Neutral |
| **Eye (👁️)** | View | View-only, preview | Gray/Neutral |
| **External Link (↗️)** | Open externally | Leaves current context | Blue |
| **Check (✓)** | Confirm/Save | Accept, save changes | Green |
| **Gear (⚙️)** | Settings | Configuration options | Gray |

**Source**: Material Design Icons, Lucide Icons, Nielsen Norman Group

---

### 3.2 Icon Usage Best Practices

#### **CRITICAL: Use ONE Icon Design Consistently**

**Georgetown Rotary Standard**: `Pencil` from Lucide Icons for ALL edit actions

❌ **WRONG - Multiple Icon Types**:
```tsx
// Don't mix different edit icons
import { Edit } from 'lucide-react'  // ❌ Squared icon
import { Pencil } from 'lucide-react'  // ❌ Different style
import { PencilLine } from 'lucide-react'  // ❌ Another variant
```

✅ **CORRECT - Single Icon Type**:
```tsx
// Use Pencil everywhere
import { Pencil } from 'lucide-react'  // ✅ Consistent
```

**Why This Matters**:
- **Visual Consistency**: Users recognize the same shape instantly
- **Brand Identity**: One icon style = professional appearance
- **Reduced Confusion**: Different icons suggest different actions
- **Accessibility**: Screen readers announce consistent labels

**Lucide Icons Used at Georgetown Rotary**:
- **Edit Action**: `Pencil` (16px, outlined style)
- **Add Action**: `Plus` (20px)
- **Delete Action**: `Trash2` (18px)
- **Close Action**: `X` (20-24px)

---

#### **Always Pair Icons with Labels** (Accessibility)
- **Why**: Icons alone are ambiguous
- **How**:
  - Visual label (text next to icon)
  - OR `aria-label` for screen readers
  - OR `title` attribute for tooltips
- **Exception**: Universally recognized icons (X for close)

#### **Icon Sizing**
- **Small**: 14-16px (inline with text)
- **Medium**: 18-24px (buttons, cards)
- **Large**: 32-48px (hero sections, empty states)
- **Touch Targets**: Icon + padding = 44x44px minimum

#### **Icon Colors - MUST BE CONSISTENT**

**Georgetown Rotary Standard**: `text-gray-400 hover:text-[#005daa]`

❌ **WRONG - Inconsistent Colors**:
```tsx
// Don't use different colors for same action
<Pencil className="text-blue-600" />  // ❌ Wrong
<Pencil className="text-gray-500" />  // ❌ Wrong shade
<Pencil className="text-[#005daa]" />  // ❌ No hover state
```

✅ **CORRECT - Standard Color Pattern**:
```tsx
<Pencil size={16}
  className="text-gray-400 hover:text-[#005daa] transition-colors"
/>
```

**Color States**:
- **Base State**: `text-gray-400` (Tailwind gray-400: #9CA3AF)
- **Hover State**: `text-[#005daa]` (Rotary Azure)
- **Transition**: `transition-colors` (200ms smooth)
- **Disabled**: `text-gray-300 opacity-50 cursor-not-allowed`

**Why Consistent Colors Matter**:
- **Predictability**: Same visual = same action
- **Brand Cohesion**: Azure is Rotary's primary color
- **Accessibility**: Consistent contrast ratios
- **User Learning**: One pattern to remember

**Source**: Material Design, Lucide Icons Best Practices, Georgetown Rotary Brand Guide

---

## Part 4: Georgetown Rotary Unified Standard

### 4.1 Card Pattern (All Sections)

#### **Base State**
```tsx
<div className="bg-white border border-gray-200 rounded-lg p-4
                hover:shadow-lg hover:border-gray-300
                cursor-pointer transition-all duration-200
                relative group">

  {/* Edit Icon - Always Visible */}
  <button
    onClick={(e) => { e.stopPropagation(); handleEdit() }}
    className="absolute top-2 right-2 p-2 bg-white/90 hover:bg-white
                rounded-full shadow-md transition-all"
    aria-label="Edit item"
    title="Edit item"
  >
    <Pencil size={16} className="text-gray-400 hover:text-[#005daa]
                                  transition-colors" />
  </button>

  {/* Card Content */}
  <div onClick={handleViewDetails}>
    {/* Name, details, etc. */}
  </div>
</div>
```

#### **Key Features**
- ✅ Edit icon always visible (no hover dependency)
- ✅ Entire card clickable → opens view modal
- ✅ Edit icon stops propagation → opens edit directly
- ✅ Hover feedback (shadow, border, lift)
- ✅ Touch-friendly (44x44px button target)

---

### 4.2 View Modal Pattern (All Sections)

```tsx
<div className="fixed inset-0 bg-black bg-opacity-50
                flex items-center justify-center p-4 z-50">
  <div className="bg-white rounded-lg max-w-2xl w-full
                  max-h-[90vh] overflow-y-auto">

    {/* Sticky Header */}
    <div className="bg-[#005daa] text-white px-6 py-4 rounded-t-lg
                    flex items-center justify-between sticky top-0 z-10">
      <div className="flex items-center gap-3">
        <Icon size={24} />
        <h2 className="text-xl font-bold">Item Details</h2>
      </div>
      <div className="flex items-center gap-2">
        <button
          onClick={handleEdit}
          className="flex items-center gap-2 px-4 py-2
                    bg-white/10 hover:bg-white/20 rounded-lg"
          aria-label="Edit item"
        >
          <Edit size={18} />
          <span className="text-sm font-medium">Edit</span>
        </button>
        <button onClick={onClose} aria-label="Close">
          <X size={20} />
        </button>
      </div>
    </div>

    {/* Scrollable Content */}
    <div className="p-6 space-y-6">
      {/* All details */}
    </div>
  </div>
</div>
```

#### **Key Features**
- ✅ Sticky header (always visible)
- ✅ Edit button in header (top-right)
- ✅ Consistent width (max-w-2xl)
- ✅ Scrollable body
- ✅ Rotary Azure header color

---

### 4.3 Edit Modal Pattern (All Sections)

```tsx
<div className="fixed inset-0 bg-black bg-opacity-50
                flex items-center justify-center p-4 z-50">
  <div className="bg-white rounded-lg max-w-2xl w-full
                  max-h-[90vh] overflow-y-auto">

    {/* Header */}
    <div className="border-b px-6 py-4 flex items-center justify-between">
      <h2 className="text-xl font-bold">Edit Item</h2>
      <button onClick={onClose} aria-label="Close">
        <X size={20} />
      </button>
    </div>

    {/* Form */}
    <form onSubmit={handleSubmit} className="p-6">
      {/* Form fields */}

      {/* Action Buttons - Bottom */}
      <div className="flex justify-end gap-3 pt-6 border-t mt-6">
        <button
          type="button"
          onClick={onClose}
          className="px-4 py-2 border border-gray-300 text-gray-700
                    rounded-lg hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-[#005daa] text-white rounded-lg
                    hover:bg-[#004a8a]"
        >
          Save Changes
        </button>
      </div>
    </form>
  </div>
</div>
```

#### **Key Features**
- ✅ Save button at bottom-right
- ✅ Cancel button at bottom-left
- ✅ Consistent spacing and colors
- ✅ Form validation support

---

## Part 5: Mobile-First Design Principles

### 5.1 Touch Targets

**WCAG 2.1 Level AAA Standard**:
- **Minimum**: 44x44 CSS pixels (48x48dp on Android)
- **Spacing**: 8px gap between targets minimum
- **Padding**: Use padding to increase clickable area beyond icon

```css
/* Good: 44x44px touch target */
button {
  padding: 14px;  /* 14px * 2 + 16px icon = 44px */
}

/* Bad: Icon-only with no padding */
button {
  padding: 0;  /* Only 16px icon = too small */
}
```

**Source**: WCAG 2.1, Google Material Design

---

### 5.2 Responsive Breakpoints

**Georgetown Rotary Standard**:
```css
/* Mobile First */
.cards {
  grid-template-columns: 1fr;
}

/* Tablet: 768px+ */
@media (min-width: 768px) {
  .cards {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop: 1024px+ */
@media (min-width: 1024px) {
  .cards {
    grid-template-columns: repeat(3, 1fr);
  }
}

/* Large Desktop: 1280px+ */
@media (min-width: 1280px) {
  .cards {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

**Source**: Tailwind CSS, Bootstrap 5, Material Design

---

### 5.3 Mobile UX Considerations

#### **No Hover Dependencies**
- ❌ **Bad**: `opacity-0 group-hover:opacity-100` (invisible on mobile)
- ✅ **Good**: Always visible OR use mobile-friendly patterns (swipe)

#### **Gestures**
- **Swipe**: Reveal actions (edit, delete) - keeps cards clean
- **Long Press**: Context menus
- **Pinch**: Zoom (if applicable)
- **Note**: Always provide button fallback

#### **Keyboard Covers**
- **Problem**: Mobile keyboards cover 40-50% of screen
- **Solution**: Top placement for "Done"/"Save" OR scroll form into view
- **Best**: Use native browser behavior (form scrolling)

**Source**: UXCam Mobile UX, Apple HIG, Material Design

---

## Part 6: Accessibility Standards (WCAG 2.1)

### 6.1 Color & Contrast

**Minimum Requirements**:
- **Text**: 4.5:1 contrast ratio (AA)
- **Large Text** (18pt+): 3:1 contrast ratio (AA)
- **UI Components**: 3:1 contrast ratio (buttons, inputs)

**Georgetown Rotary Colors**:
- **Azure**: #005daa (primary) - AA compliant on white
- **Gold**: #f7a81b (accent) - Use for icons only, not body text
- **Gray-900**: #111827 (body text) - AAA compliant on white

**Tools**:
- WebAIM Contrast Checker
- Chrome DevTools Accessibility Panel

**Source**: WCAG 2.1 Level AA/AAA

---

### 6.2 Keyboard Navigation

**Requirements**:
- ✅ All interactive elements focusable (Tab order)
- ✅ Visual focus indicators (outline)
- ✅ Skip links for long content
- ✅ ESC closes modals
- ✅ Enter submits forms
- ✅ Arrow keys navigate lists/menus

**Implementation**:
```tsx
// Focus trap in modal
useEffect(() => {
  const modal = modalRef.current
  const focusableElements = modal.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )
  const firstElement = focusableElements[0]
  const lastElement = focusableElements[focusableElements.length - 1]

  firstElement.focus()

  // Tab trapping logic...
}, [])
```

**Source**: WCAG 2.1, WAI-ARIA Authoring Practices

---

### 6.3 Screen Reader Support

**Required ARIA Attributes**:
```tsx
// Modal
<div
  role="dialog"
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
  aria-modal="true"
>
  <h2 id="modal-title">Edit Speaker</h2>
  <p id="modal-description">Modify speaker information</p>
</div>

// Button without visible label
<button aria-label="Edit speaker" title="Edit speaker">
  <Pencil size={16} />
</button>

// Card
<div role="article" aria-label="Speaker card: John Doe">
  {/* Card content */}
</div>
```

**Testing**:
- NVDA (Windows)
- JAWS (Windows)
- VoiceOver (Mac/iOS)
- TalkBack (Android)

**Source**: WAI-ARIA 1.2, WCAG 2.1

---

## Part 7: Performance Best Practices

### 7.1 Card Rendering Optimization

**Virtualization** (For 100+ Cards):
```tsx
import { useVirtualizer } from '@tanstack/react-virtual'

// Only render visible cards
const virtualizer = useVirtualizer({
  count: cards.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 300, // Card height
})
```

**Lazy Loading Images**:
```tsx
<img
  src={speaker.portrait_url}
  loading="lazy"
  decoding="async"
  alt={speaker.name}
/>
```

**Pagination**:
- Load 20-50 cards initially
- Infinite scroll OR "Load More" button
- Preserve scroll position on navigation

**Source**: React Virtual, Web.dev Performance

---

### 7.2 Modal Performance

**Code Splitting**:
```tsx
// Load modal only when needed
const EditModal = lazy(() => import('./EditModal'))

{showModal && (
  <Suspense fallback={<Spinner />}>
    <EditModal {...props} />
  </Suspense>
)}
```

**Animation Performance**:
```css
/* Use transform/opacity for animations (GPU-accelerated) */
.modal-enter {
  opacity: 0;
  transform: scale(0.9);
}

.modal-enter-active {
  opacity: 1;
  transform: scale(1);
  transition: all 200ms ease;
}
```

**Source**: Web.dev, React Performance Best Practices

---

## Part 8: Testing Checklist

### 8.1 Functional Testing

**Card Interactions**:
- [ ] Card clicks open view modal
- [ ] Edit icon opens edit modal (bypasses view)
- [ ] Hover effects work on desktop
- [ ] Touch interactions work on mobile
- [ ] No accidental triggers (adequate spacing)

**Modal Behavior**:
- [ ] Opens smoothly (no jank)
- [ ] Close button works
- [ ] ESC key closes (non-blocking only)
- [ ] Click outside closes (configurable)
- [ ] Content scrolls correctly
- [ ] Edit button in header works
- [ ] Save button at bottom works

---

### 8.2 Responsive Testing

**Viewports to Test**:
- [ ] Mobile: 320px, 375px, 414px (iPhone SE, iPhone 12/13, iPhone 14 Pro Max)
- [ ] Tablet: 768px, 834px, 1024px (iPad, iPad Pro)
- [ ] Desktop: 1280px, 1440px, 1920px

**Orientation**:
- [ ] Portrait mode (mobile/tablet)
- [ ] Landscape mode (mobile/tablet)

**Tools**:
- Chrome DevTools Device Mode
- Real device testing (iOS/Android)
- BrowserStack for cross-browser

---

### 8.3 Accessibility Testing

**Automated Tools**:
- [ ] axe DevTools (Chrome/Firefox)
- [ ] WAVE (WebAIM)
- [ ] Lighthouse Accessibility Audit

**Manual Testing**:
- [ ] Keyboard navigation (Tab, Enter, ESC)
- [ ] Screen reader (NVDA, VoiceOver)
- [ ] Color contrast (WebAIM Contrast Checker)
- [ ] Focus indicators visible
- [ ] Touch targets adequate (44x44px)

**Source**: WCAG 2.1, axe-core

---

## Part 9: Button Label Best Practices

### 9.1 Task-Specific vs Generic Button Labels

**Research Finding**: Task-specific button labels significantly improve user experience and reduce errors compared to generic labels like "Save Changes" or "Submit".

#### **The Problem with Generic Labels**

❌ **Generic Labels Create Uncertainty**:
- "Save Changes" - Save what changes? To what?
- "Submit" - Submit what exactly?
- "OK" - User uncertain what action will occur

**User Behavior**: When faced with generic labels, users must:
1. Re-read the entire dialog/form to confirm intent
2. Second-guess whether clicking is correct action
3. Experience higher error rates and anxiety

**Source**: UX Movement, "Buttons Should Be Clear Not Clever"

---

#### **Why Task-Specific Labels Are Better**

✅ **Task-Specific Labels Enable Confident Action**:
- "Update Partner" - Clear: updating partner record
- "Create Member" - Clear: creating new member
- "Delete Project" - Clear: removing project permanently

**Research Evidence** (Nielsen Norman Group):
> "Users can act on a task-specific button without reading the dialog if the button label accurately describes the action."

**Benefits**:
1. **Faster Task Completion**: Users don't need to re-read context
2. **Lower Error Rates**: Clear intent reduces accidental clicks
3. **Better Accessibility**: Screen readers announce clear actions
4. **Reduced Cognitive Load**: One label tells the whole story

**Source**: Nielsen Norman Group, "OK-Cancel or Cancel-OK? The Trouble With Buttons"

---

### 9.2 Georgetown Rotary Button Label Standard

**Pattern**: `[Action Verb] [Specific Noun]`

**Examples**:

| Context | ❌ Generic Label | ✅ Task-Specific Label |
|---------|-----------------|----------------------|
| Edit partner form | "Save Changes" | "Update Partner" |
| Add member form | "Submit" | "Create Member" |
| Edit speaker form | "Save" | "Update Speaker" |
| Delete confirmation | "OK" | "Delete Project" |
| Create project form | "Submit" | "Create Project" |

---

### 9.3 Loading State Labels

**Pattern**: `[Action Verb]ing...` (present continuous)

**Examples**:

| Action | Button Label | Loading State |
|--------|-------------|---------------|
| Update | "Update Partner" | "Updating..." |
| Create | "Create Member" | "Creating..." |
| Delete | "Delete Project" | "Deleting..." |
| Save | "Save Event" | "Saving..." |

**Implementation**:
```tsx
// ✅ CORRECT - Task-specific with matching loading state
<button type="submit" disabled={isSubmitting}>
  {isSubmitting ? 'Updating...' : 'Update Partner'}
</button>

// ❌ WRONG - Generic label
<button type="submit" disabled={isSubmitting}>
  {isSubmitting ? 'Saving...' : 'Save Changes'}
</button>
```

---

### 9.4 Modal Context Determines Button Label

**View Modals** (Non-blocking):
- Primary action: "Edit" button in header (top-right)
- Purpose: Switch to edit mode
- Label: Just "Edit" is sufficient (context is view mode)

**Edit Modals** (Blocking):
- Primary action: Save button at bottom-right
- Purpose: Commit changes to database
- Label: Task-specific ("Update Partner", not "Save Changes")

**Create Modals** (Blocking):
- Primary action: Create button at bottom-right
- Purpose: Add new record to database
- Label: Task-specific ("Create Member", not "Submit" or "Add")

---

### 9.5 Secondary Button Labels

**Cancel**: Universal standard
- **When**: User wants to abandon action without saving
- **Label**: Always "Cancel" (no ambiguity)
- **Position**: Bottom-left (Western UX convention)
- **Style**: Neutral/outline (not primary color)

**Close**: For non-blocking modals
- **When**: View-only modals with no form
- **Label**: "Close" OR X icon (top-right)
- **Position**: Header (top-right corner)
- **Style**: Icon button OR text button

---

### 9.6 Button Label Accessibility

**Screen Reader Considerations**:
```tsx
// ✅ CORRECT - Clear announcement
<button type="submit" aria-label="Update partner record">
  {isSubmitting ? 'Updating...' : 'Update Partner'}
</button>

// Screen reader announces: "Update partner record, button"
// User knows exactly what will happen

// ❌ WRONG - Ambiguous announcement
<button type="submit" aria-label="Save changes">
  Save Changes
</button>

// Screen reader announces: "Save changes, button"
// User uncertain what changes will be saved
```

**Best Practice**: Button text alone should be sufficient; only add `aria-label` if additional context is needed for screen readers.

---

### 9.7 Implementation Checklist

When creating or reviewing forms, verify:

- [ ] All submit buttons use task-specific labels ("Update Partner", not "Save")
- [ ] Loading states match button action ("Updating...", not "Saving...")
- [ ] Cancel buttons consistently labeled "Cancel"
- [ ] Close buttons (X icon) in top-right of non-blocking modals
- [ ] Edit buttons in view modals labeled "Edit" (in header, top-right)
- [ ] No generic labels like "Submit", "OK", "Apply", or "Save Changes"
- [ ] Button labels match aria-labels for accessibility
- [ ] Modal title + button label = clear user understanding

**Example Verification**:
```tsx
// Modal: "Edit Partner"
// Button: "Update Partner" ✅ MATCHES

// Modal: "Partner Details"
// Button: "Save Changes" ❌ UNCLEAR - Change to "Update Partner"
```

---

### 9.8 Research Sources

**Nielsen Norman Group**:
- "OK-Cancel or Cancel-OK? The Trouble With Buttons" (2023)
- "Button Labels and Microcopy" (2024)

**UX Movement**:
- "Buttons Should Be Clear Not Clever" (2022)
- "Why Generic Form Buttons Hurt UX" (2024)

**StackExchange UX**:
- "Are generic Save/Cancel buttons acceptable?" (consensus: No)
- "Button label best practices for forms" (2024)

**Material Design**:
- Dialog button guidelines (task-specific preferred)

---

## Part 10: Common Pitfalls to Avoid

### 10.1 Card Design Mistakes

❌ **Too Much Content**
- Cards should be scannable (3-5 seconds max)
- Use "View More" for extensive details

❌ **Hover-Dependent Actions**
- Mobile users can't hover
- Always provide visible or swipe-accessible actions

❌ **Inconsistent Card Sizes**
- Varying heights create visual chaos
- Use `align-items: stretch` or fixed heights

❌ **Poor Touch Targets**
- Icons without adequate padding
- Buttons smaller than 44x44px

---

### 10.2 Modal Design Mistakes

❌ **Modal Within Modal**
- Never nest modals
- Use stepper/wizard for multi-step flows

❌ **No Close Option**
- Always provide X button
- Consider ESC key and click-outside

❌ **Too Large**
- Modals >90vh height cover entire screen
- Use dedicated page for extensive content

❌ **Inconsistent Button Placement**
- Mixing top/bottom save buttons confuses users
- Pick one pattern and stick to it

---

### 10.3 Accessibility Mistakes

❌ **Missing Focus Trap**
- Tab escapes modal → user lost
- Implement focus management

❌ **No Keyboard Support**
- Mouse-only interactions
- Test with keyboard only

❌ **Poor Color Contrast**
- Gray-on-gray text unreadable
- Use contrast checker tools

❌ **Missing ARIA Labels**
- Icon-only buttons confuse screen readers
- Add `aria-label` to all icons

**Source**: Nielsen Norman Group, WebAIM

---

## Part 11: References & Resources

### Research Sources (October 2025)

**Card UI Design**:
- UXPin: "How to Design Card UI and Why They Matter"
- Eleken: "17 Card UI Design Examples and Best Practices"
- Halo-Lab: "Cards UI Design — Inspiring Examples and Best Practices"
- Material Design: Card Component Guidelines

**Modal UX Design**:
- UserPilot: "Modal UX Design for SaaS in 2025"
- LogRocket: "Modal UX design: Patterns, examples, and best practices"
- UX Movement: "Best Practices for Modal Windows"
- StackExchange UX: Mobile button placement discussions

**Mobile-First Design**:
- UXCam: "Mobile UX Design - The Ultimate Guide 2025"
- DesignStudioUIUX: "12 Mobile App UI/UX Design Best Practices (2025)"
- Google: Material Design Mobile Guidelines

**Accessibility**:
- W3C: WCAG 2.1 Guidelines
- WebAIM: Accessibility Resources
- WAI-ARIA: Authoring Practices Guide 1.2

---

### Tools & Libraries

**Design Systems**:
- Material Design (Google)
- Human Interface Guidelines (Apple)
- Fluent Design (Microsoft)

**Icon Libraries**:
- Lucide Icons (Georgetown Rotary uses this)
- Heroicons
- Material Icons

**React Libraries**:
- @dnd-kit/core (drag-and-drop)
- @tanstack/react-virtual (virtualization)
- Radix UI (accessible components)

**Testing Tools**:
- axe DevTools
- WAVE (WebAIM)
- Lighthouse
- BrowserStack

---

## Conclusion

These best practices represent industry consensus as of 2025 for mobile-first card and modal design. Georgetown Rotary's implementation follows these standards to provide:

1. **Consistency**: One pattern to learn across all sections
2. **Accessibility**: WCAG 2.1 compliant, screen reader friendly
3. **Mobile-First**: Touch-optimized, no hover dependencies
4. **Performance**: Optimized rendering and loading
5. **User Experience**: Intuitive, efficient workflows

**Maintained By**: Georgetown Rotary Development Team
**Last Updated**: October 14, 2025
**Next Review**: April 2026 (6 months)
