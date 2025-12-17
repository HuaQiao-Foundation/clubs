# Technical Brief: Project Share Button (Web Share API)

**Priority**: Enhancement  
**Requested by**: Chairman Frank Yih  
**Reviewed by**: Brandmine (COO)  
**Date**: 2025-12-17  
**Status**: Ready for Implementation  
**Platform**: HuaQiao Bridge / Georgetown Rotary App

---

## Executive Summary

Implement native sharing capability for service projects using the Web Share API. This enables PWA users to share project links through their device's native share sheet (WhatsApp, Telegram, WeChat, LINE, Email, etc.) with a single tap—matching the experience of native apps.

**Strategic Value**: Easy sharing is critical for connecting Rotary/Rotaract clubs with funding partners. The "missing middle" of $5,000–$15,000 projects depends on word-of-mouth discovery through messaging apps popular in ASEAN markets.

---

## User Stories

**As a** Rotaract club member on mobile  
**I want to** tap a share button on any service project  
**So that** I can quickly send the project link to a potential funding partner via WhatsApp or LINE

**As a** HuaQiao Foundation staff member  
**I want to** share YeYaYa Recommended projects  
**So that** I can promote vetted projects to our donor network

**As a** funding partner browsing projects  
**I want to** share interesting opportunities with my organization  
**So that** we can collectively evaluate which projects to support

---

## Technical Requirements

### Core Implementation

**API**: Web Share API (`navigator.share()`)

**Reference Documentation**:
- MDN: https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API
- web.dev: https://web.dev/articles/web-share

### Share Data Structure

```javascript
const shareData = {
  title: '{{ .Title }}',                                    // Project title
  text: '{{ .Description | default .Summary | truncate 150 }}',  // Project summary
  url: '{{ .Permalink }}'                                   // Canonical URL
};
```

### Browser Support Strategy

| Platform | Support | Fallback | ASEAN Relevance |
|----------|---------|----------|-----------------|
| iOS Safari | ✅ Native share sheet | — | High (urban users) |
| Android Chrome | ✅ Native share sheet | — | **Critical** (primary platform) |
| Desktop Chrome | ✅ (HTTPS required) | Clipboard | Medium |
| Desktop Firefox | ⚠️ Limited | Clipboard | Low |
| Desktop Safari | ✅ macOS Monterey+ | Clipboard | Low |

**Fallback**: Copy URL to clipboard with toast notification confirmation.

**Note**: Android dominates ASEAN mobile markets (Indonesia 90%+, Philippines 85%+, Vietnam 80%+). Native share integration with WhatsApp, LINE, and local messaging apps is essential.

---

## Implementation Specification

### 1. JavaScript Module

**File**: `assets/js/share.js`

