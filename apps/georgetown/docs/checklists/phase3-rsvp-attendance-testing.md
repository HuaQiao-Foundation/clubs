# Phase 3: RSVP & Attendance Testing Checklist

**Purpose**: Systematic testing of all RSVP and Attendance components before UAT deployment
**When to Use**: After Phase 3 implementation complete, before user acceptance testing
**Estimated Time**: 45-60 minutes for full checklist

---

## Prerequisites

- [x] Development server running (`npm run dev`) - Port 5175
- [x] Database migrations 055-056 executed - Verified: meeting_rsvps table + meeting_rsvp_summary view exist
- [x] All TypeScript compilation errors resolved (`npx tsc --noEmit` = 0 errors) - 9 errors fixed
- [x] Production build successful (`npm run build`) - 373KB main bundle

**Session Date**: December 2, 2025
**Detailed Report**: [temp/phase3-testing-session-2025-12-02.md](../temp/phase3-testing-session-2025-12-02.md)

---

## Quick Start Testing (10 minutes)

**Purpose**: Verify core functionality works end-to-end

### RSVP from Calendar
- [ ] Navigate to Calendar view
- [ ] Click on a club meeting event
- [ ] RSVPModal opens (not generic event modal)
- [ ] Select "Attending" → Save → Success message appears
- [ ] Reopen modal → Status persists as "Attending"
- [ ] Change to "Regrets" → Save → Update successful
- [ ] Test guest count field (try 0, 1, 5)
- [ ] Test dietary notes field (short and long text)

### RSVP from Events List
- [ ] Navigate to Events List view
- [ ] Find a club meeting card
- [ ] RSVPButton visible at bottom of card
- [ ] Click "Attending" button → Immediate feedback
- [ ] Click "Details" → RSVPModal opens
- [ ] Status matches button state

### Attendance Stats in Directory
- [ ] Navigate to Member Directory
- [ ] "Attendance %" column visible in table view
- [ ] Click on a member's attendance percentage
- [ ] AttendanceDashboard modal opens
- [ ] Stats display correctly (Current Quarter, YTD, Lifetime)
- [ ] Close modal (X button and overlay click work)

---

## Mobile Responsiveness Testing (20 minutes)

**Purpose**: Verify mobile-first design on actual breakpoints

### Tools Setup
```
Chrome DevTools → Toggle Device Toolbar (Cmd+Shift+M)
Test these viewports:
- iPhone SE (375x667) - Minimum mobile
- iPhone 12 Pro (390x844) - Standard mobile
- iPhone 14 Pro Max (430x932) - Large mobile
- iPad (768x1024) - Tablet
- Desktop (1920x1080) - Desktop
```

### Mobile (320px-414px) - PRIMARY USE CASE

#### RSVPModal
- [ ] Opens from bottom as bottom sheet (not centered)
- [ ] Rounded corners only at top
- [ ] Full width on mobile
- [ ] Buttons stack vertically (not horizontal)
- [ ] All buttons minimum 44px tap target
- [ ] No horizontal scrolling
- [ ] Text readable without zooming

#### AttendanceChecker
- [ ] Full width on mobile
- [ ] Header stays sticky when scrolling member list
- [ ] Member list scrollable
- [ ] Action buttons stack vertically
- [ ] "Add Visitor" / "Add Guest" buttons accessible
- [ ] No layout breaks or overflow

#### AttendanceDashboard
- [ ] Stats cards display single column
- [ ] All text readable (no truncation)
- [ ] Close button accessible (top right)
- [ ] Cards scroll smoothly
- [ ] At-risk warning banner visible if applicable

### Tablet (768px-1024px)
- [ ] Modals centered (not bottom sheet)
- [ ] Stats cards 2 columns
- [ ] Buttons horizontal (inline)
- [ ] Professional layout maintained

### Desktop (1280px+)
- [ ] Modals centered with max-width constraint
- [ ] Stats cards 3 columns
- [ ] All layouts look professional
- [ ] Touch targets still accessible (hover states)

---

## Role-Based Testing (15 minutes)

**Purpose**: Verify officer-only features work with permissions

### Setup: Switch to Officer Role
```typescript
// Temporary: Modify src/hooks/useAuth.ts
// Change: userRole: 'member' → userRole: 'officer'
```

