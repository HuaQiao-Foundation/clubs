# Phase 3 RSVP & Attendance Testing Session
**Date**: December 2, 2025
**Tester**: CTO (Code fixes) + CEO (Manual UI testing required)
**Status**: 🟡 IN PROGRESS - Prerequisites complete, manual testing needed

---

## Critical Fixes Applied (Before Testing)

### 🔧 TypeScript Errors Fixed (9 total)

**Issue 1: Event Type Mismatch** ✅ FIXED
- **File**: [CalendarView.tsx:18](src/components/CalendarView.tsx#L18)
- **Problem**: `'bod_meeting'` vs `'board_meeting'` type conflict
- **Fix**: Standardized to `'board_meeting'` to match EventViewModal
- **Impact**: Prevents type errors when passing events between components

**Issue 2: RSVPModal Props Error** ✅ FIXED
- **File**: [EventsListView.tsx:884](src/components/EventsListView.tsx#L884)
- **Problem**: Passing `eventTitle` prop that doesn't exist in RSVPModalProps
- **Fix**: Changed to pass `eventType` instead (which RSVPModal actually uses)
- **Impact**: RSVP modal now receives correct props

**Issue 3: Unused Functions** ✅ FIXED
- **File**: [RSVPListModal.tsx:48,61](src/components/meetings/RSVPListModal.tsx#L48)
- **Problem**: `getStatusIcon` and `getStatusLabel` declared but never used
- **Fix**: Removed unused functions and `User` import
- **Impact**: Cleaner code, no unused declarations

**Issue 4: member_name Property** ✅ FIXED
- **File**: [RSVPModal.tsx:66,79,148](src/components/meetings/RSVPModal.tsx#L66)
- **Problem**: Accessing `rsvp?.member_name` which doesn't exist in MeetingRSVP type
- **Fix**: Use only `memberName` state (fetched separately from members table)
- **Impact**: Proper type safety, member names display correctly

### Build Status
```bash
✅ TypeScript compilation: 0 errors (npx tsc --noEmit)
✅ Production build: Success (373KB main bundle, 40+ lazy chunks)
✅ Dev server: Running on http://localhost:5175/
✅ Database: meeting_rsvps table + meeting_rsvp_summary view exist
```

---

## Prerequisites ✅ (4/4 Complete)

- [x] Development server running (`npm run dev`) - Port 5175
- [x] Database migrations 055-056 executed - Verified tables exist
- [x] All TypeScript compilation errors resolved - 0 errors
- [x] Production build successful - 373KB main bundle

---

## Manual Testing Required

### 🎯 Quick Start Testing (10 minutes) - HIGH PRIORITY

#### Test 1: RSVP from Calendar
**Steps:**
1. Open http://localhost:5175/
2. Navigate to Calendar view
3. Click on a club meeting event
4. **Expected**: EventViewModal opens (NOT generic event modal)
5. **Expected**: Green RSVP button visible in header
6. Click green RSVP button
7. **Expected**: RSVPModal opens with dropdown CLOSED (showing "Select your response...")
8. Select "Attending" → Click "Save RSVP"
9. **Expected**: Success message, modal closes
10. Click meeting again → Click RSVP
11. **Expected**: Status shows "Attending" (persisted)
12. Change to "Regrets" → Save
13. **Expected**: Status updates successfully
14. Test guest count: Enter 2 guests
15. Test dietary notes: Enter "Vegetarian"
16. Save → Reopen
17. **Expected**: Guest count and notes persist

**Potential Issues to Watch For:**
- ⚠️ Dropdown auto-expanding (should stay closed) - Fixed in previous session
- ⚠️ Member name not displaying in header
- ⚠️ RSVP status not persisting after refresh

#### Test 2: RSVP from Events List
**Steps:**
1. Navigate to Events List view
2. Find a club meeting card
3. **Expected**: RSVPButton visible at bottom
4. Click "Attending" button
5. **Expected**: Immediate visual feedback (button state change)
6. Click "Details" link
7. **Expected**: RSVPModal opens, status matches button

**Potential Issues:**
- ⚠️ Button state not updating after RSVP
- ⚠️ eventType not displaying correctly (we changed eventTitle → eventType)

#### Test 3: Attendance Stats in Directory
**Steps:**
1. Navigate to Member Directory
2. **Expected**: "Attendance %" column visible
3. Click on a member's attendance percentage
4. **Expected**: AttendanceDashboard modal opens
5. **Expected**: Stats display (Current Quarter, YTD, Lifetime)
6. Click X button to close
7. **Expected**: Modal closes
8. Click percentage again, then click overlay
9. **Expected**: Modal closes on overlay click

---

### 📱 Mobile Responsiveness Testing (20 minutes) - CRITICAL

**Why Critical**: Georgetown members primarily use phones during meetings

**Test Viewports:**
- iPhone SE (375x667) - Minimum mobile
- iPhone 12 Pro (390x844) - Standard mobile
- iPad (768x1024) - Tablet

**Chrome DevTools Setup:**
```
1. Open DevTools (F12)
2. Click Toggle Device Toolbar (Cmd+Shift+M)
3. Select viewport from dropdown
```

#### Mobile Tests (320px-414px)

**RSVPModal:**
- [ ] Opens from bottom (bottom sheet style, not centered)
- [ ] Rounded corners only at top
- [ ] Full width on mobile
- [ ] Buttons stack vertically (Cancel above Save)
- [ ] All buttons minimum 44px tap target
- [ ] No horizontal scrolling
- [ ] Text readable without zooming

**Potential Issue:**
- ⚠️ Modal might be centered instead of bottom sheet on mobile

**AttendanceChecker:**
- [ ] Full width on mobile
- [ ] Header stays sticky when scrolling
- [ ] Member list scrollable
- [ ] Action buttons stack vertically

**AttendanceDashboard:**
- [ ] Stats cards display single column
- [ ] All text readable (no truncation)
- [ ] Close button accessible (top right)

---

### 🔐 Role-Based Testing (15 minutes)

**Setup: Switch to Officer Role**
```typescript
// File: src/hooks/useAuth.ts
// Find line ~40: userRole: 'member'
// Change to: userRole: 'officer'
// Save file, browser will hot-reload
```

#### Officer Features to Test

**View RSVPs (Events List):**
1. Navigate to Events List
2. Find club meeting card
3. **Expected**: "View RSVPs" button visible (officer only)
4. Click "View RSVPs"
5. **Expected**: RSVPList modal opens
6. **Expected**: Summary stats display at top (Attending/Maybe/Regrets)
7. Click "Cards"/"Table" toggle
8. **Expected**: View switches between card and table layout
9. Click "Export to CSV"
10. **Expected**: CSV file downloads
11. Use filter dropdown (All/Attending/Regrets/Maybe)
12. **Expected**: List filters correctly

**Take Attendance:**
1. Click "Take Attendance" on meeting card
2. **Expected**: AttendanceChecker modal opens
3. **Expected**: Member list loads with checkboxes
4. **Expected**: RSVP'd members pre-checked
5. Click "Bulk Check-in RSVP'd"
6. **Expected**: Correct count shown
7. Toggle individual member checkbox
8. **Expected**: State updates

**Add Visitor/Guest:**
1. In AttendanceChecker, click "Add Visitor"
2. **Expected**: VisitorForm opens
3. Fill: Name, Club, District
4. Click "Save & Add Another"
5. **Expected**: Form resets for another visitor
6. Click "Add Guest"
7. **Expected**: GuestForm opens
8. Fill: Name, select host from dropdown
9. Check "Prospective Member"
10. **Expected**: Form saves successfully

---

### 🔄 Real-Time Updates Testing (10 minutes)

**Setup: Two Browser Windows**
- Window 1: http://localhost:5175/ (Member A)
- Window 2: http://localhost:5175/ in Incognito (Officer)

**Test Scenario:**
1. **Window 1 (Member A):**
   - Calendar → RSVP to meeting as "Attending"
2. **Window 2 (Officer):**
   - Events List → "View RSVPs"
   - **Expected**: Member A appears immediately (1-2 sec delay normal)
3. **Window 1 (Member A):**
   - Change RSVP to "Regrets"
4. **Window 2 (Officer):**
   - **Expected**: Status updates in real-time

**Potential Issue:**
- ⚠️ Realtime subscriptions may not be working if updates don't appear

---

### 🐛 Edge Cases & Error Handling (10 minutes)

#### No Attendance Data
- [ ] Find member with zero meetings attended
- [ ] **Expected**: Dashboard shows "No data yet" (not crash)
- [ ] **Expected**: No console errors

#### Offline Mode
```
Chrome DevTools → Network tab → Set to "Offline"
```
- [ ] Try to RSVP
- [ ] **Expected**: OfflineBanner appears
- [ ] **Expected**: Error message shown
- [ ] **Expected**: No data loss or crash

#### Form Validation
- [ ] Open RSVPModal, try to save without selecting status
- [ ] **Expected**: Validation prevents submission
- [ ] **Expected**: Clear error message displayed

#### Null/Undefined Handling
- [ ] Member with `null` attendance percentage
- [ ] **Expected**: Shows "—" instead of crashing
- [ ] **Expected**: No console errors

---

## Testing Results Template

### Issues Found:
1.
2.
3.

### Pass/Fail Determination:

#### ✅ PASS (Ready for UAT)
**Criteria:**
- All critical path items work
- Mobile responsiveness verified on 3+ devices
- Zero TypeScript/build errors ✅ (Already verified)
- No crashes or data loss scenarios
- Officer features work with permissions

#### ⚠️ PARTIAL PASS (Minor fixes needed)
**Criteria:**
- 1-2 non-critical issues (e.g., tooltip text, minor styling)
- Can proceed to UAT with documented known issues

#### ❌ FAIL (Not ready for UAT)
**Criteria:**
- 3+ critical issues found
- Core workflows broken (RSVP, attendance tracking)
- TypeScript errors present (None found ✅)
- Mobile responsiveness broken
- Data loss scenarios detected

---

## Next Steps

### If PASS:
1. [ ] Deploy to staging environment
2. [ ] Run this checklist again on staging
3. [ ] Invite 2-3 program committee members for UAT
4. [ ] Monitor for issues during UAT
5. [ ] Collect feedback
6. [ ] Deploy to production after UAT approval

### If PARTIAL PASS:
1. [ ] Document known issues
2. [ ] Fix critical bugs
3. [ ] Re-test affected areas
4. [ ] Proceed to staging with known issues list

### If FAIL:
1. [ ] Document all failures
2. [ ] Prioritize fixes (critical first)
3. [ ] Fix issues
4. [ ] Run full checklist again
5. [ ] Do NOT proceed to UAT until PASS

---

## Code Review Notes (CTO Analysis)

### ✅ Strengths
- **Type Safety**: All TypeScript errors resolved, proper type definitions
- **Error Handling**: Components have try-catch blocks and loading states
- **Real-time**: Supabase subscriptions properly implemented in useRSVP hook
- **Mobile-First**: CSS shows mobile-first breakpoints (bg-white rounded-t-2xl md:rounded-2xl)
- **Clean Code**: Removed unused functions, proper separation of concerns

### ⚠️ Potential Concerns to Monitor During Testing
1. **Member Name Fetching**: RSVPModal fetches member name separately - verify no race conditions
2. **Dropdown State**: Fixed dropdown auto-opening, verify it stays closed on modal open
3. **Event Type Mapping**: Changed eventTitle → eventType, verify display names work correctly
4. **Real-time Latency**: 1-2 second delay is normal, but watch for longer delays
5. **Mobile Bottom Sheet**: Verify RSVPModal opens from bottom on mobile (not centered)

### 🔍 Files Changed in This Session
1. [CalendarView.tsx:18](src/components/CalendarView.tsx#L18) - Event type fix
2. [EventsListView.tsx:884](src/components/EventsListView.tsx#L884) - RSVPModal props fix
3. [RSVPListModal.tsx:1,48](src/components/meetings/RSVPListModal.tsx#L1) - Removed unused code
4. [RSVPModal.tsx:66,79,148](src/components/meetings/RSVPModal.tsx#L66) - member_name handling

---

## Testing Command Reference

```bash
# Development
npm run dev          # Running on http://localhost:5175/

# Type checking
npx tsc --noEmit     # ✅ 0 errors

# Build verification
npm run build        # ✅ Success (373KB main)
npm run preview      # Test production build (port 4173)

# Database
psql "$DIRECT_URL" -c "\dt meeting_rsvp*"  # ✅ Tables exist
psql "$DIRECT_URL" -c "\dv meeting_rsvp*"  # ✅ Views exist
```

---

**CTO Status**: Code fixes complete, prerequisites verified. Ready for CEO manual UI testing (45-60 minutes estimated).
