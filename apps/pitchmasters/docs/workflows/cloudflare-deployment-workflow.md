# Cloudflare Pages Deployment Guide

## Prerequisites
- Cloudflare account (free tier works)
- GitHub repository connected
- Supabase project credentials

## Step 1: Create Cloudflare Pages Project

### Via Dashboard
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select "Pages" from left sidebar
3. Click "Create a project"
4. Connect to GitHub and select `pitchmasters-toastmasters` repository
5. Choose production branch: `main`

### Build Configuration
```yaml
Build command: npm run build
Build output directory: dist
Root directory: /
Environment variables: (see below)
```

## Step 2: Environment Variables

Add these in Cloudflare Pages settings:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# Environment
VITE_APP_ENV=production

# Optional: Feature Flags
VITE_ENABLE_ANALYTICS=false
VITE_CHINA_MODE=true
```

## Step 3: Build Settings Optimization

Create/update `wrangler.toml` for local testing:
```toml
name = "pitchmasters"
compatibility_date = "2024-01-01"

[site]
bucket = "./dist"

[env.production]
name = "pitchmasters-production"

[env.preview]
name = "pitchmasters-preview"
```

## Step 4: Vite Configuration for Cloudflare

Update `vite.config.ts`:
```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          supabase: ['@supabase/supabase-js'],
          ui: ['lucide-react', '@dnd-kit/sortable'],
          utils: ['date-fns', 'clsx']
        }
      }
    }
  },
  server: {
    port: 3000,
    host: true
  }
});
```

## Step 5: Deployment Process

### Automatic Deployment (Recommended)
1. Push to `main` branch
2. Cloudflare automatically builds and deploys
3. Preview deployments created for pull requests

### Manual Deployment
```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Build project
npm run build

# Deploy to Cloudflare Pages
wrangler pages deploy dist --project-name=pitchmasters
```

## Step 6: Custom Domain Setup

### Add Custom Domain
1. Go to Pages project settings
2. Click "Custom domains" tab
3. Add domain: `pitchmasters.com` or subdomain
4. Follow DNS configuration instructions

### DNS Configuration
```
Type: CNAME
Name: @ (or subdomain)
Content: pitchmasters.pages.dev
Proxy status: Proxied (orange cloud)
```

## Step 7: Security & Privacy Configuration

### Block Search Engines & Bots
1. **Verify robots.txt**: Ensure `/public/robots.txt` is deployed
2. **Check _headers file**: Confirm `/public/_headers` is processed
3. **Page Rules**: Add rule to bypass cache for all pages
4. **Firewall Rules**: Block known bot user agents

### Cloudflare Security Settings
1. **Security Level**: Set to "High" for all paths
2. **Challenge Passage**: 30 minutes
3. **Browser Integrity Check**: Enable
4. **Bot Fight Mode**: Enable (blocks automated traffic)
5. **Rate Limiting**: 10 requests per minute per IP

## Step 8: Performance Optimization

### Cloudflare Settings
1. **Caching**: Set to "Bypass" for private content
2. **Compression**: Enable Brotli compression
3. **Minification**: Enable HTML/CSS/JS minification
4. **HTTP/3**: Enable QUIC protocol
5. **Early Hints**: Enable for faster resource loading

### Page Rules (Optional)
```
/*.js - Cache Level: Cache Everything, Edge Cache TTL: 1 month
/*.css - Cache Level: Cache Everything, Edge Cache TTL: 1 month
/assets/* - Cache Level: Cache Everything, Edge Cache TTL: 1 year
```

## Step 8: China Accessibility Verification

### Testing Methods
1. **Proxy Testing**: Use China-based VPN to test access
2. **Great Firewall Test**: Use [chinafirewalltest.com](https://www.chinafirewalltest.com/)
3. **Speed Test**: Use [dotcom-tools.com](https://www.dotcom-tools.com/website-speed-test) China locations

### Expected Results
- Load time < 5 seconds from China
- All assets load without external dependencies
- No Google Fonts or CDN failures
- Supabase connections work

## Step 9: Monitoring & Analytics

### Cloudflare Analytics
- Real User Monitoring (RUM)
- Core Web Vitals tracking
- Geographic performance data
- Error rate monitoring

### Custom Analytics (Optional)
```javascript
// Add to App.tsx for basic analytics
if (import.meta.env.VITE_ENABLE_ANALYTICS === 'true') {
  // Cloudflare Web Analytics
  const script = document.createElement('script');
  script.defer = true;
  script.src = 'https://static.cloudflareinsights.com/beacon.min.js';
  script.setAttribute('data-cf-beacon', '{"token": "your-token"}');
  document.head.appendChild(script);
}
```

## Troubleshooting

### Build Failures
```bash
# Check Node version (should be 18.x or higher)
node --version

# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Test build locally
npm run build
```

### Environment Variables Not Working
- Ensure variables start with `VITE_`
- Rebuild after adding variables
- Check preview vs production settings

### China Access Issues
- Verify no external CDN dependencies
- Check for Google Fonts references
- Ensure all assets are self-hosted
- Test Supabase connectivity

## Rollback Procedure

If issues occur after deployment:

1. **Immediate Rollback**:
   - Go to Cloudflare Pages dashboard
   - Click on deployment history
   - Select previous working deployment
   - Click "Rollback to this deployment"

2. **DNS Fallback** (if domain issues):
   - Keep Vercel deployment as backup
   - Update DNS to point back to Vercel
   - Fix issues in development
   - Retry Cloudflare deployment

## Success Checklist

- [ ] Cloudflare Pages project created
- [ ] Environment variables configured
- [ ] Build succeeds without errors
- [ ] Site loads at `.pages.dev` URL
- [ ] Custom domain configured (if applicable)
- [ ] China accessibility verified
- [ ] Performance metrics acceptable
- [ ] Supabase connections working
- [ ] Mobile responsive verified
- [ ] Toastmasters brand compliance maintained

## Support Resources

- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Vite Static Deploy Guide](https://vitejs.dev/guide/static-deploy.html#cloudflare-pages)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [Cloudflare Community](https://community.cloudflare.com/)

---

*Last Updated: September 29, 2025*
*Maintained by: Claude Code (CTO)*