```javascript
/**
 * Web Share API implementation for HuaQiao Bridge PWA
 * Provides native sharing on supported devices with clipboard fallback
 * 
 * Primary use case: Sharing service projects to messaging apps
 * Target platforms: WhatsApp, LINE, Telegram, WeChat (via clipboard)
 */

async function shareProject(title, text, url) {
  const shareData = { title, text, url };

  try {
    if (navigator.share && navigator.canShare && navigator.canShare(shareData)) {
      // Native share dialog - opens WhatsApp, LINE, Telegram, etc.
      await navigator.share(shareData);
      
      // Optional: Track share event for analytics
      if (typeof trackEvent === 'function') {
        trackEvent('project_shared', { method: 'native', url: url });
      }
    } else {
      // Fallback: copy to clipboard (works for WeChat paste)
      await copyToClipboard(url);
    }
  } catch (err) {
    if (err.name !== 'AbortError') {
      // User didn't cancel—actual error occurred
      console.error('Share failed:', err);
      await copyToClipboard(url);
    }
    // AbortError means user canceled share sheet - no action needed
  }
}

async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    showToast(getLocalizedMessage('link_copied'));
  } catch (err) {
    // Final fallback for older browsers
    fallbackCopyToClipboard(text);
  }
}

function fallbackCopyToClipboard(text) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-9999px';
  textArea.style.top = '0';
  textArea.setAttribute('readonly', '');  // Prevent keyboard popup on mobile
  document.body.appendChild(textArea);
  textArea.select();
  
  try {
    document.execCommand('copy');
    showToast(getLocalizedMessage('link_copied'));
  } catch (err) {
    showToast(getLocalizedMessage('copy_failed'));
  }
  
  document.body.removeChild(textArea);
}

function showToast(message) {
  // Check if toast container exists, create if not
  let toastContainer = document.querySelector('.toast-container');
  if (!toastContainer) {
    toastContainer = document.createElement('div');
    toastContainer.className = 'toast-container';
    document.body.appendChild(toastContainer);
  }

  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  toast.setAttribute('role', 'status');
  toast.setAttribute('aria-live', 'polite');
  
  toastContainer.appendChild(toast);

  // Trigger animation
  requestAnimationFrame(() => {
    toast.classList.add('toast--visible');
  });

  // Remove after 3 seconds
  setTimeout(() => {
    toast.classList.remove('toast--visible');
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

/**
 * Get localized message based on current language
 * Supports: English, Bahasa Indonesia, Thai, Tagalog, Chinese
 */
function getLocalizedMessage(key) {
  const lang = document.documentElement.lang || 'en';
  const messages = {
    en: {
      link_copied: 'Link copied to clipboard',
      copy_failed: 'Unable to copy link'
    },
    id: {
      link_copied: 'Tautan disalin ke clipboard',
      copy_failed: 'Tidak dapat menyalin tautan'
    },
    th: {
      link_copied: 'คัดลอกลิงก์แล้ว',
      copy_failed: 'ไม่สามารถคัดลอกลิงก์ได้'
    },
    tl: {
      link_copied: 'Nakopya ang link sa clipboard',
      copy_failed: 'Hindi makopya ang link'
    },
    zh: {
      link_copied: '链接已复制',
      copy_failed: '无法复制链接'
    }
  };
  
  const langMessages = messages[lang] || messages['en'];
  return langMessages[key] || messages['en'][key];
}

// Export for templates
window.shareProject = shareProject;
```

### 2. React Component (for HuaQiao Bridge)

**File**: `src/components/ShareButton.tsx`

