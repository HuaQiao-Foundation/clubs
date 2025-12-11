/**
 * Client-side image compression utility
 * Compresses images before uploading to Supabase Storage
 * Target: Max 1200px width, <500KB file size
 */

export interface CompressImageOptions {
  maxWidth?: number
  maxHeight?: number
  quality?: number
  maxSizeKB?: number
}

const DEFAULT_OPTIONS: Required<CompressImageOptions> = {
  maxWidth: 1200,
  maxHeight: 1200,
  quality: 0.85,
  maxSizeKB: 500,
}

/**
 * Compress an image file using Canvas API
 * @param file Original image file
 * @param options Compression options
 * @returns Compressed image as Blob
 */
export async function compressImage(
  file: File,
  options: CompressImageOptions = {}
): Promise<Blob> {
  const opts = { ...DEFAULT_OPTIONS, ...options }

  return new Promise((resolve, reject) => {
    const reader = new FileReader()

    reader.onerror = () => reject(new Error('Failed to read file'))

    reader.onload = (e) => {
      const img = new Image()

      img.onerror = () => reject(new Error('Failed to load image'))

      img.onload = () => {
        // Calculate new dimensions
        let { width, height } = img

        if (width > opts.maxWidth || height > opts.maxHeight) {
          const aspectRatio = width / height

          if (width > height) {
            width = opts.maxWidth
            height = Math.round(width / aspectRatio)
          } else {
            height = opts.maxHeight
            width = Math.round(height * aspectRatio)
          }
        }

        // Create canvas and compress
        const canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height

        const ctx = canvas.getContext('2d')
        if (!ctx) {
          reject(new Error('Failed to get canvas context'))
          return
        }

        // Preserve transparency for PNG images
        const isPNG = file.type === 'image/png'
        if (isPNG) {
          // Clear canvas with transparent background for PNG
          ctx.clearRect(0, 0, width, height)
        }

        ctx.drawImage(img, 0, 0, width, height)

        // Determine output format (preserve PNG, convert others to JPEG)
        const outputFormat = isPNG ? 'image/png' : 'image/jpeg'

        // Try different quality levels until we meet size requirements
        let quality = opts.quality
        const tryCompress = () => {
          canvas.toBlob(
            (blob) => {
              if (!blob) {
                reject(new Error('Failed to compress image'))
                return
              }

              const sizeKB = blob.size / 1024

              // If still too large and quality can be reduced, try again
              if (sizeKB > opts.maxSizeKB && quality > 0.5) {
                quality -= 0.1
                tryCompress()
              } else {
                resolve(blob)
              }
            },
            outputFormat,
            quality
          )
        }

        tryCompress()
      }

      img.src = e.target?.result as string
    }

    reader.readAsDataURL(file)
  })
}

/**
 * Validate image file type
 */
export function isValidImageType(file: File): boolean {
  const validTypes = ['image/jpeg', 'image/png', 'image/webp']
  return validTypes.includes(file.type)
}

/**
 * Format file size for display
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}
