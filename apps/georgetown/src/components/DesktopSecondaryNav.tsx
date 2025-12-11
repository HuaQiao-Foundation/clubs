import { Link, useLocation } from 'react-router-dom'
import { BarChart3, Handshake } from 'lucide-react'

const secondaryNavItems = [
  { path: '/impact', icon: BarChart3, label: 'Impact' },
  { path: '/partners', icon: Handshake, label: 'Partners' },
]

export default function DesktopSecondaryNav() {
  const location = useLocation()

  return (
    <div className="hidden lg:flex items-center gap-2 absolute top-4 right-20 z-10">
      {secondaryNavItems.map((item) => {
        const isActive = location.pathname === item.path
        const Icon = item.icon

        return (
          <Link
            key={item.path}
            to={item.path}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all duration-200 text-sm font-medium ${
              isActive
                ? 'bg-white/20 text-white'
                : 'bg-white/10 text-white/90 hover:bg-white/20 hover:text-white'
            }`}
            aria-label={item.label}
            aria-current={isActive ? 'page' : undefined}
          >
            <Icon size={16} strokeWidth={2} />
            <span>{item.label}</span>
          </Link>
        )
      })}
    </div>
  )
}
