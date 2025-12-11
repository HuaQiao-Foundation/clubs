/**
 * ThemeDisplay Component
 * Displays a leadership theme with logo (RI President, District Governor, or Club President)
 */

import { useState } from 'react'

type ThemeLevel = 'ri' | 'dg' | 'club'

type ThemeDisplayProps = {
  level: ThemeLevel
  leaderName: string
  themeName?: string
  logoUrl?: string
  photoUrl?: string  // Official portrait photo (for club president)
}

const levelLabels: Record<ThemeLevel, string> = {
  ri: 'Rotary International President',
  dg: 'District Governor',
  club: 'Club President'
}

export default function ThemeDisplay({
  level,
  leaderName,
  themeName,
  logoUrl,
  photoUrl
}: ThemeDisplayProps) {
  const [logoLoading, setLogoLoading] = useState(!!logoUrl)
  const [logoError, setLogoError] = useState(false)
  const [photoLoading, setPhotoLoading] = useState(!!photoUrl)
  const [photoError, setPhotoError] = useState(false)

  return (
    <div className={`theme-display theme-display-${level}`}>
      <div className="theme-display-header">
        <h3 className="theme-display-title">{levelLabels[level]}</h3>
        <p className="theme-display-leader">{leaderName}</p>
      </div>

      {/* Official Portrait Photo (Club President = blue, District Governor = gold) */}
      {photoUrl && !photoError && (
        <div className="theme-display-photo mt-3 relative">
          {photoLoading && (
            <div className="w-32 h-32 rounded-full mx-auto border-4 border-gray-200 bg-gray-100 animate-pulse absolute inset-0" />
          )}
          <img
            src={photoUrl}
            alt={`${leaderName} official portrait`}
            className={`w-32 h-32 object-cover rounded-full mx-auto border-4 shadow-md ${
              level === 'dg' ? 'border-[#f7a81b]' : 'border-[#0067c8]'
            } relative z-10`}
            onLoad={() => setPhotoLoading(false)}
            onError={() => {
              setPhotoLoading(false)
              setPhotoError(true)
            }}
          />
        </div>
      )}

      {/* Theme Logo and Text */}
      {(themeName || logoUrl) && (
        <div className="theme-display-content">
          {logoUrl && !logoError && (
            <div className="theme-display-logo relative">
              {logoLoading && (
                <div className="w-full h-24 bg-gray-200 rounded animate-pulse absolute inset-0" />
              )}
              <img
                src={logoUrl}
                alt={`${themeName || leaderName} theme logo`}
                className="relative z-10"
                onLoad={() => setLogoLoading(false)}
                onError={() => {
                  setLogoLoading(false)
                  setLogoError(true)
                }}
              />
            </div>
          )}
          {themeName && (
            <div className="theme-display-text">
              <p className="theme-name">{themeName}</p>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
