import { FaFacebook, FaLinkedin, FaInstagram, FaTwitter, FaWhatsapp, FaYoutube, FaTiktok, FaTelegram } from 'react-icons/fa'
import { SiWechat, SiLine, SiKakaotalk } from 'react-icons/si'

interface SocialMediaIconsProps {
  socialMediaLinks?: Record<string, string>
  size?: number
  className?: string
}

// Icon configuration with brand colors and labels
const socialIconConfig: Record<string, {
  icon: React.ComponentType<{ size?: number, className?: string }>
  color: string
  label: string
}> = {
  linkedin: { icon: FaLinkedin, color: '#0A66C2', label: 'LinkedIn' },
  facebook: { icon: FaFacebook, color: '#1877F2', label: 'Facebook' },
  instagram: { icon: FaInstagram, color: '#E4405F', label: 'Instagram' },
  twitter: { icon: FaTwitter, color: '#1DA1F2', label: 'Twitter' },
  whatsapp: { icon: FaWhatsapp, color: '#25D366', label: 'WhatsApp' },
  wechat: { icon: SiWechat, color: '#07C160', label: 'WeChat' },
  telegram: { icon: FaTelegram, color: '#0088cc', label: 'Telegram' },
  youtube: { icon: FaYoutube, color: '#FF0000', label: 'YouTube' },
  tiktok: { icon: FaTiktok, color: '#000000', label: 'TikTok' },
  line: { icon: SiLine, color: '#00B900', label: 'Line' },
  kakaotalk: { icon: SiKakaotalk, color: '#FFE812', label: 'KakaoTalk' },
}

export default function SocialMediaIcons({ socialMediaLinks, size = 16, className = '' }: SocialMediaIconsProps) {
  if (!socialMediaLinks || Object.keys(socialMediaLinks).length === 0) {
    return null
  }

  return (
    <div className={`flex items-center gap-1 ${className}`}>
      {Object.entries(socialMediaLinks).map(([platform, url]) => {
        const config = socialIconConfig[platform.toLowerCase()]
        if (!config || !url) return null

        const Icon = config.icon

        return (
          <a
            key={platform}
            href={url}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center min-h-[44px] min-w-[44px] text-gray-400 transition-colors rounded-md hover:bg-gray-50"
            title={`${config.label}: ${url}`}
            onClick={(e) => e.stopPropagation()}
            onMouseEnter={(e) => {
              e.currentTarget.style.color = config.color
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.color = ''
            }}
          >
            <Icon size={size} />
          </a>
        )
      })}
    </div>
  )
}
