import { useState, useRef, useEffect } from 'react'
import {
  format,
  startOfMonth,
  endOfMonth,
  startOfWeek,
  endOfWeek,
  addDays,
  isSameMonth,
  isSameDay,
  addMonths,
  subMonths,
  addWeeks,
  subWeeks,
  isToday
} from 'date-fns'
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon, Plus, Users, List } from 'lucide-react'
import type { Speaker, Member } from '../types/database'
import CrownIcon from './CrownIcon'
import GavelIcon from './GavelIcon'
import MicrophoneIcon from './MicrophoneIcon'
import CharityIcon from './CharityIcon'
import PartyHatIcon from './PartyHatIcon'
import GiftIcon from './GiftIcon'

// Simple event types for day designations
interface Event {
  id: string
  date: string
  type: 'club_meeting' | 'club_assembly' | 'board_meeting' | 'committee_meeting' | 'club_social' | 'service_project' | 'holiday' | 'observance'
  title: string
  description?: string
  agenda?: string
  location_id?: string
}

// Malaysia holidays data (unchanged)
const MALAYSIA_HOLIDAYS_2024_2025 = {
  // 2024 holidays
  '2024-01-01': { name: 'New Year\'s Day', type: 'national' },
  '2024-02-10': { name: 'Chinese New Year', type: 'national' },
  '2024-02-11': { name: 'Chinese New Year (2nd day)', type: 'national' },
  '2024-02-24': { name: 'Federal Territory Day', type: 'federal_territory' },
  '2024-03-09': { name: 'Ramadan begins', type: 'islamic' },
  '2024-04-08': { name: 'Hari Raya Aidilfitri', type: 'islamic' },
  '2024-04-09': { name: 'Hari Raya Aidilfitri (2nd day)', type: 'islamic' },
  '2024-05-01': { name: 'Labour Day', type: 'national' },
  '2024-05-22': { name: 'Wesak Day', type: 'national' },
  '2024-06-03': { name: 'Agong\'s Birthday', type: 'national' },
  '2024-06-15': { name: 'Hari Raya Aidiladha', type: 'islamic' },
  '2024-08-31': { name: 'Merdeka Day', type: 'national' },
  '2024-09-16': { name: 'Malaysia Day', type: 'national' },
  '2024-10-20': { name: 'Deepavali', type: 'national' },
  '2024-12-25': { name: 'Christmas Day', type: 'national' },

  // 2025 holidays
  '2025-01-01': { name: 'New Year\'s Day', type: 'national' },
  '2025-01-29': { name: 'Chinese New Year', type: 'national' },
  '2025-01-30': { name: 'Chinese New Year (2nd day)', type: 'national' },
  '2025-02-01': { name: 'Federal Territory Day', type: 'federal_territory' },
  '2025-03-28': { name: 'Hari Raya Aidilfitri', type: 'islamic' },
  '2025-03-29': { name: 'Hari Raya Aidilfitri (2nd day)', type: 'islamic' },
  '2025-05-01': { name: 'Labour Day', type: 'national' },
  '2025-05-12': { name: 'Wesak Day', type: 'national' },
  '2025-06-02': { name: 'Agong\'s Birthday', type: 'national' },
  '2025-06-05': { name: 'Hari Raya Aidiladha', type: 'islamic' },
  '2025-08-31': { name: 'Merdeka Day', type: 'national' },
  '2025-09-16': { name: 'Malaysia Day', type: 'national' },
  '2025-10-20': { name: 'Deepavali', type: 'national' },
  '2025-12-25': { name: 'Christmas Day', type: 'national' }
}

// Rotary monthly observances (simplified, no complex pattern matching)
const ROTARY_OBSERVANCES: Record<string, string> = {
  '2025-07': 'Maternal and Child Health Month',
  '2025-08': 'Membership & New Club Development Month',
  '2025-09': 'Basic Education & Literacy Month',
  '2025-10': 'Community Economic Development Month',
  '2025-11': 'Rotary Foundation Month',
  '2025-12': 'Disease Prevention & Treatment Month',
  '2026-01': 'Vocational Service Month',
  '2026-02': 'Peacebuilding & Conflict Prevention Month',
  '2026-03': 'Water, Sanitation & Hygiene Month',
  '2026-04': 'Environment Month',
  '2026-05': 'Youth Service Month',
  '2026-06': 'Rotary Fellowships Month'
}

