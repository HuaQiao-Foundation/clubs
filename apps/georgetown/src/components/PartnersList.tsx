import type { Partner } from '../types/database'
import { Mail, Phone, Globe, Calendar } from 'lucide-react'
import { format } from 'date-fns'

interface PartnersListProps {
  partners: Partner[]
  onPartnerClick: (partner: Partner) => void
}

// Partner type color mapping (Official Rotary Brand Colors)
const getPartnerTypeColor = (type: string) => {
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
const getPartnerTypeIcon = (type: string) => {
  switch (type) {
    case 'Rotary Club': return '⚙️'
    case 'Foundation': return '🏛️'
    case 'NGO': return '🤝'
    case 'Corporate': return '🏢'
    case 'Government': return '🏛️'
    default: return '🤝'
  }
}

export default function PartnersList({ partners, onPartnerClick }: PartnersListProps) {
  return (
    <div className="space-y-3">
      {partners.map((partner) => {
        return (
          <button
            key={partner.id}
            onClick={() => onPartnerClick(partner)}
            className="w-full bg-white rounded-lg p-4 shadow hover:shadow-md transition-all text-left border border-gray-200 hover:border-[#0067c8]"
          >
            <div className="flex items-start gap-4">
              {/* Icon */}
              <div className="flex-shrink-0">
                {partner.logo_url ? (
                  <div className="w-14 h-14 md:w-16 md:h-16 rounded-lg flex items-center justify-center bg-white border border-gray-200 overflow-hidden p-2">
                    <img
                      src={partner.logo_url}
                      alt={`${partner.name} logo`}
                      className="w-full h-full object-contain"
                      style={{ backgroundColor: 'transparent' }}
                    />
                  </div>
                ) : (
                  <div
                    className="w-14 h-14 md:w-16 md:h-16 rounded-lg flex items-center justify-center text-2xl"
                    style={{ backgroundColor: `${getPartnerTypeColor(partner.type)}20` }}
                  >
                    {getPartnerTypeIcon(partner.type)}
                  </div>
                )}
              </div>

              {/* Partner Info */}
              <div className="flex-1 min-w-0">
                {/* Name with Status */}
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-gray-900 text-base md:text-lg line-clamp-1">
                    {partner.name}
                  </h3>
                  {partner.status === 'Inactive' && (
                    <span className="px-2 py-0.5 text-xs font-medium bg-gray-100 text-gray-600 rounded-full">
                      Inactive
                    </span>
                  )}
                </div>

                {/* Type Badge */}
                <div className="mb-2">
                  <span
                    className="inline-flex px-3 py-1 text-xs font-semibold text-white rounded-full"
                    style={{ backgroundColor: getPartnerTypeColor(partner.type) }}
                  >
                    {partner.type}
                  </span>
                </div>

                {/* Structured Contact Info */}
                <div className="space-y-1">
                  {/* Contact Person */}
                  {partner.contact_name && (
                    <p className="text-sm text-gray-700 font-medium">
                      {partner.contact_name}
                    </p>
                  )}

                  {/* Email */}
                  {partner.contact_email && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Mail size={14} className="flex-shrink-0 text-gray-400" />
                      <span className="truncate">{partner.contact_email}</span>
                    </div>
                  )}

                  {/* Phone */}
                  {partner.contact_phone && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Phone size={14} className="flex-shrink-0 text-gray-400" />
                      <span>{partner.contact_phone}</span>
                    </div>
                  )}

                  {/* Website */}
                  {partner.website && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Globe size={14} className="flex-shrink-0 text-gray-400" />
                      <span className="truncate">{partner.website}</span>
                    </div>
                  )}

                  {/* Relationship Since */}
                  {partner.relationship_since && (
                    <div className="flex items-center gap-2 text-xs text-gray-500 mt-1">
                      <Calendar size={12} className="flex-shrink-0" />
                      <span>
                        Partner since {format(new Date(partner.relationship_since), 'MMM yyyy')}
                      </span>
                    </div>
                  )}

                  {/* Legacy Contact Info (fallback for old data) */}
                  {!partner.contact_name && !partner.contact_email && partner.contact_info && (
                    <p className="text-sm text-gray-600 line-clamp-2">
                      {partner.contact_info}
                    </p>
                  )}
                </div>
              </div>
            </div>
          </button>
        )
      })}
    </div>
  )
}
