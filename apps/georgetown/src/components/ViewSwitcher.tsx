import type { LucideIcon } from 'lucide-react'

interface ViewConfig {
  id: string
  label: string
  icon: LucideIcon
  desktopOnly?: boolean
}

interface ViewSwitcherProps {
  views: ViewConfig[]
  activeView: string
  onViewChange: (viewId: string) => void
}

export default function ViewSwitcher({
  views,
  activeView,
  onViewChange,
}: ViewSwitcherProps) {
  return (
    <div className="bg-white border-b border-gray-200 px-4 py-2 sticky top-[72px] md:top-[64px] z-30">
      <div className="flex items-center gap-2 max-w-7xl mx-auto overflow-x-auto">
        {views.map((view) => {
          const Icon = view.icon
          const isActive = activeView === view.id
          const isDesktopOnly = view.desktopOnly

          // Hide desktop-only views on mobile/tablet
          if (isDesktopOnly) {
            return (
              <button
                key={view.id}
                onClick={() => onViewChange(view.id)}
                className={`hidden md:flex items-center gap-2 px-4 py-2 rounded-lg transition-all duration-200 text-sm font-medium whitespace-nowrap ${
                  isActive
                    ? 'bg-[#0067c8] text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
                aria-label={view.label}
                aria-current={isActive ? 'page' : undefined}
              >
                <Icon size={18} strokeWidth={2} />
                <span>{view.label}</span>
              </button>
            )
          }

          return (
            <button
              key={view.id}
              onClick={() => onViewChange(view.id)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all duration-200 text-sm font-medium whitespace-nowrap ${
                isActive
                  ? 'bg-[#0067c8] text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
              aria-label={view.label}
              aria-current={isActive ? 'page' : undefined}
            >
              <Icon size={18} strokeWidth={2} />
              <span>{view.label}</span>
            </button>
          )
        })}

        {/* Desktop-only table view hint for mobile users */}
        {views.some((v) => v.desktopOnly) && (
          <div className="md:hidden ml-auto text-xs text-gray-500 whitespace-nowrap">
            🖥️ Table view on desktop
          </div>
        )}
      </div>
    </div>
  )
}