```typescript
/**
 * ShareButton Component for HuaQiao Bridge
 * Implements Web Share API with clipboard fallback
 */

import React, { useState, useCallback } from 'react';
import { useTranslation } from 'react-i18next';

interface ShareButtonProps {
  title: string;
  description: string;
  url: string;
  variant?: 'default' | 'floating' | 'icon-only';
  className?: string;
}

export const ShareButton: React.FC<ShareButtonProps> = ({
  title,
  description,
  url,
  variant = 'default',
  className = ''
}) => {
  const { t } = useTranslation();
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const displayToast = useCallback((message: string) => {
    setToastMessage(message);
    setShowToast(true);
    setTimeout(() => setShowToast(false), 3000);
  }, []);

  const copyToClipboard = useCallback(async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      displayToast(t('share.link_copied'));
    } catch (err) {
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = text;
      textArea.style.position = 'fixed';
      textArea.style.left = '-9999px';
      textArea.setAttribute('readonly', '');
      document.body.appendChild(textArea);
      textArea.select();
      
      try {
        document.execCommand('copy');
        displayToast(t('share.link_copied'));
      } catch {
        displayToast(t('share.copy_failed'));
      }
      
      document.body.removeChild(textArea);
    }
  }, [displayToast, t]);

  const handleShare = useCallback(async () => {
    const shareData = {
      title,
      text: description.substring(0, 150),
      url
    };

    try {
      if (navigator.share && navigator.canShare?.(shareData)) {
        await navigator.share(shareData);
      } else {
        await copyToClipboard(url);
      }
    } catch (err) {
      if ((err as Error).name !== 'AbortError') {
        console.error('Share failed:', err);
        await copyToClipboard(url);
      }
    }
  }, [title, description, url, copyToClipboard]);

  const buttonClasses = {
    default: 'share-button',
    floating: 'share-button share-button--floating',
    'icon-only': 'share-button share-button--icon-only'
  };

  return (
    <>
      <button
        className={`${buttonClasses[variant]} ${className}`}
        onClick={handleShare}
        aria-label={t('share.share_project')}
        title={t('share.share_project')}
      >
        <svg 
          className="share-button__icon" 
          width="20" 
          height="20" 
          viewBox="0 0 24 24" 
          fill="none" 
          stroke="currentColor" 
          strokeWidth="2" 
          strokeLinecap="round" 
          strokeLinejoin="round" 
          aria-hidden="true"
        >
          <circle cx="18" cy="5" r="3"/>
          <circle cx="6" cy="12" r="3"/>
          <circle cx="18" cy="19" r="3"/>
          <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
          <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
        </svg>
        {variant !== 'icon-only' && (
          <span className="share-button__text">{t('share.share')}</span>
        )}
      </button>

      {/* Toast Notification */}
      {showToast && (
        <div className="toast-container">
          <div 
            className="toast toast--visible" 
            role="status" 
            aria-live="polite"
          >
            {toastMessage}
          </div>
        </div>
      )}
    </>
  );
};

export default ShareButton;
```

### 3. CSS Styles

**File**: `src/styles/components/share.css`

```css
/* ==========================================================================
   Share Button Component - HuaQiao Bridge
   Uses Rotary cardinal red as accent color
   ========================================================================== */

:root {
  --rotary-red: #C41230;
  --rotary-red-dark: #9E0E27;
  --rotary-gold: #F7A81B;
}

.share-button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: transparent;
  border: 1px solid var(--color-border, #e0e0e0);
  border-radius: 0.375rem;
  color: var(--color-text-secondary, #666);
  font-size: 0.875rem;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.2s ease;
}

.share-button:hover {
  background: var(--rotary-red);
  color: white;
  border-color: var(--rotary-red);
}

.share-button:focus-visible {
  outline: 2px solid var(--rotary-gold);
  outline-offset: 2px;
}

.share-button:active {
  background: var(--rotary-red-dark);
  border-color: var(--rotary-red-dark);
}

.share-button__icon {
  flex-shrink: 0;
}

/* Icon-only variant */
.share-button--icon-only {
  padding: 0.5rem;
}

.share-button--icon-only .share-button__text {
  display: none;
}

/* Hide text on mobile, show icon only */
@media (max-width: 414px) {
  .share-button:not(.share-button--floating) .share-button__text {
    display: none;
  }
  
  .share-button:not(.share-button--floating) {
    padding: 0.5rem;
  }
}

/* ==========================================================================
   Floating Action Button (Mobile)
   ========================================================================== */

.share-button--floating {
  position: fixed;
  bottom: 1.5rem;
  right: 1rem;
  background: var(--rotary-red);
  color: white;
  border: none;
  border-radius: 50%;
  width: 56px;
  height: 56px;
  padding: 0;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(196, 18, 48, 0.3);
  z-index: 100;
}

.share-button--floating:hover {
  background: var(--rotary-red-dark);
  transform: scale(1.05);
}

.share-button--floating .share-button__text {
  display: none;
}

.share-button--floating .share-button__icon {
  width: 24px;
  height: 24px;
}

/* Only show floating button on mobile */
@media (min-width: 769px) {
  .share-button--floating {
    display: none;
  }
}

/* ==========================================================================
   Toast Notification
   ========================================================================== */

.toast-container {
  position: fixed;
  bottom: 5rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 9999;
  pointer-events: none;
}

.toast {
  background: #1a1a1a;
  color: white;
  padding: 0.75rem 1rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  opacity: 0;
  transform: translateY(1rem);
  transition: opacity 0.3s ease, transform 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  white-space: nowrap;
}

.toast--visible {
  opacity: 1;
  transform: translateY(0);
}

/* Adjust toast position when floating button is present */
@media (max-width: 768px) {
  .toast-container {
    bottom: 6rem;
  }
}
```

