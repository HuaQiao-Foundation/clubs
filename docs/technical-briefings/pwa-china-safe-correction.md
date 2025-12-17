# China-Safe PWA Implementation (Corrected)

**Created**: 2025-12-03
**Status**: CRITICAL CORRECTION
**Issue**: Original plan uses Google CDN (blocked in China)

---

## 🚨 Problem Identified

**Original Hugo implementation (Line 127 in main plan):**
```javascript
// ❌ BLOCKED IN CHINA
importScripts('https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js');
```

**Impact:**
- Service worker fails to install in China
- PWA completely broken for Chinese users
- Affects Global South audience (many access from China)

---

## ✅ Solution: Vanilla JavaScript Service Worker

### Replace Section 1.2 in Main Plan

**File**: `static/sw.js`

**China-Safe Implementation** (no external dependencies):

```javascript
// static/sw.js - China-Safe Service Worker (Vanilla JS)
// Version: 1.0.0

const CACHE_VERSION = 'brandmine-v1';
const CACHE_NAMES = {
  static: `${CACHE_VERSION}-static`,
  images: `${CACHE_VERSION}-images`,
  fonts: `${CACHE_VERSION}-fonts`,
  pages: `${CACHE_VERSION}-pages`
};

const STATIC_ASSETS = [
  '/offline.html',
  // Add other critical assets as needed
];

// Install event - precache critical assets
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker...');

  event.waitUntil(
    caches.open(CACHE_NAMES.static)
      .then(cache => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker...');

  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => {
            // Delete caches from old versions
            return name.startsWith('brandmine-') && !Object.values(CACHE_NAMES).includes(name);
          })
          .map(name => {
            console.log('[SW] Deleting old cache:', name);
            return caches.delete(name);
          })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Only handle same-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Images: Cache-first strategy
  if (request.destination === 'image') {
    event.respondWith(cacheFirst(request, CACHE_NAMES.images, {
      maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
      maxEntries: 100
    }));
    return;
  }

  // Fonts: Cache-first strategy (long-lived)
  if (request.destination === 'font') {
    event.respondWith(cacheFirst(request, CACHE_NAMES.fonts, {
      maxAge: 365 * 24 * 60 * 60 * 1000, // 1 year
      maxEntries: 30
    }));
    return;
  }

  // CSS/JS: Stale-while-revalidate strategy
  if (request.destination === 'style' || request.destination === 'script') {
    event.respondWith(staleWhileRevalidate(request, CACHE_NAMES.static, {
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      maxEntries: 60
    }));
    return;
  }

  // HTML pages: Network-first strategy
  if (request.destination === 'document' || request.mode === 'navigate') {
    event.respondWith(networkFirst(request, CACHE_NAMES.pages, {
      maxAge: 24 * 60 * 60 * 1000, // 1 day
      maxEntries: 50,
      timeout: 3000 // 3 seconds
    }));
    return;
  }

  // Default: network-first for everything else
  event.respondWith(networkFirst(request, CACHE_NAMES.static));
});

// Caching Strategies

/**
 * Cache-first: Serve from cache, fallback to network
 * Best for: Images, fonts, rarely-changing assets
 */
async function cacheFirst(request, cacheName, options = {}) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  if (cached) {
    // Check if cache entry is too old
    if (options.maxAge) {
      const cacheTime = await getCacheTime(cacheName, request.url);
      if (cacheTime && Date.now() - cacheTime > options.maxAge) {
        // Cache expired, refresh in background
        fetchAndCache(request, cacheName, options).catch(() => {});
      }
    }
    return cached;
  }

  // Not in cache, fetch from network
  return fetchAndCache(request, cacheName, options);
}

/**
 * Network-first: Try network, fallback to cache
 * Best for: HTML pages, frequently-changing content
 */
async function networkFirst(request, cacheName, options = {}) {
  const cache = await caches.open(cacheName);

  try {
    const response = await Promise.race([
      fetch(request),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('timeout')), options.timeout || 5000)
      )
    ]);

    if (response.ok) {
      // Cache successful response
      cache.put(request, response.clone()).catch(() => {});
      await setCacheTime(cacheName, request.url);
      await cleanupCache(cacheName, options.maxEntries);
    }

    return response;
  } catch (error) {
    // Network failed, try cache
    const cached = await cache.match(request);

    if (cached) {
      console.log('[SW] Network failed, serving cached:', request.url);
      return cached;
    }

    // No cache available, show offline page for navigation requests
    if (request.mode === 'navigate') {
      const offlinePage = await cache.match('/offline.html');
      if (offlinePage) {
        return offlinePage;
      }
    }

    throw error;
  }
}

/**
 * Stale-while-revalidate: Serve cached, update in background
 * Best for: CSS, JS, assets that should stay fresh
 */
async function staleWhileRevalidate(request, cacheName, options = {}) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  // Fetch fresh version in background
  const fetchPromise = fetchAndCache(request, cacheName, options).catch(() => {});

  // Return cached version immediately (if available)
  return cached || fetchPromise;
}

/**
 * Helper: Fetch and cache response
 */
async function fetchAndCache(request, cacheName, options = {}) {
  const response = await fetch(request);

  if (response.ok) {
    const cache = await caches.open(cacheName);
    cache.put(request, response.clone()).catch(() => {});
    await setCacheTime(cacheName, request.url);
    await cleanupCache(cacheName, options.maxEntries);
  }

  return response;
}

/**
 * Helper: Store cache timestamp
 */
async function setCacheTime(cacheName, url) {
  try {
    const timeCache = await caches.open(`${cacheName}-times`);
    const timeResponse = new Response(Date.now().toString());
    await timeCache.put(url, timeResponse);
  } catch (error) {
    // Silently fail - not critical
  }
}

/**
 * Helper: Get cache timestamp
 */
async function getCacheTime(cacheName, url) {
  try {
    const timeCache = await caches.open(`${cacheName}-times`);
    const timeResponse = await timeCache.match(url);
    if (timeResponse) {
      const time = await timeResponse.text();
      return parseInt(time, 10);
    }
  } catch (error) {
    // Silently fail
  }
  return null;
}

/**
 * Helper: Cleanup old cache entries (LRU)
 */
async function cleanupCache(cacheName, maxEntries) {
  if (!maxEntries) return;

  try {
    const cache = await caches.open(cacheName);
    const requests = await cache.keys();

    if (requests.length > maxEntries) {
      // Delete oldest entries (simple FIFO, could be enhanced with LRU)
      const deleteCount = requests.length - maxEntries;
      for (let i = 0; i < deleteCount; i++) {
        await cache.delete(requests[i]);
      }
    }
  } catch (error) {
    // Silently fail
  }
}
```

