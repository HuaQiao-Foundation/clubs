import type { ServiceProject } from '../types/database'
import { Pencil } from 'lucide-react'
import { getAreaOfFocusColor } from '../utils/areaOfFocusColors'
import ShareButton from './ShareButton'

interface ServiceProjectPageCardProps {
  project: ServiceProject
  onClick: (project: ServiceProject) => void
  onEdit: (project: ServiceProject) => void
}

export default function ServiceProjectPageCard({ project, onClick, onEdit }: ServiceProjectPageCardProps) {
  const handleCardClick = () => {
    onClick(project)
  }

  const handleEditClick = (e: React.MouseEvent) => {
    e.stopPropagation()
    onEdit(project)
  }

  return (
    <div
      onClick={handleCardClick}
      className="bg-white border border-gray-200 rounded-lg overflow-hidden hover:shadow-lg cursor-pointer transition-shadow relative group"
    >
      {/* Edit Button - Top Right */}
      <div className="absolute top-2 right-2 z-10">
        <button
          onClick={handleEditClick}
          className="p-2 bg-white hover:bg-gray-50 rounded-full shadow-md border border-gray-200 transition-all"
          aria-label="Edit project"
          title="Edit project"
        >
          <Pencil size={16} className="text-gray-400 hover:text-[#0067c8] transition-colors" />
        </button>
      </div>

      {/* Image */}
      {project.image_url ? (
        <img
          src={project.image_url}
          alt={project.project_name}
          className="w-full h-64 object-cover"
          style={{ objectPosition: project.image_position || 'center' }}
        />
      ) : (
        <div
          className="w-full h-64 flex items-center justify-center text-white text-6xl font-bold"
          style={{ backgroundColor: getAreaOfFocusColor(project.area_of_focus) }}
        >
          {project.project_name.charAt(0).toUpperCase()}
        </div>
      )}

      {/* Content */}
      <div className="p-4">
        {/* Area of Focus Badge */}
        <div className="mb-2">
          <span
            className="inline-block px-2 py-1 rounded text-xs font-semibold text-white"
            style={{ backgroundColor: getAreaOfFocusColor(project.area_of_focus) }}
          >
            {project.area_of_focus}
          </span>
        </div>

        {/* Title */}
        <h3 className="font-bold text-gray-900 mb-2 line-clamp-2">
          {project.project_name}
        </h3>

        {/* Description */}
        {project.description && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
            {project.description}
          </p>
        )}

        {/* Meta Info */}
        <div className="flex flex-wrap gap-2 text-xs text-gray-500 mb-3">
          <span className="px-2 py-1 bg-gray-100 rounded">
            {project.type}
          </span>
          {project.project_year && (
            <span className="px-2 py-1 bg-gray-100 rounded">
              {project.project_year}
            </span>
          )}
        </div>

        {/* Project Lead */}
        <div className="text-sm mb-2">
          <span className="text-gray-500">Project Lead:</span>{' '}
          <span className="font-medium text-gray-900">{project.champion}</span>
        </div>

        {/* Partners */}
        <div className="text-sm mb-2">
          <span className="text-gray-500">Partners:</span>{' '}
          {project.partners && project.partners.length > 0 ? (
            <span className="font-medium text-gray-700">
              {project.partners.map((p) => p.name).join(', ')}
            </span>
          ) : (
            <span className="text-gray-400 italic">None</span>
          )}
        </div>

        {/* Value */}
        {project.project_value_rm && (
          <div className="mt-2 mb-10 text-sm font-semibold text-[#0067c8]">
            RM {project.project_value_rm.toLocaleString()}
          </div>
        )}
      </div>

      {/* Status - Bottom Left */}
      <div className="absolute z-10" style={{ bottom: '8px', left: '8px' }}>
        <span
          className={`inline-block px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide ${
            project.status === 'Completed'
              ? 'bg-green-100 text-green-800'
              : project.status === 'Execution'
              ? 'bg-blue-100 text-blue-800'
              : project.status === 'Planning'
              ? 'bg-yellow-100 text-yellow-800'
              : project.status === 'Dropped'
              ? 'bg-red-100 text-red-800'
              : 'bg-gray-100 text-gray-800'
          }`}
        >
          {project.status}
        </span>
      </div>

      {/* Share Button - Bottom Right (subtle, no extra spacing) */}
      <div className="absolute z-10" style={{ bottom: '8px', right: '8px' }}>
        <ShareButton
          project={project}
          variant="icon-only"
          className="min-h-[36px] min-w-[36px] p-2 hover:bg-white/80 rounded-md transition-colors !border-0 !shadow-none !bg-transparent opacity-60 hover:opacity-100"
        />
      </div>
    </div>
  )
}
