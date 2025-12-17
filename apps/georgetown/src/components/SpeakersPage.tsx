import { Outlet } from 'react-router-dom'
import KanbanBoard from './KanbanBoard'

/**
 * Page wrapper for speakers section
 * Renders Kanban board + outlet for modal routes
 *
 * This enables hybrid modal + URL routing:
 * - /speakers → Shows board only
 * - /speakers/:id → Shows board + detail modal (via Outlet)
 * - /speakers/:id/edit → Shows board + edit modal (via Outlet)
 */
export default function SpeakersPage() {
  return (
    <>
      {/* Board - always visible */}
      <KanbanBoard />

      {/* Modal outlet - renders child routes (detail/edit modals) */}
      <Outlet />
    </>
  )
}