// Static club events are now replaced by database events passed as props

interface CalendarProps {
  speakers: Speaker[]
  events: Event[]
  members: Member[]
  rsvpSummaries?: Record<string, { attending: number; total: number }>
  onDateClick?: (date: Date) => void
  onSpeakerClick?: (speaker: Speaker) => void
  onAddSpeakerClick?: () => void
  onAddEventClick?: () => void
  onEventClick?: (event: Event) => void
  onRSVPBadgeClick?: (event: Event) => void
  onViewSpeakersClick?: () => void
  onViewMembersClick?: () => void
  onViewListClick?: () => void
}

export function Calendar({ speakers, events, members, rsvpSummaries = {}, onSpeakerClick, onAddSpeakerClick, onAddEventClick, onEventClick, onRSVPBadgeClick, onViewSpeakersClick, onViewMembersClick, onViewListClick }: CalendarProps) {
  // Load current date from localStorage, default to today
  const [currentDate, setCurrentDate] = useState(() => {
    const saved = localStorage.getItem('calendarCurrentDate')
    return saved ? new Date(saved) : new Date()
  })

  // Load view mode from localStorage, default to 'month'
  const [viewMode, setViewMode] = useState<'month' | 'week'>(() => {
    const saved = localStorage.getItem('calendarViewMode')
    return (saved === 'week' || saved === 'month') ? saved : 'month'
  })

  const calendarRef = useRef<HTMLDivElement>(null)
  const touchStartX = useRef<number | null>(null)
  const touchEndX = useRef<number | null>(null)
  const [expandedDay, setExpandedDay] = useState<string | null>(null)

  // Save view mode to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('calendarViewMode', viewMode)
  }, [viewMode])

  // Save current date to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('calendarCurrentDate', currentDate.toISOString())
  }, [currentDate])

  // Mobile swipe navigation
  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.changedTouches[0].screenX
  }

  const handleTouchEnd = (e: React.TouchEvent) => {
    touchEndX.current = e.changedTouches[0].screenX
    handleSwipe()
  }

  const handleSwipe = () => {
    if (!touchStartX.current || !touchEndX.current) return

    const distance = touchStartX.current - touchEndX.current
    const isLeftSwipe = distance > 50
    const isRightSwipe = distance < -50

    if (isLeftSwipe) {
      if (viewMode === 'month') {
        setCurrentDate(addMonths(currentDate, 1))
      } else {
        setCurrentDate(addWeeks(currentDate, 1))
      }
    }
    if (isRightSwipe) {
      if (viewMode === 'month') {
        setCurrentDate(subMonths(currentDate, 1))
      } else {
        setCurrentDate(subWeeks(currentDate, 1))
      }
    }

    touchStartX.current = null
    touchEndX.current = null
  }

  // Mobile progressive disclosure - tap to expand day details
  const handleDayTap = (date: Date) => {
    const dateKey = format(date, 'yyyy-MM-dd')
    if (window.innerWidth <= 640) { // Mobile only
      setExpandedDay(expandedDay === dateKey ? null : dateKey)
    }
  }

  // Generate calendar days based on view mode
  let startDate: Date
  let endDate: Date

  if (viewMode === 'month') {
    startDate = startOfWeek(startOfMonth(currentDate))
    endDate = endOfWeek(endOfMonth(currentDate))
  } else {
    // Week view: just show current week
    startDate = startOfWeek(currentDate)
    endDate = endOfWeek(currentDate)
  }

  const calendarDays: Date[] = []
  let day = startDate

  while (day <= endDate) {
    calendarDays.push(new Date(day))
    day = addDays(day, 1)
  }

  // Get week date range for header
  const getWeekDateRange = () => {
    const start = startOfWeek(currentDate)
    const end = endOfWeek(currentDate)
    const startMonth = format(start, 'MMM')
    const endMonth = format(end, 'MMM')
    const year = format(end, 'yyyy')

    if (startMonth === endMonth) {
      return `${startMonth} ${format(start, 'd')}-${format(end, 'd')}, ${year}`
    } else {
      return `${startMonth} ${format(start, 'd')} - ${endMonth} ${format(end, 'd')}, ${year}`
    }
  }

  // Get speakers for a specific date
  const getSpeakersForDate = (date: Date) => {
    return speakers.filter(speaker =>
      speaker.scheduled_date && isSameDay(new Date(speaker.scheduled_date), date)
    )
  }

  // Get events for a specific date
  const getEventsForDate = (date: Date) => {
    const dateKey = format(date, 'yyyy-MM-dd')
    return events.filter(event => event.date === dateKey)
  }

  // Get members with birthdays on a specific date
  const getBirthdaysForDate = (date: Date) => {
    const month = date.getMonth() + 1
    const day = date.getDate()
    return members.filter(member =>
      member.birth_month === month && member.birth_day === day
    )
  }

  // Get Malaysia holiday info for date
  const getHolidayInfo = (date: Date) => {
    const dateKey = format(date, 'yyyy-MM-dd')
    return MALAYSIA_HOLIDAYS_2024_2025[dateKey as keyof typeof MALAYSIA_HOLIDAYS_2024_2025]
  }

  // Get monthly Rotary observance
  const getMonthlyObservance = (date: Date) => {
    const monthKey = format(date, 'yyyy-MM')
    return ROTARY_OBSERVANCES[monthKey as keyof typeof ROTARY_OBSERVANCES]
  }

  // Check if date is weekend
  const isWeekend = (date: Date) => {
    const day = date.getDay()
    return day === 0 || day === 6 // Sunday or Saturday
  }

  // Simple day styling without complex patterns
  const getDayClasses = (date: Date) => {
    const isCurrentMonth = isSameMonth(date, currentDate)
    const holiday = getHolidayInfo(date)
    const dayEvents = getEventsForDate(date)
    const weekend = isWeekend(date)
    const today = isToday(date)
    const hasSpeakers = getSpeakersForDate(date).length > 0

    // Week view gets taller cells for more detail
    const minHeightClass = viewMode === 'week'
      ? 'min-h-[300px] sm:min-h-[280px] md:min-h-[320px]'
      : 'min-h-[140px] sm:min-h-[120px] md:min-h-[120px]'

    let classes = `${minHeightClass} p-1 sm:p-3 border-r border-b border-gray-200 relative touch-manipulation w-full max-w-full overflow-hidden `

    if (!isCurrentMonth) {
      classes += 'bg-gray-50 text-gray-400 '
    } else if (holiday) {
      classes += 'bg-pink-50 text-[#d41367] '
    } else if (dayEvents.length > 0) {
      if (dayEvents.some(e => e.type === 'holiday')) {
        classes += 'bg-pink-50 text-[#d41367] ' // User-managed holidays - Cranberry
      } else if (dayEvents.some(e => e.type === 'observance')) {
        classes += 'bg-orange-50 text-[#f7a81b] ' // Rotary observances - Gold
      } else if (dayEvents.some(e => e.type === 'service_project')) {
        classes += 'bg-cyan-50 text-[#00adbb] ' // Service projects - Turquoise
      } else if (dayEvents.some(e => e.type === 'club_social')) {
        classes += 'bg-purple-50 text-purple-700 ' // Social events - Purple
      } else if (dayEvents.some(e => e.type === 'club_assembly')) {
        classes += 'bg-green-50 text-green-700 ' // Club assemblies - Green
      } else if (dayEvents.some(e => e.type === 'board_meeting')) {
        classes += 'bg-gray-50 text-gray-700 ' // Board meetings - Gray
      } else if (dayEvents.some(e => e.type === 'committee_meeting')) {
        classes += 'bg-indigo-50 text-indigo-700 ' // Committee meetings - Indigo
      } else {
        classes += 'bg-blue-50 text-blue-700 ' // Regular club meetings
      }
    } else if (weekend) {
      classes += 'bg-gray-50 text-gray-600 '
    } else {
      classes += 'bg-white text-gray-900 '
    }

    if (today) {
      classes += 'ring-2 ring-[#0067c8] '
    }

    if (hasSpeakers) {
      classes += 'border-l-4 border-l-[#f7a81b] '
    }


    return classes
  }

  return (
    <div className="w-full max-w-full overflow-x-hidden">
      <div className="max-w-7xl mx-auto p-3 md:p-6 lg:p-8">

        {/* Calendar Container */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">

          {/* Calendar Header - Month/Week Navigation */}
          <div className="bg-white border-b border-gray-200 p-4 md:p-6">
            <div className="flex items-center justify-between">

              {/* Month/Week Display */}
              <div className="flex items-center gap-3">
                <CalendarIcon className="text-[#0067c8] flex-shrink-0" size={28} />
                <div>
                  <h2 className="text-xl md:text-2xl lg:text-3xl font-bold text-gray-900 leading-tight">
                    {viewMode === 'month' ? format(currentDate, 'MMMM yyyy') : getWeekDateRange()}
                  </h2>
                  {/* Mobile swipe hint */}
                  <p className="text-xs text-gray-400 lg:hidden mt-1">
                    ← Swipe to navigate {viewMode === 'month' ? 'months' : 'weeks'} →
                  </p>
                </div>
              </div>

              {/* Navigation Buttons */}
              <div className="flex items-center gap-3">
                {/* View Mode Toggle - Left of navigation */}
                <div className="flex items-center gap-2 mr-2">
                  <button
                    onClick={() => setViewMode('month')}
                    className={`px-3 py-2 rounded-lg font-medium transition-all duration-200 touch-manipulation min-h-[44px] text-sm ${
                      viewMode === 'month'
                        ? 'bg-[#0067c8] text-white shadow-md'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    Month
                  </button>
                  <button
                    onClick={() => setViewMode('week')}
                    className={`px-3 py-2 rounded-lg font-medium transition-all duration-200 touch-manipulation min-h-[44px] text-sm ${
                      viewMode === 'week'
                        ? 'bg-[#0067c8] text-white shadow-md'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    Week
                  </button>
                </div>

                <button
                  onClick={() => {
                    if (viewMode === 'month') {
                      setCurrentDate(subMonths(currentDate, 1))
                    } else {
                      setCurrentDate(subWeeks(currentDate, 1))
                    }
                  }}
                  className="p-2.5 md:p-3 text-gray-600 hover:text-[#0067c8] hover:bg-gray-100 rounded-lg transition-all duration-200 touch-manipulation min-w-[44px] min-h-[44px] flex items-center justify-center border border-gray-200"
                  aria-label={viewMode === 'month' ? 'Previous month' : 'Previous week'}
                >
                  <ChevronLeft size={18} />
                </button>

                <button
                  onClick={() => setCurrentDate(new Date())}
                  className="px-3 py-2.5 md:px-4 md:py-3 text-sm font-semibold bg-[#0067c8] text-white hover:bg-[#004080] rounded-lg transition-all duration-200 touch-manipulation min-h-[44px] shadow-md hover:shadow-lg"
                >
                  TODAY
                </button>

                <button
                  onClick={() => {
                    if (viewMode === 'month') {
                      setCurrentDate(addMonths(currentDate, 1))
                    } else {
                      setCurrentDate(addWeeks(currentDate, 1))
                    }
                  }}
                  className="p-2.5 md:p-3 text-gray-600 hover:text-[#0067c8] hover:bg-gray-100 rounded-lg transition-all duration-200 touch-manipulation min-w-[44px] min-h-[44px] flex items-center justify-center border border-gray-200"
                  aria-label={viewMode === 'month' ? 'Next month' : 'Next week'}
                >
                  <ChevronRight size={18} />
                </button>
              </div>
            </div>

            {/* Rotary Observance - Close to month context */}
            {getMonthlyObservance(currentDate) && (
              <div className="mt-3 p-3 bg-[#0067c8]/5 rounded-lg border border-[#0067c8]/10">
                <p className="text-sm text-[#0067c8] font-medium flex items-center gap-2">
                  <span>🌟</span>
                  <span>{getMonthlyObservance(currentDate)}</span>
                </p>
              </div>
            )}
          </div>

          {/* Calendar Grid - Immediately follows header for cognitive continuity */}
          <div className="w-full max-w-full">
            {/* Days of week header - Mobile optimized */}
            <div className="grid grid-cols-7 bg-gray-50 border-b border-gray-200 w-full" style={{ width: '100%', maxWidth: '100%', boxSizing: 'border-box' }}>
            {['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((day) => (
              <div key={day} className="p-1 sm:p-3 text-center font-semibold text-gray-700 text-xs sm:text-sm border-r border-gray-200 last:border-r-0 min-h-[40px] sm:min-h-[44px] flex items-center justify-center">
                <span className="hidden sm:inline">{day}</span>
                <span className="sm:hidden">{day.slice(0, 3)}</span>
              </div>
            ))}
          </div>

          {/* Calendar Body - Mobile swipe enabled with width constraints and scrolling */}
          <div
            ref={calendarRef}
            className="grid grid-cols-7 auto-rows-min w-full max-w-full overflow-x-hidden"
            style={{ width: '100%', maxWidth: '100%', boxSizing: 'border-box' }}
            onTouchStart={handleTouchStart}
            onTouchEnd={handleTouchEnd}
          >
            {calendarDays.map((date) => {
              const staticHoliday = getHolidayInfo(date)
              const dayEvents = getEventsForDate(date)
              const daySpeakers = getSpeakersForDate(date)
              const birthdays = getBirthdaysForDate(date)
              const dateKey = format(date, 'yyyy-MM-dd')
              const isExpanded = expandedDay === dateKey
              const hasContent = daySpeakers.length > 0 || dayEvents.length > 0 || staticHoliday || birthdays.length > 0

              // Only show static holiday if there's no database holiday for this date
              const hasDbHoliday = dayEvents.some(e => e.type === 'holiday')
              const holiday = hasDbHoliday ? null : staticHoliday

              return (
                <div
                  key={dateKey}
                  className={`${getDayClasses(date)} ${isExpanded ? 'ring-2 ring-[#f7a81b] bg-blue-50' : ''} ${hasContent ? 'cursor-pointer sm:cursor-default' : ''}`}
                  onClick={() => hasContent && handleDayTap(date)}
                >
                  {/* Mobile-optimized date header */}
                  <div className="flex items-center justify-between mb-2 sm:mb-2">
                    <span className={`text-sm sm:text-sm font-semibold ${isToday(date) ? 'text-[#0067c8]' : ''}`}>
                      {format(date, 'd')}
                    </span>

                    {/* Mobile-first: Show primary indicator only */}
                    <div className="flex items-center gap-1">
                      {/* Speaker badge removed - redundant with speaker cards below */}

                      {/* Priority 1: Club meetings/events */}
                      {dayEvents.length > 0 && (
                        <div
                          className={`text-xs px-1.5 py-0.5 rounded font-medium ${
                            dayEvents.some(e => e.type === 'holiday') ? 'bg-pink-100 text-[#d41367] cursor-pointer' :
                            dayEvents.some(e => e.type === 'observance') ? 'bg-orange-100 text-[#f7a81b] cursor-pointer' :
                            dayEvents.some(e => e.type === 'service_project') ? 'bg-cyan-100 text-[#00adbb]' :
                            dayEvents.some(e => e.type === 'club_social') ? 'bg-purple-100 text-purple-700' :
                            dayEvents.some(e => e.type === 'club_assembly') ? 'bg-green-100 text-green-700' :
                            dayEvents.some(e => e.type === 'board_meeting') ? 'bg-gray-100 text-gray-700' :
                            dayEvents.some(e => e.type === 'committee_meeting') ? 'bg-indigo-100 text-indigo-700' :
                            'bg-blue-100 text-blue-700'
                          }`}
                          onClick={(e) => {
                            // Only clickable for holidays and observances, not meetings
                            const firstEvent = dayEvents[0]
                            if (firstEvent.type === 'holiday' || firstEvent.type === 'observance') {
                              e.stopPropagation()
                              onEventClick?.(firstEvent)
                            }
                          }}
                        >
                          {dayEvents.some(e => e.type === 'holiday') ? <GiftIcon size={12} /> :
                           dayEvents.some(e => e.type === 'observance') ? '⭐' :
                           dayEvents.some(e => e.type === 'service_project') ? <CharityIcon size={12} /> :
                           dayEvents.some(e => e.type === 'club_social') ? <PartyHatIcon size={12} /> :
                           dayEvents.some(e => e.type === 'club_assembly') ? '🏛️' :
                           dayEvents.some(e => e.type === 'board_meeting') ? '📋' :
                           dayEvents.some(e => e.type === 'committee_meeting') ? '👥' :
                           <GavelIcon size={12} />}
                        </div>
                      )}

                      {/* Priority 3: Static holidays */}
                      {holiday && !hasDbHoliday && (
                        <div
                          className="text-xs bg-pink-100 text-[#d41367] px-1.5 py-0.5 rounded font-medium cursor-pointer"
                          onClick={(e) => {
                            e.stopPropagation()
                            const holidayEvent: Event = {
                              id: `static-holiday-${format(date, 'yyyy-MM-dd')}`,
                              date: format(date, 'yyyy-MM-dd'),
                              type: 'holiday',
                              title: holiday.name,
                              description: `${holiday.type === 'national' ? 'National' :
                                          holiday.type === 'islamic' ? 'Islamic' :
                                          holiday.type === 'federal_territory' ? 'Federal Territory' : 'Regional'} holiday observed in Malaysia`
                            }
                            onEventClick?.(holidayEvent)
                          }}
                        >
                          <GiftIcon size={12} />
                        </div>
                      )}

                    </div>
                  </div>

                  {/* Mobile-first content with progressive disclosure */}
                  <div className="space-y-2 sm:space-y-1">
                    {/* Priority 1: SPEAKERS (most important for meeting context) */}
                    {daySpeakers.length > 0 && (
                      <div className="space-y-1.5 sm:space-y-1">
                        {/* Always show first speaker */}
                        {daySpeakers.slice(0, 1).map((speaker) => (
                          <div
                            key={speaker.id}
                            className={`bg-[#0067c8] text-white rounded-lg cursor-pointer hover:bg-[#004080] transition-colors touch-manipulation ${
                              viewMode === 'week' ? 'px-3 py-2.5' : 'px-2.5 py-2 sm:px-2 sm:py-1.5'
                            }`}
                            onClick={(e) => {
                              e.stopPropagation()
                              onSpeakerClick?.(speaker)
                            }}
                            title={`${speaker.name} - ${speaker.topic}`}
                          >
                            <div className={`font-semibold truncate ${viewMode === 'week' ? 'text-sm' : 'text-xs'}`}>
                              {speaker.name}
                            </div>
                            <div className={`opacity-90 truncate ${viewMode === 'week' ? 'text-xs' : 'text-xs hidden sm:block'}`}>
                              {speaker.organization}
                            </div>
                            {viewMode === 'week' && speaker.topic && (
                              <div className="text-xs opacity-75 truncate mt-1">
                                {speaker.topic}
                              </div>
                            )}
                          </div>
                        ))}

                        {/* Progressive disclosure: Show additional speakers on mobile when expanded */}
                        {(isExpanded || window.innerWidth > 640) && daySpeakers.slice(1).map((speaker) => (
                          <div
                            key={speaker.id}
                            className={`bg-[#0067c8]/80 text-white rounded cursor-pointer hover:bg-[#004080] transition-colors ${
                              viewMode === 'week' ? 'px-3 py-2 text-sm' : 'px-2 py-1.5 sm:px-2 sm:py-1 text-xs'
                            }`}
                            onClick={(e) => {
                              e.stopPropagation()
                              onSpeakerClick?.(speaker)
                            }}
                          >
                            <div className="font-medium truncate">{speaker.name}</div>
                            <div className={`opacity-75 truncate ${viewMode === 'week' ? 'text-xs' : 'text-xs'}`}>
                              {speaker.organization}
                            </div>
                            {viewMode === 'week' && speaker.topic && (
                              <div className="text-xs opacity-60 truncate mt-0.5">
                                {speaker.topic}
                              </div>
                            )}
                          </div>
                        ))}

                        {/* Tap hint for mobile when there are more speakers */}
                        {!isExpanded && daySpeakers.length > 1 && (
                          <div className="text-xs text-[#0067c8] font-semibold text-center py-1 sm:hidden">
                            • Tap for {daySpeakers.length - 1} more •
                          </div>
                        )}
                      </div>
                    )}

                    {/* Priority 2: CLUB MEETINGS/EVENTS */}
                    {dayEvents.length > 0 && (
                      <div className="space-y-1">
                        {/* Always show first event */}
                        {dayEvents.slice(0, 1).map((event) => {
                          const summary = rsvpSummaries[event.id]
                          return (
                          <div
                            key={event.id}
                            className={`px-2 py-1.5 rounded text-xs font-medium cursor-pointer transition-colors ${
                              event.type === 'holiday'
                                ? 'bg-pink-50 text-[#d41367] hover:bg-pink-100'
                                : event.type === 'observance'
                                ? 'bg-orange-50 text-[#f7a81b] hover:bg-orange-100'
                                : event.type === 'service_project'
                                ? 'bg-cyan-50 text-[#00adbb] hover:bg-cyan-100'
                                : event.type === 'club_social'
                                ? 'bg-purple-50 text-purple-700 hover:bg-purple-100'
                                : event.type === 'club_assembly'
                                ? 'bg-green-50 text-green-700 hover:bg-green-100'
                                : event.type === 'board_meeting'
                                ? 'bg-gray-50 text-gray-700 hover:bg-gray-100'
                                : event.type === 'committee_meeting'
                                ? 'bg-indigo-50 text-indigo-700 hover:bg-indigo-100'
                                : 'bg-blue-50 text-blue-700 hover:bg-blue-100'
                            }`}
                            onClick={(e) => {
                              e.stopPropagation()
                              onEventClick?.(event)
                            }}
                          >
                            <div className="flex items-center justify-between gap-1">
                              <div className="truncate">{event.title}</div>
                              {summary && summary.attending > 0 && (
                                <div
                                  className="flex items-center gap-0.5 bg-green-600 text-white px-1.5 py-0.5 rounded font-semibold flex-shrink-0 cursor-pointer hover:bg-green-700 transition-colors"
                                  onClick={(e) => {
                                    e.stopPropagation()
                                    onRSVPBadgeClick?.(event)
                                  }}
                                  title="Click to view attendees"
                                >
                                  <Users size={10} />
                                  <span>{summary.total}</span>
                                </div>
                              )}
                            </div>
                          </div>
                        )}
                        )}

                        {/* Progressive disclosure: Show additional events when expanded */}
                        {(isExpanded || window.innerWidth > 640) && dayEvents.slice(1).map((event) => (
                          <div
                            key={event.id}
                            className={`px-2 py-1 rounded text-xs font-medium cursor-pointer transition-colors ${
                              event.type === 'holiday'
                                ? 'bg-pink-50 text-[#d41367] hover:bg-pink-100'
                                : event.type === 'observance'
                                ? 'bg-orange-50 text-[#f7a81b] hover:bg-orange-100'
                                : event.type === 'service_project'
                                ? 'bg-cyan-50 text-[#00adbb] hover:bg-cyan-100'
                                : event.type === 'club_social'
                                ? 'bg-purple-50 text-purple-700 hover:bg-purple-100'
                                : event.type === 'club_assembly'
                                ? 'bg-green-50 text-green-700 hover:bg-green-100'
                                : event.type === 'board_meeting'
                                ? 'bg-gray-50 text-gray-700 hover:bg-gray-100'
                                : event.type === 'committee_meeting'
                                ? 'bg-indigo-50 text-indigo-700 hover:bg-indigo-100'
                                : 'bg-blue-50 text-blue-700 hover:bg-blue-100'
                            }`}
                            onClick={(e) => {
                              e.stopPropagation()
                              onEventClick?.(event)
                            }}
                          >
                            <div className="truncate">{event.title}</div>
                          </div>
                        ))}

                        {!isExpanded && dayEvents.length > 1 && (
                          <div className="text-xs text-gray-500 text-center py-0.5 sm:hidden">
                            +{dayEvents.length - 1} more
                          </div>
                        )}
                      </div>
                    )}

                    {/* Priority 3: STATIC HOLIDAYS (show when expanded or on desktop) */}
                    {holiday && !hasDbHoliday && (isExpanded || window.innerWidth > 640) && (
                      <div
                        className="text-xs text-[#d41367] font-medium cursor-pointer hover:text-[#b01549] transition-colors truncate"
                        onClick={(e) => {
                          e.stopPropagation()
                          const holidayEvent: Event = {
                            id: `static-holiday-${format(date, 'yyyy-MM-dd')}`,
                            date: format(date, 'yyyy-MM-dd'),
                            type: 'holiday',
                            title: holiday.name,
                            description: `${holiday.type === 'national' ? 'National' :
                                        holiday.type === 'islamic' ? 'Islamic' :
                                        holiday.type === 'federal_territory' ? 'Federal Territory' : 'Regional'} holiday observed in Malaysia`
                          }
                          onEventClick?.(holidayEvent)
                        }}
                      >
                        {holiday.name}
                      </div>
                    )}

                    {/* Priority 4: BIRTHDAYS */}
                    {birthdays.length > 0 && (
                      <div className="space-y-1">
                        {birthdays.slice(0, isExpanded || window.innerWidth > 640 ? birthdays.length : 1).map((member) => (
                          <div
                            key={member.id}
                            className="flex items-center gap-1.5 px-2 py-1 rounded text-xs font-medium bg-[#f7a81b]/10 text-gray-800"
                            title={`${member.name}'s Birthday`}
                          >
                            <CrownIcon size={12} className="flex-shrink-0" />
                            <span className="truncate">{member.name}</span>
                          </div>
                        ))}

                        {!isExpanded && birthdays.length > 1 && (
                          <div className="text-xs text-gray-500 text-center py-0.5 sm:hidden">
                            +{birthdays.length - 1} more birthday{birthdays.length > 2 ? 's' : ''}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Mobile Action Buttons - Below calendar to not interfere with temporal context */}
      <div className="lg:hidden mt-4 p-4 space-y-3">
          <div className="grid grid-cols-1 gap-3 mb-3">
            <button
              onClick={onViewListClick}
              className="flex items-center justify-center gap-2 px-4 py-4 bg-[#0067c8] text-white rounded-lg hover:bg-[#004080] text-sm font-semibold transition-all duration-200 touch-manipulation min-h-[56px] shadow-md hover:shadow-lg"
            >
              <List size={18} />
              <span className="font-bold tracking-wide">LIST VIEW</span>
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={onViewSpeakersClick}
              className="flex items-center justify-center gap-2 px-4 py-4 bg-[#f7a81b] text-gray-900 rounded-lg hover:bg-[#e5a50a] text-sm font-semibold transition-all duration-200 touch-manipulation min-h-[56px] shadow-md hover:shadow-lg border border-[#f7a81b]"
            >
              <MicrophoneIcon size={18} fill="#000" />
              <span className="font-bold tracking-wide">VIEW SPEAKERS</span>
            </button>
            <button
              onClick={onViewMembersClick}
              className="flex items-center justify-center gap-2 px-4 py-4 bg-white border-2 border-[#0067c8] text-[#0067c8] rounded-lg hover:bg-[#0067c8] hover:text-white text-sm font-semibold transition-all duration-200 touch-manipulation min-h-[56px] shadow-sm hover:shadow-md"
            >
              <Users size={18} />
              <span className="font-bold tracking-wide">VIEW MEMBERS</span>
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={onAddSpeakerClick}
              className="flex items-center justify-center gap-2 px-4 py-3 bg-white border-2 border-[#0067c8] text-[#0067c8] rounded-lg hover:bg-[#0067c8] hover:text-white text-sm font-semibold transition-all duration-200 touch-manipulation min-h-[52px] shadow-sm hover:shadow-md"
            >
              <Plus size={18} />
              <span>Add Speaker</span>
            </button>

            <button
              onClick={onAddEventClick}
              className="flex items-center justify-center gap-2 px-4 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 hover:border-gray-400 text-sm font-medium transition-all duration-200 touch-manipulation min-h-[52px] shadow-sm hover:shadow-md"
            >
              <Plus size={18} />
              <span>Add Event</span>
            </button>
          </div>
        </div>

      </div>
    </div>
  )
}