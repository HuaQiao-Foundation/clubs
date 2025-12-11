/**
 * Simple Markdown Renderer
 * Converts basic markdown to React elements
 * Supports: **bold**, *italics*, line breaks
 */

import React from 'react'

export function renderSimpleMarkdown(text: string | undefined): React.ReactNode {
  if (!text) return null

  // Split by line breaks first
  const lines = text.split('\n')

  return lines.map((line, lineIndex) => {
    // Process inline formatting (bold and italics)
    const parts: React.ReactNode[] = []
    let currentIndex = 0

    // Regex to match **bold** or *italics*
    const regex = /(\*\*(.+?)\*\*|\*(.+?)\*)/g
    let match

    while ((match = regex.exec(line)) !== null) {
      // Add text before the match
      if (match.index > currentIndex) {
        parts.push(line.substring(currentIndex, match.index))
      }

      // Add the formatted text
      if (match[2]) {
        // Bold (**text**)
        parts.push(<strong key={`b-${lineIndex}-${match.index}`}>{match[2]}</strong>)
      } else if (match[3]) {
        // Italics (*text*)
        parts.push(<em key={`i-${lineIndex}-${match.index}`}>{match[3]}</em>)
      }

      currentIndex = match.index + match[0].length
    }

    // Add remaining text
    if (currentIndex < line.length) {
      parts.push(line.substring(currentIndex))
    }

    // Return line with formatting (or empty for blank lines)
    return (
      <React.Fragment key={lineIndex}>
        {parts.length > 0 ? parts : <br />}
        {lineIndex < lines.length - 1 && <br />}
      </React.Fragment>
    )
  })
}