### 4. i18n Translations

**File**: `public/locales/en/translation.json` (partial)

```json
{
  "share": {
    "share": "Share",
    "share_project": "Share this project",
    "share_initiative": "Share this initiative",
    "link_copied": "Link copied to clipboard",
    "copy_failed": "Unable to copy link"
  }
}
```

**File**: `public/locales/id/translation.json` (Bahasa Indonesia)

```json
{
  "share": {
    "share": "Bagikan",
    "share_project": "Bagikan proyek ini",
    "share_initiative": "Bagikan inisiatif ini",
    "link_copied": "Tautan disalin ke clipboard",
    "copy_failed": "Tidak dapat menyalin tautan"
  }
}
```

**File**: `public/locales/th/translation.json` (Thai)

```json
{
  "share": {
    "share": "แชร์",
    "share_project": "แชร์โครงการนี้",
    "share_initiative": "แชร์กิจกรรมนี้",
    "link_copied": "คัดลอกลิงก์แล้ว",
    "copy_failed": "ไม่สามารถคัดลอกลิงก์ได้"
  }
}
```

**File**: `public/locales/tl/translation.json` (Tagalog)

```json
{
  "share": {
    "share": "Ibahagi",
    "share_project": "Ibahagi ang proyektong ito",
    "share_initiative": "Ibahagi ang inisyatibang ito",
    "link_copied": "Nakopya ang link sa clipboard",
    "copy_failed": "Hindi makopya ang link"
  }
}
```

**File**: `public/locales/zh/translation.json` (Chinese - for HQF staff)

```json
{
  "share": {
    "share": "分享",
    "share_project": "分享此项目",
    "share_initiative": "分享此倡议",
    "link_copied": "链接已复制",
    "copy_failed": "无法复制链接"
  }
}
```

---

## Placement Options

### Option A: Project Card Header (Recommended for Browse View)

Place share button in project card for easy sharing while browsing.

```tsx
// In ProjectCard component
<article className="project-card">
  <header className="project-card__header">
    <h3>{project.title}</h3>
    <ShareButton
      title={project.title}
      description={project.summary}
      url={`/projects/${project.id}`}
      variant="icon-only"
    />
  </header>
  {/* ... rest of card */}
</article>
```

**Pros**: Share without opening full project page, efficient for browsing  
**Cons**: Smaller touch target

### Option B: Project Detail Header (Recommended for Detail View)

Place share button prominently in project detail header.

```tsx
// In ProjectDetail component
<header className="project-detail__header">
  <div className="project-detail__badges">
    {project.yeYaYaRecommended && <YeYaYaBadge />}
    {project.sdgTags.map(tag => <SDGBadge key={tag} tag={tag} />)}
  </div>
  <h1>{project.title}</h1>
  <div className="project-detail__meta">
    <span className="project-detail__club">{project.clubName}</span>
    <span className="project-detail__funding">
      ${project.fundingNeeded.toLocaleString()} needed
    </span>
    <ShareButton
      title={project.title}
      description={project.summary}
      url={window.location.href}
    />
  </div>
</header>
```

**Pros**: Always visible, conventional placement  
**Cons**: Less prominent than floating button

### Option C: Floating Action Button (Mobile - Recommended)

Fixed position button in bottom-right corner on mobile devices.

```tsx
// Render conditionally on mobile
{isMobile && (
  <ShareButton
    title={project.title}
    description={project.summary}
    url={window.location.href}
    variant="floating"
  />
)}
```

