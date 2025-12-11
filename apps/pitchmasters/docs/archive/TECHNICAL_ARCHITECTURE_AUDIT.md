# Pitchmasters Technical Architecture Audit

## Technology Stack

### Frontend Framework & Build Tools
- **React**: 19.1.1 (Latest stable)
- **TypeScript**: 5.7.2 (Full type safety)
- **Vite**: 7.1.6 (Modern build tool with optimizations)
- **React Router DOM**: 7.9.3 (Client-side routing)

### Styling & UI
- **Tailwind CSS**: 3.4.17 (Utility-first CSS framework)
- **Custom CSS**: Component-specific styling in `src/index.css`
- **Self-hosted fonts**: Montserrat (headlines), Source Sans 3 (body text)
- **Toastmasters Brand Colors**:
  - Loyal Blue (#004165)
  - True Maroon (#772432)
  - Cool Gray (#A9B2B1)

### Database & Backend
- **Supabase**: PostgreSQL with real-time capabilities
- **Authentication**: Supabase Auth (JWT-based)
- **ORM**: Supabase client with TypeScript definitions

### Key Libraries
- **@dnd-kit**: 6.1.0/8.0.0/3.2.2 (Drag and drop functionality)
- **date-fns**: 4.1.0 (Date manipulation)
- **lucide-react**: 0.544.0 (Icon library)

### Development Tools
- **ESLint**: 9.15.0 (Code linting)
- **TypeScript ESLint**: 8.15.0 (TypeScript-specific linting)
- **PostCSS**: 8.5.1 with Autoprefixer 10.4.20
- **Vite React Plugin**: 4.3.4

## Architecture

### Application Type
- **Single Page Application (SPA)** with client-side routing
- **Static site deployment** ready (Cloudflare Pages configured)
- **Progressive Web App** features (manifest.webmanifest, service worker ready)

### Project Structure
```
src/
├── components/           # Reusable UI components
│   ├── EcosystemPartnerDirectory.tsx
│   ├── Layout.tsx
│   ├── MemberDirectory.tsx
│   └── PrivacySettings.tsx
├── pages/               # Route-specific page components
│   ├── Dashboard.tsx
│   ├── MembersPage.tsx
│   ├── MemberProfilePage.tsx
│   ├── CommunityPage.tsx
│   └── FaviconTestPage.tsx
├── hooks/               # Custom React hooks
│   ├── useDebounce.ts
│   ├── useLazyLoading.ts
│   ├── usePerformanceMetrics.ts
│   └── useSwipeGesture.ts
├── lib/                 # External service configurations
│   └── supabase.ts
├── types/               # TypeScript type definitions
│   └── index.ts
├── utils/               # Utility functions
│   ├── permissions.ts
│   ├── privacy.ts
│   ├── runValidation.ts
│   └── testScenarios.ts
└── App.tsx              # Main application component
```

### API/Data Fetching Pattern
- **Supabase Client**: Direct database queries with TypeScript safety
- **Real-time subscriptions**: WebSocket-based updates
- **Row Level Security (RLS)**: Database-enforced tenant isolation
- **No REST API layer**: Direct database access through Supabase

### Mobile Responsiveness Strategy
- **Mobile-first design**: 320px-414px primary, scales to 1920px
- **Touch-friendly interface**: 44px minimum touch targets
- **Swipe gestures**: Custom hook for mobile interactions
- **Tailwind breakpoints**: Responsive design system

### Performance Optimizations
- **Code splitting**: Manual chunks for vendor, Supabase, and UI libraries
- **Lazy loading**: Custom hook for performance optimization
- **Performance metrics**: Custom monitoring with Core Web Vitals
- **esbuild minification**: Fast build times
- **Sourcemap disabled**: Production optimization

## Data Layer

### Database Schema Overview
Multi-tenant architecture with club-level isolation:

```sql
clubs (Root tenant table)
├── users (Club members, officers, admins)
├── meetings (Club meetings with scheduling)
│   ├── speeches (Meeting presentations)
│   └── meeting_roles (Functional roles assignment)
└── Future: ecosystem_partners, privacy_settings, member_profiles
```

### Key Tables

#### clubs
- **Purpose**: Top-level tenant definition
- **Key Fields**: id (UUID), name, charter_number, timezone
- **Isolation**: Root table for multi-club architecture

#### users
- **Purpose**: Club members with role-based access
- **Key Fields**: id (UUID), email, full_name, club_id, role
- **Roles**: 'member', 'officer', 'admin'
- **Isolation**: Scoped to club_id via foreign key

#### meetings
- **Purpose**: Toastmasters meeting management
- **Key Fields**: id (UUID), club_id, title, date, meeting_type, status
- **Types**: 'regular', 'special', 'demo'
- **Status**: 'scheduled', 'in_progress', 'completed', 'cancelled'

#### speeches
- **Purpose**: Speech tracking and Pathways progress
- **Key Fields**: id (UUID), meeting_id, user_id, title, manual, objectives
- **Integration**: Supports both Pathways and traditional manuals

#### meeting_roles
- **Purpose**: Official Toastmasters functional roles
- **Key Fields**: id (UUID), meeting_id, user_id, role_type
- **Roles**: 'toastmaster', 'evaluator', 'timer', 'grammarian', 'ah_counter', 'table_topics_master'

### Authentication/Authorization
- **Supabase Auth**: JWT-based authentication
- **Row Level Security**: Database-enforced data isolation
- **Role-based permissions**: Member/Officer/Admin hierarchy
- **Club-scoped access**: Users only see their club's data

### Data Privacy & Compliance
- **Tenant isolation**: Complete data segregation by club
- **GDPR compliance**: Right to erasure implementation ready
- **Audit trail**: Timestamps for all data modifications
- **Cross-club features**: Controlled through explicit permissions

## Deployment & Hosting

### Current Setup
- **Cloudflare Pages**: Static site hosting configured
- **Build Command**: `npm run build` (TypeScript compilation + Vite build)
- **Environment Variables**: Supabase URL and anonymous key
- **Domain**: Ready for custom domain setup

### Build Configuration
- **Output Directory**: `dist/`
- **Build Optimizations**:
  - Code splitting by library type
  - esbuild minification
  - 1000kb chunk size warning limit
- **Development Server**: Port 3000 with host access

## Unique Features & Technical Decisions

### Toastmasters-Specific Features
- **Brand Compliance**: Official colors, fonts, and styling guidelines
- **Meeting Structure**: Follows official Toastmasters meeting format
- **Role Management**: Standard Toastmasters functional roles
- **Speech Tracking**: Pathways and traditional manual support
- **Charter Integration**: Ready for official charter numbers

### China-Friendly Architecture
- **Self-hosted Assets**: All fonts and resources served locally
- **No External Dependencies**: Zero reliance on Google Fonts, CDNs
- **Network Independence**: Complete functionality without external APIs
- **Font Strategy**: Montserrat and Source Sans 3 in `/public/assets/fonts/`

### Performance & UX Innovations
- **Performance Monitoring**: Real-time Core Web Vitals tracking
- **Lazy Loading**: Custom implementation for large member lists
- **Swipe Gestures**: Mobile-native interaction patterns
- **Touch Optimization**: 44px minimum touch targets throughout

### Multi-Club Architecture
- **Tenant Isolation**: Database-level security with RLS policies
- **Scalable Design**: UUID primary keys, indexed foreign keys
- **Future-Ready**: Schema supports horizontal partitioning
- **Cross-Club Features**: Controlled networking and contest capabilities

### Development Quality
- **TypeScript Coverage**: 100% type safety with strict configuration
- **Code Splitting**: Optimized bundle loading strategy
- **Error Boundaries**: Production-ready error handling
- **Accessibility**: Touch-friendly design with proper contrast ratios

## Technical Constraints & Compliance

### Business Requirements
- **Multi-club support**: Complete tenant isolation
- **Mobile-first**: Founders use phones during meetings
- **Global accessibility**: Multiple timezones, cross-cultural design
- **Revenue architecture**: Freemium model support
- **Toastmasters compliance**: Official brand guidelines adherence

### Performance Targets
- **Core Web Vitals**: >90 score on mobile
- **Load Time**: <3 seconds on 3G networks
- **Bundle Size**: Optimized chunks under 1MB
- **Offline Capability**: PWA features for meeting continuity

This architecture provides a solid foundation for a globally scalable, Toastmasters-compliant club management platform optimized for startup founders and mobile-first usage patterns.