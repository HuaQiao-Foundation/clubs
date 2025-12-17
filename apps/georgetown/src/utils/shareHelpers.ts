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

// Track pending share operation to prevent "InvalidStateError: An earlier share has not yet completed"
let isShareInProgress = false

/**
 * Main share function with Web Share API and clipboard fallback
 * @param contentType - Type of content being shared ('project' or 'speaker')
 */
export async function shareContent(
  data: ShareData,
  contentType: 'project' | 'speaker',
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): Promise<{ success: boolean; method?: 'native' | 'clipboard'; error?: Error }> {
  // Prevent multiple simultaneous share operations
  if (isShareInProgress) {
    console.warn('Share already in progress, ignoring duplicate request')
    return { success: false }
  }

  try {
    // Try Web Share API first
    if (navigator.share && navigator.canShare && navigator.canShare(data)) {
      isShareInProgress = true
      await navigator.share(data)

      // Track analytics
      const contentId = extractIdFromUrl(data.url)
      trackEvent(`${contentType}-shared`, {
        method: 'native',
        [`${contentType}Id`]: contentId,
      })

      onSuccess?.('native')
      return { success: true, method: 'native' }
    } else {
      // Fallback to clipboard
      return await copyToClipboard(data.url, contentType, onSuccess, onError)
    }
  } catch (error) {
    const err = error as Error

    // User canceled share sheet - not an error
    if (err.name === 'AbortError') {
      return { success: false }
    }

    // Actual error - try clipboard fallback
    console.error('Share failed:', err)
    return await copyToClipboard(data.url, contentType, onSuccess, onError)
  } finally {
    // Always reset the flag when share completes or fails
    isShareInProgress = false
  }
}

/**
 * Legacy function for backward compatibility
 * @deprecated Use shareContent instead
 */
export async function shareProject(
  data: ShareData,
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): Promise<{ success: boolean; method?: 'native' | 'clipboard'; error?: Error }> {
  return shareContent(data, 'project', onSuccess, onError)
}

/**
 * Copy URL to clipboard using modern Clipboard API
 */
export async function copyToClipboard(
  text: string,
  contentType: 'project' | 'speaker' = 'project',
  onSuccess?: (method: 'native' | 'clipboard') => void,
  onError?: (error: Error) => void
): Promise<{ success: boolean; method?: 'native' | 'clipboard'; error?: Error }> {
  try {
    // Try modern Clipboard API
    await navigator.clipboard.writeText(text)

    // Track analytics
    const contentId = extractIdFromUrl(text)
    trackEvent(`${contentType}-shared`, {
      method: 'clipboard',
      [`${contentType}Id`]: contentId,
    })

    onSuccess?.('clipboard')
    return { success: true, method: 'clipboard' }
  } catch (error) {
    // Fallback to execCommand for older browsers
    return fallbackCopyToClipboard(text, contentType, onSuccess, onError)
  }
}

/**
 * Legacy clipboard fallback for older browsers
 */
function fallbackCopyToClipboard(
  text: string,
  contentType: 'project' | 'speaker' = 'project',
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
      const contentId = extractIdFromUrl(text)
      trackEvent(`${contentType}-shared`, {
        method: 'clipboard',
        [`${contentType}Id`]: contentId,
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
 * Generate shareable URL for a speaker
 */
export function generateSpeakerUrl(speakerId: string): string {
  const baseUrl = window.location.origin
  return `${baseUrl}/speakers?id=${speakerId}`
}

/**
 * Extract ID from URL (for analytics)
 * Works for both projects and speakers
 */
function extractIdFromUrl(url: string): string | undefined {
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