**Pros**: Thumb-friendly on mobile, always accessible while scrolling  
**Cons**: May overlap content, requires z-index management

### **Recommendation: Option B + C Combined**

- **Desktop**: Share button in project detail header
- **Mobile**: Both header button AND floating action button
- **Browse view**: Icon-only share on each project card

---

## Content Types to Include

| Content Type | Include Share Button | Priority | Notes |
|--------------|---------------------|----------|-------|
| Service Projects | ✅ Yes | **Critical** | Primary share target for funding |
| YeYaYa Recommended Projects | ✅ Yes | **Critical** | Premium vetted projects |
| YeYaYa Gift of Mobility Updates | ✅ Yes | High | Program awareness |
| Club Profiles | ✅ Yes | Medium | Club recruitment |
| Funding Partner Spotlights | ✅ Yes | Medium | Donor recognition |
| SDG Category Pages | ❌ No | — | Navigation pages |
| Search Results | ❌ No | — | Dynamic pages |
| User Dashboard | ❌ No | — | Private content |

---

## Acceptance Criteria

### Functional Requirements
- [ ] Share button appears on all service project detail pages
- [ ] Share button appears on all project cards in browse view (icon-only)
- [ ] Share button appears on YeYaYa program pages
- [ ] Share button appears on club profile pages
- [ ] Tapping share on mobile opens native share sheet
- [ ] Clicking share on desktop copies link and shows toast
- [ ] Toast notification disappears after 3 seconds
- [ ] Floating button appears only on mobile (≤768px)

