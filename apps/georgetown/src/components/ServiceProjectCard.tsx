/**
 * ServiceProjectCard Component
 * Displays a service project card on the timeline view
 */

import type { ServiceProject } from '../types/database'
import { getAreaOfFocusColor } from '../utils/areaOfFocusColors'
import { format, parseISO } from 'date-fns'
import { Award, Users, MapPin, Calendar } from 'lucide-react'
import ShareButton from './ShareButton'

type ServiceProjectCardProps = {
  project: ServiceProject
  onClick?: () => void
}

export default function ServiceProjectCard({ project, onClick }: ServiceProjectCardProps) {
  const areaColor = getAreaOfFocusColor(project.area_of_focus)
  const completionDate = project.completion_date
    ? format(parseISO(project.completion_date), 'MMM d, yyyy')
    : null

  return (
    <div
      onClick={onClick}
      className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 hover:shadow-md transition-shadow cursor-pointer"
    >
      {/* Header with Area of Focus Badge */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h4 className="font-semibold text-gray-900 text-sm mb-1 line-clamp-2">
            {project.project_name}
          </h4>
          <span
            className="inline-block px-2 py-1 rounded text-xs font-medium"
            style={{
              backgroundColor: `${areaColor}20`,
              color: areaColor
            }}
          >
            {project.area_of_focus}
          </span>
        </div>
        <ShareButton project={project} variant="icon-only" className="ml-2" />
      </div>

      {/* Project Details */}
      <div className="space-y-2 text-sm text-gray-600">
        {/* Completion Date */}
        {completionDate && (
          <div className="flex items-center gap-2">
            <Calendar size={14} className="text-gray-400 flex-shrink-0" />
            <span>Completed: {completionDate}</span>
          </div>
        )}

        {/* Location */}
        {project.location && (
          <div className="flex items-center gap-2">
            <MapPin size={14} className="text-gray-400 flex-shrink-0" />
            <span className="truncate">{project.location}</span>
          </div>
        )}

        {/* Beneficiaries */}
        {project.beneficiary_count && project.beneficiary_count > 0 && (
          <div className="flex items-center gap-2">
            <Users size={14} className="text-gray-400 flex-shrink-0" />
            <span>{project.beneficiary_count.toLocaleString()} beneficiaries</span>
          </div>
        )}

        {/* Project Value */}
        {project.project_value_rm && project.project_value_rm > 0 && (
          <div className="flex items-center gap-2">
            <Award size={14} className="text-gray-400 flex-shrink-0" />
            <span>
              {project.project_value_rm.toLocaleString('en-MY', {
                style: 'currency',
                currency: 'MYR',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
              })}
            </span>
          </div>
        )}
      </div>

      {/* Impact Summary */}
      {project.impact && (
        <div className="mt-3 pt-3 border-t border-gray-100">
          <p className="text-sm text-gray-600 line-clamp-2">{project.impact}</p>
        </div>
      )}

      {/* Project Lead */}
      <div className="mt-3 flex items-center justify-between">
        <span className="text-sm text-gray-500">
          Project Lead: <span className="font-medium text-gray-700">{project.champion}</span>
        </span>
        <span className="text-sm font-medium text-[#0067c8]">{project.type}</span>
      </div>

      {/* Would Repeat Indicator */}
      {project.would_repeat && (
        <div className="mt-2">
          {project.would_repeat === 'yes' && (
            <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-700">
              ✓ Would Repeat
            </span>
          )}
          {project.would_repeat === 'modified' && (
            <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-yellow-100 text-yellow-700">
              ⚠ Repeat with Changes
            </span>
          )}
          {project.would_repeat === 'no' && (
            <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-700">
              ✗ Do Not Repeat
            </span>
          )}
        </div>
      )}
    </div>
  )
}
