import type { Member } from '../types/database'
import { Mail, Phone, ExternalLink, Calendar, User, Building, Gift, Globe, Pencil, Link } from 'lucide-react'
import { useState } from 'react'
import LinkedInIcon from './LinkedInIcon'
import SocialMediaIcons from './SocialMediaIcons'
import MemberDetailModal from './MemberDetailModal'
import PHFPin from './PHFPin'
import ShareButton from './ShareButton'

// Birthday utility functions
const formatBirthday = (month?: number, day?: number): string | null => {
  if (!month || !day) return null
  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December']
  return `${monthNames[month - 1]} ${day}`
}

const isToday = (month?: number, day?: number): boolean => {
  if (!month || !day) return false
  const today = new Date()
  return today.getMonth() + 1 === month && today.getDate() === day
}

interface MemberCardProps {
  member: Member
}

export default function MemberCard({ member }: MemberCardProps) {
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false)

  const handleCardClick = () => {
    setIsDetailModalOpen(true)
  }

  const handleEdit = (e: React.MouseEvent) => {
    e.stopPropagation()
    setIsDetailModalOpen(true)
    // The MemberDetailModal will handle showing the edit modal
  }

  return (
    <>
      <div
        onClick={handleCardClick}
        className="group bg-white rounded-lg shadow-sm border border-gray-200/60 p-4 cursor-pointer hover:shadow-md transition-all duration-200 hover:border-gray-300 hover:-translate-y-0.5 touch-manipulation"
      >
        {/* Header with Name and Role */}
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center gap-3 flex-1">
            {member.portrait_url ? (
              <img
                src={member.portrait_url}
                alt={`${member.name} portrait`}
                className="w-10 h-10 rounded-full object-cover shadow-sm flex-shrink-0"
                onError={(e) => {
                  const target = e.target as HTMLImageElement
                  target.style.display = 'none'
                  const fallback = target.nextElementSibling as HTMLElement
                  if (fallback) fallback.style.display = 'flex'
                }}
              />
            ) : null}
            <div
              className={`w-10 h-10 rounded-full text-white flex items-center justify-center text-sm font-semibold shadow-sm ${
                member.type === 'Honorary' ? 'bg-gradient-to-br from-[#f7a81b] to-[#e09916]' :
                member.type === 'Former Member' ? 'bg-gradient-to-br from-gray-400 to-gray-500' :
                'bg-gradient-to-br from-[#0067c8] to-[#004080]'
              }`}
              style={{ display: member.portrait_url ? 'none' : 'flex' }}
            >
              {member.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <h4 className="font-semibold text-gray-900 text-sm truncate" style={{ fontFamily: "'Open Sans', sans-serif" }}>
                  {member.prefix ? `${member.prefix} ` : ''}{member.name}
                </h4>
                {member.phf && (
                  <div className="flex-shrink-0" title={`Paul Harris Fellow: ${member.phf}`}>
                    <PHFPin size={14} />
                  </div>
                )}
                {member.charter_member && (
                  <div className="flex-shrink-0" title="Charter Member - Founding Member of Georgetown Rotary Club">
                    <svg width="16" height="16" viewBox="0 0 93.86 122.88" xmlns="http://www.w3.org/2000/svg">
                      <path fill="#f7a81b" fillRule="evenodd" clipRule="evenodd" d="M3.26,0H90.6c1.79,0,3.26,1.47,3.26,3.26v7.68c0,1.79-1.47,3.26-3.26,3.26h-4.05v10.33 c0,1.79-1.47,3.26-3.26,3.26h-7.43v95.08H18.01V27.8h-7.43c-1.79,0-3.26-1.47-3.26-3.26V14.21H3.26C1.47,14.21,0,12.74,0,10.94 V3.26C0,1.47,1.47,0,3.26,0L3.26,0z M29.5,34.95L29.5,34.95c1.72,0,3.12,1.4,3.12,3.12v72.72c0,1.72-1.4,3.12-3.12,3.12l0,0 c-1.72,0-3.12-1.4-3.12-3.12V38.07C26.38,36.35,27.79,34.95,29.5,34.95L29.5,34.95z M63.31,34.95L63.31,34.95 c1.72,0,3.12,1.4,3.12,3.12v72.72c0,1.72-1.4,3.12-3.12,3.12l0,0c-1.72,0-3.12-1.4-3.12-3.12V38.07 C60.18,36.35,61.59,34.95,63.31,34.95L63.31,34.95z M46.4,34.95L46.4,34.95c1.72,0,3.12,1.4,3.12,3.12v72.72 c0,1.72-1.4,3.12-3.12,3.12l0,0c-1.72,0-3.12-1.4-3.12-3.12V38.07C43.28,36.35,44.69,34.95,46.4,34.95L46.4,34.95z"/>
                    </svg>
                  </div>
                )}
                {isToday(member.birth_month, member.birth_day) && (
                  <div className="flex-shrink-0" title="Happy Birthday! 🎂">
                    <Gift size={14} className="text-[#f7a81b] animate-pulse" />
                  </div>
                )}
              </div>
              {member.roles && member.roles.length > 0 && !member.roles.every(r => r === 'Member') && (
                <div className="text-sm font-medium text-[#0067c8]">
                  {member.roles.filter(r => r !== 'Member').join(' • ')}
                </div>
              )}
              {member.job_title && (
                <div className="text-sm font-medium text-gray-700 truncate">
                  {member.job_title}
                </div>
              )}
            </div>
          </div>
          <div className="flex gap-1">
            <ShareButton member={member} variant="icon-only" />
            <button
              onClick={handleEdit}
              className="min-h-[44px] min-w-[44px] p-2 hover:bg-blue-50 rounded-md transition-colors touch-manipulation inline-flex items-center justify-center"
              aria-label="Edit member"
              title="Edit member"
            >
              <Pencil size={16} className="text-gray-400 hover:text-[#0067c8] transition-colors" />
            </button>
          </div>
        </div>

        {/* Classification */}
        {member.classification && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Building size={14} className="text-gray-400 flex-shrink-0" />
              <span className="truncate">{member.classification}</span>
            </div>
          </div>
        )}

        {/* Company */}
        {member.company_name && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Building size={14} className="text-gray-400 flex-shrink-0" />
              <span className="truncate">{member.company_name}</span>
            </div>
          </div>
        )}

        {/* Company Website */}
        {member.company_url && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Link size={14} className="text-gray-400 flex-shrink-0" />
              <a
                href={member.company_url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[#0067c8] hover:text-[#004080] inline-flex items-center gap-1 transition-colors min-h-[44px] py-2"
                title="Visit company website"
                onClick={(e) => e.stopPropagation()}
              >
                <span className="truncate max-w-[180px]">
                  {member.company_url.replace(/^https?:\/\//, '').replace(/\/$/, '')}
                </span>
                <ExternalLink size={12} className="flex-shrink-0" />
              </a>
            </div>
          </div>
        )}

        {/* Member Since */}
        {member.member_since && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Calendar size={14} className="text-gray-400 flex-shrink-0" />
              <span>Club Member since {member.member_since}</span>
            </div>
          </div>
        )}

        {/* Rotary Resume Indicator */}
        {member.rotary_resume && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <User size={14} className="text-[#0067c8] flex-shrink-0" />
              <span className="text-[#0067c8] font-medium">Rotary Resume Available</span>
            </div>
          </div>
        )}

        {/* Birthday */}
        {formatBirthday(member.birth_month, member.birth_day) && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Gift size={14} className={`flex-shrink-0 ${isToday(member.birth_month, member.birth_day) ? 'text-[#f7a81b]' : 'text-gray-400'}`} />
              <span className={isToday(member.birth_month, member.birth_day) ? 'text-[#f7a81b] font-medium' : ''}>
                Birthday: {formatBirthday(member.birth_month, member.birth_day)}
                {isToday(member.birth_month, member.birth_day) && ' 🎂'}
              </span>
            </div>
          </div>
        )}

        {/* Citizenship */}
        {member.citizenship && (
          <div className="mb-2">
            <div className="flex items-center gap-1.5 text-sm text-gray-600">
              <Globe size={14} className="text-gray-400 flex-shrink-0" />
              <span>{member.citizenship}</span>
            </div>
          </div>
        )}

        {/* Contact Info */}
        <div className="space-y-1">
          {member.email && (
            <div className="flex items-center gap-1.5 text-sm text-gray-500">
              <Mail size={14} className="text-gray-400 flex-shrink-0" />
              <span className="truncate">{member.email}</span>
            </div>
          )}

          {member.mobile && (
            <div className="flex items-center gap-1.5 text-sm text-gray-500">
              <Phone size={14} className="text-gray-400 flex-shrink-0" />
              <span>{member.mobile}</span>
            </div>
          )}

          {/* Social Media Links - after phone number */}
          {member.social_media_links && Object.keys(member.social_media_links).length > 0 && (
            <div className="pt-1">
              <SocialMediaIcons socialMediaLinks={member.social_media_links} size={16} />
            </div>
          )}
        </div>

        {/* Personal LinkedIn Badge - at the bottom */}
        {member.linkedin && (
          <div className="mt-2 pt-2 border-t border-gray-100">
            <a
              href={member.linkedin}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 text-white bg-[#0077B5] hover:bg-[#005885] px-3 py-2 rounded transition-colors touch-manipulation shadow-sm min-h-[44px]"
              title="View LinkedIn Profile"
              aria-label={`View ${member.name}'s LinkedIn profile`}
              onClick={(e) => e.stopPropagation()}
            >
              <LinkedInIcon size={14} />
              <span className="text-sm font-medium">LinkedIn</span>
            </a>
          </div>
        )}

        {/* Membership Status Badge */}
        {member.type && member.type !== 'Active' && (
          <div className="mt-2">
            <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
              {member.type}
            </span>
          </div>
        )}
      </div>

      {isDetailModalOpen && (
        <MemberDetailModal
          member={member}
          onClose={() => setIsDetailModalOpen(false)}
        />
      )}
    </>
  )
}