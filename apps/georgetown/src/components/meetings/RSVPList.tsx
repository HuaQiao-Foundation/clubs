import { useState } from 'react'
import { X, Download, Users, UserCheck, UserX, HelpCircle } from 'lucide-react'
import { useEventRSVPList, useRSVP } from '../../hooks/useRSVP'
import { usePermissions } from '../../hooks/usePermissions'
import { format } from 'date-fns'

/**
 * RSVPList Component
 * Purpose: Admin dashboard showing who's coming (meal planning)
 *
 * Requirements:
 * - Only visible to officers/admins (permission check)
 * - Table/card view toggle (mobile: cards, desktop: table)
 * - Summary stats at top
 * - Export to CSV button
 * - Real-time updates
 *
 * Usage:
 * <RSVPList eventId="uuid" isOpen={true} onClose={() => setIsOpen(false)} />
 */

interface RSVPListProps {
  eventId: string
  isOpen: boolean
  onClose: () => void
}

export function RSVPList({ eventId, isOpen, onClose }: RSVPListProps) {
  const { rsvps, isLoading } = useEventRSVPList(eventId)
  const { summary } = useRSVP(eventId)
  const { isOfficer } = usePermissions()
  const [viewMode, setViewMode] = useState<'cards' | 'table'>('cards')

  if (!isOfficer) {
    return null // Only officers/admins can view
  }

  const handleExportCSV = () => {
    if (!rsvps.length) return

    const headers = ['Name', 'Status', 'Guests', 'Dietary Notes', 'Last Updated']
    const rows = rsvps.map(r => [
      r.member_name,
      r.status.replace('_', ' '),
      r.guest_count || 0,
      r.dietary_notes || '',
      r.updated_at ? format(new Date(r.updated_at), 'yyyy-MM-dd HH:mm') : ''
    ])

    const csvContent = [
      headers.join(','),
      ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
    ].join('\n')

    const blob = new Blob([csvContent], { type: 'text/csv' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `rsvp-list-${eventId}.csv`
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const handleOverlayClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose()
    }
  }

  if (!isOpen) return null

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case 'attending':
        return 'bg-green-100 text-green-800'
      case 'not_attending':
        return 'bg-gray-100 text-gray-800'
      case 'maybe':
        return 'bg-yellow-100 text-yellow-800'
      default:
        return 'bg-blue-100 text-blue-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'attending':
        return <UserCheck className="w-4 h-4" />
      case 'not_attending':
        return <UserX className="w-4 h-4" />
      case 'maybe':
        return <HelpCircle className="w-4 h-4" />
      default:
        return <Users className="w-4 h-4" />
    }
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-end md:items-center justify-center bg-black bg-opacity-50"
      onClick={handleOverlayClick}
    >
      <div className="bg-white rounded-t-2xl md:rounded-2xl w-full md:max-w-5xl max-h-[90vh] overflow-y-auto shadow-xl">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-900">RSVP List</h2>
            <button
              onClick={onClose}
              className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
              aria-label="Close modal"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Summary Stats */}
          {summary && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-green-50 rounded-lg p-3">
                <div className="text-2xl font-bold text-green-700">
                  {summary.total_headcount}
                </div>
                <div className="text-sm text-green-600">Total Attending</div>
                <div className="text-xs text-green-500 mt-1">
                  {summary.attending_count} members + {summary.total_guests} guests
                </div>
              </div>
              <div className="bg-gray-50 rounded-lg p-3">
                <div className="text-2xl font-bold text-gray-700">
                  {summary.not_attending_count}
                </div>
                <div className="text-sm text-gray-600">Not Attending</div>
              </div>
              <div className="bg-yellow-50 rounded-lg p-3">
                <div className="text-2xl font-bold text-yellow-700">
                  {summary.maybe_count}
                </div>
                <div className="text-sm text-yellow-600">Maybe</div>
              </div>
              <div className="bg-blue-50 rounded-lg p-3">
                <div className="text-2xl font-bold text-blue-700">
                  {summary.response_rate_pct}%
                </div>
                <div className="text-sm text-blue-600">Response Rate</div>
                <div className="text-xs text-blue-500 mt-1">
                  {summary.no_response_count} no response
                </div>
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="flex flex-col md:flex-row gap-3 mt-4">
            <button
              onClick={handleExportCSV}
              disabled={!rsvps.length}
              className="flex items-center justify-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Download className="w-4 h-4" />
              <span>Export CSV</span>
            </button>

            {/* View toggle for desktop */}
            <div className="hidden md:flex border border-gray-300 rounded-lg overflow-hidden">
              <button
                onClick={() => setViewMode('cards')}
                className={`px-4 py-2 text-sm font-medium ${
                  viewMode === 'cards'
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-700 hover:bg-gray-50'
                }`}
              >
                Cards
              </button>
              <button
                onClick={() => setViewMode('table')}
                className={`px-4 py-2 text-sm font-medium ${
                  viewMode === 'table'
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-700 hover:bg-gray-50'
                }`}
              >
                Table
              </button>
            </div>
          </div>
        </div>

        {/* List Content */}
        <div className="p-6">
          {isLoading ? (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-4 text-gray-500">Loading RSVPs...</p>
            </div>
          ) : rsvps.length === 0 ? (
            <div className="text-center py-12">
              <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500">No RSVPs yet</p>
            </div>
          ) : (
            <>
              {/* Mobile: Always cards | Desktop: Toggle */}
              {(viewMode === 'cards' || window.innerWidth < 768) ? (
                <div className="space-y-3">
                  {rsvps.map((rsvp) => (
                    <div
                      key={rsvp.id}
                      className="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h3 className="font-medium text-gray-900">{rsvp.member_name}</h3>
                          <div className="flex items-center gap-2 mt-2">
                            <span
                              className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${getStatusBadgeColor(
                                rsvp.status
                              )}`}
                            >
                              {getStatusIcon(rsvp.status)}
                              {rsvp.status.replace('_', ' ')}
                            </span>
                            {rsvp.guest_count > 0 && (
                              <span className="text-xs text-gray-500">
                                +{rsvp.guest_count} {rsvp.guest_count === 1 ? 'guest' : 'guests'}
                              </span>
                            )}
                          </div>
                          {rsvp.dietary_notes && (
                            <p className="text-sm text-gray-600 mt-2">
                              <span className="font-medium">Dietary:</span> {rsvp.dietary_notes}
                            </p>
                          )}
                        </div>
                        {rsvp.updated_at && (
                          <div className="text-xs text-gray-400">
                            {format(new Date(rsvp.updated_at), 'MMM d, h:mm a')}
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                /* Desktop: Table view */
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50 border-b border-gray-200">
                      <tr>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Name
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Status
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Guests
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Dietary Notes
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Updated
                        </th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {rsvps.map((rsvp) => (
                        <tr key={rsvp.id} className="hover:bg-gray-50">
                          <td className="px-4 py-3 text-sm font-medium text-gray-900">
                            {rsvp.member_name}
                          </td>
                          <td className="px-4 py-3 text-sm">
                            <span
                              className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${getStatusBadgeColor(
                                rsvp.status
                              )}`}
                            >
                              {getStatusIcon(rsvp.status)}
                              {rsvp.status.replace('_', ' ')}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-500">
                            {rsvp.guest_count || 0}
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-500">
                            <span className="line-clamp-2">{rsvp.dietary_notes || '—'}</span>
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-500">
                            {rsvp.updated_at
                              ? format(new Date(rsvp.updated_at), 'MMM d, h:mm a')
                              : '—'}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  )
}
