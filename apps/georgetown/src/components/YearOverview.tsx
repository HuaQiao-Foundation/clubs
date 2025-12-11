/**
 * YearOverview Component
 * Displays comprehensive information about a Rotary year including:
 * - Club information and charter date
 * - Multi-level leadership themes (RI, DG, Club)
 * - Statistics summary
 */

import type { RotaryYear } from '../types/database'
import ThemeDisplay from './ThemeDisplay'
import { Calendar, Users, Award, TrendingUp, Edit, FileText, BookOpen, Star, AlertCircle, ArrowUp, ArrowDown, Minus } from 'lucide-react'
import { renderSimpleMarkdown } from '../utils/simpleMarkdown'

type YearOverviewProps = {
  rotaryYear: RotaryYear
  onEdit?: () => void
  canEdit: boolean
  actualSpeakerCount?: number
  actualProjectCount?: number
  previousYearMemberCount?: number
}

export default function YearOverview({
  rotaryYear,
  onEdit,
  canEdit,
  actualSpeakerCount,
  actualProjectCount,
  previousYearMemberCount
}: YearOverviewProps) {
  // Calculate member count trend
  const currentMemberCount = rotaryYear.member_count_year_end || 0
  const memberCountChange = previousYearMemberCount !== undefined
    ? currentMemberCount - previousYearMemberCount
    : null

  const getTrendIndicator = () => {
    if (memberCountChange === null || memberCountChange === 0) {
      return (
        <Minus size={16} className="text-gray-400 ml-2" />
      )
    } else if (memberCountChange > 0) {
      return (
        <div className="flex items-center gap-1 ml-2">
          <ArrowUp size={16} className="text-green-600" />
          <span className="text-xs font-semibold text-green-600">+{memberCountChange}</span>
        </div>
      )
    } else {
      return (
        <div className="flex items-center gap-1 ml-2">
          <ArrowDown size={16} className="text-red-600" />
          <span className="text-xs font-semibold text-red-600">{memberCountChange}</span>
        </div>
      )
    }
  }

  return (
    <div className="year-overview">
      {/* Leadership Themes Grid - Ordered by relevance: Local → Regional → International */}
      <div className="themes-grid mb-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Club President Theme - Most relevant to members */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-5">
            <ThemeDisplay
              level="club"
              leaderName={rotaryYear.club_president_name}
              themeName={rotaryYear.club_president_theme}
              logoUrl={rotaryYear.club_president_theme_logo_url}
              photoUrl={rotaryYear.club_president_photo_url}
            />
          </div>

          {/* District Governor Theme - Regional leadership */}
          {rotaryYear.dg_name && (
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-5">
              <ThemeDisplay
                level="dg"
                leaderName={rotaryYear.dg_name}
                themeName={rotaryYear.dg_theme}
                logoUrl={rotaryYear.dg_theme_logo_url}
                photoUrl={rotaryYear.district_governor_photo_url}
              />
            </div>
          )}

          {/* RI President Theme - International context */}
          {rotaryYear.ri_president_name && (
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-5">
              <ThemeDisplay
                level="ri"
                leaderName={rotaryYear.ri_president_name}
                themeName={rotaryYear.ri_president_theme}
                logoUrl={rotaryYear.ri_president_theme_logo_url}
              />
            </div>
          )}
        </div>
      </div>

      {/* Statistics Summary */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center gap-2 mb-4">
          <TrendingUp size={20} className="text-[#0067c8]" />
          <h3 className="text-lg font-semibold text-gray-900">Year Statistics</h3>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-6 gap-4">
          {/* Members */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Users size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">Members</span>
            </div>
            <div className="flex items-center">
              <p className="text-2xl font-bold text-[#0067c8]">{rotaryYear.member_count_year_end || 0}</p>
              {getTrendIndicator()}
            </div>
            <p className="text-xs text-gray-600 mt-1">Year end</p>
          </div>

          {/* Meetings */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Calendar size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">Meetings</span>
            </div>
            <p className="text-2xl font-bold text-[#0067c8]">{rotaryYear.stats.meetings || 0}</p>
            <p className="text-xs text-gray-600 mt-1">Total held</p>
          </div>

          {/* Speakers */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Users size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">Speakers</span>
            </div>
            <p className="text-2xl font-bold text-[#0067c8]">
              {actualSpeakerCount !== undefined ? actualSpeakerCount : (rotaryYear.stats.speakers || 0)}
            </p>
            <p className="text-xs text-gray-600 mt-1">Presented</p>
          </div>

          {/* Projects */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Award size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">Projects</span>
            </div>
            <p className="text-2xl font-bold text-[#0067c8]">
              {actualProjectCount !== undefined ? actualProjectCount : (rotaryYear.stats.projects || 0)}
            </p>
            <p className="text-xs text-gray-600 mt-1">Completed</p>
          </div>

          {/* Beneficiaries */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Users size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">People Served</span>
            </div>
            <p className="text-2xl font-bold text-[#0067c8]">
              {(rotaryYear.stats.beneficiaries || 0).toLocaleString()}
            </p>
            <p className="text-xs text-gray-600 mt-1">Beneficiaries</p>
          </div>

          {/* Project Value */}
          <div className="stat-item">
            <div className="flex items-center gap-2 mb-1">
              <Award size={16} className="text-gray-400" />
              <span className="text-xs text-gray-500 uppercase tracking-wide">Project Value</span>
            </div>
            <p className="text-2xl font-bold text-[#0067c8]">
              {(rotaryYear.stats.project_value_rm || 0).toLocaleString('en-MY', {
                style: 'currency',
                currency: 'MYR',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
              })}
            </p>
            <p className="text-xs text-gray-600 mt-1">Total value</p>
          </div>
        </div>
      </div>

      {/* Year Summary */}
      <div className="mt-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <FileText size={20} className="text-[#0067c8]" />
            <h2 className="text-xl font-bold text-gray-900">Year Summary</h2>
          </div>
          {onEdit && (
            <button
              onClick={onEdit}
              className="p-1.5 text-gray-400 hover:text-[#0067c8] hover:bg-gray-100 rounded transition-colors"
              title="Edit year narrative"
            >
              <Edit size={16} />
            </button>
          )}
        </div>

        {rotaryYear.summary ? (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="prose prose-sm max-w-none">
              <div className="text-sm text-gray-700 leading-relaxed">
                {renderSimpleMarkdown(rotaryYear.summary)}
              </div>
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="text-center py-8 text-gray-400">
              <FileText size={32} className="mx-auto mb-2 text-gray-300" />
              <p className="text-sm">No summary yet. {canEdit ? 'Click edit to add a year summary.' : ''}</p>
            </div>
          </div>
        )}
      </div>

      {/* Narrative */}
      <div className="mt-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <BookOpen size={20} className="text-[#0067c8]" />
            <h2 className="text-xl font-bold text-gray-900">Narrative</h2>
          </div>
          {onEdit && (
            <button
              onClick={onEdit}
              className="p-1.5 text-gray-400 hover:text-[#0067c8] hover:bg-gray-100 rounded transition-colors"
              title="Edit year narrative"
            >
              <Edit size={16} />
            </button>
          )}
        </div>

        {rotaryYear.narrative ? (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="prose prose-sm max-w-none">
              <div className="text-sm text-gray-700 leading-relaxed">
                {renderSimpleMarkdown(rotaryYear.narrative)}
              </div>
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="text-center py-8 text-gray-400">
              <BookOpen size={32} className="mx-auto mb-2 text-gray-300" />
              <p className="text-sm">No narrative yet. {canEdit ? 'Click edit to add the full story of this year.' : ''}</p>
            </div>
          </div>
        )}
      </div>

      {/* Highlights */}
      <div className="mt-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Star size={20} className="text-[#0067c8]" />
            <h2 className="text-xl font-bold text-gray-900">Highlights</h2>
          </div>
          {onEdit && (
            <button
              onClick={onEdit}
              className="p-1.5 text-gray-400 hover:text-[#0067c8] hover:bg-gray-100 rounded transition-colors"
              title="Edit year narrative"
            >
              <Edit size={16} />
            </button>
          )}
        </div>

        {rotaryYear.highlights && rotaryYear.highlights.length > 0 ? (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="space-y-4">
              {rotaryYear.highlights.map((highlight, index) => (
                <div key={index} className="border-l-4 border-[#0067c8] pl-4">
                  <h3 className="font-semibold text-gray-900 mb-1">{highlight.title}</h3>
                  <p className="text-sm text-gray-700 leading-relaxed">{highlight.description}</p>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="text-center py-8 text-gray-400">
              <Star size={32} className="mx-auto mb-2 text-gray-300" />
              <p className="text-sm">No highlights yet. {canEdit ? 'Click edit to add key achievements.' : ''}</p>
            </div>
          </div>
        )}
      </div>

      {/* Challenges */}
      <div className="mt-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <AlertCircle size={20} className="text-[#0067c8]" />
            <h2 className="text-xl font-bold text-gray-900">Challenges & Resolutions</h2>
          </div>
          {onEdit && (
            <button
              onClick={onEdit}
              className="p-1.5 text-gray-400 hover:text-[#0067c8] hover:bg-gray-100 rounded transition-colors"
              title="Edit year narrative"
            >
              <Edit size={16} />
            </button>
          )}
        </div>

        {rotaryYear.challenges && rotaryYear.challenges.length > 0 ? (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="space-y-4">
              {rotaryYear.challenges.map((challenge, index) => (
                <div key={index} className="border-l-4 border-gray-300 pl-4">
                  <h3 className="font-semibold text-gray-900 mb-1">{challenge.issue}</h3>
                  <p className="text-sm text-gray-700 leading-relaxed">{challenge.resolution}</p>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="text-center py-8 text-gray-400">
              <AlertCircle size={32} className="mx-auto mb-2 text-gray-300" />
              <p className="text-sm">No challenges recorded yet. {canEdit ? 'Click edit to document lessons learned.' : ''}</p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
