/**
 * Cloudflare Pages Functions middleware
 * Handles server-side Open Graph meta tag injection for shareable content
 *
 * This enables WhatsApp, Telegram, and other platforms to show rich previews
 * when sharing links.
 *
 * Supported routes:
 * - /speakers/:uuid - Speaker details with portrait, topic
 * - /projects?id=uuid - Service project details with image, description
 * - /members/:uuid - Member details with portrait, role, classification
 * - /partners/:uuid - Partner organization details with logo, description
 * - /events/:uuid - Event details with date, time, location
 *
 * How it works:
 * 1. Detect crawler user agents (Telegram, WhatsApp, Facebook, etc.)
 * 2. Match URL pattern and extract ID
 * 3. Fetch data from Supabase
 * 4. Inject content-specific meta tags into HTML
 * 5. Return modified HTML to crawler
 *
 * Note: This runs on Cloudflare's edge network, so it's fast and serverless
 */

import { createClient } from '@supabase/supabase-js'

// Supabase configuration
// Production credentials for rmorlqozjwbftzowqmps.supabase.co
const SUPABASE_URL = 'https://rmorlqozjwbftzowqmps.supabase.co'
const SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtb3JscW96andiZnR6b3dxbXBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4NzIwNDMsImV4cCI6MjA4MTQ0ODA0M30.RzsIZo_-kGF2sAaXWfd4K-bj5PgVvrFNUOsGNycRkQ8'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export async function onRequest(context: {
  request: Request
  next: () => Promise<Response>
  env: any
}): Promise<Response> {
  const { request, next } = context
  const url = new URL(request.url)

  // Detect if request is from a crawler/bot (check once for all routes)
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

  // Initialize Supabase client for crawler requests
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

  // Process speaker URLs: /speakers/:uuid
  const speakerMatch = url.pathname.match(/^\/speakers\/([^/]+)$/)
  if (speakerMatch) {
    const speakerId = speakerMatch[1]

    // Validate UUID format
    if (UUID_REGEX.test(speakerId)) {
      try {
        // Fetch speaker data from Supabase
        const { data: speaker, error } = await supabase
          .from('speakers')
          .select('id, name, topic, organization, portrait_url')
          .eq('id', speakerId)
          .single()

        if (!error && speaker) {
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
        }
      } catch (error) {
        console.error('Error injecting speaker meta tags:', error)
      }
    }
  }

  // Process service project URLs: /projects?id=uuid
  if (url.pathname === '/projects') {
    const projectId = url.searchParams.get('id')

    // Validate UUID format
    if (projectId && UUID_REGEX.test(projectId)) {
      try {
        // Fetch project data from Supabase
        const { data: project, error } = await supabase
          .from('service_projects')
          .select('id, project_name, description, image_url, area_of_focus')
          .eq('id', projectId)
          .single()

        if (error) {
          console.error('Error fetching project:', error)
        }

        if (!error && project) {
          // Get the base HTML response
          const response = await next()
          const html = await response.text()

          // Inject project-specific meta tags
          const modifiedHtml = injectMetaTags(html, {
            title: project.project_name,
            description: project.description || `${project.area_of_focus} project - Georgetown Rotary`,
            image: project.image_url || '',
            url: `${url.origin}/projects?id=${project.id}`,
          })

          // Return modified HTML
          return new Response(modifiedHtml, {
            headers: response.headers,
          })
        }
      } catch (error) {
        console.error('Error injecting project meta tags:', error)
      }
    }
  }

  // Process member URLs: /members/:uuid
  const memberMatch = url.pathname.match(/^\/members\/([^/]+)$/)
  if (memberMatch) {
    const memberId = memberMatch[1]

    // Validate UUID format
    if (UUID_REGEX.test(memberId)) {
      try {
        // Fetch member data from Supabase
        const { data: member, error } = await supabase
          .from('members')
          .select('id, name, portrait_url, roles, classification, job_title, company_name')
          .eq('id', memberId)
          .eq('active', true)
          .single()

        if (!error && member) {
          // Get the base HTML response
          const response = await next()
          const html = await response.text()

          // Build description from available fields
          let description = ''
          if (member.job_title && member.company_name) {
            description = `${member.job_title} at ${member.company_name}`
          } else if (member.job_title) {
            description = member.job_title
          } else if (member.classification) {
            description = member.classification
          } else if (member.roles && member.roles.length > 0) {
            description = member.roles[0]
          } else {
            description = 'Georgetown Rotary Club Member'
          }

          // Inject member-specific meta tags
          const modifiedHtml = injectMetaTags(html, {
            title: member.name,
            description,
            image: member.portrait_url || '',
            url: `${url.origin}/members/${member.id}`,
          })

          // Return modified HTML
          return new Response(modifiedHtml, {
            headers: response.headers,
          })
        }
      } catch (error) {
        console.error('Error injecting member meta tags:', error)
      }
    }
  }

  // Process partner URLs: /partners/:uuid
  const partnerMatch = url.pathname.match(/^\/partners\/([^/]+)$/)
  if (partnerMatch) {
    const partnerId = partnerMatch[1]

    // Validate UUID format
    if (UUID_REGEX.test(partnerId)) {
      try {
        // Fetch partner data from Supabase
        const { data: partner, error } = await supabase
          .from('partners')
          .select('id, name, description, logo_url, type, website, city, country')
          .eq('id', partnerId)
          .single()

        if (!error && partner) {
          // Get the base HTML response
          const response = await next()
          const html = await response.text()

          // Build description from available fields
          let description = partner.description || ''
          if (!description && partner.type) {
            description = `${partner.type} partner`
            if (partner.city || partner.country) {
              const location = [partner.city, partner.country].filter(Boolean).join(', ')
              description += ` - ${location}`
            }
          }
          if (!description) {
            description = 'Georgetown Rotary Club Partner'
          }

          // Inject partner-specific meta tags
          const modifiedHtml = injectMetaTags(html, {
            title: `${partner.name} - Georgetown Rotary Partner`,
            description,
            image: partner.logo_url || '',
            url: `${url.origin}/partners/${partner.id}`,
          })

          // Return modified HTML
          return new Response(modifiedHtml, {
            headers: response.headers,
          })
        }
      } catch (error) {
        console.error('Error injecting partner meta tags:', error)
      }
    }
  }

  // Process event URLs: /events/:uuid
  const eventMatch = url.pathname.match(/^\/events\/([^/]+)$/)
  if (eventMatch) {
    const eventId = eventMatch[1]

    // Validate UUID format
    if (UUID_REGEX.test(eventId)) {
      try {
        // Fetch event data from Supabase (with location join)
        const { data: event, error } = await supabase
          .from('events')
          .select(`
            id,
            title,
            description,
            date,
            start_time,
            end_time,
            type,
            location:locations(name, address)
          `)
          .eq('id', eventId)
          .single()

        if (!error && event) {
          // Get the base HTML response
          const response = await next()
          const html = await response.text()

          // Build description from date, time, and location
          let description = ''

          // Format date (e.g., "Monday, December 18, 2025")
          const eventDate = new Date(event.date)
          const formattedDate = eventDate.toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          })

          description = formattedDate

          // Add time if available
          if (event.start_time) {
            description += ` at ${event.start_time}`
          }

          // Add location if available
          const locationData = Array.isArray(event.location) ? event.location[0] : event.location
          if (locationData?.name) {
            description += ` - ${locationData.name}`
          }

          // Add brief description if available
          if (event.description) {
            const briefDesc = event.description.substring(0, 100)
            description += `. ${briefDesc}${event.description.length > 100 ? '...' : ''}`
          }

          // Inject event-specific meta tags
          const modifiedHtml = injectMetaTags(html, {
            title: event.title,
            description,
            image: '', // Events don't have images yet, will use club logo fallback
            url: `${url.origin}/events/${event.id}`,
          })

          return new Response(modifiedHtml, {
            headers: response.headers,
          })
        }
      } catch (error) {
        console.error('Error injecting event meta tags:', error)
      }
    }
  }

  // No special handling matched, pass through
  return next()
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

  // Add image tags if available (both OG and Twitter)
  if (meta.image) {
    modifiedHtml = modifiedHtml
      .replace(
        /<meta property="og:image" content="[^"]*" \/>/,
        `<meta property="og:image" content="${escapeHtml(meta.image)}" />`
      )
      .replace(
        /<meta name="twitter:image" content="[^"]*" \/>/,
        `<meta name="twitter:image" content="${escapeHtml(meta.image)}" />`
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
