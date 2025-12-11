import { WifiOff, Wifi } from 'lucide-react'
import { useNetworkStatus } from '../hooks/useNetworkStatus'

export default function OfflineBanner() {
  const { isOnline, wasOffline } = useNetworkStatus()

  // Show "back online" message briefly
  if (isOnline && wasOffline) {
    return (
      <div className="fixed top-0 left-0 right-0 z-50 bg-green-600 text-white py-3 px-4 text-center shadow-lg animate-in slide-in-from-top">
        <div className="flex items-center justify-center gap-2">
          <Wifi size={20} />
          <span className="font-medium">Back online!</span>
        </div>
      </div>
    )
  }

  // Show offline message
  if (!isOnline) {
    return (
      <div className="fixed top-0 left-0 right-0 z-50 bg-amber-600 text-white py-3 px-4 text-center shadow-lg">
        <div className="flex items-center justify-center gap-2">
          <WifiOff size={20} />
          <span className="font-medium">
            You're offline. Some features may not work until you reconnect.
          </span>
        </div>
      </div>
    )
  }

  return null
}
