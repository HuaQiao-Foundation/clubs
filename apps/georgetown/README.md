# Georgetown Rotary Club - Speaker Management System

A real-time collaborative speaker database for Georgetown Rotary Club members to manage potential and scheduled speakers.

## Features

### Speaker Management
- **Drag-and-Drop Board**: Organize speakers across 6 status columns (Ideas → Approached → Agreed → Scheduled → Spoken → Dropped)
- **Multiple Views**: Switch between Board, Cards Grid, and List/Spreadsheet views
- **Real-Time Synchronization**: Multiple users can view and edit simultaneously
- **Speaker Bureau**: Professional portfolio view with recommendation system for district sharing
- **Auto-Linking**: Speakers automatically linked to Rotary years when moved to "Spoken" status

### Timeline & History
- **Annual Rotary Year Timeline**: Browse institutional history by Rotary year (July 1 - June 30)
- **Leadership Themes**: View RI President, District Governor, and Club President themes with official logos
- **Narrative Editing**: Document year summaries, highlights, and challenges (officers/chairs access)
- **Auto-Calculated Statistics**: Real-time tracking of meetings, speakers, projects, beneficiaries, and project value
- **Member Growth Tracking**: Monitor membership changes (new members, transfers, resignations)
- **Year-Specific Photo Galleries**: Browse photos organized by Rotary year

### Photo Gallery
- **Professional Gallery**: Standalone photo library with lightbox viewing at /photos
- **Comprehensive Metadata**: Caption, photographer, location, event date, and tags for each photo
- **Event Categorization**: Filter by meeting, service, social, observance, or fellowship events
- **Search & Filter**: Find photos by caption, photographer, tags, Rotary year, or event type
- **Timeline Integration**: Year-specific photo albums accessible from timeline view
- **Image Optimization**: Automatic compression (max 2MB, 1920px width) for fast loading

### Service Projects & Partners
- **Project Management**: Track service projects with board workflow and cards view
- **Timeline Integration**: Completed projects auto-link to Rotary years with statistics tracking
- **Community Partners**: Manage partnerships with local organizations and businesses

### Member Directory
- **Comprehensive Roster**: Manage club membership with roles, classifications, and contact information
- **Professional Profiles**: LinkedIn integration, company information, and Rotary service history
- **Paul Harris Fellow Tracking**: PHF level badges and recognition
- **Birthday Tracking**: Month/day tracking for member celebrations

### Design & Accessibility
- **Professional Design**: Uses official Rotary brand colors (Azure #0067c8, Gold #f7a81b)
- **Mobile-First Responsive**: Optimized for phones, tablets, and desktop devices (320px-1920px)
- **Touch-Friendly**: 44px minimum touch targets, gesture-based navigation
- **China-Accessible**: Self-hosted fonts, no external CDNs, deployed on Cloudflare Pages

### Progressive Web App (PWA)
- **📱 Installable**: Add to home screen on iOS, Android, and desktop browsers
- **🔌 Offline Support**: View cached members, speakers, and events without internet connection
- **⚡ Fast Performance**: Instant load times with intelligent caching strategies
- **🔄 Auto-Updates**: Prompted when new version available (user-controlled)
- **🌏 China-Safe**: Zero external CDN dependencies, fully self-hosted service worker

## Setup Instructions

### 1. Set up Supabase Database

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to the SQL Editor in your Supabase dashboard
3. Copy and paste the contents of `database.sql` file and execute it
4. This will create the speakers table with all necessary columns and enable real-time updates

### 2. Configure Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. In your Supabase dashboard, find your project settings:
   - Go to Settings → API
   - Copy your Project URL and paste it as `VITE_SUPABASE_URL`
   - Copy your Anon/Public key and paste it as `VITE_SUPABASE_ANON_KEY`

### 3. Install and Run

```bash
# Install dependencies
npm install

# Run development server (PWA disabled for fast HMR)
npm run dev

# Test PWA features in development
npm run dev:pwa

# Preview production PWA build locally
npm run preview:pwa

# Run Lighthouse PWA audit
npm run lighthouse
```

The application will be available at `http://localhost:5180`

**Note**: Use `npm run dev` (not `dev:pwa`) for normal development. The PWA is disabled by default to ensure fast Hot Module Replacement (HMR).

### 4. Build for Production

```bash
npm run build
```

The built files will be in the `dist` directory, including:
- Service worker (`sw.js`) for offline support
- Web app manifest for installability
- Optimized assets with precaching

## Database Schema

The `speakers` table includes the following fields:
- `name`: Speaker's full name
- `email`: Contact email
- `phone`: Contact phone number
- `organization`: Speaker's organization/company
- `topic`: Speaking topic
- `notes`: Additional notes
- `status`: Current status (ideas, approached, agreed, scheduled, spoken, dropped)
- `scheduled_date`: Date when speaker is scheduled
- `position`: Order position within status column
- Automatic timestamps and user tracking

## Usage

1. **Add Speaker**: Click the "Add Speaker" button in the header
2. **Edit Speaker**: Click the edit icon on any speaker card
3. **Delete Speaker**: Click the trash icon on any speaker card
4. **Move Speaker**: Drag and drop cards between columns or reorder within columns
5. **Schedule Speaker**: Set a date when editing a speaker in "Scheduled" status

## Notes

- All changes are synchronized in real-time across all connected users
- The database uses Row Level Security (RLS) - you may want to add authentication for production use
- Currently uses public access for demo purposes - add authentication for production
