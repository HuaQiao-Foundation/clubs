import { useNavigate } from 'react-router-dom'
import { Plus, Filter } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import type { ReactNode } from 'react'

interface ViewConfig {
  id: string
  label: string
  icon: LucideIcon
  desktopOnly?: boolean
}

interface AppHeaderProps {
  sectionName: string
  onAddClick?: () => void
  addButtonLabel?: string
  showAddButton?: boolean
  views?: ViewConfig[]
  activeView?: string
  onViewChange?: (view: string) => void
  showFiltersToggle?: boolean
  filtersExpanded?: boolean
  onFiltersToggle?: () => void
  headerInfo?: ReactNode
}

export default function AppHeader({
  sectionName,
  onAddClick,
  addButtonLabel = 'Add',
  showAddButton = false,
  views,
  activeView,
  onViewChange,
  showFiltersToggle = false,
  filtersExpanded = false,
  onFiltersToggle,
  headerInfo,
}: AppHeaderProps) {
  const navigate = useNavigate()
  const hasViews = views && views.length > 0 && activeView && onViewChange

  return (
    <header className="bg-[#0067c8] text-white px-4 py-3 sticky top-0 z-40 shadow-md">
      <div className="flex items-center justify-between max-w-7xl mx-auto gap-4">
        {/* Left: Logo + Club Name + Section */}
        <div className="flex items-center gap-3 flex-shrink-0">
          <button
            onClick={() => navigate('/')}
            className="hover:opacity-80 transition-opacity"
            aria-label="Return to Dashboard"
          >
            <img
              src="/assets/images/logos/RotaryMBS-Simple_REV.svg"
              alt="Rotary Logo"
              className="h-8 md:h-10"
            />
          </button>
          <div>
            <p
              className="text-[10px] md:text-xs uppercase tracking-wide opacity-90 leading-tight"
              style={{ fontFamily: "'Open Sans', sans-serif" }}
            >
              Georgetown Rotary Club
            </p>
            <h1
              className="text-lg md:text-2xl font-bold tracking-tight leading-tight"
              style={{ fontFamily: "'Open Sans Condensed', sans-serif" }}
            >
              {sectionName}
            </h1>
          </div>
        </div>

        {/* Right: Custom Header Info OR View Switcher + Add Button */}
        <div className="flex items-center gap-2 md:gap-3">
          {/* Custom Header Info (optional) */}
          {headerInfo && (
            <div className="mr-2 md:mr-4">
              {headerInfo}
            </div>
          )}
          {/* View Switcher (inline in header) */}
          {hasViews && (
            <div className="flex gap-2">
              {views.map((view) => {
                const Icon = view.icon
                const isActive = activeView === view.id

                // Hide desktop-only views on mobile
                if (view.desktopOnly) {
                  return (
                    <button
                      key={view.id}
                      onClick={() => onViewChange(view.id)}
                      className={`hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-md transition-all min-h-[36px] ${
                        isActive
                          ? 'bg-white/20 text-white border border-white/30'
                          : 'text-white/70 hover:text-white hover:bg-white/10 border border-transparent'
                      }`}
                      aria-label={`Switch to ${view.label} view`}
                    >
                      <Icon size={16} />
                      <span className="text-sm">{view.label}</span>
                    </button>
                  )
                }

                return (
                  <button
                    key={view.id}
                    onClick={() => onViewChange(view.id)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md transition-all min-h-[44px] md:min-h-[36px] ${
                      isActive
                        ? 'bg-white/20 text-white border border-white/30'
                        : 'text-white/70 hover:text-white hover:bg-white/10 border border-transparent'
                    }`}
                    aria-label={`Switch to ${view.label} view`}
                  >
                    <Icon size={16} />
                    <span className="text-sm">{view.label}</span>
                  </button>
                )
              })}
            </div>
          )}

          {/* Filters Toggle Button */}
          {showFiltersToggle && onFiltersToggle && (
            <button
              onClick={onFiltersToggle}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md transition-all min-h-[44px] md:min-h-[36px] ${
                filtersExpanded
                  ? 'bg-white/20 text-white border border-white/30'
                  : 'text-white/70 hover:text-white hover:bg-white/10 border border-transparent'
              }`}
              aria-label="Toggle filters"
            >
              <Filter size={16} />
              <span className="text-sm">Filters</span>
            </button>
          )}

          {/* + Button */}
          {showAddButton && onAddClick && (
            <button
              onClick={onAddClick}
              className="p-2.5 bg-[#f7a81b] hover:bg-[#f4b000] text-[#0067c8] rounded-lg transition-all duration-200 shadow-md hover:shadow-lg border border-[#f7a81b] min-w-[44px] min-h-[44px] flex items-center justify-center"
              aria-label={addButtonLabel}
              title={addButtonLabel}
            >
              <Plus size={20} strokeWidth={2.5} />
              <span className="hidden md:inline-block ml-1 text-sm font-semibold">
                {addButtonLabel.replace('+ ', '')}
              </span>
            </button>
          )}
        </div>
      </div>
    </header>
  )
}
