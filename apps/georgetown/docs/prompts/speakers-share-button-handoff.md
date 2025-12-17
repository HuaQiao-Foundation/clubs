# Handoff Prompt: Add Share Button to Speakers Cards

**Date:** 2025-12-17
**Feature:** Web Share API for Speakers (Phase 2)
**Context:** Continuation of Web Share API implementation
**Estimated Time:** 1-2 hours

---

## Background

Georgetown Rotary recently implemented Web Share API for Service Projects (commit `73a7c87`). This was Georgetown's first i18n implementation and established patterns for native mobile sharing.

**What exists:**
- ✅ ShareButton component (`/src/components/ShareButton.tsx`)
- ✅ Share utilities (`/src/utils/shareHelpers.ts`)
- ✅ i18n configuration with 5 languages (EN/ID/TH/TL/ZH)
- ✅ Analytics tracking via Umami
- ✅ Query parameter routing pattern

**Reference documentation:**
- `/docs/dev-journals/2025-12-17-web-share-api-service-projects.md` - Complete implementation details
- `/docs/georgetown-rotary-share-api-brief.md` - Original technical brief

---

## Objective

Add share buttons to **Speaker cards** on the Speakers page (http://localhost:5180/speakers) using the existing ShareButton component and patterns.

---

## Task Breakdown

### 1. Identify Speaker Components

**Find the speaker card component(s):**
```bash
# Look for speaker card components
apps/georgetown/src/components/*Speaker*.tsx
```

**Expected components:**
- `SpeakerCard.tsx` - Kanban board view
- `SpeakerDetailModal.tsx` - Detail view modal

**Note:** Just like Service Projects, there may be multiple card components for different views. Check which component is actually rendered on `/speakers`.

---

### 2. Update Share Utilities (Minor Change)

**File:** `/src/utils/shareHelpers.ts`

**Add new function:**
```typescript
export function generateSpeakerUrl(speakerId: string): string {
  const baseUrl = window.location.origin
  return `${baseUrl}/speakers?id=${speakerId}`
}
```

**Location:** Add right after `generateProjectUrl()` function (around line 120)

---

### 3. Add ShareButton to Speaker Cards

**File:** `SpeakerCard.tsx` (or equivalent component)

**Pattern to follow:** See `ServiceProjectPageCard.tsx` lines 28-42

**Steps:**
1. Import ShareButton
2. Add icon-only share button in top-right corner
3. Match styling with edit button

**Expected styling:**
```typescript
<ShareButton
  speaker={speaker}  // Pass speaker object
  variant="icon-only"
  className="p-2 bg-white hover:bg-gray-50 rounded-full shadow-md border border-gray-200 !min-h-0 !min-w-0"
/>
```

---

### 4. Update ShareButton Component

**File:** `/src/components/ShareButton.tsx`

**Current limitation:** Only accepts `ServiceProject` type

**Required changes:**

**Option A - Separate prop (Recommended):**
```typescript
interface ShareButtonProps {
  project?: ServiceProject
  speaker?: Speaker
  variant?: 'default' | 'icon-only'
  className?: string
}

// In handleShare:
const shareUrl = project
  ? generateProjectUrl(project.id)
  : speaker
  ? generateSpeakerUrl(speaker.id)
  : ''

const shareData = {
  title: project?.project_name || speaker?.name || '',
  text: project?.description || speaker?.topic || '',
  url: shareUrl,
}
```

**Option B - Generic content prop:**
```typescript
interface ShareButtonProps {
  content: {
    id: string
    title: string
    description?: string
    type: 'project' | 'speaker'
  }
  variant?: 'default' | 'icon-only'
  className?: string
}
```

**Recommendation:** Use Option A for type safety and backward compatibility with existing Service Project usage.

---

### 5. Add i18n Translations for Speakers

**Files:** All 5 locale files in `/src/i18n/locales/`

**Add to each file:**

**English (en.json):**
```json
{
  "share": {
    "share": "Share",
    "share_project": "Share this project",
    "share_speaker": "Share this speaker",
    "link_copied": "Link copied to clipboard",
    "copy_failed": "Unable to copy link"
  }
}
```

**Indonesian (id.json):**
```json
{
  "share": {
    "share_speaker": "Bagikan pembicara ini"
  }
}
```

**Thai (th.json):**
```json
{
  "share": {
    "share_speaker": "แชร์วิทยากรคนนี้"
  }
}
```

**Tagalog (tl.json):**
```json
{
  "share": {
    "share_speaker": "Ibahagi ang speaker na ito"
  }
}
```

**Chinese (zh.json):**
```json
{
  "share": {
    "share_speaker": "分享此演讲者"
  }
}
```

---

### 6. Update ShareButton ARIA Labels

**In ShareButton component:**
```typescript
const ariaLabel = project
  ? t('share.share_project')
  : speaker
  ? t('share.share_speaker')
  : t('share.share')
```

---

### 7. Add URL Routing for Speakers

**File:** `/src/components/SpeakersPage.tsx` (or equivalent)

**Pattern:** Follow `ServiceProjectsPage.tsx` lines 210-226

**Add useEffect:**
```typescript
import { useSearchParams } from 'react-router-dom'

const [searchParams, setSearchParams] = useSearchParams()

useEffect(() => {
  const speakerId = searchParams.get('id')

  if (speakerId && speakers.length > 0) {
    const speaker = speakers.find((s) => s.id === speakerId)

    if (speaker) {
      setSelectedSpeaker(speaker)
      setIsViewModalOpen(true)
      setSearchParams({})
    } else {
      console.warn(`Speaker with id ${speakerId} not found`)
      setSearchParams({})
    }
  }
}, [searchParams, speakers, setSearchParams])
```

---

### 8. Add ShareButton to SpeakerDetailModal (Optional)

**File:** `SpeakerDetailModal.tsx`

**Pattern:** Follow `ServiceProjectDetailModal.tsx` lines 40-44

**Add to modal header:**
```typescript
<ShareButton
  speaker={speaker}
  variant="default"
  className="!bg-white/10 hover:!bg-white/20 !border-0 !text-white !min-h-0"
/>
```

---

## Design Requirements

### Visual Styling
- **Icon:** Lucide React `Share2` (same as projects)
- **Size:** 16px icon (matches edit button)
- **Color:** `text-gray-400` with `hover:text-[#0067c8]` (Rotary blue)
- **Touch target:** 44px minimum (mobile-first)
- **Position:** Top-right corner next to edit button

### Behavior
- **Desktop:** Copy link to clipboard, show toast
- **Mobile:** Open native share sheet (WhatsApp, LINE, etc.)
- **Toast:** Only show on clipboard copy (not native share)
- **Stop propagation:** Prevent triggering card click

---

## Testing Checklist

### Desktop
- [ ] Share button visible on speaker cards
- [ ] Click share → "Link copied" toast appears
- [ ] Paste URL → Opens `/speakers?id=abc123`
- [ ] URL opens correct speaker detail modal
- [ ] Query parameter clears after modal opens

### Mobile
- [ ] Tap share → Native share sheet appears
- [ ] Share to WhatsApp works
- [ ] Cancel share → No error shown

### i18n
- [ ] Change to Indonesian → Button shows correct translation
- [ ] Toast messages translate correctly

### Analytics
- [ ] Check Umami for `speaker-shared` event
- [ ] Metadata includes `method` and `speakerId`

---

## Analytics Event

**Event name:** `speaker-shared`

**Metadata:**
```typescript
{
  method: 'native' | 'clipboard',
  speakerId: string,
}
```

**Implementation:** Already handled by `shareHelpers.ts` if you update the analytics tracking to support speakers.

---

## Files to Modify

### New Files
- None (all infrastructure exists)

### Modified Files
1. `/src/components/ShareButton.tsx` - Add speaker support
2. `/src/utils/shareHelpers.ts` - Add `generateSpeakerUrl()`
3. `/src/components/SpeakerCard.tsx` - Add share button (check actual component name)
4. `/src/components/SpeakersPage.tsx` - Add URL routing (check actual page component)
5. `/src/i18n/locales/*.json` - Add speaker translations (5 files)
6. `/src/components/SpeakerDetailModal.tsx` - Add share button (optional)

---

## Common Issues & Solutions

### Issue: ShareButton not appearing
**Solution:** Check which component is actually rendered. There may be multiple card components like `SpeakerCard`, `SpeakerPageCard`, `SpeakerBureauCard`, etc.

### Issue: TypeScript error on speaker prop
**Solution:** Import `Speaker` type from `/src/types/database.ts`

### Issue: Share button too large/prominent
**Solution:** Use className overrides: `!min-h-0 !min-w-0` to prevent 44px touch target on cards

### Issue: Icon color wrong
**Solution:** Ensure `iconClasses` logic handles both project and speaker cases

---

## Quality Gates

Before considering complete:
- ✅ Zero TypeScript errors (`npm run build`)
- ✅ Share button matches edit button styling
- ✅ All 5 languages work correctly
- ✅ Desktop clipboard + toast works
- ✅ URL routing works (incoming share links)
- ✅ Analytics tracking works
- ✅ Accessibility (keyboard nav, ARIA labels)

---

## Documentation

After completion, create dev journal:
- `/docs/dev-journals/2025-12-17-speakers-share-button.md`

Include:
- Files modified
- Any issues encountered
- Testing results
- Screenshots (optional)

---

## Commit Message Template

```
feat(georgetown): add Web Share API for speakers

Extend Web Share API to speaker cards, enabling native mobile
sharing and desktop clipboard fallback.

Changes:
- Update ShareButton to support both projects and speakers
- Add generateSpeakerUrl() to share utilities
- Integrate ShareButton into SpeakerCard components
- Add URL routing for /speakers?id=abc
- Add speaker translations to all 5 i18n locales

Styling matches Service Projects implementation:
- Discrete gray icon with Rotary blue hover
- 16px icon size, 44px touch target
- Positioned in card top-right corner

Analytics: speaker-shared event with method and speakerId

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Quick Start Commands

```bash
# Navigate to Georgetown app
cd /Users/randaleastman/dev/clubs/apps/georgetown

# Find speaker components
ls -la src/components/*[Ss]peaker*.tsx

# Start dev server
npm run dev

# Open speakers page
open http://localhost:5180/speakers

# Build to verify TypeScript
npm run build
```

---

## Reference Implementation

See Service Projects implementation:
- **Card integration:** `ServiceProjectPageCard.tsx` lines 28-42
- **Modal integration:** `ServiceProjectDetailModal.tsx` lines 40-44
- **URL routing:** `ServiceProjectsPage.tsx` lines 210-226
- **Share utilities:** `shareHelpers.ts` lines 120-130
- **Component design:** `ShareButton.tsx` complete file

---

## Questions?

If you encounter issues:
1. Check the Service Projects implementation first
2. Review the technical brief: `/docs/georgetown-rotary-share-api-brief.md`
3. Check the dev journal: `/docs/dev-journals/2025-12-17-web-share-api-service-projects.md`

---

**Prepared by:** CTO (Claude)
**Date:** 2025-12-17
**Estimated Time:** 1-2 hours
**Difficulty:** Easy (patterns established)
**Status:** Ready for implementation
