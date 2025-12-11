# Icon Usage Standard - Georgetown Rotary Application

## Purpose
Establish consistent, accessible icon usage across all cards and components to ensure users can quickly recognize information types.

---

## 🎯 Icon Library
**Standard:** [Lucide React](https://lucide.dev/) - Modern, consistent, accessible icons
**Size Standard:** 12px for inline icons, 14px for emphasis, 16px for buttons

---

## 📋 Icon Mapping Standards (2025 Best Practices)

### **Contact Information**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Email** | ✉️ | `<Mail size={12} />` | member.email, partner.contact_email | `text-gray-400` |
| **Phone** | 📞 | `<Phone size={12} />` | member.mobile, partner.contact_phone | `text-gray-400` |
| **Website/URL** | 🔗 | `<Link size={12} />` | partner.website, member.company_url | `text-gray-400` |
| **External Link** | ↗️ | `<ExternalLink size={10} />` | Clickable website links (inline) | `text-[#005daa]` |

**Rationale:**
- `Mail` = Universal email symbol
- `Phone` = Universal phone symbol
- `Link` = Hyperlink/URL/website address (matches business card conventions)
- `ExternalLink` = Clickable link indicator (opens new tab)

---

### **Organization Information**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Company/Organization** | 🏢 | `<Building size={12} />` | member.company_name, speaker.organization | `text-gray-400` |
| **Rotary Classification** | 🏢 | `<Building size={12} />` | member.classification (e.g., "Law - General") | `text-gray-400` |
| **Partner Type Badge** | N/A | Emoji in helper | Uses emoji: ⚙️🏛️🤝🏢 | Colored background |

**Rationale:**
- `Building` = Business/professional context (company OR classification)
- **IMPORTANT:** Same icon for both company_name and classification is acceptable because:
  - They never appear together on the same card
  - Context makes meaning clear ("Company:" vs classification value)
  - Visual consistency more important than differentiation

**Alternative Considered:** `Briefcase` for classification
- ❌ Rejected: Too similar to Building, adds confusion
- ✅ Better: Keep Building for all business/professional contexts

---

### **Geographic & Demographic**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Country/Citizenship** | 🌍 | `<Globe size={12} />` | member.citizenship | `text-gray-400` |
| **Location/City** | 📍 | `<MapPin size={12} />` | project.location | `text-gray-400` |

**Rationale:**
- `Globe` = Country/nationality (broader geographic)
- `MapPin` = Specific location/city (precise geographic)
- Different use cases prevent confusion

---

### **Dates & Time**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Calendar Date** | 📅 | `<Calendar size={12} />` | member.member_since, speaker.scheduled_date | `text-gray-400` or accent |
| **Birthday** | 🎁 | `<Gift size={12} />` | member.birth_month/birth_day | `text-[#f7a81b]` if today |

**Rationale:**
- `Calendar` = Any date context
- `Gift` = Birthday specifically (celebratory context)

---

### **People & Roles**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Person/User** | 👤 | `<User size={12} />` | Rotary Resume, proposer | `text-[#005daa]` (Rotary context) |
| **Team/Group** | 👥 | `<Users size={14} />` | Project beneficiaries | `text-gray-400` |

**Rationale:**
- `User` = Individual person/profile
- `Users` = Multiple people/beneficiaries

---

### **Special Indicators**
| Data Type | Icon | Lucide Component | Usage Example | Color |
|-----------|------|------------------|---------------|-------|
| **Edit Action** | ✏️ | `<Pencil size={16} />` | Edit buttons on cards | `text-gray-400` hover `text-[#005daa]` |
| **Rotarian Badge** | ✓ | `<BadgeCheck size={14} />` | speaker.is_rotarian | `text-[#f7a81b]` |
| **LinkedIn** | in | `<LinkedInIcon size={12} />` | Social profile link | White on `#0077B5` background |

---

## 🚫 Icon Anti-Patterns (What NOT to Do)

### **Problem 1: Same Icon, Different Meanings**
❌ **Bad:** Using `Globe` for both website AND citizenship on same card
```typescript
<Globe /> {member.citizenship}
<Globe /> {member.website}  // CONFUSING!
```

✅ **Good:** Different icons for different contexts
```typescript
<Globe size={12} /> {member.citizenship}      // Country
<ExternalLink size={10} /> {member.website}   // Website link
```

### **Problem 2: Inconsistent Usage Across Cards**
❌ **Bad:** Email uses `Mail` on Member card, `AtSign` on Partner card
✅ **Good:** Email always uses `Mail` icon everywhere

### **Problem 3: Too Many Similar Icons**
❌ **Bad:** `Building`, `Briefcase`, `Factory` for slight variations
✅ **Good:** One `Building` icon for all business/professional contexts

---

## 📐 Implementation Standards

### **Size Guidelines**
```typescript
// Inline information (most common)
<Mail size={12} className="text-gray-400" />

// Emphasis or special status
<BadgeCheck size={14} className="text-[#f7a81b]" />

// Interactive buttons
<Pencil size={16} className="text-gray-400 hover:text-[#005daa]" />

// Clickable external links (smaller, inline)
<ExternalLink size={10} className="text-[#005daa]" />
```

### **Color Standards**
```typescript
// Default (neutral information)
className="text-gray-400"

// Rotary-specific (important info)
className="text-[#005daa]"  // Rotary Azure

// Accent/highlight (special status)
className="text-[#f7a81b]"  // Rotary Gold

// Contextual (birthday today, scheduled date)
className={isToday ? 'text-[#f7a81b]' : 'text-gray-400'}
```

### **Spacing Standards**
```typescript
// Icon + text container
<div className="flex items-center gap-1.5 text-xs text-gray-600">
  <Icon size={12} className="text-gray-400" />
  <span>{content}</span>
</div>
```

---

## 📝 Partner Card Icon Implementation

### **Current Issues**
1. ❌ Missing icons entirely (no visual hierarchy)
2. ❌ Website uses `ExternalLink` but should follow standard
3. ❌ No icons for contact person, email, phone

### **Proposed Partner Card Structure**

```typescript
{/* Contact Person */}
{partner.contact_name && (
  <div className="flex items-center gap-1.5 text-xs text-gray-600">
    <User size={12} className="text-gray-400" />
    <span className="font-medium text-gray-900">{partner.contact_name}</span>
    {partner.contact_title && (
      <span className="text-gray-500">({partner.contact_title})</span>
    )}
  </div>
)}

{/* Email */}
{partner.contact_email && (
  <div className="flex items-center gap-1.5 text-xs text-gray-600">
    <Mail size={12} className="text-gray-400" />
    <span className="truncate">{partner.contact_email}</span>
  </div>
)}

{/* Phone */}
{partner.contact_phone && (
  <div className="flex items-center gap-1.5 text-xs text-gray-600">
    <Phone size={12} className="text-gray-400" />
    <span>{partner.contact_phone}</span>
  </div>
)}

{/* Website */}
{partner.website && (
  <div className="flex items-center gap-1.5 text-xs text-gray-600">
    <Globe size={12} className="text-gray-400" />
    <a
      href={partner.website}
      target="_blank"
      rel="noopener noreferrer"
      className="text-[#005daa] hover:text-[#004080] inline-flex items-center gap-1"
      onClick={(e) => e.stopPropagation()}
    >
      <span className="truncate">
        {partner.website.replace(/^https?:\/\//, '')}
      </span>
      <ExternalLink size={10} />
    </a>
  </div>
)}
```

---

## 🔄 Migration Checklist

### **Cards to Update**
- [x] MemberCard - Updated with Link icon for company_url (2025-10-17)
- [x] SpeakerCard - Updated with Link icon for primary_url and additional_urls (2025-10-17)
- [x] PartnerCard - Updated with Link icon for website (2025-10-17)
- [x] SpeakerCardSimple - Verified consistent (2025-10-17)
- [ ] ServiceProjectCard - Review for consistency
- [ ] ServiceProjectPageCard - Review for consistency

### **Standards to Verify**
- [x] All emails use `Mail` icon
- [x] All phones use `Phone` icon
- [x] All websites use `Link` icon (with `ExternalLink` for clickable indicator)
- [x] All companies/orgs use `Building` icon
- [x] All countries use `Globe` icon
- [x] All dates use `Calendar` icon
- [x] All edit buttons use `Pencil` icon
- [x] Sizes: 12px default, 14px emphasis, 16px buttons, 10px inline links

---

## 📚 Icon Quick Reference

```typescript
// Import statement (add only what you need)
import {
  Mail,           // Email
  Phone,          // Phone number
  Link,           // Website, URL
  ExternalLink,   // Clickable external links (inline indicator)
  Globe,          // Country, citizenship, internet
  Building,       // Company, organization, classification
  MapPin,         // Specific location/city
  Calendar,       // Dates, anniversaries
  Gift,           // Birthday
  User,           // Person, profile, resume
  Users,          // Multiple people, beneficiaries
  Pencil,         // Edit action
  BadgeCheck,     // Verification, Rotarian status
} from 'lucide-react'
```

---

## 🎯 Key Principles

1. **Consistency Over Variety** - Same icon = same meaning across all cards
2. **Context Clarity** - Icon meaning should be obvious from context
3. **Accessibility** - Always pair icons with text labels
4. **Visual Hierarchy** - Icon color indicates importance (gray = neutral, Rotary blue = important)
5. **Mobile First** - Icons help scanability on small screens

---

**Last Updated:** 2025-10-17
**Status:** Active Standard
**Review:** Quarterly or when adding new card types
