/**
 * BottomNavSettings Component
 * Modal for customizing bottom navigation items
 *
 * Features:
 * - Drag-and-drop reordering of selected items
 * - Add/remove items (max 5)
 * - Real-time preview
 * - Touch-friendly interface (44px minimum targets)
 * - Rotary brand styling
 */

import { useState, useEffect } from 'react'
import { X, GripVertical, Plus, Minus, Check } from 'lucide-react'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core'
import type { DragEndEvent } from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { useBottomNavConfig, type NavItem } from '../hooks/useBottomNavConfig'

interface BottomNavSettingsProps {
  isOpen: boolean
  onClose: () => void
}

interface SortableNavItemProps {
  item: NavItem
  onRemove: (id: string) => void
}

function SortableNavItem({ item, onRemove }: SortableNavItemProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: item.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  }

  const Icon = item.icon

  return (
    <div
      ref={setNodeRef}
      style={style}
      className="flex items-center gap-3 bg-white border border-gray-200 rounded-lg p-3 touch-manipulation"
    >
      {/* Drag Handle */}
      <button
        type="button"
        className="touch-manipulation cursor-grab active:cursor-grabbing text-gray-400 hover:text-gray-600"
        {...attributes}
        {...listeners}
      >
        <GripVertical size={20} />
      </button>

      {/* Icon and Label */}
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-[#0067c8]/10 flex items-center justify-center">
          <Icon size={20} className="text-[#0067c8]" />
        </div>
        <span className="font-medium text-gray-900 truncate">{item.label}</span>
      </div>

      {/* Remove Button */}
      <button
        type="button"
        onClick={() => onRemove(item.id)}
        className="flex-shrink-0 w-10 h-10 flex items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 transition-colors touch-manipulation"
        aria-label={`Remove ${item.label}`}
      >
        <Minus size={20} />
      </button>
    </div>
  )
}

export default function BottomNavSettings({ isOpen, onClose }: BottomNavSettingsProps) {
  const {
    selectedNavItems,
    availableNavItems,
    selectedItemIds,
    updateSelectedItems,
    maxItemsReached,
    maxItems,
  } = useBottomNavConfig()

  const [workingItemIds, setWorkingItemIds] = useState<string[]>(selectedItemIds)

  // Reset working state when modal opens
  useEffect(() => {
    if (isOpen) {
      setWorkingItemIds(selectedItemIds)
    }
  }, [isOpen, selectedItemIds])

  // Configure drag-and-drop sensors
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // 8px movement required before drag starts
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event

    if (over && active.id !== over.id) {
      setWorkingItemIds((items) => {
        const oldIndex = items.indexOf(active.id as string)
        const newIndex = items.indexOf(over.id as string)
        return arrayMove(items, oldIndex, newIndex)
      })
    }
  }

  const handleRemove = (id: string) => {
    setWorkingItemIds((items) => items.filter((itemId) => itemId !== id))
  }

  const handleAdd = (id: string) => {
    if (workingItemIds.length < maxItems) {
      setWorkingItemIds((items) => [...items, id])
    }
  }

  const handleSave = () => {
    updateSelectedItems(workingItemIds)
    onClose()
  }

  const handleCancel = () => {
    setWorkingItemIds(selectedItemIds)
    onClose()
  }

  if (!isOpen) return null

  const workingItems = workingItemIds
    .map(id => selectedNavItems.find(item => item.id === id) || availableNavItems.find(item => item.id === id))
    .filter((item): item is NavItem => item !== undefined)

  const remainingAvailableItems = availableNavItems.filter(
    item => !workingItemIds.includes(item.id)
  )

  return (
    <div className="fixed inset-0 z-[100] flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={handleCancel}
      />

      {/* Modal */}
      <div className="relative w-full sm:max-w-lg bg-white sm:rounded-2xl shadow-2xl max-h-[90vh] flex flex-col overflow-hidden animate-slide-up sm:animate-scale-in rounded-t-2xl">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
          <h2 className="text-xl font-bold text-gray-900">
            Customize Navigation
          </h2>
          <button
            onClick={handleCancel}
            className="w-10 h-10 flex items-center justify-center rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors touch-manipulation"
            aria-label="Close"
          >
            <X size={24} />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          {/* Instructions */}
          <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-900">
              Select up to {maxItems} items and drag to reorder. Changes are saved when you tap Done.
            </p>
          </div>

          {/* Selected Items (Sortable) */}
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">
              Selected Items ({workingItemIds.length}/{maxItems})
            </h3>

            {workingItems.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                No items selected. Add items from below.
              </div>
            ) : (
              <DndContext
                sensors={sensors}
                collisionDetection={closestCenter}
                onDragEnd={handleDragEnd}
              >
                <SortableContext
                  items={workingItemIds}
                  strategy={verticalListSortingStrategy}
                >
                  <div className="space-y-2">
                    {workingItems.map((item) => (
                      <SortableNavItem
                        key={item.id}
                        item={item}
                        onRemove={handleRemove}
                      />
                    ))}
                  </div>
                </SortableContext>
              </DndContext>
            )}
          </div>

          {/* Available Items */}
          {remainingAvailableItems.length > 0 && (
            <div>
              <h3 className="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">
                Available Items
              </h3>
              <div className="space-y-2">
                {remainingAvailableItems.map((item) => {
                  const Icon = item.icon
                  const isDisabled = maxItemsReached && !workingItemIds.includes(item.id)

                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => handleAdd(item.id)}
                      disabled={isDisabled}
                      className={`w-full flex items-center gap-3 p-3 rounded-lg border transition-all touch-manipulation ${
                        isDisabled
                          ? 'border-gray-200 bg-gray-50 opacity-50 cursor-not-allowed'
                          : 'border-gray-200 bg-white hover:border-[#0067c8] hover:bg-[#0067c8]/5'
                      }`}
                    >
                      <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-[#0067c8]/10 flex items-center justify-center">
                        <Icon size={20} className="text-[#0067c8]" />
                      </div>
                      <span className="flex-1 text-left font-medium text-gray-900">
                        {item.label}
                      </span>
                      <Plus size={20} className="text-gray-400" />
                    </button>
                  )
                })}
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex gap-3 px-6 py-4 border-t border-gray-200 bg-gray-50">
          <button
            onClick={handleCancel}
            className="flex-1 min-h-[44px] px-4 py-2.5 rounded-lg font-semibold text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 transition-colors touch-manipulation"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={workingItemIds.length === 0}
            className="flex-1 min-h-[44px] px-4 py-2.5 rounded-lg font-semibold text-white bg-[#0067c8] hover:bg-[#0056a8] disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors touch-manipulation flex items-center justify-center gap-2"
          >
            <Check size={20} />
            Done
          </button>
        </div>
      </div>
    </div>
  )
}
