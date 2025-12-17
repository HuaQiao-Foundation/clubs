import { useState } from 'react'
import { X, Edit, MapPin, Users, Calendar, DollarSign, Target } from 'lucide-react'
import type { ServiceProject } from '../types/database'
import { getAreaOfFocusColor, getAreaOfFocusLabel } from '../utils/areaOfFocusColors'
import { format } from 'date-fns'
import ServiceProjectModal from './ServiceProjectModal'
import ShareButton from './ShareButton'

interface ServiceProjectDetailModalProps {
  project: ServiceProject
  onClose: () => void
}

export default function ServiceProjectDetailModal({
  project,
  onClose,
}: ServiceProjectDetailModalProps) {
  const [isEditMode, setIsEditMode] = useState(false)

  const handleEditClose = () => {
    setIsEditMode(false)
    // Optionally refresh the data or close the modal completely
    // For now, return to view mode
  }

  if (isEditMode) {
    return <ServiceProjectModal project={project} onClose={handleEditClose} />
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 overflow-y-auto">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header Bar - Always Visible */}
        <div className="bg-[#0067c8] text-white px-6 py-4 rounded-t-lg flex items-center justify-between sticky top-0 z-10">
          <div className="flex items-center gap-3">
            <Target size={24} className="text-white" />
            <h2 className="text-xl font-bold">Project Details</h2>
          </div>
          <div className="flex items-center gap-2">
            <ShareButton project={project} variant="default" />
            <button
              onClick={() => setIsEditMode(true)}
              className="flex items-center gap-2 px-4 py-2 bg-white/10 hover:bg-white/20 rounded-lg transition-colors"
              title="Edit project"
            >
              <Edit size={18} />
              <span className="text-sm font-medium">Edit</span>
            </button>
            <button
              onClick={onClose}
              className="p-2 hover:bg-white/20 rounded-lg transition-colors"
              title="Close"
            >
              <X size={20} />
            </button>
          </div>
        </div>

        {/* Project Image or Fallback */}
        {project.image_url ? (
          <img
            src={project.image_url}
            alt={project.project_name}
            className="w-full h-64 object-cover"
            style={{ objectPosition: project.image_position || 'center' }}
          />
        ) : (
          <div
            className="w-full h-64 flex items-center justify-center"
            style={{ backgroundColor: getAreaOfFocusColor(project.area_of_focus) }}
          >
            <div className="text-white text-9xl font-bold opacity-30">
              {project.project_name.charAt(0).toUpperCase()}
            </div>
          </div>
        )}

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Title and Area of Focus */}
          <div>
            <div className="mb-3">
              <span
                className="inline-block px-3 py-1.5 rounded-lg text-sm font-semibold text-white"
                style={{ backgroundColor: getAreaOfFocusColor(project.area_of_focus) }}
              >
                {getAreaOfFocusLabel(project.area_of_focus)}
              </span>
            </div>
            <div className="flex items-start justify-between gap-4">
              <h1 className="text-3xl font-bold text-gray-900 flex-1">
                {project.project_name}
              </h1>
              <span
                className={`px-4 py-2 rounded-full text-sm font-bold uppercase tracking-wide flex-shrink-0 ${
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

            {/* Description */}
            {project.description && (
              <div className="mt-2">
                <h3 className="text-sm font-semibold text-gray-700 mb-2">Description</h3>
                <p className="text-gray-600 leading-relaxed">{project.description}</p>
              </div>
            )}
          </div>

          {/* Key Details Grid */}
          <div className="grid md:grid-cols-2 gap-4">
            {/* Project Lead */}
            <div className="flex items-start space-x-3">
              <Users className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm text-gray-500">Project Lead</div>
                <div className="font-semibold text-gray-900">{project.champion}</div>
              </div>
            </div>

            {/* Dates */}
            <div className="flex items-start space-x-3">
              <Calendar className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm text-gray-500">Timeline</div>
                <div className="font-semibold text-gray-900">
                  {format(new Date(project.start_date), 'MMM d, yyyy')}
                  {project.end_date && ` - ${format(new Date(project.end_date), 'MMM d, yyyy')}`}
                </div>
                {project.project_year && (
                  <div className="text-sm text-gray-600">FY {project.project_year}</div>
                )}
              </div>
            </div>

            {/* Location */}
            {project.location && (
              <div className="flex items-start space-x-3">
                <MapPin className="w-5 h-5 text-gray-400 mt-0.5" />
                <div>
                  <div className="text-sm text-gray-500">Location</div>
                  <div className="font-semibold text-gray-900">{project.location}</div>
                </div>
              </div>
            )}

            {/* Project Value */}
            {project.project_value_rm && (
              <div className="flex items-start space-x-3">
                <DollarSign className="w-5 h-5 text-gray-400 mt-0.5" />
                <div>
                  <div className="text-sm text-gray-500">Project Value</div>
                  <div className="font-semibold text-azure text-lg">
                    RM {project.project_value_rm.toLocaleString()}
                  </div>
                </div>
              </div>
            )}

            {/* Beneficiaries */}
            {project.beneficiary_count && (
              <div className="flex items-start space-x-3">
                <Target className="w-5 h-5 text-gray-400 mt-0.5" />
                <div>
                  <div className="text-sm text-gray-500">Beneficiaries</div>
                  <div className="font-semibold text-gray-900">
                    {project.beneficiary_count.toLocaleString()} people
                  </div>
                </div>
              </div>
            )}

            {/* Project Type */}
            <div className="flex items-start space-x-3">
              <div className="w-5 h-5 text-gray-400 mt-0.5 flex items-center justify-center text-xs font-bold">
                T
              </div>
              <div>
                <div className="text-sm text-gray-500">Project Type</div>
                <div className="font-semibold text-gray-900">
                  {project.type}
                </div>
              </div>
            </div>

            {/* Partners */}
            {project.partners && project.partners.length > 0 && (
              <div className="flex items-start space-x-3">
                <Users className="w-5 h-5 text-gray-400 mt-0.5" />
                <div>
                  <div className="text-sm text-gray-500">Partners</div>
                  <div className="flex flex-wrap gap-2 mt-1">
                    {project.partners.map((partner) => (
                      <div
                        key={partner.id}
                        className="px-2 py-1 bg-gray-50 border border-gray-200 rounded text-xs"
                      >
                        <div className="font-medium text-gray-900">{partner.name}</div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Grant Number - only for Global Grants */}
            {project.type === 'Global Grant' && project.grant_number && (
              <div className="flex items-start space-x-3">
                <div className="w-5 h-5 text-gray-400 mt-0.5 flex items-center justify-center text-xs font-bold">
                  #
                </div>
                <div>
                  <div className="text-sm text-gray-500">TRF Grant Number</div>
                  <div className="font-semibold text-gray-900">{project.grant_number}</div>
                </div>
              </div>
            )}
          </div>

          {/* Impact */}
          {project.impact && (
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">Impact</h3>
              <div className="bg-blue-50 p-4 rounded-lg border-l-4 border-azure">
                <p className="text-gray-700 whitespace-pre-wrap">{project.impact}</p>
              </div>
            </div>
          )}

          {/* Notes */}
          {project.notes && (
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">Notes</h3>
              <div className="bg-gray-50 p-4 rounded-lg">
                <p className="text-gray-700 whitespace-pre-wrap">{project.notes}</p>
              </div>
            </div>
          )}

          {/* Created By */}
          {project.created_by && (
            <div className="pt-4 border-t text-sm text-gray-500">
              Created by {project.created_by} on{' '}
              {format(new Date(project.created_at), 'MMM d, yyyy')}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
