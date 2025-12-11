import { useMemberAttendanceStats } from '../../hooks/useAttendance'
import { AlertTriangle, TrendingUp, Calendar, Award } from 'lucide-react'
import { format } from 'date-fns'

/**
 * AttendanceDashboard Component
 * Purpose: Member personal attendance stats
 *
 * Requirements:
 * - Shows member's own attendance statistics
 * - Cards: Current quarter, YTD, Lifetime, Last attended, Consecutive absences
 * - At-risk warning if below 60%
 * - Mobile-optimized card layout
 *
 * Usage:
 * <AttendanceDashboard memberId="uuid" />
 */

interface AttendanceDashboardProps {
  memberId: string
  className?: string
}

export function AttendanceDashboard({ memberId, className = '' }: AttendanceDashboardProps) {
  const { stats, isLoading, error } = useMemberAttendanceStats(memberId)

  if (isLoading) {
    return (
      <div className={`bg-white rounded-lg shadow-md p-6 ${className}`}>
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/2"></div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="h-32 bg-gray-200 rounded"></div>
            <div className="h-32 bg-gray-200 rounded"></div>
            <div className="h-32 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    )
  }

  if (error || !stats) {
    return (
      <div className={`bg-white rounded-lg shadow-md p-6 ${className}`}>
        <div className="text-center py-12">
          <AlertTriangle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <p className="text-gray-500">
            {error ? 'Failed to load attendance stats' : 'No attendance data available'}
          </p>
        </div>
      </div>
    )
  }

  const isAtRisk = (stats.ytd_percentage !== null && stats.ytd_percentage !== undefined && stats.ytd_percentage < 60) || stats.consecutive_absences >= 4

  return (
    <div className={`bg-white rounded-lg shadow-md ${className}`}>
      {/* Header */}
      <div className="px-6 py-4 border-b border-gray-200">
        <h2 className="text-xl font-semibold text-gray-900">My Attendance</h2>
        {isAtRisk && (
          <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
            <div>
              <p className="text-sm font-medium text-red-900">Attendance Alert</p>
              <p className="text-sm text-red-700 mt-1">
                {stats.ytd_percentage !== null && stats.ytd_percentage !== undefined && stats.ytd_percentage < 60 && (
                  <span>
                    Your attendance is below the 60% Rotary requirement ({stats.ytd_percentage.toFixed(1)}%).
                  </span>
                )}
                {stats.consecutive_absences >= 4 && (
                  <span>
                    {' '}You have {stats.consecutive_absences} consecutive absences.
                  </span>
                )}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Stats Cards */}
      <div className="p-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Current Quarter */}
        <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
          <div className="flex items-center gap-2 mb-2">
            <Calendar className="w-5 h-5 text-blue-600" />
            <h3 className="text-sm font-medium text-blue-900">Current Quarter</h3>
          </div>
          <div className="text-3xl font-bold text-blue-700">
            {stats.current_quarter_attended}/{stats.current_quarter_meetings}
          </div>
          <p className="text-sm text-blue-600 mt-1">
            {stats.current_quarter_percentage !== null && stats.current_quarter_percentage !== undefined
              ? `${stats.current_quarter_percentage.toFixed(1)}% attendance`
              : 'No data yet'}
          </p>
        </div>

        {/* Year-to-Date */}
        <div className="bg-green-50 rounded-lg p-4 border border-green-200">
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="w-5 h-5 text-green-600" />
            <h3 className="text-sm font-medium text-green-900">Year-to-Date</h3>
          </div>
          <div className="text-3xl font-bold text-green-700">
            {stats.ytd_attended}/{stats.ytd_meetings}
          </div>
          <p className="text-sm text-green-600 mt-1">
            {stats.ytd_percentage !== null && stats.ytd_percentage !== undefined
              ? `${stats.ytd_percentage.toFixed(1)}% attendance`
              : 'No data yet'}
          </p>
        </div>

        {/* Lifetime */}
        <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
          <div className="flex items-center gap-2 mb-2">
            <Award className="w-5 h-5 text-purple-600" />
            <h3 className="text-sm font-medium text-purple-900">Lifetime</h3>
          </div>
          <div className="text-3xl font-bold text-purple-700">
            {stats.lifetime_attended}/{stats.lifetime_meetings}
          </div>
          <p className="text-sm text-purple-600 mt-1">
            {stats.lifetime_percentage !== null && stats.lifetime_percentage !== undefined
              ? `${stats.lifetime_percentage.toFixed(1)}% attendance`
              : 'No data yet'}
          </p>
        </div>

        {/* Last Attended */}
        <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <h3 className="text-sm font-medium text-gray-700 mb-2">Last Attended</h3>
          <div className="text-lg font-semibold text-gray-900">
            {stats.last_attended_date
              ? format(new Date(stats.last_attended_date), 'EEEE, MMM d, yyyy')
              : 'No attendance yet'}
          </div>
        </div>

        {/* Consecutive Absences */}
        {stats.consecutive_absences > 0 && (
          <div className={`rounded-lg p-4 border ${
            stats.consecutive_absences >= 4
              ? 'bg-red-50 border-red-200'
              : 'bg-yellow-50 border-yellow-200'
          }`}>
            <h3 className={`text-sm font-medium mb-2 ${
              stats.consecutive_absences >= 4 ? 'text-red-900' : 'text-yellow-900'
            }`}>
              Consecutive Absences
            </h3>
            <div className={`text-3xl font-bold ${
              stats.consecutive_absences >= 4 ? 'text-red-700' : 'text-yellow-700'
            }`}>
              {stats.consecutive_absences}
            </div>
            <p className={`text-sm mt-1 ${
              stats.consecutive_absences >= 4 ? 'text-red-600' : 'text-yellow-600'
            }`}>
              {stats.consecutive_absences >= 4 ? 'Action needed!' : 'Recent absences'}
            </p>
          </div>
        )}

        {/* Makeup Credits */}
        {stats.makeups_credited > 0 && (
          <div className="bg-indigo-50 rounded-lg p-4 border border-indigo-200">
            <h3 className="text-sm font-medium text-indigo-900 mb-2">Makeup Credits</h3>
            <div className="text-3xl font-bold text-indigo-700">
              {stats.makeups_credited}
            </div>
            <p className="text-sm text-indigo-600 mt-1">
              Other clubs & events
            </p>
          </div>
        )}
      </div>

      {/* Footer Info */}
      <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 rounded-b-lg">
        <p className="text-xs text-gray-500">
          Rotary requires 60% attendance for active membership. Attendance is calculated based on the Rotary year (July 1 - June 30).
        </p>
      </div>
    </div>
  )
}
