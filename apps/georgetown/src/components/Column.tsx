import { useDroppable } from '@dnd-kit/core'
import type { ReactNode } from 'react'

interface ColumnProps {
  id: string
  title: string
  color: string
  count: number
  children: ReactNode
  icon?: string
  onAddSpeaker?: (status: string) => void
}

export default function Column({ id, title, count, children, onAddSpeaker }: ColumnProps) {
  const { setNodeRef, isOver } = useDroppable({
    id,
  })

  const getHeaderColor = (columnId: string) => {
    const colorMap = {
      'ideas': 'text-slate-700',
      'approached': 'text-blue-700',
      'agreed': 'text-emerald-700',
      'scheduled': 'text-amber-700',
      'spoken': 'text-gray-700',
      'dropped': 'text-rose-700'
    }
    return colorMap[columnId as keyof typeof colorMap] || 'text-gray-700'
  }

  return (
    <div className="flex flex-col w-full md:w-80 flex-shrink-0 px-3 h-full md:min-h-[600px]">
      <div
        className={`flex flex-col h-full md:min-h-[500px] rounded-lg border bg-white ${
          isOver ? 'ring-2 ring-[#0067c8] ring-opacity-30 shadow-lg' : 'shadow-sm'
        } transition-all duration-200 hover:shadow-md border-gray-200`}
      >
        {/* Professional Header */}
        <div className="px-5 py-4 border-b border-gray-200 bg-white rounded-t-lg">
          <div className="flex items-center justify-between">
            <h3 className={`text-sm font-semibold uppercase tracking-wide ${getHeaderColor(id)}`}
                style={{ fontFamily: "'Open Sans', sans-serif" }}>
              {title}
            </h3>
            <div className="flex items-center gap-2">
              <span className="bg-gray-100 text-gray-600 text-xs font-medium px-2.5 py-1 rounded-full min-w-[24px] text-center">
                {count}
              </span>
            </div>
          </div>
        </div>

        {/* Content Area - Droppable zone wraps the scrollable container */}
        <div
          ref={setNodeRef}
          className="flex-1 p-4 overflow-y-auto space-y-3 custom-scrollbar min-h-0"
        >
          {/* Professional Add Button */}
          <button
            onClick={() => onAddSpeaker?.(id)}
            className="w-full py-6 md:py-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-[#0067c8] hover:bg-[#0067c8]/5 transition-all duration-200 text-gray-500 hover:text-[#0067c8] font-medium text-base md:text-sm flex items-center justify-center gap-2 group bg-white touch-manipulation">
            <svg className="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
            Add Speaker
          </button>

          {children}

          {count === 0 && (
            <div className="text-center py-12 text-gray-400 text-sm">
              <div className="mb-2 text-gray-300">
                <svg className="w-8 h-8 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                </svg>
              </div>
              Drop speakers here
            </div>
          )}

          {/* Padding at bottom to ensure drop zone extends beyond last card */}
          {count > 0 && <div className="h-32" />}
        </div>
      </div>
    </div>
  )
}