### Officer Features

#### View RSVPs (Events List)
- [ ] Navigate to Events List
- [ ] Find club meeting card
- [ ] "View RSVPs" button visible (officer only)
- [ ] Click "View RSVPs" → RSVPList modal opens
- [ ] RSVP summary stats display at top
- [ ] Toggle Cards/Table view works
- [ ] Export to CSV button works
- [ ] Filter by status works (All/Attending/Regrets/Maybe)

#### Take Attendance (Events List)
- [ ] Click "Take Attendance" on meeting card
- [ ] AttendanceChecker modal opens
- [ ] Member list loads
- [ ] RSVP'd members auto-selected (checked)
- [ ] "Bulk Check-in RSVP'd" button works
- [ ] Bulk check-in shows correct count
- [ ] "Check in All Members" button works
- [ ] Individual member toggle works

#### Add Visitor/Guest
- [ ] In AttendanceChecker, click "Add Visitor"
- [ ] VisitorForm opens
- [ ] Fill: Name, Club, District
- [ ] "Save & Add Another" → Form resets
- [ ] "Save & Close" → Modal closes
- [ ] Click "Add Guest"
- [ ] GuestForm opens
- [ ] Fill: Name, select "Hosted By" from dropdown
- [ ] Check "Prospective Member"
- [ ] Add contact info and notes
- [ ] Save → Guest added successfully

#### At-Risk Member Detection
- [ ] Navigate to Member Directory
- [ ] Look for red warning icons (⚠️) in Attendance column
- [ ] Icons appear for members with < 60% YTD or 4+ consecutive absences
- [ ] Click at-risk member → Dashboard shows alert banner
- [ ] Alert banner shows specific warning (percentage or absences)

---

## Real-Time Updates Testing (10 minutes)

**Purpose**: Verify Supabase subscriptions work correctly

### Setup: Two Browser Windows
- Window 1: Member A (logged in as member)
- Window 2: Officer (logged in as officer)

### Test Scenario
#### Window 1 (Member A):
- [ ] Open Calendar
- [ ] RSVP to meeting as "Attending"

#### Window 2 (Officer):
- [ ] Open Events List → "View RSVPs"
- [ ] Member A appears in list immediately (no manual refresh)

#### Window 1 (Member A):
- [ ] Change RSVP to "Regrets"

#### Window 2 (Officer):
- [ ] Member A status updates in real-time (1-2 second delay normal)

---

## Edge Cases & Error Handling (10 minutes)

**Purpose**: Verify graceful degradation and error handling

### Database Connectivity

#### No Attendance Data
- [ ] Member with zero meetings attended
- [ ] Dashboard shows "No data yet" (not crash)
- [ ] No console errors

#### Offline Mode
- [ ] Turn off network in DevTools (Network → Offline)
- [ ] Offline banner appears (OfflineBanner component)
- [ ] Try to RSVP → Error message shown
- [ ] No data loss or crash

### Form Validation

#### RSVPModal
- [ ] Try to save without selecting status
- [ ] Validation prevents submission
- [ ] Clear error message displayed

#### GuestForm
- [ ] Try to save without guest name
- [ ] Validation error shown
- [ ] Try to save without selecting host
- [ ] Validation error shown

#### Null/Undefined Handling
- [ ] Member with `null` attendance percentage
- [ ] Shows "—" instead of crashing
- [ ] Member with `undefined` YTD stats
- [ ] Dashboard handles gracefully (no errors)

---

## Build & TypeScript Verification (5 minutes)

**Purpose**: Ensure production-ready code quality

### TypeScript Compilation
```bash
npx tsc --noEmit
```
- [ ] Zero TypeScript errors
- [ ] Zero TypeScript warnings

### Production Build
```bash
npm run build
```
- [ ] Build completes successfully
- [ ] No errors in build output
- [ ] Check bundle size (should be ~400-500KB)

### Preview Production Build
```bash
npm run preview
# Open http://localhost:4173
```
- [ ] All components load correctly
- [ ] No console errors
- [ ] Images/assets load properly
- [ ] Modals function correctly
- [ ] Performance feels smooth

---

## Performance Testing (5 minutes)

**Purpose**: Verify acceptable load times

