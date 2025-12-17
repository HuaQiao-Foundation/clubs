/**
 * Cloudflare Pages Functions middleware
 * Handles server-side Open Graph meta tag injection for speaker URLs
 *
 * This enables WhatsApp, Telegram, and iMessage to show speaker names
 * instead of "Private System" when sharing links.
 *
 * How it works:
 * 1. Detect /speakers/:uuid URLs
 * 2. Fetch speaker data from Supabase
 * 3. Inject speaker-specific meta tags into HTML
 * 4. Return modified HTML to crawler
 *
 * Note: This runs on Cloudflare's edge network, so it's fast and serverless
 */

import { createClient } from '@supabase/supabase-js'

// Supabase configuration (from environment variables)
const SUPABASE_URL = 'https://zooszmqdrdocuiuledql.supabase.co'
const SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpvb3N6bXFkcmRvY3VpdWxlZHFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM5MDk5NTcsImV4cCI6MjA0OTQ4NTk1N30.v4jOJx7oLNvjh_ALaVnAXAYJxJHjB93kKZ7JqE7gQKg'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export async function onRequest(context: {
  request: Request
  next: () => Promise<Response>
  env: any
}): Promise<Response> {
  const { request, next } = context
  const url = new URL(request.url)

  // Only process speaker URLs: /speakers/:uuid
  const speakerMatch = url.pathname.match(/^\/speakers\/([^/]+)$/)

  if (!speakerMatch) {
    // Not a speaker URL, pass through
    return next()
  }

  const speakerId = speakerMatch[1]

  // Validate UUID format
  if (!UUID_REGEX.test(speakerId)) {
    return next()
  }

  // Detect if request is from a crawler/bot
  const userAgent = request.headers.get('user-agent') || ''
  const isCrawler =
    userAgent.includes('WhatsApp') ||
    userAgent.includes('Telegram') ||
    userAgent.includes('Slack') ||
    userAgent.includes('facebookexternalhit') ||
    userAgent.includes('Twitterbot') ||
    userAgent.includes('LinkedInBot')

  // If not a crawler, just pass through (let React handle it)
  if (!isCrawler) {
    return next()
  }

  try {
    // Fetch speaker data from Supabase
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    const { data: speaker, error } = await supabase
      .from('speakers')
      .select('id, name, topic, organization, portrait_url')
      .eq('id', speakerId)
      .single()

    if (error || !speaker) {
      // Speaker not found, pass through
      return next()
    }

    // Get the base HTML response
    const response = await next()
    const html = await response.text()

    // Inject speaker-specific meta tags
    const modifiedHtml = injectMetaTags(html, {
      title: speaker.name,
      description:
        speaker.topic ||
        (speaker.organization ? `Speaker from ${speaker.organization}` : 'Georgetown Rotary Speaker'),
      image: speaker.portrait_url || '',
      url: `${url.origin}/speakers/${speaker.id}`,
    })

    // Return modified HTML
    return new Response(modifiedHtml, {
      headers: response.headers,
    })
  } catch (error) {
    console.error('Error injecting meta tags:', error)
    // On error, just pass through
    return next()
  }
}

/**
 * Inject Open Graph meta tags into HTML
 */
function injectMetaTags(
  html: string,
  meta: { title: string; description: string; image: string; url: string }
): string {
  // Replace the default Open Graph tags with speaker-specific ones
  let modifiedHtml = html
    .replace(
      /<meta property="og:title" content="[^"]*" \/>/,
      `<meta property="og:title" content="${escapeHtml(meta.title)}" />`
    )
    .replace(
      /<meta property="og:description" content="[^"]*" \/>/,
      `<meta property="og:description" content="${escapeHtml(meta.description)}" />`
    )
    .replace(
      /<meta property="og:url" content="[^"]*" \/>/,
      `<meta property="og:url" content="${escapeHtml(meta.url)}" />`
    )
    .replace(
      /<meta name="twitter:title" content="[^"]*" \/>/,
      `<meta name="twitter:title" content="${escapeHtml(meta.title)}" />`
    )
    .replace(
      /<meta name="twitter:description" content="[^"]*" \/>/,
      `<meta name="twitter:description" content="${escapeHtml(meta.description)}" />`
    )

  // Add image tag if available
  if (meta.image) {
    modifiedHtml = modifiedHtml.replace(
      /<meta property="og:image" content="[^"]*" \/>/,
      `<meta property="og:image" content="${escapeHtml(meta.image)}" />`
    )
  }

  // Also update document title
  modifiedHtml = modifiedHtml.replace(
    /<title>[^<]*<\/title>/,
    `<title>${escapeHtml(meta.title)} - Georgetown Rotary</title>`
  )

  return modifiedHtml
}

/**
 * Escape HTML special characters
 */
function escapeHtml(text: string): string {
  const map: { [key: string]: string } = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  }
  return text.replace(/[&<>"']/g, (char) => map[char])
}
