export function isValidUrl(url: string): boolean {
  if (!url || url.trim() === '') return true // Empty is okay (optional field)

  try {
    const parsed = new URL(url)
    // Only allow http and https protocols
    return ['http:', 'https:'].includes(parsed.protocol)
  } catch {
    return false
  }
}

export function sanitizeUrl(url: string): string {
  const trimmed = url.trim()
  if (!trimmed) return ''

  // Add https:// if no protocol specified
  if (!trimmed.match(/^https?:\/\//i)) {
    return `https://${trimmed}`
  }

  return trimmed
}

export function getUrlError(url: string): string | null {
  if (!url || url.trim() === '') return null

  if (!isValidUrl(url)) {
    return 'Please enter a valid URL (e.g., https://example.com)'
  }

  return null
}
