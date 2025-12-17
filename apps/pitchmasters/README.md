# Pitchmasters Club Management Platform

## Overview
A multi-club Toastmasters management platform designed specifically for startup-focused clubs. Built with React 19.1.1, TypeScript, Vite 7.1.6, and Supabase.

## Phase 1 Setup Complete ✅

### ✅ Technical Foundation
- **React 19.1.1 + TypeScript + Vite 7.1.6** - Modern development stack
- **Tailwind CSS 3.4.17** - Utility-first styling with Toastmasters compliance
- **Multi-club database schema** - Tenant isolation with Row Level Security
- **Self-hosted fonts** - China-friendly design (Montserrat, Source Sans 3)
- **Production build verified** - Ready for deployment

### ✅ Toastmasters Brand Compliance
- **Official colors**: Loyal Blue (#004165), True Maroon (#772432), Cool Gray (#A9B2B1)
- **Typography**: Montserrat (headlines), Source Sans 3 (body text)
- **Required disclaimer** in footer
- **Mobile-first responsive design** (320px minimum, 44px touch targets)

### ✅ Architecture & Performance
- **Multi-club tenant isolation** via club_id foreign keys
- **Row Level Security policies** for data protection
- **Mobile-optimized components** with touch-friendly interface
- **China-compatible assets** (no external CDNs or blocked services)
- **UUID primary keys** for scalability and security

## Quick Start

```bash
# Install dependencies
npm install

# Start development server (without PWA)
npm run dev

# Start development server (with PWA enabled for testing)
npm run dev:pwa

# Build for production
npm run build

# Preview production build (without PWA)
npm run preview

# Preview production build (with PWA)
npm run preview:pwa

# Run Lighthouse CI tests
npm run lighthouse

# Type checking
npm run typecheck

# Linting
npm run lint
```

## Environment Setup

1. Copy `.env.example` to `.env.local`
2. Add your Supabase credentials:
```
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Database Setup

Run the schema in `docs/database/schema.sql` in your Supabase SQL editor to create:
- Multi-club tenant isolation
- Row Level Security policies
- Optimized indexes
- Sample data for development

## Key Features

### 🏢 Multi-Club Architecture
- Tenant isolation at the database level
- Scalable design for global expansion
- Cross-club networking capabilities (future)

### 📱 Mobile-First Design
- Touch targets minimum 44px
- Responsive breakpoints from 320px
- Optimized for startup founders on mobile

### 🎨 Toastmasters Brand Compliance
- Official color palette and typography
- Required disclaimers and legal compliance
- Professional appearance worthy of TI standards

### 🌏 China-Friendly
- Self-hosted fonts and assets
- No Google Fonts or external CDNs
- Network independence for blocked regions
- Service worker with China-safe caching strategies

### 📲 Progressive Web App (PWA)
- **Installable** on mobile devices and desktops
- **Offline support** with intelligent caching
- **User-controlled updates** (no auto-refresh)
- **Offline indicator** shows connection status
- **Smart caching strategies**:
  - Auth endpoints: Never cached (security)
  - Mutations: Never cached (data integrity)
  - Storage/images: Cache-first (30 days)
  - API reads: Network-first with 5-min cache
- **Lighthouse score**: 90+ accessibility, passing performance metrics

## Tech Stack

- **Frontend**: React 19.1.1, TypeScript, Vite 7.1.6
- **Database**: Supabase (PostgreSQL with Row Level Security)
- **Styling**: Tailwind CSS 3.4.17 + custom CSS
- **Icons**: Lucide React 0.544.0
- **Interactions**: @dnd-kit for drag and drop
- **Routing**: React Router DOM 7.9.2
- **Dates**: date-fns 4.1.0

## Project Structure

```
src/
├── components/     # Reusable UI components
├── pages/         # Route-level pages
├── lib/           # Utilities and configurations
├── hooks/         # Custom React hooks
├── types/         # TypeScript type definitions
└── index.css      # Global styles with brand compliance

docs/
├── database/      # Database schema and protocols
└── [other docs]   # Technical documentation

public/
└── assets/fonts/  # Self-hosted fonts for China compatibility
```

## Development Server

The development server runs at http://localhost:3000 with:
- Hot module replacement
- TypeScript checking
- ESLint integration
- Network access for mobile testing

## Phase 1 Success Criteria Met ✅

- ✅ Multi-club database schema with tenant isolation
- ✅ Toastmasters brand compliance (colors, fonts, disclaimers)
- ✅ Mobile-first responsive design (320px-414px primary)
- ✅ Touch-friendly interface (44px minimum touch targets)
- ✅ Self-hosted fonts load properly
- ✅ Charter compliance features ready
- ✅ Revenue architecture foundation
- ✅ Cross-browser compatibility
- ✅ Production build successful

## Next Steps

1. **Connect to Supabase**: Add environment variables
2. **Implement authentication**: User login and club selection
3. **Build meeting management**: Create and manage meetings
4. **Add speech tracking**: Pathways and manual progress
5. **Member management**: User roles and permissions

---

**Ready for Technical COO review and Phase 2 planning.**