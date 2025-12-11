import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { ViteImageOptimizer } from 'vite-plugin-image-optimizer'

// Read version from package.json
import packageJson from './package.json'

// https://vite.dev/config/
export default defineConfig({
  define: {
    __APP_VERSION__: JSON.stringify(packageJson.version)
  },
  plugins: [
    react(),
    // Custom plugin to add X-Robots-Tag headers for search engine blocking
    {
      name: 'robots-headers',
      configureServer(server) {
        server.middlewares.use('/', (_req, res, next) => {
          // Add comprehensive search engine blocking headers
          res.setHeader('X-Robots-Tag', 'noindex, nofollow, noarchive, nosnippet, noimageindex, notranslate')
          res.setHeader('X-Frame-Options', 'DENY')
          res.setHeader('X-Content-Type-Options', 'nosniff')
          next()
        })
      }
    },
    ViteImageOptimizer({
      test: /\.(jpe?g|png|gif|tiff|webp|svg|avif)$/i,
      includePublic: true,
      logStats: true,
      png: {
        quality: 80
      },
      jpeg: {
        quality: 75
      },
      jpg: {
        quality: 75
      },
      webp: {
        quality: 80
      },
      avif: {
        quality: 70
      },
      cache: false,
      cacheLocation: undefined
    })
  ],
  assetsInclude: ['**/*.svg'],
  build: {
    assetsDir: 'assets',
    rollupOptions: {
      output: {
        assetFileNames: (assetInfo) => {
          if (assetInfo.name?.endsWith('.svg')) {
            return 'assets/images/[name]-[hash][extname]'
          }
          if (assetInfo.name?.match(/\.(jpg|jpeg|png|gif|webp|avif)$/)) {
            return 'assets/images/[name]-[hash][extname]'
          }
          if (assetInfo.name?.match(/\.(woff|woff2|eot|ttf|otf)$/)) {
            return 'assets/fonts/[name]-[hash][extname]'
          }
          return 'assets/[name]-[hash][extname]'
        }
      }
    }
  }
})
