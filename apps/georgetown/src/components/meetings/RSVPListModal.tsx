import { X, Users, UserCheck, UserX, UserMinus, Edit2 } from 'lucide-react'
import { useEventRSVPList } from '../../hooks/useRSVP'
import { useAuth } from '../../hooks/useAuth'

/**
 * RSVPListModal Component
 * Purpose: Show list of attendees for an event
 *
 * Features:
 * - Displays all members who RSVP'd
 * - Shows RSVP status (attending, maybe, not attending)
 * - Shows guest counts
 * - Shows dietary restrictions
 * - Click your own RSVP to edit it
 * - Mobile-optimized layout
 *
 * Usage:
 * <RSVPListModal eventId="uuid" eventTitle="AGM 2025" isOpen={true} onClose={() => setIsOpen(false)} onEditRSVP={() => openRSVPModal()} />
 */

interface RSVPListModalProps {
  eventId: string
  eventTitle?: string
  eventDate?: string
  isOpen: boolean
  onClose: () => void
  onEditRSVP?: () => void
}

export function RSVPListModal({ eventId, eventTitle, eventDate, isOpen, onClose, onEditRSVP }: RSVPListModalProps) {
  const { rsvps, isLoading } = useEventRSVPList(eventId)
  const { memberId } = useAuth()

  const handleOverlayClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose()
    }
  }

  if (!isOpen) return null

  const attendingRsvps = rsvps.filter(r => r.status === 'attending')
  const maybeRsvps = rsvps.filter(r => r.status === 'maybe')
  const notAttendingRsvps = rsvps.filter(r => r.status === 'not_attending')

  const totalHeadcount = attendingRsvps.reduce((sum, r) => sum + 1 + (r.guest_count || 0), 0)

  return (
    <div
      className="fixed inset-0 z-50 flex items-end md:items-center justify-center bg-black bg-opacity-50"
      onClick={handleOverlayClick}
    >
      <div className="bg-white rounded-t-2xl md:rounded-2xl w-full md:max-w-2xl max-h-[90vh] overflow-y-auto shadow-xl">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold text-gray-900 flex items-center gap-2">
              <Users className="w-5 h-5 text-green-600" />
              RSVP Attendees
            </h2>
            {eventTitle && (
              <p className="text-sm text-gray-600 mt-1">
                {eventTitle}
                {eventDate && ` - ${new Date(eventDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`}
              </p>
            )}
          </div>
          <button
            onClick={onClose}
            className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
            aria-label="Close modal"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Summary */}
        <div className="bg-green-50 border-b border-green-100 px-6 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-green-700">{attendingRsvps.length}</div>
                <div className="text-xs text-green-600">Attending</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-700">{totalHeadcount}</div>
                <div className="text-xs text-green-600">Total Headcount</div>
              </div>
            </div>
            {maybeRsvps.length > 0 && (
              <div className="text-sm text-orange-600">
                {maybeRsvps.length} maybe
              </div>
            )}
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {isLoading ? (
            <div className="text-center py-8 text-gray-500">Loading attendees...</div>
          ) : rsvps.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              No RSVPs yet for this event.
            </div>
          ) : (
            <div className="space-y-6">
              {/* Attending */}
              {attendingRsvps.length > 0 && (
                <div>
                  <h3 className="text-sm font-semibold text-green-700 mb-3 flex items-center gap-2">
                    <UserCheck className="w-4 h-4" />
                    Attending ({attendingRsvps.length})
                  </h3>
                  <div className="space-y-3">
                    {attendingRsvps.map((rsvp) => {
                      const isCurrentUser = rsvp.member_id === memberId
                      return (
                      <div
                        key={rsvp.id}
                        className={`bg-green-50 border border-green-200 rounded-lg p-4 ${
                          isCurrentUser
                            ? 'cursor-pointer hover:bg-green-100 hover:border-green-300 transition-colors'
                            : ''
                        }`}
                        onClick={isCurrentUser ? () => {
                          onEditRSVP?.()
                        } : undefined}
                        title={isCurrentUser ? 'Click to edit your RSVP' : undefined}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="font-medium text-gray-900 flex items-center gap-2">
                              {rsvp.member_name}
                              {isCurrentUser && (
                                <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded font-normal flex items-center gap-1">
                                  <Edit2 size={10} />
                                  You - Click to edit
                                </span>
                              )}
                            </div>
                            {rsvp.guest_count > 0 && (
                              <div className="text-sm text-gray-600 mt-1">
                                + {rsvp.guest_count} guest{rsvp.guest_count > 1 ? 's' : ''}
                              </div>
                            )}
                            {rsvp.guest_names && rsvp.guest_names.length > 0 && (
                              <div className="text-xs text-gray-500 mt-1">
                                {rsvp.guest_names.join(', ')}
                              </div>
                            )}
                            {rsvp.dietary_notes && (
                              <div className="text-xs text-orange-600 mt-2">
                                🍽️ {rsvp.dietary_notes}
                              </div>
                            )}
                          </div>
                          <div className="flex items-center gap-2 ml-4">
                            <span className="bg-green-600 text-white px-2 py-1 rounded text-xs font-medium">
                              {1 + (rsvp.guest_count || 0)}
                            </span>
                          </div>
                        </div>
                      </div>
                    )}
                    )}
                  </div>
                </div>
              )}

              {/* Maybe */}
              {maybeRsvps.length > 0 && (
                <div>
                  <h3 className="text-sm font-semibold text-orange-700 mb-3 flex items-center gap-2">
                    <UserMinus className="w-4 h-4" />
                    Maybe ({maybeRsvps.length})
                  </h3>
                  <div className="space-y-3">
                    {maybeRsvps.map((rsvp) => {
                      const isCurrentUser = rsvp.member_id === memberId
                      return (
                      <div
                        key={rsvp.id}
                        className={`bg-orange-50 border border-orange-200 rounded-lg p-4 ${
                          isCurrentUser
                            ? 'cursor-pointer hover:bg-orange-100 hover:border-orange-300 transition-colors'
                            : ''
                        }`}
                        onClick={isCurrentUser ? () => {
                          onEditRSVP?.()
                        } : undefined}
                        title={isCurrentUser ? 'Click to edit your RSVP' : undefined}
                      >
                        <div className="font-medium text-gray-900 flex items-center gap-2">
                          {rsvp.member_name}
                          {isCurrentUser && (
                            <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded font-normal flex items-center gap-1">
                              <Edit2 size={10} />
                              You - Click to edit
                            </span>
                          )}
                        </div>
                        {rsvp.guest_count > 0 && (
                          <div className="text-sm text-gray-600 mt-1">
                            + {rsvp.guest_count} guest{rsvp.guest_count > 1 ? 's' : ''}
                          </div>
                        )}
                      </div>
                    )}
                    )}
                  </div>
                </div>
              )}

              {/* Regrets */}
              {notAttendingRsvps.length > 0 && (
                <div>
                  <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
                    <UserX className="w-4 h-4" />
                    Regrets ({notAttendingRsvps.length})
                  </h3>
                  <div className="space-y-2">
                    {notAttendingRsvps.map((rsvp) => {
                      const isCurrentUser = rsvp.member_id === memberId
                      return (
                      <div
                        key={rsvp.id}
                        className={`bg-gray-50 border border-gray-200 rounded-lg p-3 ${
                          isCurrentUser
                            ? 'cursor-pointer hover:bg-gray-100 hover:border-gray-300 transition-colors'
                            : ''
                        }`}
                        onClick={isCurrentUser ? () => {
                          onEditRSVP?.()
                        } : undefined}
                        title={isCurrentUser ? 'Click to edit your RSVP' : undefined}
                      >
                        <div className="text-sm text-gray-700 flex items-center gap-2">
                          {rsvp.member_name}
                          {isCurrentUser && (
                            <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded font-normal flex items-center gap-1">
                              <Edit2 size={10} />
                              You - Click to edit
                            </span>
                          )}
                        </div>
                      </div>
                    )}
                    )}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 flex justify-end">
          <button
            onClick={onClose}
            className="px-6 py-3 bg-gray-600 text-white rounded-lg font-medium hover:bg-gray-700 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  )
}
