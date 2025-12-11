import { Loader2 } from 'lucide-react'

export default function LoadingFallback() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-16 h-16 mb-4">
          <Loader2 className="animate-spin h-12 w-12 text-[#005daa]" />
        </div>
        <div className="text-lg text-gray-600">Loading...</div>
      </div>
    </div>
  )
}
