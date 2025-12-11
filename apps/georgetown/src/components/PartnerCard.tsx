import type { Partner } from '../types/database'
import { Pencil, ExternalLink, User, Mail, Phone, Link, MapPin, Globe } from 'lucide-react'
import { getPartnerTypeColor, getPartnerTypeIcon } from '../utils/partnerHelpers'
import SocialMediaIcons from './SocialMediaIcons'

interface PartnerCardProps {
  partner: Partner
  onClick: (partner: Partner) => void
  onEdit: (partner: Partner) => void
}

export default function PartnerCard({ partner, onClick, onEdit }: PartnerCardProps) {
  const handleCardClick = () => {
    onClick(partner)
  }

  const handleEditClick = (e: React.MouseEvent) => {
    e.stopPropagation()
    onEdit(partner)
  }

  return (
    <div
      onClick={handleCardClick}
      className="bg-white rounded-lg p-4 md:p-6 shadow hover:shadow-lg transition-all text-left border border-gray-200 hover:border-[#0067c8] cursor-pointer relative group"
    >
      {/* Edit Icon - Top Right */}
      <button
        onClick={handleEditClick}
        className="absolute top-2 right-2 z-10 min-h-[44px] min-w-[44px] p-2 bg-white hover:bg-gray-50 rounded-full shadow-md border border-gray-200 transition-all inline-flex items-center justify-center"
        aria-label="Edit partner"
        title="Edit partner"
      >
        <Pencil size={16} className="text-gray-400 hover:text-[#0067c8] transition-colors" />
      </button>

      {/* Logo/Icon */}
      <div className="flex items-start gap-4 mb-4">
        {partner.logo_url ? (
          <div className="w-16 h-16 rounded-lg flex items-center justify-center flex-shrink-0 bg-gray-50 border border-gray-200 overflow-hidden p-2">
            <img
              src={partner.logo_url}
              alt={`${partner.name} logo`}
              className="w-full h-full object-contain"
            />
          </div>
        ) : (
          <div
            className="w-16 h-16 rounded-lg flex items-center justify-center text-3xl flex-shrink-0"
            style={{ backgroundColor: `${getPartnerTypeColor(partner.type)}20` }}
          >
            {getPartnerTypeIcon(partner.type)}
          </div>
        )}
        <div className="flex-1 min-w-0">
          <h3 className="font-semibold text-gray-900 text-lg mb-1 line-clamp-2">
            {partner.name}
          </h3>
          {partner.status === 'Inactive' && (
            <span className="inline-block px-2 py-0.5 text-xs font-medium bg-gray-100 text-gray-600 rounded-full">
              Inactive
            </span>
          )}
        </div>
      </div>

      {/* Type Badge */}
      <div className="mb-3">
        <span
          className="inline-flex px-3 py-1 text-xs font-semibold text-white rounded-full"
          style={{ backgroundColor: getPartnerTypeColor(partner.type) }}
        >
          {partner.type}
        </span>
      </div>

      {/* Contact Info Preview */}
      <div className="space-y-1 text-sm text-gray-600">
        {/* Contact Person */}
        {partner.contact_name && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <User size={14} className="text-gray-400 flex-shrink-0" />
            <span className="font-medium text-gray-900">{partner.contact_name}</span>
            {partner.contact_title && (
              <span className="text-gray-500">({partner.contact_title})</span>
            )}
          </div>
        )}

        {/* Email */}
        {partner.contact_email && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <Mail size={14} className="text-gray-400 flex-shrink-0" />
            <span className="truncate">{partner.contact_email}</span>
          </div>
        )}

        {/* Phone */}
        {partner.contact_phone && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <Phone size={14} className="text-gray-400 flex-shrink-0" />
            <span>{partner.contact_phone}</span>
          </div>
        )}

        {/* Website */}
        {partner.website && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <Link size={14} className="text-gray-400 flex-shrink-0" />
            <a
              href={partner.website}
              target="_blank"
              rel="noopener noreferrer"
              className="text-[#0067c8] hover:text-[#004080] inline-flex items-center gap-1 transition-colors min-h-[44px] py-2"
              onClick={(e) => e.stopPropagation()}
              title={`Visit ${partner.name} website`}
            >
              <span className="truncate max-w-[180px]">
                {partner.website.replace(/^https?:\/\//, '').replace(/\/$/, '')}
              </span>
              <ExternalLink size={12} className="flex-shrink-0" />
            </a>
          </div>
        )}

        {/* City */}
        {partner.city && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <MapPin size={14} className="text-gray-400 flex-shrink-0" />
            <span>{partner.city}</span>
          </div>
        )}

        {/* Country */}
        {partner.country && (
          <div className="flex items-center gap-1.5 text-sm text-gray-600">
            <Globe size={14} className="text-gray-400 flex-shrink-0" />
            <span>{partner.country}</span>
          </div>
        )}

        {/* Social Media Links */}
        {partner.social_media_links && (
          <div className="mt-2">
            <SocialMediaIcons socialMediaLinks={partner.social_media_links} size={16} />
          </div>
        )}

        {/* Fallback to legacy contact_info (if no modern fields) */}
        {!partner.contact_name && !partner.contact_email && !partner.contact_phone && !partner.website && partner.contact_info && (
          <p className="text-sm text-gray-600 line-clamp-2">{partner.contact_info}</p>
        )}
      </div>
    </div>
  )
}