### Accessibility Requirements
- [ ] Button is keyboard navigable (Tab focus, Enter/Space activate)
- [ ] Button has appropriate ARIA labels
- [ ] Toast has `role="status"` and `aria-live="polite"`
- [ ] Focus visible indicator uses Rotary gold (#F7A81B)
- [ ] Color contrast meets WCAG AA standards

### Internationalization Requirements
- [ ] Translations work correctly (EN/ID/TH/TL/ZH)
- [ ] Toast messages display in current language
- [ ] RTL support not required (no target languages use RTL)

### Technical Requirements
- [ ] No external dependencies (works offline after initial load)
- [ ] Compatible with React 19 + TypeScript
- [ ] Follows existing component patterns
- [ ] Works in China (no blocked APIs)
- [ ] Works in restricted networks (Indonesia, Vietnam)

---

## Testing Checklist

### Device & Browser Testing

| Device | Browser | Expected Behavior | Tested |
|--------|---------|-------------------|--------|
| iPhone 14 | Safari | Native share sheet | [ ] |
| iPhone 14 | Chrome | Native share sheet | [ ] |
| Samsung Galaxy | Chrome | Native share sheet | [ ] |
| Samsung Galaxy | Samsung Internet | Native share sheet | [ ] |
| Xiaomi (MIUI) | Chrome | Native share sheet | [ ] |
| Oppo/Vivo | Chrome | Native share sheet | [ ] |
| MacBook | Chrome | Clipboard + toast | [ ] |
| MacBook | Safari | Native share or clipboard | [ ] |
| Windows | Chrome | Clipboard + toast | [ ] |
| Windows | Firefox | Clipboard + toast | [ ] |

### Messaging App Integration Testing

| App | Platform | Share Works | Notes |
|-----|----------|-------------|-------|
| WhatsApp | Android/iOS | [ ] | Primary ASEAN channel |
| LINE | Android/iOS | [ ] | Thailand, Indonesia |
| Telegram | Android/iOS | [ ] | Tech-savvy users |
| WeChat | iOS | [ ] | Via clipboard paste |
| Facebook Messenger | Android/iOS | [ ] | Philippines |
| Email | All | [ ] | Formal sharing |

### Accessibility Testing
- [ ] Keyboard navigation (Tab to focus, Enter to activate)
- [ ] Screen reader announces "Share this project"
- [ ] VoiceOver (iOS) reads button correctly
- [ ] TalkBack (Android) reads button correctly
- [ ] Focus visible on button (gold outline)

### Edge Cases
- [ ] User cancels share sheet (no error shown)
- [ ] Clipboard API unavailable (fallback execCommand works)
- [ ] Very long project titles (truncated in share text)
- [ ] Special characters in title/description (escaped properly)
- [ ] Offline state (button still visible, clipboard fallback works)
- [ ] Slow network (no blocking on share action)

---

## Files to Create/Modify

### New Files
| File | Purpose |
|------|---------|
| `src/components/ShareButton.tsx` | React share button component |
| `src/styles/components/share.css` | Share button and toast styles |
| `public/locales/id/translation.json` | Bahasa Indonesia translations |
| `public/locales/th/translation.json` | Thai translations |
| `public/locales/tl/translation.json` | Tagalog translations |

### Modified Files
| File | Changes |
|------|---------|
| `public/locales/en/translation.json` | Add share translations |
| `public/locales/zh/translation.json` | Add share translations |
| `src/pages/ProjectDetail.tsx` | Include ShareButton component |
| `src/components/ProjectCard.tsx` | Include icon-only ShareButton |
| `src/styles/main.css` | Import share.css |

---

## Implementation Notes

### WeChat Considerations

WeChat on iOS blocks the Web Share API. The clipboard fallback is intentional—users can:
1. Tap share → "Link copied" toast appears
2. Open WeChat
3. Paste link in chat

**UX Enhancement** (optional): Detect WeChat browser and show "Copy & paste to share in WeChat" message instead of generic clipboard message.

```javascript
function isWeChat() {
  return /MicroMessenger/i.test(navigator.userAgent);
}

// In toast message logic
const message = isWeChat() 
  ? t('share.copy_for_wechat')  // "Link copied - paste in WeChat to share"
  : t('share.link_copied');
```

### Analytics Integration (Optional)

Track share events for understanding content virality:

```typescript
const handleShare = async () => {
  // ... share logic ...
  
  // Track successful shares
  analytics.track('project_shared', {
    projectId: project.id,
    method: navigator.share ? 'native' : 'clipboard',
    projectType: project.yeYaYaRecommended ? 'yeya_recommended' : 'standard',
    fundingGoal: project.fundingNeeded,
    sdgTags: project.sdgTags
  });
};
```

### Performance Considerations

- Share button renders immediately (no lazy loading needed)
- Toast container created on first share (not on page load)
- No external API calls during share action
- CSS transitions use GPU-accelerated properties (`transform`, `opacity`)

---

## Timeline Estimate

| Phase | Tasks | Duration |
|-------|-------|----------|
| 1. Setup | Create component, styles, base translations | 2 hours |
| 2. Integration | Add to ProjectDetail, ProjectCard pages | 2 hours |
| 3. i18n | Complete all 5 language translations | 1 hour |
| 4. Testing | Device testing, accessibility audit | 3 hours |
| 5. Polish | Edge cases, WeChat detection, analytics | 2 hours |

**Total Estimate**: 10 hours

---

## References

- MDN Web Share API: https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API
- web.dev PWA Share: https://web.dev/articles/web-share
- Can I Use - Web Share: https://caniuse.com/web-share
- React TypeScript Cheatsheet: https://react-typescript-cheatsheet.netlify.app/

---

## Approval

| Role | Name | Status |
|------|------|--------|
| Chairman | Frank Yih | Requested |
| COO | Brandmine (Claude) | ✅ Reviewed |
| CTO | Georgetown Rotary Dev | Pending |

---

**Prepared by**: Brandmine (COO)  
**For**: CTO (Georgetown Rotary Development)  
**Platform**: HuaQiao Bridge (bridge.huaqiao.asia)  
**Repository**: brandomy/huaqiao-bridge
