# Social Media Links: Best Practices & Implementation Recommendation

**Date**: 2025-10-17
**Purpose**: Research and recommend approach for capturing and displaying social media links for Partners (and later Speakers)
**Context**: Multinational Rotary environment with diverse social media platform usage

---

## Research Summary

### 1. Database Storage Best Practices (2025)

**Recommended Approach: JSONB Column in PostgreSQL**

**Advantages**:
- ✅ **Flexible Schema** - Add new platforms without database migrations
- ✅ **Performance** - JSONB supports GIN indexes for fast queries
- ✅ **Hybrid Model** - Store structured data (name, email) in columns, flexible data (social links) in JSONB
- ✅ **Future-Proof** - Accommodates new platforms (TikTok, Threads, etc.) without schema changes
- ✅ **Regional Flexibility** - Easily support WeChat, WhatsApp, Line, KakaoTalk, etc.

**Industry Pattern**:
```json
{
  "facebook": "https://facebook.com/username",
  "linkedin": "https://linkedin.com/company/name",
  "wechat": "wechat-id",
  "whatsapp": "+60123456789"
}
```

**Alternative Considered**: Separate columns for each platform (❌ Not recommended)
- Requires migration for every new platform
- Creates empty columns for unused platforms
- Not flexible enough for multinational use

---

### 2. Display Best Practices (2025 UX Guidelines)

**Recommended Approach: Clickable Icon Row**

**Industry Standards**:
- ✅ **Icon-Only Display** - Cleaner UI, universally recognized
- ✅ **Monochrome or Brand Colors** - Monochrome for clean look, brand colors for emphasis
- ✅ **Horizontal Row** - Icons in single row at bottom/side of card
- ✅ **Equal Size & Spacing** - All icons same size (16-20px for cards)
- ✅ **3-4 Platforms Maximum** - Don't overwhelm, show most relevant
- ✅ **Hover Tooltips** - Show platform name + handle on hover
- ✅ **Direct Links** - Click opens platform in new tab

**Visual Hierarchy**:
- Primary contact info (email, phone) at top
- Social media icons at bottom or side
- Most important platform first (left to right)

---

### 3. Multinational Platform Considerations

**Global Platforms** (Western markets):
- Facebook
- LinkedIn
- Instagram
- Twitter/X

**Asia-Specific Platforms** (Critical for Malaysian/Chinese partners):
- **WeChat** (China, Malaysia, Singapore) - Dominant in Chinese communities
- **WhatsApp** (Global, especially Malaysia) - Primary messaging in SEA
- **Line** (Thailand, Taiwan, Japan)
- **KakaoTalk** (South Korea)