### Load Times
- [ ] Calendar view loads in < 2 seconds
- [ ] Member Directory loads in < 2 seconds
- [ ] RSVPModal opens in < 100ms
- [ ] AttendanceDashboard loads stats in < 1 second

### Bundle Size
```bash
npm run build
ls -lh dist/assets/
```
- [ ] Main bundle ~400-500KB
- [ ] Total assets < 1MB
- [ ] Image optimization active

---

## Critical Path Testing (15 minutes)

**Purpose**: Minimum viable test to verify Phase 3 works

### 1. Member RSVP Flow (3 min)
- [ ] Calendar → Click meeting → RSVP "Attending" → Save → Success
- [ ] Events List shows RSVP button state matches selection

### 2. Officer RSVP Management (5 min)
- [ ] Events List → "View RSVPs" → See member's RSVP
- [ ] Export to CSV → File downloads successfully
- [ ] Filter works (Attending only)

### 3. Officer Attendance (5 min)
- [ ] Events List → "Take Attendance"
- [ ] Bulk check-in RSVP'd members → Correct count
- [ ] Add visitor → Form opens → Save → Success
- [ ] Visitor appears in attendance records

### 4. Member Attendance Stats (2 min)
- [ ] Directory → Click attendance % → Dashboard opens
- [ ] Stats display correctly (not "—" for all fields)
- [ ] Close modal works

---

## Pass/Fail Criteria

### ✅ PASS (Ready for UAT)
- All critical path items checked
- Mobile responsiveness verified on 3+ devices
- Zero TypeScript/build errors
- No crashes or data loss scenarios
- Officer features work with permissions

### ⚠️ PARTIAL PASS (Minor fixes needed)
- 1-2 non-critical issues found (e.g., tooltip text, minor styling)
- Fix and re-test affected areas only
- Can proceed to UAT with known issues documented

### ❌ FAIL (Not ready for UAT)
- 3+ critical issues found
- Core workflows broken (RSVP, attendance tracking)
- TypeScript errors present
- Mobile responsiveness broken
- Data loss scenarios detected

→ Review implementation, fix issues, run full checklist again

---

## Next Steps

### After PASS:
1. [ ] Deploy to staging environment
2. [ ] Run this checklist again on staging
3. [ ] Invite 2-3 program committee members for UAT
4. [ ] Monitor for any issues during UAT
5. [ ] Collect feedback
6. [ ] Deploy to production after UAT approval

### After PARTIAL PASS:
1. [ ] Document known issues
2. [ ] Fix critical bugs
3. [ ] Re-test affected areas
4. [ ] Proceed to staging with known issues list

### After FAIL:
1. [ ] Document all failures
2. [ ] Prioritize fixes (critical first)
3. [ ] Fix issues
4. [ ] Run full checklist again
5. [ ] Do NOT proceed to UAT until PASS

---

## Testing Notes

**Date Tested**: December 2, 2025
**Tested By**: CTO (Code fixes + Prerequisites) + CEO (Manual UI testing needed)
**Result**: ⬜ PASS | ⬜ PARTIAL PASS | ⬜ FAIL

### Pre-Testing Fixes Applied:
1. ✅ Fixed CalendarView Event type mismatch (bod_meeting → board_meeting)
2. ✅ Fixed EventsListView RSVPModal props (eventTitle → eventType)
3. ✅ Removed unused functions in RSVPListModal (getStatusIcon, getStatusLabel)
4. ✅ Fixed RSVPModal member_name property errors (use memberName state only)
5. ✅ Removed unused imports (User from lucide-react)

**TypeScript Status**: 0 errors (9 fixed)
**Build Status**: Success (373KB main bundle)
**Dev Server**: http://localhost:5175/

### Issues Found During Manual Testing:
1.
2.
3.

### Notes:


---

## Related Documentation

- [Phase 3 Implementation Summary](../dev-journals/2025-12-02-phase3-priority3-integration-complete.md)
- [Phase 3 Component Docs](../dev-journals/2025-12-02-phase3-rsvp-attendance-components.md)
- [Mobile-First Design Standard](../standards/responsive-design-standard.md)
- [UAT Testing Guide](../workflows/uat-testing-workflow.md) ← Create this next!
