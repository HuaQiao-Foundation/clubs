/**
 * Dynamic meta tag updates for social sharing
 *
 * Updates Open Graph and Twitter Card meta tags when viewing speakers
 * This enables better previews when sharing links to specific speakers
 *
 * LIMITATION: Only works for platforms that execute JavaScript (Twitter, LinkedIn)
 * WhatsApp, Telegram, iMessage use static HTML and won't see dynamic updates
 * For those platforms, we would need SSR/prerendering
 */

interface MetaTagOptions {
  title: string
  description?: string
  image?: string
  url?: string
}

/**
 * Update meta tags for social sharing
 * Call this when a speaker/project is loaded
 */
export function updateMetaTags(options: MetaTagOptions): void {
  const { title, description, image, url } = options

  // Update document title
  document.title = `${title} - Georgetown Rotary`

  // Update or create Open Graph tags
  updateMetaTag('og:title', title, 'property')
  if (description) {
    updateMetaTag('og:description', description, 'property')
  }
  if (image) {
    updateMetaTag('og:image', image, 'property')
  }
  if (url) {
    updateMetaTag('og:url', url, 'property')
  }

  // Update Twitter Card tags
  updateMetaTag('twitter:title', title, 'name')
  if (description) {
    updateMetaTag('twitter:description', description, 'name')
  }
  if (image) {
    updateMetaTag('twitter:image', image, 'name')
  }
}

/**
 * Reset meta tags to default state
 * Call this when navigating back to board view
 */
export function resetMetaTags(): void {
  updateMetaTags({
    title: 'Georgetown Rotary Speakers',
    description: 'Speaker and event management for Georgetown Rotary Club',
    url: window.location.origin,
  })
}

/**
 * Update or create a meta tag
 */
function updateMetaTag(
  property: string,
  content: string,
  attribute: 'property' | 'name' = 'property'
): void {
  let element = document.querySelector(
    `meta[${attribute}="${property}"]`
  ) as HTMLMetaElement

  if (!element) {
    element = document.createElement('meta')
    element.setAttribute(attribute, property)
    document.head.appendChild(element)
  }

  element.setAttribute('content', content)
}

/**
 * Generate speaker meta tags
 */
export function getSpeakerMetaTags(speaker: {
  name: string
  topic?: string
  organization?: string
  portrait_url?: string
  id: string
}): MetaTagOptions {
  const title = speaker.name
  const description =
    speaker.topic ||
    (speaker.organization ? `Speaker from ${speaker.organization}` : 'Georgetown Rotary Speaker')

  return {
    title,
    description,
    image: speaker.portrait_url || undefined,
    url: `${window.location.origin}/speakers/${speaker.id}`,
  }
}

/**
 * Generate project meta tags
 */
export function getProjectMetaTags(project: {
  project_name: string
  description?: string
  id: string
}): MetaTagOptions {
  return {
    title: project.project_name,
    description: project.description?.substring(0, 200) || 'Georgetown Rotary Service Project',
    url: `${window.location.origin}/projects?id=${project.id}`,
  }
}
