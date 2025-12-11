import { useState } from 'react'

export default function ErrorTest() {
  const [shouldThrow, setShouldThrow] = useState(false)

  if (shouldThrow) {
    throw new Error('Test error - Error boundary working!')
  }

  return (
    <div className="p-8 max-w-lg mx-auto">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-4">Error Boundary Test</h1>
        <p className="text-gray-600 mb-6">
          Click the button below to trigger an error and test the error boundary.
        </p>
        <button
          onClick={() => setShouldThrow(true)}
          className="w-full px-4 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium"
        >
          Trigger Error
        </button>
        <p className="text-sm text-gray-500 mt-4">
          This component is only available in development mode for testing purposes.
        </p>
      </div>
    </div>
  )
}
