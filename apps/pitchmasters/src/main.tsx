import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'

// AGGRESSIVE SERVICE WORKER CLEANUP IN DEV MODE
// Prevents service worker conflicts during development
if (import.meta.env.DEV && 'serviceWorker' in navigator) {
  console.log('[Main] Dev mode detected - cleaning service workers...')

  // Unregister all service workers
  navigator.serviceWorker.getRegistrations()
    .then(registrations => {
      console.log(`[Main] Found ${registrations.length} service worker(s)`)
      return Promise.all(
        registrations.map(registration => {
          console.log('[Main] Unregistering:', registration.scope)
          return registration.unregister()
        })
      )
    })
    .then(() => caches.keys())
    .then(cacheNames => {
      console.log(`[Main] Found ${cacheNames.length} cache(s)`)
      return Promise.all(
        cacheNames.map(name => {
          console.log('[Main] Deleting cache:', name)
          return caches.delete(name)
        })
      )
    })
    .then(() => {
      console.log('[Main] ✅ Dev environment clean - HMR should work perfectly')
    })
    .catch(err => {
      console.error('[Main] Error cleaning service workers:', err)
    })
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)