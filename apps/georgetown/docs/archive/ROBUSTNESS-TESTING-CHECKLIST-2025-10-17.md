# Georgetown Rotary - Robustness Testing Checklist
**Date**: October 17, 2025
**Application**: Georgetown Rotary Speaker Management System
**Purpose**: Comprehensive manual testing checklist for production readiness validation

---

## Testing Overview

This checklist covers all critical user flows, edge cases, and robustness scenarios for the Georgetown Rotary application. Each item should be tested and marked with ✅ PASS, ⚠️ PARTIAL, or ❌ FAIL.

**Testers**: CEO, COO, or designated Rotary officers
**Environment**: Preview build (http://localhost:4173/) or production
**Devices Required**: iPhone/Android phone, iPad/tablet, desktop/laptop

---

## Section 1: Mobile-First Validation

### 1.1 Touch Targets (320px-414px viewports)

**Test on**: iPhone SE (320px), iPhone 12/13 (375px), iPhone 14 Pro Max (414px)

- [ ] **All buttons are easy to tap** (44x44px minimum)
  - [ ] Bottom navigation tabs (Home, Members, Calendar, Projects, Speakers)
  - [ ] "Add Speaker" button in header
  - [ ] Edit buttons on speaker cards
  - [ ] LinkedIn/social media buttons
  - [ ] Close/cancel buttons on modals

- [ ] **No accidental taps** when scrolling
  - [ ] Cards don't trigger when swiping
  - [ ] Drag-and-drop requires 8px movement before activating

- [ ] **Links are tappable** (not too small)
  - [ ] Website URLs in speaker/member/partner cards
  - [ ] Email addresses (should open email app)
  - [ ] Phone numbers (should open phone app)

**Result**: _____ / 8 items passed

---

### 1.2 Typography Readability

**Test on**: Mobile devices (320px-414px)

- [ ] **Body text is 14px minimum** (readable without zoom)
  - [ ] Speaker card descriptions
  - [ ] Member contact info
  - [ ] Project descriptions
  - [ ] Form helper text

- [ ] **Headings are clearly distinguished**
  - [ ] Section headers (SPEAKERS, MEMBERS, etc.)
  - [ ] Card titles
  - [ ] Modal titles

- [ ] **Line height provides good readability**
  - [ ] Paragraph text not cramped
  - [ ] Lists have proper spacing

**Result**: _____ / 9 items passed

---

### 1.3 Responsive Layouts

**Test on**: 320px, 375px, 414px, 768px, 1024px, 1440px

- [ ] **320px (iPhone SE)** - Smallest mobile
  - [ ] No horizontal scrolling
  - [ ] Content fits within viewport
  - [ ] Bottom nav visible and functional
  - [ ] Forms are usable

- [ ] **375px (iPhone 12/13)** - Primary mobile
  - [ ] Optimal card sizing
  - [ ] Grid layouts work correctly
  - [ ] Modals fit on screen

- [ ] **414px (iPhone Pro Max)** - Large mobile
  - [ ] No wasted space
  - [ ] Cards scale appropriately

- [ ] **768px (iPad)** - Tablet
  - [ ] Grid changes to 2 columns
  - [ ] Desktop nav appears
  - [ ] Bottom nav still visible

- [ ] **1024px (Desktop)** - Small desktop
  - [ ] Grid changes to 3-4 columns
  - [ ] Full desktop navigation visible
  - [ ] Bottom nav hidden

- [ ] **1440px+ (Large Desktop)** - Wide screen
  - [ ] Content has max-width constraint
  - [ ] No excessive whitespace
  - [ ] Grid layouts optimal

**Result**: _____ / 19 items passed

---

### 1.4 Touch Gestures

**Test on**: Mobile devices (iOS and Android)

- [ ] **Drag-and-drop works on mobile**
  - [ ] Can drag speaker cards between board columns
  - [ ] Drag indicator appears (8px activation)
  - [ ] Drop zones highlight correctly
  - [ ] Card snaps into place on drop

- [ ] **Horizontal scroll on board view**
  - [ ] Swipe left/right between columns
  - [ ] Snap scrolling works
  - [ ] No accidental vertical scroll

- [ ] **Pull-to-refresh** (browser default)
  - [ ] Works as expected
  - [ ] Doesn't interfere with drag-and-drop

- [ ] **Long press on cards**
  - [ ] Opens detail modal
  - [ ] Doesn't trigger unwanted actions

**Result**: _____ / 9 items passed

---

## Section 2: Core Functionality Testing

### 2.1 Speaker Management

**Precondition**: Access /speakers page

**Create Speaker:**
- [ ] Click "Add Speaker" button
- [ ] Fill required fields (Name, Topic)
- [ ] Add optional fields (email, phone, organization, date)
- [ ] Upload portrait photo
- [ ] Add LinkedIn URL
- [ ] Add social media links
- [ ] Select "Is Rotarian" checkbox
- [ ] Save successfully
- [ ] Speaker appears in "Ideas" column

**Edit Speaker:**
- [ ] Click edit button on speaker card
- [ ] Modify fields
- [ ] Save changes
- [ ] Changes persist after refresh

**Drag-and-Drop:**
- [ ] Drag speaker from Ideas → Approached
- [ ] Drag speaker to Scheduled
- [ ] Drag speaker to Spoken
- [ ] Drag speaker to Dropped
- [ ] Status updates immediately
- [ ] Changes persist after refresh

**View Speaker Details:**
- [ ] Click speaker card to open detail modal
- [ ] All fields display correctly
- [ ] Portrait photo displays
- [ ] Links are clickable and open in new tab

**Filter Speakers:**
- [ ] Search by name
- [ ] Filter by status (Active, Pipeline, Scheduled, Spoken, Dropped)
- [ ] Filter by Rotarian status
- [ ] Filter by scheduled date (Upcoming, Past)
- [ ] Filter by recommended speakers
- [ ] Multiple filters work together

**View Modes:**
- [ ] Switch to Cards view (grid layout)
- [ ] Switch to Board view (kanban)
- [ ] Switch to List view (spreadsheet)
- [ ] All views show correct data

**List View Features:**
- [ ] Sort by name, organization, topic, status, date
- [ ] Sort direction toggles (ascending/descending)
- [ ] Export to CSV
- [ ] CSV includes all visible columns
- [ ] Column visibility toggle
- [ ] Drag-and-drop to reorder columns

**Result**: _____ / 35 items passed

---

### 2.2 Member Directory

**Precondition**: Access /members page

**Create Member:**
- [ ] Click "Add Member" button
- [ ] Fill required fields (Name)
- [ ] Add optional fields (prefix, job title, email, mobile, company)
- [ ] Upload portrait photo
- [ ] Add LinkedIn URL
- [ ] Add social media links
- [ ] Select roles (President, Secretary, etc.)
- [ ] Select member type (Active, Honorary, Former)
- [ ] Mark as charter member (if applicable)
- [ ] Add Paul Harris Fellow level (if applicable)
- [ ] Add birthday (month and day)
- [ ] Add citizenship
- [ ] Add classification
- [ ] Add member since year
- [ ] Save successfully

**Edit Member:**
- [ ] Click edit button on member card
- [ ] Modify fields
- [ ] Save changes
- [ ] Changes persist after refresh

**View Member Details:**
- [ ] Click member card to open detail modal
- [ ] All fields display correctly
- [ ] Portrait photo displays
- [ ] Links are clickable

**Birthday Highlighting:**
- [ ] Members with today's birthday show gift icon
- [ ] Birthday section highlights in gold
- [ ] "Happy Birthday" message appears

**PHF Badge Display:**
- [ ] PHF pin icon appears for Paul Harris Fellows
- [ ] Tooltip shows PHF level

**Filter Members:**
- [ ] Search by name
- [ ] Filter by role (President, Officer, Chair, Member)
- [ ] Filter by member type (Active, Honorary, Former)
- [ ] Filter by charter member status
- [ ] Multiple filters work together

**Result**: _____ / 27 items passed

---

### 2.3 Service Projects

**Precondition**: Access /projects page

**Create Project:**
- [ ] Click "Add Project" button
- [ ] Fill required fields (Project name, Rotary year)
- [ ] Add optional fields (description, start date, completion date)
- [ ] Select status (Planning, In Progress, Completed)
- [ ] Add project leader
- [ ] Add budget information
- [ ] Upload project photo
- [ ] Save successfully

**Edit Project:**
- [ ] Click edit button on project card
- [ ] Modify fields
- [ ] Save changes
- [ ] Changes persist after refresh

**View Project Details:**
- [ ] Click project card to open detail modal
- [ ] All fields display correctly
- [ ] Project photo displays
- [ ] Date formatting correct

**Filter Projects:**
- [ ] Search by project name
- [ ] Filter by status (Planning, In Progress, Completed)
- [ ] Filter by Rotary year
- [ ] Multiple filters work together

**Result**: _____ / 17 items passed

---

### 2.4 Partners Directory

**Precondition**: Access /partners page

**Create Partner:**
- [ ] Click "Add Partner" button
- [ ] Fill required fields (Partner name, Type)
- [ ] Select partner type (Rotary Club, Foundation, NGO, Corporate, Government)
- [ ] Add contact information (name, email, phone)
- [ ] Add website URL
- [ ] Add social media links
- [ ] Add logo image
- [ ] Save successfully

**Edit Partner:**
- [ ] Click edit button on partner card
- [ ] Modify fields
- [ ] Save changes
- [ ] Changes persist after refresh

**View Partner Details:**
- [ ] Click partner card to open detail modal
- [ ] All fields display correctly
- [ ] Logo displays correctly
- [ ] Links are clickable

**Filter Partners:**
- [ ] Search by partner name
- [ ] Filter by partner type
- [ ] Multiple filters work together

**Result**: _____ / 16 items passed

---

### 2.5 Timeline / History

**Precondition**: Access /timeline page

**Year Selection:**
- [ ] Dropdown shows all Rotary years
- [ ] Current year is marked as "(Current)"
- [ ] Selecting different year loads correct data

**Year Overview:**
- [ ] President and theme display correctly
- [ ] Theme logo loads properly (if exists)
- [ ] Statistics display correctly
  - [ ] Total members
  - [ ] Member net change
  - [ ] Total meetings
  - [ ] Total speakers
  - [ ] Completed projects
  - [ ] Club year summary displays
  - [ ] Detailed narrative displays
  - [ ] Highlights list displays
  - [ ] Challenges list displays

**Edit Year Narrative (Officers/Chairs only):**
- [ ] Edit button appears for officers/chairs
- [ ] Click edit button opens NarrativeEditor modal
- [ ] Year summary field is editable
- [ ] Detailed narrative field is editable
- [ ] Highlights can be added/removed
- [ ] Challenges can be added/removed
- [ ] Auto-save works (2-second debounce)
- [ ] Save indicator shows "Saving..." then "Saved"
- [ ] Changes persist immediately
- [ ] Close modal and verify changes saved

**Service Projects Section:**
- [ ] Completed projects from selected year display
- [ ] Project cards show correctly
- [ ] Empty state displays if no projects
- [ ] Click project opens detail modal

**Featured Speakers Section:**
- [ ] Speakers who spoke during selected year display
- [ ] Speaker cards show correctly (SpeakerCardSimple, read-only)
- [ ] Empty state displays if no speakers
- [ ] Click speaker opens detail modal

**Photo Gallery Section:**
- [ ] Photos from selected year display
- [ ] Photo grid layout works (2-4 columns responsive)
- [ ] Lazy loading prevents all photos loading at once
- [ ] Click photo opens lightbox
- [ ] Lightbox shows full-size image
- [ ] Lightbox shows title, caption, date
- [ ] Close lightbox with X button or click outside
- [ ] Empty state displays if no photos

**Upload Photo (Officers/Chairs only):**
- [ ] Upload button appears in photo section
- [ ] Click opens PhotoUploadModal
- [ ] Selected year is pre-filled in form
- [ ] Upload photo with all fields
- [ ] Photo appears in gallery after upload

**Result**: _____ / 41 items passed

---

### 2.6 Photo Gallery

**Precondition**: Access /photos page

**Upload Photo (Officers/Chairs only):**
- [ ] Click "Upload Photo" button
- [ ] Select image file (JPG, PNG, WebP)
- [ ] Image preview appears
- [ ] Fill title (required)
- [ ] Add caption with markdown (optional)
- [ ] Select photo date
- [ ] Add photographer name
- [ ] Add location
- [ ] Select Rotary year
- [ ] Select category (General, Event, Fellowship, Service, Community, Members)
- [ ] Add tags
- [ ] Select visibility (Public, Members Only, Officers Only)
- [ ] Upload successfully
- [ ] Compression happens automatically
- [ ] Photo appears in gallery

**View Photos:**
- [ ] Grid layout displays correctly
- [ ] Lazy loading works (images load as you scroll)
- [ ] Click photo to open lightbox
- [ ] Lightbox displays full-size image
- [ ] Caption renders with markdown (bold, italics)
- [ ] Close lightbox works

**Filter Photos:**
- [ ] Search by title or caption
- [ ] Filter by Rotary year
- [ ] Filter by category
- [ ] Filter by photographer
- [ ] Filter by tags
- [ ] Multiple filters work together

**Result**: _____ / 25 items passed

---

### 2.7 Calendar View

**Precondition**: Access /calendar page

**View Calendar:**
- [ ] Current month displays by default
- [ ] Navigate to previous month
- [ ] Navigate to next month
- [ ] Today's date is highlighted
- [ ] Events appear on correct dates

**Add Event:**
- [ ] Click "Add Event" button or click on date
- [ ] Fill required fields (Title, Date, Type)
- [ ] Select event type (Club Meeting, Club Event, Service Project, Holiday, Observance)
- [ ] Add description
- [ ] Select location
- [ ] Save successfully
- [ ] Event appears on calendar

**Edit Event:**
- [ ] Click event to open detail modal
- [ ] Click edit button
- [ ] Modify fields
- [ ] Save changes
- [ ] Changes appear on calendar

**Delete Event:**
- [ ] Click event to open detail modal
- [ ] Click delete button
- [ ] Confirm deletion
- [ ] Event removed from calendar

**Filter Events:**
- [ ] Filter by event type
- [ ] Only selected types display

**Result**: _____ / 19 items passed

---

## Section 3: Robustness & Edge Case Testing

### 3.1 Network Conditions

**Test with**: Chrome DevTools → Network → Throttling

**Slow 3G Simulation:**
- [ ] Application loads within 10 seconds
- [ ] Loading indicators appear during data fetch
- [ ] Images load progressively
- [ ] No broken UI elements
- [ ] Real-time updates still work (delayed)

**Offline Mode:**
- [ ] Turn on airplane mode or disable network
- [ ] Try to load page (should show browser offline page)
- [ ] Try to create speaker (should fail gracefully)
- [ ] Try to edit member (should fail gracefully)
- [ ] Turn network back on
- [ ] Verify app recovers and loads data

**Intermittent Connectivity:**
- [ ] Use Network throttling → Offline for 5 seconds → Online
- [ ] Verify loading states appear
- [ ] Verify error messages are user-friendly
- [ ] Verify app recovers when connection restored

**API Call Failures:**
- [ ] Block Supabase domain in browser (DevTools → Network → Block request domain)
- [ ] Try to load data (should show error message, not crash)
- [ ] Unblock and verify recovery

**Result**: _____ / 16 items passed

---

### 3.2 Empty States

**No Data Scenarios:**

- [ ] **No Speakers** - Speakers page with zero speakers
  - [ ] Shows helpful empty state message
  - [ ] "Add Speaker" button visible and functional

- [ ] **No Members** - Members page with zero members
  - [ ] Shows helpful empty state message
  - [ ] "Add Member" button visible

- [ ] **No Projects** - Projects page with zero projects
  - [ ] Shows helpful empty state message
  - [ ] "Add Project" button visible

- [ ] **No Partners** - Partners page with zero partners
  - [ ] Shows helpful empty state message
  - [ ] "Add Partner" button visible

- [ ] **No Photos** - Photo gallery with zero photos
  - [ ] Shows helpful empty state message
  - [ ] "Upload Photo" button visible

- [ ] **Timeline with no speakers** - Year with zero speakers
  - [ ] Shows "No speakers have presented during this Rotary year yet"

- [ ] **Timeline with no projects** - Year with zero projects
  - [ ] Shows "No completed projects linked to this Rotary year yet"

- [ ] **Timeline with no photos** - Year with zero photos
  - [ ] Shows "No photos from this Rotary year yet"

**Result**: _____ / 8 items passed

---

### 3.3 Long Text Inputs

**Test with**: Very long strings (200+ characters)

- [ ] **Long speaker name** (100 characters)
  - [ ] Name truncates in card view
  - [ ] Full name visible in detail modal
  - [ ] No layout breaking

- [ ] **Long organization name** (150 characters)
  - [ ] Truncates with ellipsis
  - [ ] No horizontal overflow

- [ ] **Long topic** (300 characters)
  - [ ] Truncates to 2 lines in card view
  - [ ] Full text visible in modal

- [ ] **Long description** (1000 characters)
  - [ ] Scrollable in modal
  - [ ] No performance issues

- [ ] **Long URL** (500 characters)
  - [ ] Truncates with ellipsis
  - [ ] Full URL in title tooltip
  - [ ] Clickable and works correctly

- [ ] **Long notes field** (2000 characters)
  - [ ] Textarea expands correctly
  - [ ] Saves successfully
  - [ ] No database errors

**Result**: _____ / 12 items passed

---

### 3.4 Special Characters

**Test with**: Emojis, accents, symbols

- [ ] **Name with accents** (José García, François Müller)
  - [ ] Displays correctly
  - [ ] Search works
  - [ ] Sorting works

- [ ] **Name with emojis** (John Doe 😊)
  - [ ] Displays correctly
  - [ ] No layout breaking

- [ ] **Description with markdown** (**bold**, *italic*)
  - [ ] Renders correctly
  - [ ] No XSS vulnerabilities

- [ ] **URLs with query parameters** (https://example.com?foo=bar&baz=qux)
  - [ ] Links work correctly
  - [ ] No encoding issues

- [ ] **Email with special characters** (john+tag@example.com)
  - [ ] Displays correctly
  - [ ] mailto: link works

- [ ] **Phone with formatting** (+1 (555) 123-4567)
  - [ ] Displays correctly
  - [ ] tel: link works

**Result**: _____ / 12 items passed

---

### 3.5 Invalid Data

**Test with**: Malformed or invalid inputs

- [ ] **Invalid email** (notanemail)
  - [ ] HTML5 validation catches error
  - [ ] Error message displayed

- [ ] **Invalid URL** (notaurl)
  - [ ] ⚠️ Currently no validation (known issue)
  - [ ] Link may not work but shouldn't break app

- [ ] **Invalid phone** (abc123)
  - [ ] ⚠️ Currently no validation (known issue)
  - [ ] Stores as text, won't break app

- [ ] **Future date for past event** (scheduled date in 2030 for "Spoken" speaker)
  - [ ] ⚠️ No validation (known issue)
  - [ ] Data saves but may be incorrect

- [ ] **Impossible date** (February 30)
  - [ ] Browser date picker prevents this

- [ ] **Negative numbers** (if any numeric fields)
  - [ ] Should be prevented or handled gracefully

**Result**: _____ / 6 items passed

---

### 3.6 Maximum Data Scenarios

**Test with**: Large datasets

- [ ] **100+ speakers**
  - [ ] Cards view loads smoothly
  - [ ] Board view performs well
  - [ ] List view sorts quickly
  - [ ] Filtering works efficiently
  - [ ] No visual glitches

- [ ] **100+ members**
  - [ ] Directory loads smoothly
  - [ ] Filtering works efficiently
  - [ ] Scrolling is smooth

- [ ] **50+ service projects**
  - [ ] Grid loads smoothly
  - [ ] No performance issues

- [ ] **200+ photos**
  - [ ] Lazy loading works correctly
  - [ ] Scrolling performance is good
  - [ ] Filtering works efficiently

**Result**: _____ / 13 items passed

---

### 3.7 Image Handling

**Test with**: Various image formats and sizes

- [ ] **Large image (10MB)** - Maximum allowed
  - [ ] Upload succeeds
  - [ ] Compression reduces size
  - [ ] Displays correctly

- [ ] **Very large image (20MB)** - Exceeds limit
  - [ ] Upload rejected with error message
  - [ ] Error message is clear

- [ ] **Tiny image (1KB)** - Very small
  - [ ] Upload succeeds
  - [ ] Displays correctly (may be pixelated but okay)

- [ ] **Square portrait** (1000x1000px)
  - [ ] Displays correctly in circular crop
  - [ ] No distortion

- [ ] **Wide portrait** (1000x500px)
  - [ ] Crops to circle correctly
  - [ ] Face centered (manual check)

- [ ] **Tall portrait** (500x1000px)
  - [ ] Crops to circle correctly

- [ ] **Missing image** (broken URL)
  - [ ] Fallback to initials avatar
  - [ ] No broken image icon

- [ ] **Very slow loading image**
  - [ ] Loading placeholder appears
  - [ ] Image loads eventually
  - [ ] No layout shift

**Result**: _____ / 16 items passed

---

## Section 4: User Error Handling

### 4.1 Form Validation

**Required Fields:**
- [ ] **Speaker form** - Try to save without name
  - [ ] Validation error appears
  - [ ] Field highlighted in red
  - [ ] Error message clear

- [ ] **Speaker form** - Try to save without topic
  - [ ] Validation error appears

- [ ] **Member form** - Try to save without name
  - [ ] Validation error appears

- [ ] **Project form** - Try to save without name
  - [ ] Validation error appears

- [ ] **Photo upload** - Try to upload without selecting image
  - [ ] Error message appears

- [ ] **Photo upload** - Try to upload without title
  - [ ] Error message appears

**Result**: _____ / 12 items passed

---

### 4.2 Duplicate Detection

**Note**: Currently no duplicate detection (known limitation)

- [ ] **Duplicate speaker** - Create speaker with same name and email
  - [ ] ⚠️ Allows duplicate (no validation yet)
  - [ ] Both entries visible
  - [ ] No data corruption

- [ ] **Duplicate member** - Create member with same email
  - [ ] ⚠️ Allows duplicate (no validation yet)

**Result**: _____ / 2 items tested (⚠️ passes with caveat)

---

### 4.3 Concurrent Editing

**Test with**: Two browser windows or two devices

- [ ] **Edit same speaker in two windows**
  - [ ] Both windows load latest data
  - [ ] Edit in Window 1, save
  - [ ] Window 2 receives real-time update
  - [ ] Edit in Window 2, save
  - [ ] Last save wins (expected behavior)
  - [ ] No data corruption

- [ ] **Drag speaker in Window 1, drag same speaker in Window 2**
  - [ ] Real-time updates show changes
  - [ ] Last action wins
  - [ ] No duplicate or missing speaker

**Result**: _____ / 8 items passed

---

## Section 5: Accessibility Testing

### 5.1 Keyboard Navigation

**Test without mouse** (keyboard only)

- [ ] **Tab through page** - Use Tab key to navigate
  - [ ] Focus visible on all interactive elements
  - [ ] Tab order is logical
  - [ ] Skip link appears on first Tab
  - [ ] Can skip to main content

- [ ] **Navigate bottom nav** - Use Tab/Arrow keys
  - [ ] All nav items reachable
  - [ ] Enter activates navigation
  - [ ] Active state visible

- [ ] **Open and close modal** - Use keyboard only
  - [ ] Tab to "Add Speaker" button
  - [ ] Press Enter to open modal
  - [ ] Tab through form fields
  - [ ] Escape closes modal
  - [ ] Focus returns to trigger button

- [ ] **Fill form** - Use keyboard only
  - [ ] All fields reachable by Tab
  - [ ] Text inputs work
  - [ ] Select dropdowns work (Arrow keys + Enter)
  - [ ] Checkboxes work (Space to toggle)
  - [ ] Buttons work (Enter to activate)

- [ ] **Save form** - Use keyboard only
  - [ ] Tab to Save button
  - [ ] Enter saves form
  - [ ] Success feedback provided

**Result**: _____ / 17 items passed

---

### 5.2 Screen Reader Testing

**Test with**: VoiceOver (Mac), NVDA (Windows), or TalkBack (Android)

**Note**: Requires actual screen reader software. Mark N/A if unable to test.

- [ ] **Page title announced**
  - [ ] "Georgetown Rotary - Speakers" (or similar)

- [ ] **Section headings announced**
  - [ ] "SPEAKERS", "MEMBERS", etc.

- [ ] **Buttons announced correctly**
  - [ ] "Add Speaker button"
  - [ ] "Edit speaker button"

- [ ] **Links announced correctly**
  - [ ] "Visit website, link"
  - [ ] "View LinkedIn profile, link"

- [ ] **Form labels read**
  - [ ] "Name, required, edit text"
  - [ ] "Email, optional, edit text"

- [ ] **Status badges read**
  - [ ] "Scheduled, badge" or similar

- [ ] **Image alt text read**
  - [ ] "John Doe portrait"
  - [ ] "Rotary wheel logo"

**Result**: _____ / 14 items passed (or mark N/A)

---

### 5.3 Color Contrast

**Test with**: Contrast checker or visual inspection

- [ ] **Primary text on white background** (#1f2937 on #ffffff)
  - [ ] High contrast, easily readable
  - [ ] Passes WCAG AA (4.5:1 minimum)

- [ ] **Azure blue on white** (#005daa on #ffffff)
  - [ ] High contrast (8.59:1)
  - [ ] Passes WCAG AAA

- [ ] **Gold on white** (#f7a81b on #ffffff)
  - [ ] Moderate contrast (4.57:1)
  - [ ] Passes WCAG AA

- [ ] **Gray text on white** (#6b7280 on #ffffff)
  - [ ] Moderate contrast (4.69:1)
  - [ ] Passes WCAG AA

- [ ] **Status badges**
  - [ ] Blue badge: blue-800 on blue-100 (sufficient contrast)
  - [ ] Green badge: emerald-800 on emerald-100 (sufficient contrast)
  - [ ] Amber badge: amber-800 on amber-100 (sufficient contrast)
  - [ ] Red badge: rose-800 on rose-100 (sufficient contrast)

**Result**: _____ / 12 items passed

---

### 5.4 Focus Indicators

**Visual inspection:**

- [ ] **All interactive elements have visible focus**
  - [ ] Buttons show blue ring on focus
  - [ ] Links show blue ring on focus
  - [ ] Form inputs show blue ring on focus
  - [ ] Cards show focus state

- [ ] **Focus indicators are visible**
  - [ ] Not hidden by other elements
  - [ ] Sufficient color contrast
  - [ ] Ring is 2px minimum width

- [ ] **Focus order is logical**
  - [ ] Top to bottom
  - [ ] Left to right
  - [ ] Modal fields before outside elements

**Result**: _____ / 9 items passed

---

## Section 6: Browser Compatibility

### 6.1 Chrome (Latest)

**Version**: _____

- [ ] Application loads correctly
- [ ] All features work
- [ ] Drag-and-drop works
- [ ] Images load correctly
- [ ] No console errors
- [ ] Lighthouse score > 80 for Performance
- [ ] Lighthouse score > 95 for Accessibility

**Result**: _____ / 7 items passed

---

### 6.2 Safari (Latest)

**Version**: _____

- [ ] Application loads correctly
- [ ] All features work
- [ ] Drag-and-drop works
- [ ] Images load correctly
- [ ] No console errors
- [ ] Fonts load correctly (Open Sans)
- [ ] Mobile Safari (iOS) - Test on iPhone
  - [ ] Bottom nav doesn't overlap Safari toolbar
  - [ ] Input fields don't zoom in when focused (font-size ≥ 16px)

**Result**: _____ / 9 items passed

---

### 6.3 Firefox (Latest)

**Version**: _____

- [ ] Application loads correctly
- [ ] All features work
- [ ] Drag-and-drop works
- [ ] Images load correctly
- [ ] No console errors

**Result**: _____ / 5 items passed

---

### 6.4 Edge (Latest)

**Version**: _____

- [ ] Application loads correctly
- [ ] All features work
- [ ] No console errors

**Result**: _____ / 3 items passed

---

## Section 7: Performance Testing

### 7.1 Lighthouse Audit (Chrome DevTools)

**Instructions**:
1. Open Chrome DevTools (F12)
2. Navigate to "Lighthouse" tab
3. Select "Mobile" device, all categories
4. Click "Generate report"

**Results**:

- [ ] **Performance Score**: _____ / 100 (target: > 80)
  - [ ] Largest Contentful Paint (LCP): _____ seconds (target: < 2.5s)
  - [ ] First Input Delay (FID): _____ ms (target: < 100ms)
  - [ ] Cumulative Layout Shift (CLS): _____ (target: < 0.1)

- [ ] **Accessibility Score**: _____ / 100 (target: > 95)
  - [ ] Issues found: _____ (list below)

- [ ] **Best Practices Score**: _____ / 100 (target: > 90)
  - [ ] Issues found: _____ (list below)

- [ ] **SEO Score**: N/A (internal club app, robots blocked intentionally)

**Notes**: _____

---

### 7.2 Network Performance

**Test with**: Chrome DevTools → Network → Throttling

**Slow 3G:**
- [ ] **Initial page load**: _____ seconds (target: < 10s)
- [ ] **Time to Interactive**: _____ seconds (target: < 15s)
- [ ] **Images load progressively** (not all at once)
- [ ] **Loading indicators appear** during data fetch

**Fast 3G:**
- [ ] **Initial page load**: _____ seconds (target: < 5s)
- [ ] **Time to Interactive**: _____ seconds (target: < 8s)

**4G:**
- [ ] **Initial page load**: _____ seconds (target: < 3s)
- [ ] **Time to Interactive**: _____ seconds (target: < 5s)

**Result**: _____ / 10 items passed

---

### 7.3 Bundle Size Analysis

**From build output:**

```
dist/assets/index-DwL9D6Xd.css   56.80 kB │ gzip:   9.82 kB
dist/assets/index-C44Os10T.js   847.46 kB │ gzip: 222.14 kB
Total: 3.5MB (includes optimized images)
```

- [ ] **Total bundle size** reasonable for feature set
- [ ] **JavaScript bundle**: 847KB (222KB gzipped) - ⚠️ Large, consider code splitting
- [ ] **CSS bundle**: 57KB (10KB gzipped) - ✅ Excellent
- [ ] **Images optimized** (26% reduction during build)

**Result**: Assessment complete

---

## Section 8: Security Testing (CEO/Admin)

**Note**: Requires Supabase dashboard access (CEO only)

### 8.1 Row-Level Security (RLS)

**Verify in Supabase Dashboard**:

- [ ] **speakers table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **members table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **partners table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **service_projects table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **photos table** - RLS enabled
  - [ ] Public can read approved photos
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **club_events table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can insert/update/delete

- [ ] **rotary_years table** - RLS enabled
  - [ ] Public can read
  - [ ] Only authenticated officers/chairs can update

**Result**: _____ / 14 items passed

---

### 8.2 Storage Bucket Permissions

**Verify in Supabase Dashboard → Storage**:

- [ ] **club-photos bucket** - Public read access
  - [ ] Public can view photos via URL
  - [ ] Only authenticated officers/chairs can upload

- [ ] **Uploaded files** have correct visibility
  - [ ] Files are accessible via public URL

**Result**: _____ / 3 items passed

---

### 8.3 Authentication

**Test login flow** (if authentication enabled):

- [ ] Non-authenticated users can view data
- [ ] Non-authenticated users cannot create/edit/delete
- [ ] Login redirects to correct page
- [ ] Logout works correctly
- [ ] Session persists across page refresh

**Result**: _____ / 5 items passed (or mark N/A if auth not enabled)

---

## Section 9: Real-Time Collaboration

### 9.1 Multiple Users

**Test with**: Two browser windows or two devices

- [ ] **Two users view speakers page**
  - [ ] User 1 creates speaker
  - [ ] Speaker appears in User 2's view instantly (via real-time subscription)

- [ ] **Two users view members page**
  - [ ] User 1 edits member
  - [ ] Changes appear in User 2's view instantly

- [ ] **Two users view timeline page**
  - [ ] User 1 edits year narrative
  - [ ] Changes appear in User 2's view after auto-save

- [ ] **Two users view photos page**
  - [ ] User 1 uploads photo
  - [ ] Photo appears in User 2's view instantly

**Result**: _____ / 8 items passed

---

## Section 10: Mobile Device Testing

### 10.1 iPhone (iOS Safari)

**Device**: _____
**iOS Version**: _____

- [ ] Application loads correctly
- [ ] Bottom navigation doesn't overlap content or Safari toolbar
- [ ] Touch targets are easy to tap
- [ ] Drag-and-drop works smoothly
- [ ] Forms work correctly (no keyboard issues)
- [ ] Input fields don't zoom when focused
- [ ] Portrait orientation works
- [ ] Landscape orientation works
- [ ] Fonts render correctly (Open Sans)
- [ ] Images load correctly
- [ ] Modals display correctly
- [ ] No horizontal scrolling

**Result**: _____ / 12 items passed

---

### 10.2 Android (Chrome)

**Device**: _____
**Android Version**: _____

- [ ] Application loads correctly
- [ ] Bottom navigation works
- [ ] Touch targets are easy to tap
- [ ] Drag-and-drop works smoothly
- [ ] Forms work correctly
- [ ] Portrait orientation works
- [ ] Landscape orientation works
- [ ] Fonts render correctly
- [ ] Images load correctly
- [ ] Modals display correctly
- [ ] No horizontal scrolling

**Result**: _____ / 11 items passed

---

### 10.3 iPad / Tablet

**Device**: _____
**iOS/Android Version**: _____

- [ ] Application loads correctly
- [ ] Responsive layout adapts to tablet size
- [ ] Grid layouts use 2-3 columns
- [ ] Bottom nav and desktop nav both visible (optional based on breakpoint)
- [ ] Touch targets appropriate for tablet
- [ ] No wasted space
- [ ] Modals sized appropriately

**Result**: _____ / 7 items passed

---

## Testing Summary

### Overall Results

**Total Items Tested**: _____ / 527
**Pass Rate**: _____ %

### Breakdown by Section

1. Mobile-First Validation: _____ / 45
2. Core Functionality: _____ / 180
3. Robustness & Edge Cases: _____ / 95
4. User Error Handling: _____ / 22
5. Accessibility: _____ / 52
6. Browser Compatibility: _____ / 24
7. Performance: _____ / 10
8. Security (CEO): _____ / 22
9. Real-Time Collaboration: _____ / 8
10. Mobile Device Testing: _____ / 30

### Critical Issues Found

List any critical issues that must be fixed before production:

1. _____
2. _____
3. _____

### High-Priority Issues Found

List any high-priority issues that should be fixed soon:

1. _____
2. _____
3. _____

### Known Limitations (Acceptable)

List known limitations that are acceptable for MVP:

1. No duplicate detection (planned for future)
2. Limited URL validation (acceptable risk)
3. No retry logic for failed API calls (acceptable for internal use)
4. _____

---

## Recommendations

Based on testing results:

**Pre-Launch (Must Fix):**
- [ ] _____
- [ ] _____

**Post-Launch (Should Fix):**
- [ ] _____
- [ ] _____

**Future Enhancements:**
- [ ] _____
- [ ] _____

---

## Sign-Off

**Tester Name**: _____
**Role**: _____
**Date**: _____
**Signature**: _____

**Production Approval**: ☐ Approved  ☐ Needs Work  ☐ Not Ready

**Notes**: _____

---

**Document Version**: 1.0
**Last Updated**: October 17, 2025
**Next Review**: After production deployment (30 days)
