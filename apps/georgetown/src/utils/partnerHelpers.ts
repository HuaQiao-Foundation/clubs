// Partner type color mapping (Official Rotary Brand Colors)
export const getPartnerTypeColor = (type: string) => {
  const colorMap: Record<string, string> = {
    'Rotary Club': '#0067c8',      // Rotary Azure (primary)
    'Foundation': '#901f93',       // Violet (official Rotary secondary)
    'NGO': '#009739',              // Grass Green (official Rotary)
    'Corporate': '#e02927',        // Cardinal (official Rotary)
    'Government': '#17458f',       // Rotary Royal Blue (official Rotary)
  }
  return colorMap[type] || '#6b7280'
}

// Partner type icon mapping
export const getPartnerTypeIcon = (type: string) => {
  switch (type) {
    case 'Rotary Club': return '⚙️'
    case 'Foundation': return '🏛️'
    case 'NGO': return '🤝'
    case 'Corporate': return '🏢'
    case 'Government': return '🏛️'
    default: return '🤝'
  }
}