**Emerging Platforms**:
- TikTok (Global youth engagement)
- Threads (Meta's Twitter alternative)
- YouTube (Video content)

**Georgetown Rotary Recommendation**:
Support 6-8 platforms initially:
1. LinkedIn (Professional networking)
2. Facebook (General social)
3. Instagram (Visual content)
4. WhatsApp (Messaging/contact)
5. WeChat (Chinese community)
6. YouTube (Video content)
7. Twitter/X (News/updates)
8. TikTok (Youth engagement)

---

### 4. Icon Library Recommendation

**Primary Recommendation: `react-icons` Package**

**Why NOT Lucide**:
- ❌ Lucide is **deprecating brand icons** (Facebook, Instagram, LinkedIn removed in 2025)
- ❌ Lucide policy: No brand logos due to legal/maintenance concerns
- ❌ Not suitable for social media icons

**Why `react-icons`**:
- ✅ Includes Simple Icons library (2000+ brand logos)
- ✅ Actively maintained for brand consistency
- ✅ Supports all major platforms (Facebook, LinkedIn, Instagram, WhatsApp, WeChat, etc.)
- ✅ Tree-shakeable (only imports what you use)
- ✅ Consistent sizing with Lucide (same API)

**Installation**:
```bash
npm install react-icons
```

**Usage Example**:
```typescript
import { FaFacebook, FaLinkedin, FaInstagram, FaWhatsapp } from 'react-icons/fa'
import { SiWechat } from 'react-icons/si'

<FaFacebook size={16} className="text-gray-600 hover:text-[#1877F2]" />
<FaLinkedin size={16} className="text-gray-600 hover:text-[#0A66C2]" />
<SiWechat size={16} className="text-gray-600 hover:text-[#07C160]" />
```

---

## Recommended Implementation for Georgetown Rotary

### Phase 1: Partners Section

#### **Database Schema (Migration 043)**

```sql
-- Add social_media_links JSONB column to partners table
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS social_media_links JSONB DEFAULT '{}'::jsonb;

-- Add GIN index for performance
CREATE INDEX IF NOT EXISTS idx_partners_social_media_links
  ON partners USING GIN (social_media_links);

-- Add validation constraint (optional - ensures valid JSON)
ALTER TABLE partners
  ADD CONSTRAINT social_media_links_is_object
  CHECK (jsonb_typeof(social_media_links) = 'object');

COMMENT ON COLUMN partners.social_media_links IS 'Social media platform links stored as {"platform": "url/handle"}';
```

**Example Data**:
```json
{
  "linkedin": "https://linkedin.com/company/rotary-international",
  "facebook": "https://facebook.com/rotary",
  "wechat": "rotary_official",
  "whatsapp": "+60123456789",
  "instagram": "https://instagram.com/rotary"
}
```

---

#### **TypeScript Type Update**

```typescript
// src/types/database.ts
export type Partner = {
  // ... existing fields
  social_media_links?: Record<string, string>  // Platform name -> URL/handle
}

// Social media platform types
export type SocialMediaPlatform =
  | 'linkedin'
  | 'facebook'
  | 'instagram'
  | 'twitter'
  | 'whatsapp'
  | 'wechat'
  | 'youtube'
  | 'tiktok'
```

---

#### **PartnerCard Display**

```typescript
import { FaFacebook, FaLinkedin, FaInstagram, FaTwitter, FaWhatsapp, FaYoutube, FaTiktok } from 'react-icons/fa'
import { SiWechat } from 'react-icons/si'

// Icon mapping with brand colors
const socialIcons: Record<string, { icon: React.ComponentType<any>, color: string, label: string }> = {
  linkedin: { icon: FaLinkedin, color: '#0A66C2', label: 'LinkedIn' },
  facebook: { icon: FaFacebook, color: '#1877F2', label: 'Facebook' },
  instagram: { icon: FaInstagram, color: '#E4405F', label: 'Instagram' },
  twitter: { icon: FaTwitter, color: '#1DA1F2', label: 'Twitter' },
  whatsapp: { icon: FaWhatsapp, color: '#25D366', label: 'WhatsApp' },
  wechat: { icon: SiWechat, color: '#07C160', label: 'WeChat' },
  youtube: { icon: FaYoutube, color: '#FF0000', label: 'YouTube' },
  tiktok: { icon: FaTiktok, color: '#000000', label: 'TikTok' },
}

// In PartnerCard component
{partner.social_media_links && Object.keys(partner.social_media_links).length > 0 && (
  <div className="flex items-center gap-2 mt-2">
    {Object.entries(partner.social_media_links).map(([platform, url]) => {
      const socialConfig = socialIcons[platform.toLowerCase()]
      if (!socialConfig) return null

      const Icon = socialConfig.icon
      return (
        <a
          key={platform}
          href={url}
          target="_blank"
          rel="noopener noreferrer"
          className="text-gray-400 hover:text-gray-600 transition-colors"
          title={`${socialConfig.label}: ${url}`}
          onClick={(e) => e.stopPropagation()}
          style={{ color: 'inherit' }}
          onMouseEnter={(e) => e.currentTarget.style.color = socialConfig.color}
          onMouseLeave={(e) => e.currentTarget.style.color = 'inherit'}
        >
          <Icon size={16} />
        </a>
      )
    })}
  </div>
)}
```

---

#### **PartnerModal Form Fields**

```typescript
// Add social media inputs to PartnerModal
<div className="space-y-3">
  <label className="block text-sm font-medium text-gray-700">
    Social Media Links
  </label>

  {/* LinkedIn */}
  <div className="flex items-center gap-2">
    <FaLinkedin size={16} className="text-[#0A66C2]" />
    <input
      type="url"
      placeholder="https://linkedin.com/company/..."
      value={formData.social_media_links?.linkedin || ''}
      onChange={(e) => setFormData({
        ...formData,
        social_media_links: {
          ...formData.social_media_links,
          linkedin: e.target.value
        }
      })}
      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#005daa] focus:border-transparent"
    />
  </div>

  {/* Facebook */}
  <div className="flex items-center gap-2">
    <FaFacebook size={16} className="text-[#1877F2]" />
    <input
      type="url"
      placeholder="https://facebook.com/..."
      value={formData.social_media_links?.facebook || ''}
      onChange={(e) => setFormData({
        ...formData,
        social_media_links: {
          ...formData.social_media_links,
          facebook: e.target.value
        }
      })}
      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#005daa] focus:border-transparent"
    />
  </div>

  {/* WeChat */}
  <div className="flex items-center gap-2">
    <SiWechat size={16} className="text-[#07C160]" />
    <input
      type="text"
      placeholder="WeChat ID or QR code URL"
      value={formData.social_media_links?.wechat || ''}
      onChange={(e) => setFormData({
        ...formData,
        social_media_links: {
          ...formData.social_media_links,
          wechat: e.target.value
        }
      })}
      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#005daa] focus:border-transparent"
    />
  </div>

  {/* WhatsApp */}
  <div className="flex items-center gap-2">
    <FaWhatsapp size={16} className="text-[#25D366]" />
    <input
      type="tel"
      placeholder="+60123456789"
      value={formData.social_media_links?.whatsapp || ''}
      onChange={(e) => setFormData({
        ...formData,
        social_media_links: {
          ...formData.social_media_links,
          whatsapp: e.target.value
        }
      })}
      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#005daa] focus:border-transparent"
    />
  </div>

  {/* Add more platforms as needed */}
</div>
```

---

### Phase 2: Speakers Section (Future)

Apply the same pattern:
1. Add `social_media_links JSONB` column to `speakers` table
2. Update `Speaker` TypeScript type
3. Add social icons to `SpeakerCard`
4. Add form fields to `SpeakerModal`

---

## Benefits of This Approach

### 1. **Flexibility**
- ✅ Add new platforms without database migrations
- ✅ Partners can have different platforms (some use WeChat, others WhatsApp)
- ✅ Future-proof for emerging platforms

### 2. **Performance**
- ✅ JSONB with GIN indexing allows fast queries
- ✅ Tree-shakeable icons (only bundle what you use)
- ✅ No unnecessary columns for unused platforms

### 3. **User Experience**
- ✅ Clean visual display (icons only)
- ✅ Hover shows platform name
- ✅ Brand colors on hover (familiar to users)
- ✅ Direct links to platforms

### 4. **Multinational Support**
- ✅ Supports Western platforms (LinkedIn, Facebook)
- ✅ Supports Asian platforms (WeChat, WhatsApp, Line)
- ✅ Accommodates regional preferences

### 5. **Maintenance**
- ✅ Single JSONB column easier to manage than multiple columns
- ✅ react-icons actively maintained for brand consistency
- ✅ No breaking changes when platforms rebrand

---

## Implementation Checklist

**Partners Section**:
- [ ] Install `react-icons` package
- [ ] Create Migration 043 (add social_media_links JSONB column)
- [ ] Update TypeScript Partner type
- [ ] Create SocialMediaIcons helper component
- [ ] Update PartnerCard to display social icons
- [ ] Update PartnerModal to add social media form fields
- [ ] Update PartnerDetailModal to display social links
- [ ] Test with sample data (LinkedIn, Facebook, WeChat, WhatsApp)

**Speakers Section** (Phase 2):
- [ ] Create Migration 044 (add social_media_links to speakers)
- [ ] Update TypeScript Speaker type
- [ ] Update SpeakerCard
- [ ] Update SpeakerModal
- [ ] Update SpeakerDetailModal

---

## Alternative Approaches Considered

### ❌ **Option 1: Separate Columns**
```sql
ALTER TABLE partners
  ADD COLUMN linkedin_url TEXT,
  ADD COLUMN facebook_url TEXT,
  ADD COLUMN wechat_id TEXT;
```

**Rejected Because**:
- Requires migration for every new platform
- Creates many empty columns
- Not flexible for regional differences
- Hard to iterate on

### ❌ **Option 2: Array of Objects**
```json
[
  {"platform": "linkedin", "url": "https://..."},
  {"platform": "facebook", "url": "https://..."}
]
```

**Rejected Because**:
- More complex queries
- Harder to update individual platforms
- No benefit over key-value JSONB

---

## Recommended Decision

**✅ Implement JSONB approach with `react-icons` library**

**Reasoning**:
1. **Most flexible** - Accommodates any platform without schema changes
2. **Best performance** - JSONB with GIN indexes
3. **Best UX** - Clean icon display with brand colors
4. **Multinational ready** - Supports WeChat, WhatsApp, Line, etc.
5. **Future-proof** - Easily add TikTok, Threads, new platforms
6. **Industry standard** - JSONB for flexible schema, icon libraries for brand display

---

## Next Steps

1. **CEO Approval**: Confirm JSONB + react-icons approach
2. **Install Package**: `npm install react-icons`
3. **Create Migration 043**: Add social_media_links to partners
4. **Implement Partners**: Update PartnerCard, PartnerModal, types
5. **Test with Real Data**: Add social links for existing partners
6. **Apply to Speakers**: Repeat pattern for speakers table

---

**Status**: Recommendation complete. Awaiting CEO approval to proceed with implementation.
