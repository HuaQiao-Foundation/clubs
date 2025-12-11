import type { Speaker } from '../types/database'
import { BadgeCheck, Calendar } from 'lucide-react'
import { format } from 'date-fns'

interface SpeakersListProps {
  speakers: Speaker[]
  onSpeakerClick: (speaker: Speaker) => void
}

export default function SpeakersList({ speakers, onSpeakerClick }: SpeakersListProps) {
  return (
    <div className="space-y-3">
      {speakers.map((speaker) => {
        return (
          <button
            key={speaker.id}
            onClick={() => onSpeakerClick(speaker)}
            className="w-full bg-white rounded-lg p-4 shadow hover:shadow-md transition-all text-left border border-gray-200 hover:border-[#0067c8]"
          >
            <div className="flex items-start gap-4">
              {/* Portrait */}
              <div className="flex-shrink-0">
                {speaker.portrait_url ? (
                  <img
                    src={speaker.portrait_url}
                    alt={speaker.name}
                    className="w-14 h-14 md:w-16 md:h-16 rounded-full object-cover border-2 border-gray-200"
                    onError={(e) => {
                      e.currentTarget.style.display = 'none'
                      const fallback = e.currentTarget.nextElementSibling as HTMLElement
                      if (fallback) fallback.style.display = 'flex'
                    }}
                  />
                ) : null}
                <div
                  className="w-14 h-14 md:w-16 md:h-16 rounded-full bg-gradient-to-br from-[#0067c8] to-[#004080] text-white flex items-center justify-center text-base font-semibold border-2 border-gray-200"
                  style={{ display: speaker.portrait_url ? 'none' : 'flex' }}
                >
                  {speaker.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                </div>
              </div>

              {/* Speaker Info */}
              <div className="flex-1 min-w-0">
                {/* Name with badge */}
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-gray-900 text-base truncate">
                    {speaker.name}
                  </h3>
                  {speaker.is_rotarian && (
                    <BadgeCheck
                      size={14}
                      className="text-[#f7a81b] flex-shrink-0"
                      aria-label={speaker.rotary_club ? `Rotarian - ${speaker.rotary_club}` : 'Rotarian'}
                    />
                  )}
                </div>

                {/* Organization */}
                {speaker.organization && (
                  <p className="text-sm text-gray-600 mb-1 truncate">
                    {speaker.organization}
                  </p>
                )}

                {/* Topic */}
                {speaker.topic && (
                  <p className="text-sm text-gray-700 mb-2 line-clamp-2">
                    {speaker.topic}
                  </p>
                )}

                {/* Status and Date */}
                <div className="flex flex-wrap items-center gap-2">
                  {/* Status Badge */}
                  <span
                    className={`inline-flex px-2 py-0.5 text-xs font-medium rounded-full ${
                      speaker.status === 'spoken'
                        ? 'bg-gray-100 text-gray-700'
                        : speaker.status === 'scheduled'
                        ? 'bg-amber-100 text-amber-700'
                        : speaker.status === 'agreed'
                        ? 'bg-emerald-100 text-emerald-700'
                        : speaker.status === 'approached'
                        ? 'bg-blue-100 text-blue-700'
                        : speaker.status === 'ideas'
                        ? 'bg-slate-100 text-slate-700'
                        : 'bg-rose-100 text-rose-700'
                    }`}
                  >
                    {speaker.status.charAt(0).toUpperCase() + speaker.status.slice(1)}
                  </span>

                  {/* Scheduled Date */}
                  {speaker.scheduled_date && (
                    <div className="flex items-center gap-1 text-xs text-gray-600">
                      <Calendar size={12} />
                      <span>{format(new Date(speaker.scheduled_date), 'MMM d, yyyy')}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </button>
        )
      })}
    </div>
  )
}
