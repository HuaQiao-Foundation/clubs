import { Link, useLocation } from 'react-router-dom'
import { Users, Calendar, Target, Mic, Clock, Handshake } from 'lucide-react'

const navItems = [
  { path: '/members', icon: Users, label: 'Members' },
  { path: '/calendar', icon: Calendar, label: 'Calendar' },
  { path: '/speakers', icon: Mic, label: 'Speakers' },
  { path: '/projects', icon: Target, label: 'Projects' },
  { path: '/partners', icon: Handshake, label: 'Partners' },
  { path: '/timeline', icon: Clock, label: 'Timeline' },
]

export default function BottomNav() {
  const location = useLocation()

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-[#0067c8] border-t border-[#0056a8] z-50 h-16 safe-area-inset-bottom shadow-lg">
      <div className="flex items-center justify-around h-full max-w-7xl mx-auto px-2">
        {navItems.map((item) => {
          // Check if current path matches this nav item
          // For Calendar, also include /events-list as active
          const isActive = location.pathname === item.path ||
            (item.path === '/calendar' && location.pathname === '/events-list')
          const Icon = item.icon

          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex flex-col items-center justify-center gap-1 px-2 sm:px-3 py-2 rounded-lg transition-all duration-200 min-w-[60px] relative ${
                isActive
                  ? 'text-white bg-white/20'
                  : 'text-white/70 hover:text-white hover:bg-white/10'
              }`}
              aria-label={item.label}
              aria-current={isActive ? 'page' : undefined}
            >
              {isActive && (
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-1 bg-[#f7a81b] rounded-b-full" />
              )}
              <Icon
                size={20}
                strokeWidth={2}
              />
              <span className="text-[10px] sm:text-xs font-medium leading-tight">
                {item.label}
              </span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
