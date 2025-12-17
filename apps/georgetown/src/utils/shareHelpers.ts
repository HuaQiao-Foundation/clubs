/**
 * Web Share API utilities for Georgetown Rotary Club
 * Handles native sharing with clipboard fallback
 * China-safe, offline-capable, analytics-integrated
 */

import { trackEvent } from './analytics'

export interface ShareData {
  title: string
  text: string
  url: string
}

/**
 * Main share function with Web Share API and clipboard fallback
 */
export async function shareProject(
  data: ShareData,
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): Promise<{ success: boolean; method?: 'native' | 'clipboard'; error?: Error }> {
  try {
    // Try Web Share API first
    if (navigator.share && navigator.canShare && navigator.canShare(data)) {
      await navigator.share(data)

      // Track analytics
      trackEvent('project-shared', {
        method: 'native',
        projectId: extractProjectIdFromUrl(data.url),
      })

      onSuccess?.('native')
      return { success: true, method: 'native' }
    } else {
      // Fallback to clipboard
      return await copyToClipboard(data.url, onSuccess, onError)
    }
  } catch (error) {
    const err = error as Error

    // User canceled share sheet - not an error
    if (err.name === 'AbortError') {
      return { success: false }
    }

    // Actual error - try clipboard fallback
    console.error('Share failed:', err)
    return await copyToClipboard(data.url, onSuccess, onError)
  }
}

/**
 * Copy URL to clipboard using modern Clipboard API
 */
export async function copyToClipboard(
  text: string,
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): Promise<{ success: boolean; method?: 'native' | 'clipboard'; error?: Error }> {
  try {
    // Try modern Clipboard API
    await navigator.clipboard.writeText(text)

    // Track analytics
    trackEvent('project-shared', {
      method: 'clipboard',
      projectId: extractProjectIdFromUrl(text),
    })

    onSuccess?.('clipboard')
    return { success: true, method: 'clipboard' }
  } catch (error) {
    // Fallback to execCommand for older browsers
    return fallbackCopyToClipboard(text, onSuccess, onError)
  }
}

/**
 * Legacy clipboard fallback for older browsers
 */
function fallbackCopyToClipboard(
  text: string,
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): { success: boolean; method?: 'native' | 'clipboard'; error?: Error } {
  const textArea = document.createElement('textarea')
  textArea.value = text
  textArea.style.position = 'fixed'
  textArea.style.left = '-9999px'
  textArea.style.top = '0'
  textArea.setAttribute('readonly', '')

  document.body.appendChild(textArea)
  textArea.select()

  try {
    const successful = document.execCommand('copy')
    document.body.removeChild(textArea)

    if (successful) {
      trackEvent('project-shared', {
        method: 'clipboard',
        projectId: extractProjectIdFromUrl(text),
      })

      onSuccess?.('clipboard')
      return { success: true, method: 'clipboard' }
    } else {
      throw new Error('execCommand copy failed')
    }
  } catch (error) {
    document.body.removeChild(textArea)
    const err = error as Error
    onError?.(err)
    return { success: false, error: err }
  }
}

/**
 * Generate shareable URL for a service project
 */
export function generateProjectUrl(projectId: string): string {
  const baseUrl = window.location.origin
  return `${baseUrl}/projects?id=${projectId}`
}

/**
 * Extract project ID from URL (for analytics)
 */
function extractProjectIdFromUrl(url: string): string | undefined {
  try {
    const urlObj = new URL(url)
    return urlObj.searchParams.get('id') || undefined
  } catch {
    return undefined
  }
}

/**
 * Optional: Detect WeChat browser for specific messaging
 */
export function isWeChat(): boolean {
  return /MicroMessenger/i.test(navigator.userAgent)
}
