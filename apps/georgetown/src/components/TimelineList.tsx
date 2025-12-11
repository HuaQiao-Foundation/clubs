import type { RotaryYear } from '../types/database'
import { ChevronRight } from 'lucide-react'

interface TimelineListProps {
  rotaryYears: RotaryYear[]
  onYearClick: (year: RotaryYear) => void
}

export default function TimelineList({ rotaryYears, onYearClick }: TimelineListProps) {
  return (
    <div className="space-y-4">
      {rotaryYears.map((year) => {
        return (
          <button
            key={year.id}
            onClick={() => onYearClick(year)}
            className="w-full bg-white rounded-lg p-5 shadow hover:shadow-lg transition-all text-left border border-gray-200 hover:border-[#0067c8]"
          >
            {/* Rotary Year Header */}
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl md:text-2xl font-bold text-[#0067c8]">
                {year.rotary_year}
              </h3>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>

            {/* Leadership Section */}
            <div className="space-y-3 mb-4">
              {/* Club President */}
              {year.club_president_name && (
                <div className="flex items-center gap-3">
                  {year.club_president_photo_url && (
                    <img
                      src={year.club_president_photo_url}
                      alt={year.club_president_name}
                      className="w-10 h-10 rounded-full object-cover border-2 border-[#0067c8]"
                    />
                  )}
                  <div>
                    <p className="text-xs text-gray-500">Club President</p>
                    <p className="text-sm font-medium text-gray-900">
                      {year.club_president_name}
                    </p>
                  </div>
                </div>
              )}

              {/* RI President Theme */}
              {year.ri_president_theme && (
                <div className="flex items-center gap-3">
                  {year.ri_president_theme_logo_url && (
                    <img
                      src={year.ri_president_theme_logo_url}
                      alt="RI Theme"
                      className="w-10 h-10 object-contain"
                    />
                  )}
                  <div>
                    <p className="text-xs text-gray-500">RI President</p>
                    <p className="text-sm font-medium text-gray-900">
                      {year.ri_president_name}
                    </p>
                    <p className="text-xs text-gray-600 italic">
                      "{year.ri_president_theme}"
                    </p>
                  </div>
                </div>
              )}
            </div>

            {/* Key Statistics */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-3 border-t border-gray-200">
              {year.stats?.meetings !== null && year.stats?.meetings !== undefined && (
                <div>
                  <p className="text-xs text-gray-500">Meetings</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {year.stats.meetings}
                  </p>
                </div>
              )}

              {year.stats?.speakers !== null && year.stats?.speakers !== undefined && (
                <div>
                  <p className="text-xs text-gray-500">Speakers</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {year.stats.speakers}
                  </p>
                </div>
              )}

              {year.stats?.projects !== null && year.stats?.projects !== undefined && (
                <div>
                  <p className="text-xs text-gray-500">Projects</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {year.stats.projects}
                  </p>
                </div>
              )}

              {year.stats?.project_value_rm !== null && year.stats?.project_value_rm !== undefined && (
                <div>
                  <p className="text-xs text-gray-500">Value</p>
                  <p className="text-lg font-semibold text-[#0067c8]">
                    RM {year.stats.project_value_rm.toLocaleString()}
                  </p>
                </div>
              )}

              {year.stats?.beneficiaries !== null && year.stats?.beneficiaries !== undefined && (
                <div className="col-span-2">
                  <p className="text-xs text-gray-500">People Served</p>
                  <p className="text-lg font-semibold text-gray-900">
                    {year.stats.beneficiaries.toLocaleString()}
                  </p>
                </div>
              )}
            </div>
          </button>
        )
      })}
    </div>
  )
}
