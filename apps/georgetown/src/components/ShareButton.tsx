/**
 * ShareButton Component
 * Web Share API button with clipboard fallback
 *
 * Variants:
 * - default: Button with icon and text
 * - icon-only: Icon only (for cards)
 *
 * Follows Georgetown patterns:
 * - Tailwind CSS only (inline classes)
 * - Lucide React icons
 * - Existing Toast component integration
 * - i18next translations
 * - Umami analytics tracking
 */

import { useState, useCallback } from 'react'
import { Share2 } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import Toast from './Toast'
import { shareProject, generateProjectUrl } from '../utils/shareHelpers'
import type { ServiceProject } from '../types/database'

interface ShareButtonProps {
  project: ServiceProject
  variant?: 'default' | 'icon-only'
  className?: string
}

export default function ShareButton({
  project,
  variant = 'default',
  className = ''
}: ShareButtonProps) {
  const { t } = useTranslation()
  const [toast, setToast] = useState<{
    show: boolean
    type: 'success' | 'error' | 'info'
    message: string
  }>({
    show: false,
    type: 'success',
    message: '',
  })

  const handleShare = useCallback(async (e: React.MouseEvent) => {
    e.stopPropagation()

    const shareUrl = generateProjectUrl(project.id)
    const shareData = {
      title: project.project_name,
      text: project.description?.substring(0, 150) || `${project.area_of_focus} project`,
      url: shareUrl,
    }

    await shareProject(
      shareData,
      (method) => {
        if (method === 'clipboard') {
          setToast({
            show: true,
            type: 'success',
            message: t('share.link_copied'),
          })
        }
      },
      () => {
        setToast({
          show: true,
          type: 'error',
          message: t('share.copy_failed'),
        })
      }
    )
  }, [project, t])

  const handleToastClose = useCallback(() => {
    setToast((prev) => ({ ...prev, show: false }))
  }, [])

  const baseClasses = `
    inline-flex items-center justify-center gap-2
    bg-white border border-gray-300
    rounded-lg transition-all
    hover:bg-gray-50 hover:border-gray-400
    focus-visible:outline focus-visible:outline-2
    focus-visible:outline-offset-2 focus-visible:outline-[#f7a81b]
    active:bg-gray-100
    touch-manipulation
  `

  const variantClasses = {
    default: 'px-4 py-2 min-h-[44px] text-sm font-medium text-gray-700',
    'icon-only': 'p-2 min-h-[44px] min-w-[44px] text-gray-600',
  }

  return (
    <>
      <button
        onClick={handleShare}
        className={`${baseClasses} ${variantClasses[variant]} ${className}`}
        aria-label={t('share.share_project')}
        title={t('share.share_project')}
      >
        <Share2 size={18} className="flex-shrink-0" />
        {variant === 'default' && (
          <span className="hidden md:inline">{t('share.share')}</span>
        )}
      </button>

      {toast.show && (
        <Toast
          type={toast.type}
          message={toast.message}
          onClose={handleToastClose}
          duration={5000}
        />
      )}
    </>
  )
}