---

## Benefits of Vanilla JS Approach

### ✅ China Compliance
- **Zero external dependencies**: No Google CDN, no blocked domains
- **100% self-hosted**: All code served from brandmine.com
- **Verifiable**: Search build output for Google URLs → zero results

### ✅ Technical Advantages
- **Smaller**: ~5KB vs 150KB (Workbox bundle)
- **Faster**: No library parsing, direct execution
- **Transparent**: Can see exactly what it's doing
- **Maintainable**: Hugo is simple (static caching), doesn't need Workbox complexity

### ✅ Reliable
- **No library versions**: Can't break from Workbox updates
- **No CDN dependencies**: Works even if Google CDN goes down
- **Browser-native**: Uses only standard Service Worker API

---

## Complete File Checklist (China-Safe)

### Hugo Site Files

1. **`static/sw.js`** ✅
   - Vanilla JavaScript (no external imports)
   - All caching strategies implemented
   - ~5KB total size

2. **`static/offline.html`** ✅
   - Already in main plan (no changes needed)
   - Self-contained HTML/CSS
   - No external dependencies

3. **`static/site.webmanifest`** ✅
   - Already in main plan (no changes needed)
   - All assets self-hosted

4. **`layouts/_default/baseof.html`** ✅
   - Service worker registration (no changes needed)
   - Already China-safe

### Verification Checklist

Before deployment, run these checks:

```bash
# Check for Google domains in build
grep -R "googleapis" ./public
grep -R "gstatic" ./public
grep -R "google" ./public

# Expected result: No matches (or only in unrelated contexts like analytics)
```

---

## Hub Site Status

**No changes needed.** Hub implementation is already China-safe:

```typescript
VitePWA({
  // All Workbox code bundled locally by Vite
  // No Google CDN imports
  // ✅ China-compliant
})
```

---

## Testing China Compliance

### Local Testing

1. **Build Hugo site:**
   ```bash
   hugo --gc --minify
   ```

2. **Verify service worker has no external imports:**
   ```bash
   cat public/sw.js | grep "importScripts"
   # Expected: No matches

   cat public/sw.js | grep "google"
   # Expected: No matches
   ```

3. **Test in Chrome DevTools:**
   - Application → Service Workers
   - Should show "activated and running"
   - No errors in console

4. **Test offline mode:**
   - Network → Offline
   - Navigate to cached pages
   - Should work perfectly

### Production Verification

After deployment:

1. **Check service worker source:**
   ```bash
   curl https://brandmine.com/sw.js | grep "google"
   # Expected: No matches
   ```

2. **Test from China (or use VPN):**
   - Visit site from Chinese IP
   - Service worker should install
   - PWA should work offline

---

## Comparison: Original vs China-Safe

| Aspect | Original Plan | China-Safe Version |
|--------|--------------|-------------------|
| **Hugo SW** | Workbox CDN (Google) | Vanilla JS (self-hosted) |
| **Hub SW** | Vite PWA (bundled) | ✅ No change needed |
| **China Access** | ❌ Blocked | ✅ Works |
| **File Size** | 150KB | 5KB |
| **Dependencies** | Workbox library | Zero |
| **Reliability** | CDN-dependent | Self-contained |
| **Maintenance** | Library updates | Stable (vanilla JS) |

---

## Update Required in Main Plan

**Replace section 1.2 "Create Service Worker"** with this China-safe implementation.

**Keep everything else:**
- ✅ Section 1.1: Enhance Web Manifest (no changes)
- ✅ Section 1.3: Register Service Worker (no changes)
- ✅ Section 1.4: Create Offline Page (no changes)
- ✅ Section 1.5: Custom Install Prompt (no changes)
- ✅ Phase 2: Hub Site (already China-safe)

---

## Final Verification

Before marking PWA implementation complete:

### Required Checks

- [ ] `public/sw.js` contains NO `importScripts()` calls
- [ ] `public/sw.js` contains NO Google domains
- [ ] Service worker activates successfully in DevTools
- [ ] Offline mode works (cached pages load)
- [ ] PWA installs on mobile devices
- [ ] Lighthouse PWA score: 100/100
- [ ] Test from Chinese IP or VPN (optional but recommended)

---

## Conclusion

**Original Plan Status**: ❌ **NOT China-safe** (Hugo site uses Google CDN)

**Corrected Plan Status**: ✅ **China-safe** (both sites fully compliant)

**Action Required**: Replace section 1.2 in main plan with vanilla JS implementation above.

**Hub Site**: ✅ No changes needed (already compliant).

---

**Next Steps**:
1. Randal approves China-safe correction
2. CTO implements vanilla JS service worker (Hugo)
3. Test thoroughly (including China compliance checks)
4. Deploy with confidence
