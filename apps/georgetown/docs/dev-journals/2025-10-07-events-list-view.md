# Events List View

**Status**: ✅ Complete (Production)
**Implementation Date**: 2025-10-07
**Related Dev Journals**: N/A (implemented in single session)

---

## Acceptance Criteria

- ✅ Default date range: Rotary year start (July 1) to current month end
- ✅ Date range filter with start/end date inputs
- ✅ "Reset to Rotary Year" button restores defaults
- ✅ Desktop: Table view with Date, Type, Location, Speaker columns
- ✅ Mobile: Card-based layout with touch-optimized spacing
- ✅ Event type badges with Rotary brand colors
- ✅ Summary statistics: Total Events, Club Meetings, Speakers, Locations
- ✅ Navigation: "List View" button in Calendar, "Calendar View" in List
- ✅ Real-time data from Supabase (events + speakers)
- ✅ Empty state message when no events found
- ✅ Mobile responsive (320px+)
- ✅ Rotary brand compliance

---

## Overview
A comprehensive list view showing all events and speakers in a table format, defaulting to the current Rotary year (starting July 1).

## Implementation Date
2025-10-07

## Features

### 1. **Rotary Year Default Range**
- Automatically calculates Rotary year start date (July 1)
- If current month is before July: starts from previous year's July 1
- If current month is July or after: starts from current year's July 1
- Default end date: end of current month

### 2. **Date Range Filter**
- Collapsible filter panel
- Start date and end date inputs
- "Reset to Rotary Year" button to restore defaults
- Filters button in header to show/hide

### 3. **Desktop Table View**
Columns:
- **Date**: Full date (e.g., "Mon, Oct 7, 2025") + event title
- **Type**: Badge showing event type (Meeting, Event, Service, Holiday)
- **Location**: Location name with MapPin icon, truncated address
- **Speaker(s)**: Speaker name, organization, and topic (italic)

### 4. **Mobile Card View**
- Stacked card layout for mobile devices
- Each card shows:
  - Date and event title
  - Type badge
  - Location in gray box with icon
  - Speaker(s) in blue box with icon
- Touch-optimized with proper spacing

### 5. **Summary Statistics**
Four cards at bottom showing:
- Total Events count
- Club Meetings count
- Total Speakers count
- Events with Location count

### 6. **Navigation**
- "List View" button added to Calendar (desktop and mobile)
- "Calendar View" button in List View to return
- Accessible via route: `/events-list`

### 7. **Data Integration**
- Fetches events with location join from Supabase
- Fetches speakers filtered by date range and status='scheduled'
- Real-time capable (subscribes to Supabase changes)
- Matches speakers to events by date

## User Experience

### Desktop View
Clean table layout with:
- Hover effects on rows
- Proper column alignment
- Icons for visual identification
- Truncated text for long addresses
- Quoted speaker topics for clarity

### Mobile View
- Full-width cards
- Proper touch targets (56px minimum)
- Color-coded sections (gray for location, blue for speakers)
- Easy scanning with clear visual hierarchy

### Empty State
When no events found:
- Large calendar icon
- "No events found" message
- Suggestion to adjust date range

## Colors & Branding

**Event Type Badges:**
- Club Meeting: Azure (#005daa)
- Club Event: Purple (#901f93)
- Service Project: Turquoise (#00adbb)
- Holiday: Cranberry (#d41367)

**UI Elements:**
- Primary action (List View button): Azure (#005daa)
- Location boxes: Gray background (#f9fafb)
- Speaker boxes: Blue background (#eff6ff)
- Icons: Azure (#005daa)

## Data Flow

1. Component mounts → Calculate Rotary year dates
2. Set default date range (July 1 to end of current month)
3. Fetch events with locations
4. Fetch speakers with status='scheduled'
5. Combine data: Match speakers to events by date
6. Display in table (desktop) or cards (mobile)

## Technical Implementation

**Component:** `EventsListView.tsx`
**Route:** `/events-list`
**Dependencies:**
- date-fns (for date calculations)
- lucide-react (for icons)
- react-router-dom (for navigation)
- Supabase (for data fetching)

**Database Queries:**
```typescript
// Events with locations
.from('events')
.select('*, location:locations(*)')
.gte('date', startDate)
.lte('date', endDate)
.order('date', { ascending: true })

// Speakers
.from('speakers')
.select('*')
.gte('scheduled_date', startDate)
.lte('scheduled_date', endDate)
.eq('status', 'scheduled')
.order('scheduled_date', { ascending: true })
```

## Benefits

1. **Quick Overview**: See all meetings at a glance
2. **Rotary Year Context**: Automatically shows relevant period
3. **Detailed Information**: Location, speaker, and topic all visible
4. **Flexible Filtering**: Adjust date range as needed
5. **Mobile Friendly**: Works great on phones during meetings
6. **Print Friendly**: Table layout suitable for printing (future enhancement)

## Future Enhancements

1. Export to CSV/Excel
2. Print stylesheet optimization
3. Filter by event type
4. Filter by location
5. Search speakers by name or topic
6. Sort columns (click headers)
7. Link to edit event/speaker
8. Show speaker contact details on hover
9. Group by month with headers
10. Pagination for very large date ranges

## Files Modified

1. `src/components/EventsListView.tsx` (NEW)
2. `src/App.tsx` (added route)
3. `src/components/Calendar.tsx` (added List View button)
4. `src/components/CalendarView.tsx` (added navigation handler)

## Usage

From Calendar:
- Click "List View" button (desktop: top right, mobile: full-width button)

From List View:
- Click "Filters" to adjust date range
- Click "Calendar View" to return to calendar
- Scroll to see all events in range
- View summary stats at bottom

## Accessibility

- Semantic HTML table structure
- Clear column headers
- Proper button labels
- Touch-friendly targets (44px+)
- Color not sole indicator (icons + text)
- Loading state with spinner
- Empty state with helpful message
