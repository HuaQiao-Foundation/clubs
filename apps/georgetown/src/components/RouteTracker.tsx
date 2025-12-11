import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import { trackPageView } from '../utils/analytics'

/**
 * RouteTracker Component
 *
 * Automatically tracks page views on route changes.
 * Must be placed inside Router context.
 */
export default function RouteTracker() {
  const location = useLocation()

  useEffect(() => {
    // Track page view on route change
    const pagePath = location.pathname
    const pageTitle = getPageTitle(pagePath)

    trackPageView(pagePath, pageTitle)
  }, [location])

  // This component doesn't render anything
  return null
}

/**
 * Map route paths to human-readable page titles
 */
function getPageTitle(path: string): string {
  const titleMap: Record<string, string> = {
    '/': 'Dashboard',
    '/about': 'About',
    '/members': 'Member Directory',
    '/calendar': 'Calendar',
    '/projects': 'Service Projects',
    '/speakers': 'Speaker Board',
    '/timeline': 'Timeline',
    '/photos': 'Photo Gallery',
    '/partners': 'Partners',
    '/impact': 'Impact',
    '/speakers-bureau': 'Speaker Bureau',
    '/events-list': 'Events List',
    '/availability': 'Availability',
  }

  return titleMap[path] || path
}
