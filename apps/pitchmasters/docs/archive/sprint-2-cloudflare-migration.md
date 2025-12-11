# Sprint 2: Cloudflare Pages Migration

## Sprint Overview
**Dates**: September 29, 2025 - October 13, 2025
**Goal**: Migrate Pitchmasters from Vercel to Cloudflare Pages for China accessibility
**Priority**: Critical - Current Vercel deployment blocked in China
**Points**: 8 story points planned

## Business Context
### Problem Statement
Vercel's infrastructure is incompatible with China's network requirements, blocking access for potential club members in Asia's largest market. This migration is critical for Pitchmasters' mission to serve startup founders globally.

### Success Criteria
1. ✅ Application accessible from mainland China without VPN
2. ✅ Performance maintains <3 second load time globally
3. ✅ All Supabase integrations remain functional
4. ✅ Zero downtime during migration
5. ✅ Toastmasters brand compliance maintained

## Technical Approach

### Phase 1: Setup & Configuration (Day 1-2)
**Objective**: Establish Cloudflare Pages project with proper build configuration

**Tasks**:
1. Create Cloudflare account
2. Initialize Pages project
3. Configure Vite build settings for Cloudflare
4. Set up environment variables for Supabase

**Technical Details**:
```javascript
// vite.config.ts adjustments for Cloudflare
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: false, // Disable for production
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          ui: ['lucide-react', '@dnd-kit/sortable'],
          utils: ['date-fns', 'clsx']
        }
      }
    }
  }
});
```

### Phase 2: Environment Migration (Day 3-4)
**Objective**: Transfer all configuration from Vercel to Cloudflare

**Environment Variables Required**:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VITE_APP_ENV` (production/preview/development)

**Build Command**: `npm run build`
**Output Directory**: `dist`
**Node Version**: 18.x or higher

### Phase 3: Deployment & Testing (Day 5-6)
**Objective**: Deploy application and validate functionality

**Testing Checklist**:
- [ ] Build completes without errors
- [ ] All pages load correctly
- [ ] Supabase authentication works
- [ ] Database queries execute properly
- [ ] China accessibility verified (use proxy/VPN to test)
- [ ] Performance metrics meet standards

### Phase 4: DNS & Domain Transfer (Day 7-8)
**Objective**: Point domain to Cloudflare Pages

**DNS Configuration**:
1. Update CNAME record to point to Cloudflare Pages
2. Configure SSL/TLS settings (Full or Full Strict)
3. Set up custom domain in Cloudflare Pages
4. Verify domain propagation globally

## Architecture Benefits

### Cloudflare Pages Advantages
1. **Global CDN**: 200+ data centers including China partnerships
2. **Automatic SSL**: Free SSL certificates with auto-renewal
3. **Preview Deployments**: Automatic preview URLs for branches
4. **Build Optimization**: Intelligent caching and compression
5. **DDoS Protection**: Enterprise-grade security included

### China Accessibility Strategy
- **Network**: Cloudflare's China network partnership ensures accessibility
- **Assets**: Self-hosted fonts and assets (no Google CDN dependencies)
- **Performance**: Edge caching reduces latency for Asian users
- **Compliance**: Maintains Toastmasters brand standards globally

## Migration Risks & Mitigation

### Risk 1: Build Configuration Issues
**Mitigation**: Test build locally first, use Cloudflare's build preview

### Risk 2: Environment Variable Mismatch
**Mitigation**: Document all variables, test in preview environment first

### Risk 3: DNS Propagation Delays
**Mitigation**: Keep Vercel deployment active during transition period

### Risk 4: China Access Still Blocked
**Mitigation**: Have backup plan with Cloudflare Workers for additional routing

## Rollback Plan
If critical issues occur:
1. Revert DNS to point back to Vercel
2. Document specific failure points
3. Address issues in development environment
4. Retry migration with fixes

## Performance Targets
- **Build Time**: <2 minutes
- **Deploy Time**: <30 seconds after build
- **Global Load Time**: <3 seconds
- **China Load Time**: <5 seconds
- **Lighthouse Score**: >90 on mobile

## Documentation Requirements
### To Create
1. Cloudflare deployment guide
2. Environment variable documentation
3. Build optimization notes
4. China testing procedures

### To Update
1. README.md with new deployment instructions
2. CLAUDE.md with hosting platform change
3. Package.json scripts if needed

## Sprint Deliverables
1. ✅ Cloudflare Pages deployment live
2. ✅ Domain successfully transferred
3. ✅ China accessibility confirmed
4. ✅ Performance benchmarks met
5. ✅ Documentation updated
6. ✅ Team trained on new deployment process

## Daily Standup Topics
**Day 1-2**: Account setup, initial configuration
**Day 3-4**: Environment variables, build testing
**Day 5-6**: Deployment validation, performance testing
**Day 7-8**: DNS transfer, final validation
**Day 9-10**: Documentation, knowledge transfer

## Success Metrics
- Zero downtime during migration
- China accessibility restored
- Performance maintained or improved
- All features remain functional
- Toastmasters compliance maintained

## Dependencies
- CEO approval for Cloudflare account
- Access to DNS management
- Supabase project details
- Current Vercel configuration

## Next Steps After Migration
1. Set up Cloudflare Analytics
2. Configure caching rules
3. Implement Cloudflare Workers for advanced features
4. Monitor China access patterns
5. Optimize for Cloudflare's infrastructure

---

*Sprint Lead: Claude Code (CTO)*
*Status: In Progress*
*Last Updated: September 29, 2025*