import type { Member } from '../types/database'
import { Phone, Mail } from 'lucide-react'
import PHFPin from './PHFPin'

interface MembersListProps {
  members: Member[]
  onMemberClick: (member: Member) => void
}

export default function MembersList({ members, onMemberClick }: MembersListProps) {
  return (
    <div className="space-y-3">
      {members.map((member) => {
        // Get primary role (first role or "Member")
        const primaryRole = member.roles && member.roles.length > 0 ? member.roles[0] : 'Member'

        // Get status display
        const statusDisplay = member.type || 'Active'

        return (
          <button
            key={member.id}
            onClick={() => onMemberClick(member)}
            className="w-full bg-white rounded-lg p-4 shadow hover:shadow-md transition-all text-left border border-gray-200 hover:border-[#0067c8]"
          >
            <div className="flex items-start gap-4">
              {/* Portrait with fallback to initials */}
              <div className="flex-shrink-0">
                {member.portrait_url ? (
                  <img
                    src={member.portrait_url}
                    alt={member.name}
                    className="w-16 h-16 md:w-20 md:h-20 rounded-full object-cover border-2 border-gray-200"
                    onError={(e) => {
                      e.currentTarget.style.display = 'none'
                      const fallback = e.currentTarget.nextElementSibling as HTMLElement
                      if (fallback) fallback.style.display = 'flex'
                    }}
                  />
                ) : null}
                <div
                  className="w-16 h-16 md:w-20 md:h-20 rounded-full bg-gradient-to-br from-[#0067c8] to-[#004080] text-white flex items-center justify-center text-lg md:text-xl font-semibold border-2 border-gray-200"
                  style={{ display: member.portrait_url ? 'none' : 'flex' }}
                >
                  {member.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                </div>
              </div>

              {/* Member Info */}
              <div className="flex-1 min-w-0">
                {/* Name with badges */}
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-gray-900 text-base md:text-lg truncate">
                    {member.name}
                  </h3>
                  {member.phf && (
                    <PHFPin className="flex-shrink-0" />
                  )}
                </div>

                {/* Role and Status */}
                <p className="text-sm text-gray-600 mb-2">
                  {primaryRole} • {statusDisplay}
                </p>

                {/* Contact Info */}
                <div className="space-y-1">
                  {member.email && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Mail size={14} className="flex-shrink-0 text-gray-400" />
                      <span className="truncate">{member.email}</span>
                    </div>
                  )}
                  {member.mobile && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Phone size={14} className="flex-shrink-0 text-gray-400" />
                      <span>{member.mobile}</span>
                    </div>
                  )}
                </div>

                {/* Classification (if exists) */}
                {member.classification && (
                  <p className="text-xs text-gray-500 mt-2 truncate">
                    {member.classification}
                  </p>
                )}
              </div>
            </div>
          </button>
        )
      })}
    </div>
  )
}
