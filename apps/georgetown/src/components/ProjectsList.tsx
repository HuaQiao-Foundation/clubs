import type { ServiceProject } from '../types/database'
import { getAreaOfFocusColor } from '../utils/areaOfFocusColors'

interface ProjectsListProps {
  projects: ServiceProject[]
  onProjectClick: (project: ServiceProject) => void
}

export default function ProjectsList({ projects, onProjectClick }: ProjectsListProps) {
  return (
    <div className="space-y-3">
      {projects.map((project) => {
        return (
          <button
            key={project.id}
            onClick={() => onProjectClick(project)}
            className="w-full bg-white rounded-lg p-4 shadow hover:shadow-md transition-all text-left border border-gray-200 hover:border-[#0067c8]"
          >
            <div className="space-y-3">
              {/* Area of Focus Badge */}
              <div>
                <span
                  className="inline-block px-3 py-1 rounded-full text-xs font-semibold text-white"
                  style={{ backgroundColor: getAreaOfFocusColor(project.area_of_focus) }}
                >
                  {project.area_of_focus}
                </span>
              </div>

              {/* Project Name */}
              <h3 className="font-semibold text-gray-900 text-base md:text-lg line-clamp-2">
                {project.project_name}
              </h3>

              {/* Description (if exists) */}
              {project.description && (
                <p className="text-sm text-gray-600 line-clamp-2">
                  {project.description}
                </p>
              )}

              {/* Meta Info */}
              <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
                {/* Project Lead */}
                <div>
                  <span className="text-gray-500 text-xs">Project Lead:</span>
                  <p className="text-gray-900 font-medium truncate">{project.champion}</p>
                </div>

                {/* Type */}
                <div>
                  <span className="text-gray-500 text-xs">Type:</span>
                  <p className="text-gray-900 font-medium">{project.type}</p>
                </div>

                {/* Status */}
                <div>
                  <span className="text-gray-500 text-xs">Status:</span>
                  <p>
                    <span
                      className={`inline-flex px-2 py-0.5 text-xs font-medium rounded-full ${
                        project.status === 'Completed'
                          ? 'bg-gray-100 text-gray-700'
                          : project.status === 'Execution'
                          ? 'bg-green-100 text-green-700'
                          : project.status === 'Approved'
                          ? 'bg-blue-100 text-blue-700'
                          : project.status === 'Planning'
                          ? 'bg-yellow-100 text-yellow-700'
                          : 'bg-purple-100 text-purple-700'
                      }`}
                    >
                      {project.status}
                    </span>
                  </p>
                </div>

                {/* Project Value */}
                {project.project_value_rm && (
                  <div>
                    <span className="text-gray-500 text-xs">Value:</span>
                    <p className="text-[#0067c8] font-semibold">
                      RM {project.project_value_rm.toLocaleString()}
                    </p>
                  </div>
                )}

                {/* People Served */}
                {project.beneficiary_count && (
                  <div>
                    <span className="text-gray-500 text-xs">People Served:</span>
                    <p className="text-gray-900 font-medium">
                      {project.beneficiary_count.toLocaleString()}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </button>
        )
      })}
    </div>
  )
}
