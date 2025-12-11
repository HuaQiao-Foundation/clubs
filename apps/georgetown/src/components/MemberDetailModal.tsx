import { X, Phone, Mail, Calendar, User, Building, Settings, ExternalLink, Edit, Gift, Globe } from 'lucide-react'
import { useState } from 'react'
import type { Member } from '../types/database'
import LinkedInIcon from './LinkedInIcon'
import PHFPin from './PHFPin'
import MemberModal from './MemberModal'

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

interface MemberDetailModalProps {
  member: Member
  onClose: () => void
}

export default function MemberDetailModal({ member, onClose }: MemberDetailModalProps) {
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)

  const handleEdit = () => {
    setIsEditModalOpen(true)
  }

  const getRoleBadge = (role: string) => {
    if (role === 'Member') return null

    const roleConfig = {
      'Club President': { bg: 'bg-[#0067c8]', text: 'text-white' },
      'Vice President': { bg: 'bg-blue-100', text: 'text-blue-800' },
      'Club Secretary': { bg: 'bg-green-100', text: 'text-green-800' },
      'Club Treasurer': { bg: 'bg-amber-100', text: 'text-amber-800' },
    } as const

    const config = roleConfig[role as keyof typeof roleConfig] || { bg: 'bg-gray-100', text: 'text-gray-800' }
    return (
      <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${config.bg} ${config.text}`}>
        {role}
      </span>
    )
  }


  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4 sm:p-6">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] sm:max-h-[85vh] overflow-y-auto touch-manipulation">
        {/* Header */}
        <div className="bg-[#0067c8] text-white px-6 py-4 rounded-t-lg flex items-center justify-between">
          <div className="flex items-center">
            {member.portrait_url ? (
              <img
                src={member.portrait_url}
                alt={`${member.name} portrait`}
                className="w-12 h-12 rounded-full object-cover mr-4 border-2 border-white/30"
                onError={(e) => {
                  const target = e.target as HTMLImageElement
                  target.style.display = 'none'
                  const fallback = target.nextElementSibling as HTMLElement
                  if (fallback) fallback.style.display = 'flex'
                }}
              />
            ) : null}
            <div
              className="w-12 h-12 rounded-full bg-white bg-opacity-20 text-white flex items-center justify-center text-lg font-bold mr-4"
              style={{ display: member.portrait_url ? 'none' : 'flex' }}
            >
              {member.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
            </div>
            <div>
              <h2 className="text-xl font-semibold">
                {member.prefix ? `${member.prefix} ` : ''}{member.name}
              </h2>
              {member.job_title && (
                <p className="text-blue-200 text-sm font-medium">{member.job_title}</p>
              )}
              <p className="text-blue-100 text-sm">{member.classification || 'Georgetown Rotary Member'}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            {member.linkedin && (
              <a
                href={member.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="px-4 py-2 bg-[#0067c8] text-white rounded-lg hover:bg-[#004080] transition-colors flex items-center gap-2"
                title="View LinkedIn Profile"
              >
                <LinkedInIcon size={16} />
                <span className="hidden sm:inline">LinkedIn</span>
              </a>
            )}
            <button
              onClick={handleEdit}
              className="p-2 hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
              title="Edit member"
            >
              <Edit size={20} />
            </button>
            <button
              onClick={onClose}
              className="p-2 hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
            >
              <X size={20} />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Role and Status */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-3">
            <div className="flex items-center gap-3 flex-wrap">
              {member.roles && member.roles.length > 0 && member.roles.map(role => getRoleBadge(role))}
              {member.phf && (
                <div className="flex items-center gap-1.5 text-sm font-medium text-gray-700" title="Paul Harris Fellow">
                  <PHFPin size={20} />
                  <span>Paul Harris Fellow {member.phf}</span>
                </div>
              )}
              {member.charter_member && (
                <div className="flex items-center gap-2 text-sm font-bold" title="Charter Member - Founding Member of Georgetown Rotary Club">
                  <svg width="24" height="24" viewBox="0 0 93.86 122.88" xmlns="http://www.w3.org/2000/svg">
                    <path fill="#f7a81b" fillRule="evenodd" clipRule="evenodd" d="M3.26,0H90.6c1.79,0,3.26,1.47,3.26,3.26v7.68c0,1.79-1.47,3.26-3.26,3.26h-4.05v10.33 c0,1.79-1.47,3.26-3.26,3.26h-7.43v95.08H18.01V27.8h-7.43c-1.79,0-3.26-1.47-3.26-3.26V14.21H3.26C1.47,14.21,0,12.74,0,10.94 V3.26C0,1.47,1.47,0,3.26,0L3.26,0z M29.5,34.95L29.5,34.95c1.72,0,3.12,1.4,3.12,3.12v72.72c0,1.72-1.4,3.12-3.12,3.12l0,0 c-1.72,0-3.12-1.4-3.12-3.12V38.07C26.38,36.35,27.79,34.95,29.5,34.95L29.5,34.95z M63.31,34.95L63.31,34.95 c1.72,0,3.12,1.4,3.12,3.12v72.72c0,1.72-1.4,3.12-3.12,3.12l0,0c-1.72,0-3.12-1.4-3.12-3.12V38.07 C60.18,36.35,61.59,34.95,63.31,34.95L63.31,34.95z M46.4,34.95L46.4,34.95c1.72,0,3.12,1.4,3.12,3.12v72.72 c0,1.72-1.4,3.12-3.12,3.12l0,0c-1.72,0-3.12-1.4-3.12-3.12V38.07C43.28,36.35,44.69,34.95,46.4,34.95L46.4,34.95z"/>
                  </svg>
                  <span className="text-[#f7a81b] font-bold text-sm">Charter Member</span>
                </div>
              )}
            </div>
            {member.member_since && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Calendar size={16} />
                <span>Club Member since {member.member_since}</span>
              </div>
            )}
          </div>

          {/* Classification */}
          {member.classification && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Professional Classification</h3>
              <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                <Building size={20} className="text-[#0067c8]" />
                <p className="text-gray-700 font-medium">{member.classification}</p>
              </div>
            </div>
          )}

          {/* Company Information */}
          {member.company_name && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Company</h3>
              <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                <Building size={20} className="text-[#0067c8]" />
                <div className="flex-1">
                  <p className="text-gray-700 font-medium">{member.company_name}</p>
                  {member.company_url && (
                    <a
                      href={member.company_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-[#0067c8] hover:text-[#004080] transition-colors text-sm flex items-center gap-1 mt-1"
                    >
                      <span>Visit website</span>
                      <ExternalLink size={14} />
                    </a>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Birthday Celebration */}
          {formatBirthday(member.birth_month, member.birth_day) && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Birthday Celebration</h3>
              <div className={`flex items-center gap-3 p-4 rounded-lg border ${
                isToday(member.birth_month, member.birth_day)
                  ? 'bg-[#f7a81b]/10 border-[#f7a81b]/30'
                  : 'bg-gray-50 border-gray-200'
              }`}>
                <Gift size={20} className={`${isToday(member.birth_month, member.birth_day) ? 'text-[#f7a81b]' : 'text-gray-400'}`} />
                <div>
                  <p className="text-sm font-medium text-gray-700">Birthday</p>
                  <p className={`text-base ${isToday(member.birth_month, member.birth_day) ? 'text-[#f7a81b] font-semibold' : 'text-gray-600'}`}>
                    {formatBirthday(member.birth_month, member.birth_day)}
                    {isToday(member.birth_month, member.birth_day) && ' 🎂 Today!'}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Contact Information */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Contact Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {member.email && (
                <div className="flex items-center gap-3">
                  <Mail size={16} className="text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-700">Email</p>
                    <a
                      href={`mailto:${member.email}`}
                      className="text-[#0067c8] hover:text-[#004080] transition-colors"
                    >
                      {member.email}
                    </a>
                  </div>
                </div>
              )}

              {member.mobile && (
                <div className="flex items-center gap-3">
                  <Phone size={16} className="text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-700">Mobile</p>
                    <a
                      href={`tel:${member.mobile}`}
                      className="text-[#0067c8] hover:text-[#004080] transition-colors"
                    >
                      {member.mobile}
                    </a>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Personal Information */}
          {(member.gender || member.citizenship) && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Personal Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {member.gender && (
                  <div className="flex items-center gap-3">
                    <User size={16} className="text-gray-400" />
                    <div>
                      <p className="text-sm font-medium text-gray-700">Gender</p>
                      <p className="text-gray-600">{member.gender}</p>
                    </div>
                  </div>
                )}

                {member.citizenship && (
                  <div className="flex items-center gap-3">
                    <Globe size={16} className="text-gray-400" />
                    <div>
                      <p className="text-sm font-medium text-gray-700">Citizenship</p>
                      <p className="text-gray-600">{member.citizenship}</p>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Rotary Profile */}
          {(member.rotary_id || member.rotary_profile_url || member.rotary_resume) && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Rotary Profile</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {member.rotary_id && (
                  <div className="flex items-center gap-3">
                    <Settings size={16} className="text-gray-400" />
                    <div>
                      <p className="text-sm font-medium text-gray-700">Rotary ID Number</p>
                      <p className="text-gray-600 font-mono">{member.rotary_id}</p>
                    </div>
                  </div>
                )}

                {member.rotary_profile_url && (
                  <div className="flex items-center gap-3">
                    <Settings size={16} className="text-gray-400" />
                    <div>
                      <p className="text-sm font-medium text-gray-700">Rotary Profile</p>
                      <a
                        href={member.rotary_profile_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-[#0067c8] hover:text-[#004080] transition-colors flex items-center gap-1"
                      >
                        <span>View Profile</span>
                        <ExternalLink size={14} />
                      </a>
                    </div>
                  </div>
                )}

                {member.rotary_resume && (
                  <div className="md:col-span-2 flex flex-col gap-3">
                    <div className="flex items-start gap-3">
                      <User size={16} className="text-gray-400 mt-1" />
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-700 mb-2">Rotary Resume</p>
                        <div className="bg-gray-50 rounded-lg p-4 border">
                          <pre className="text-gray-700 text-sm leading-relaxed whitespace-pre-wrap font-sans">
                            {member.rotary_resume}
                          </pre>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      {isEditModalOpen && (
        <MemberModal
          member={member}
          onClose={() => setIsEditModalOpen(false)}
        />
      )}
    </div>
  )
}