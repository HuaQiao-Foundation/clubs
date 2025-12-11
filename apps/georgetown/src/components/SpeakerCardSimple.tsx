/**
 * SpeakerCardSimple Component
 * Displays a speaker card on the timeline view (read-only, clickable)
 */

import type { Speaker } from '../types/database'
import { Calendar, Building, Users } from 'lucide-react'
import { format, parseISO } from 'date-fns'

type SpeakerCardSimpleProps = {
  speaker: Speaker
  onClick?: () => void
}

export default function SpeakerCardSimple({ speaker, onClick }: SpeakerCardSimpleProps) {
  const scheduledDate = speaker.scheduled_date
    ? format(parseISO(speaker.scheduled_date), 'MMM d, yyyy')
    : null

  return (
    <div
      onClick={onClick}
      className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 hover:shadow-md transition-shadow cursor-pointer"
    >
      {/* Header with Name and Rotarian Badge */}
      <div className="flex items-start gap-3 mb-2">
        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#0067c8] to-[#004080] text-white flex items-center justify-center text-sm font-semibold shadow-sm flex-shrink-0">
          {speaker.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-semibold text-gray-900 text-sm line-clamp-1">
              {speaker.name}
            </h4>
            {speaker.is_rotarian && (
              <div className="flex-shrink-0" title={`Rotarian${speaker.rotary_club ? ` - ${speaker.rotary_club}` : ''}`}>
                <Users size={14} className="text-[#0067c8]" />
              </div>
            )}
          </div>
          {speaker.job_title && (
            <p className="text-xs text-gray-600 line-clamp-1">{speaker.job_title}</p>
          )}
        </div>
      </div>

      {/* Topic */}
      {speaker.topic && (
        <div className="mb-2">
          <p className="text-sm font-medium text-[#0067c8] line-clamp-2">{speaker.topic}</p>
        </div>
      )}

      {/* Organization */}
      {speaker.organization && (
        <div className="flex items-center gap-1.5 text-xs text-gray-600 mb-2">
          <Building size={12} className="text-gray-400" />
          <span className="truncate">{speaker.organization}</span>
        </div>
      )}

      {/* Scheduled Date */}
      {scheduledDate && (
        <div className="flex items-center gap-1.5 text-xs font-medium text-[#f7a81b] mt-2 pt-2 border-t border-gray-100">
          <Calendar size={12} />
          <span>{scheduledDate}</span>
        </div>
      )}
    </div>
  )
}
