# Toastmasters Adaptation Guide

**Based On**: Georgetown Rotary Club Speaker Management System
**Created**: 2025-10-18
**Purpose**: Specific guidance for adapting Georgetown patterns to Toastmasters Club application

---

## Table of Contents

1. [Toastmasters vs Rotary: Core Differences](#toastmasters-vs-rotary-core-differences)
2. [Database Schema Adaptations](#database-schema-adaptations)
3. [Feature Mapping](#feature-mapping)
4. [Brand Adaptation](#brand-adaptation)
5. [Toastmasters-Specific Features](#toastmasters-specific-features)
6. [Quick Start Implementation](#quick-start-implementation)

---

## Toastmasters vs Rotary: Core Differences

### Organization Structure

**Georgetown Rotary**:
- ~50 members
- Officers: President, Secretary, Treasurer
- Program Committee: Manages speakers
- Service Projects: Community-focused
- Weekly meetings with 1 guest speaker

**Toastmasters Club**:
- ~20-40 members
- Officers: President, VP Education, VP Membership, VP PR, Secretary, Treasurer, Sergeant at Arms
- Education focus: Member speeches and evaluations
- Competency paths: Icebreaker → CC → AC → DTM
- Weekly meetings with multiple member speeches

### Data Model Differences

| Georgetown Rotary | Toastmasters Equivalent |
|-------------------|-------------------------|
| Speaker (external guests) | Speech (by members) |
| Kanban status (Ideas→Approached→Agreed→Scheduled→Spoken→Dropped) | Speech status (Planned→Scheduled→Delivered→Evaluated) |
| Timeline (past years, themes, officers) | Club history (past officers, award recipients) |
| Member directory (portraits, roles, classifications) | Member directory (portraits, competency levels, awards) |
| Partner organizations | None (club-internal focus) |
| Club photos | Meeting photos, awards photos |

---

## Database Schema Adaptations

### 1. Speakers Table → Speeches Table

**Georgetown `speakers` table**:
```sql
CREATE TABLE speakers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  company TEXT,
  title TEXT,
  phone TEXT,
  email TEXT,
  topic TEXT,
  rotary_affiliation TEXT,
  website TEXT,
  scheduled_date DATE,
  kanban_status TEXT NOT NULL, -- Ideas, Approached, Agreed, Scheduled, Spoken, Dropped
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Toastmasters `speeches` table**:
```sql
CREATE TABLE speeches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  project_name TEXT, -- e.g., "CC3: Get to the Point", "Icebreaker"
  competency_path TEXT, -- e.g., "Competent Communicator", "Advanced Communicator Bronze"
  speech_number INTEGER, -- e.g., 1-10 for CC, 1-20 for AC
  objectives TEXT[], -- Learning objectives for this speech
  time_min INTEGER NOT NULL, -- Minimum time (e.g., 5 minutes)
  time_max INTEGER NOT NULL, -- Maximum time (e.g., 7 minutes)
  actual_time INTEGER, -- Actual delivery time in seconds
  scheduled_date DATE,
  delivered_date DATE,
  status TEXT NOT NULL, -- Planned, Scheduled, Delivered, Evaluated
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Differences**:
- `member_id` instead of external contact fields
- `project_name` and `competency_path` instead of company/organization
- Time tracking (min/max/actual)
- `delivered_date` separate from `scheduled_date` (may reschedule)

---

### 2. Members Table Adaptations

**Georgetown `members` table**:
```sql
CREATE TABLE members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  portrait_url TEXT,
  roles JSONB DEFAULT '[]', -- ["President", "Board Member"]
  classification TEXT, -- Georgetown uses Rotary classifications
  bio TEXT,
  join_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Toastmasters `members` table** (adapted):
```sql
CREATE TABLE members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  portrait_url TEXT,
  roles JSONB DEFAULT '[]', -- ["VP Education", "Toastmaster"]
  competency_levels JSONB DEFAULT '{}', -- {"CC": 10, "AC": 5, "CL": 3}
  current_path TEXT, -- Current focus: "Competent Communicator", "Advanced Communicator Bronze", etc.
  awards JSONB DEFAULT '[]', -- ["CC Award", "Best Speaker Award"]
  bio TEXT,
  join_date DATE,
  member_status TEXT DEFAULT 'active', -- active, inactive, guest
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Additions**:
- `competency_levels` - Track progress in CC, AC, CL, AL, DTM paths
- `current_path` - What they're currently working on
- `awards` - Toastmasters awards and achievements
- `member_status` - Track active/inactive/guest status

---

### 3. NEW: Meeting Roles Table

**Toastmasters-Specific** (no Georgetown equivalent):
```sql
CREATE TABLE meeting_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  role_type TEXT NOT NULL, -- Toastmaster, General Evaluator, Timer, Grammarian, Ah-Counter, Table Topics Master, Speaker
  member_id UUID REFERENCES members(id) ON DELETE SET NULL,
  speech_id UUID REFERENCES speeches(id) ON DELETE SET NULL, -- Only for "Speaker" role
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Role Types**:
- **Toastmaster** - Runs the meeting
- **General Evaluator** - Evaluates the meeting overall
- **Timer** - Tracks speech times
- **Grammarian** - Tracks word usage
- **Ah-Counter** - Counts filler words
- **Table Topics Master** - Runs impromptu speaking
- **Speaker** - Delivers prepared speech

---

### 4. NEW: Evaluations Table

**Toastmasters-Specific** (no Georgetown equivalent):
```sql
CREATE TABLE evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  speech_id UUID NOT NULL REFERENCES speeches(id) ON DELETE CASCADE,
  evaluator_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  strengths TEXT[], -- Array of positive feedback points
  improvements TEXT[], -- Array of improvement suggestions
  overall_rating INTEGER CHECK (overall_rating >= 1 AND overall_rating <= 5),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 5. Meetings Table

**Georgetown doesn't track meetings** (weekly, no complex scheduling).

**Toastmasters `meetings` table**:
```sql
CREATE TABLE meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_date DATE NOT NULL,
  theme TEXT, -- Meeting theme (e.g., "Leadership", "Confidence")
  word_of_the_day TEXT,
  attendance INTEGER,
  notes TEXT,
  status TEXT DEFAULT 'planned', -- planned, in_progress, completed
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Feature Mapping

### Georgetown Rotary → Toastmasters

| Georgetown Feature | Toastmasters Adaptation |
|--------------------|-------------------------|
| **KanbanBoard** (Speaker pipeline) | **SpeechBoard** (Speech pipeline: Planned→Scheduled→Delivered→Evaluated) |
| **SpeakerCard** | **SpeechCard** (show member, title, project, time, evaluator) |
| **EditSpeakerModal** | **EditSpeechModal** (project dropdown, time fields, objectives) |
| **MemberDirectory** | **MemberDirectory** (add competency progress bars, awards badges) |
| **Timeline** (past years) | **ClubHistory** (past officers, award winners by year) |
| **Dashboard** | **Dashboard** (upcoming speeches, recent evaluations, member progress) |
| **AboutPage** | **AboutPage** (Toastmasters mission, club charter, meeting info) |

---

## Brand Adaptation

### Color Scheme

**Georgetown Rotary**:
- Primary: Rotary Azure `#005daa`
- Accent: Rotary Gold `#f7a81b`

**Toastmasters** (adapt based on official brand):
- Primary: Toastmasters Blue `#004165`
- Accent: Toastmasters Orange `#F47E3E`

**Find/Replace in codebase**:
```bash
# In all .tsx/.css files:
#005daa → #004165
#f7a81b → #F47E3E
```

### Tailwind Config

**Update** `tailwind.config.js`:
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        'tm-blue': '#004165',
        'tm-orange': '#F47E3E',
      }
    }
  }
}
```

**Use in components**:
```tsx
// Instead of: bg-[#005daa]
// Use: bg-tm-blue

<button className="bg-tm-blue hover:bg-tm-blue/90">
  Schedule Speech
</button>
```

---

## Toastmasters-Specific Features

### 1. Speech Timer

**New Component**: `SpeechTimer.tsx`

**Features**:
- Green light: 0-minimum time
- Yellow light: minimum-maximum time
- Red light: maximum+ time
- Audible bell at min, max, and overtime (30s past max)

**Georgetown Equivalent**: None

**Implementation**:
```tsx
// src/components/SpeechTimer.tsx
import { useState, useEffect } from 'react'

interface SpeechTimerProps {
  minTime: number // seconds
  maxTime: number // seconds
  onComplete: (actualTime: number) => void
}

export default function SpeechTimer({ minTime, maxTime, onComplete }: SpeechTimerProps) {
  const [elapsed, setElapsed] = useState(0)
  const [isRunning, setIsRunning] = useState(false)

  // Timer logic...
  // Green: 0-minTime
  // Yellow: minTime-maxTime
  // Red: maxTime+

  return (
    <div className="flex flex-col items-center gap-4">
      {/* Traffic light display */}
      <div className="flex gap-4">
        <div className={`w-16 h-16 rounded-full ${elapsed < minTime ? 'bg-green-500' : 'bg-gray-300'}`} />
        <div className={`w-16 h-16 rounded-full ${elapsed >= minTime && elapsed <= maxTime ? 'bg-yellow-500' : 'bg-gray-300'}`} />
        <div className={`w-16 h-16 rounded-full ${elapsed > maxTime ? 'bg-red-500' : 'bg-gray-300'}`} />
      </div>

      {/* Time display */}
      <div className="text-4xl font-mono">
        {Math.floor(elapsed / 60)}:{(elapsed % 60).toString().padStart(2, '0')}
      </div>

      {/* Controls */}
      <div className="flex gap-2">
        <button onClick={() => setIsRunning(!isRunning)} className="btn-primary">
          {isRunning ? 'Pause' : 'Start'}
        </button>
        <button onClick={() => { setElapsed(0); setIsRunning(false) }} className="btn-secondary">
          Reset
        </button>
      </div>
    </div>
  )
}
```

---

### 2. Competency Progress Visualization

**New Component**: `CompetencyProgress.tsx`

**Features**:
- Progress bars for each path (CC, AC, CL, AL, DTM)
- Visual badges for completed awards
- Next speech recommendation

**Georgetown Equivalent**: None (Rotary doesn't have competency paths)

**Usage in MemberCard**:
```tsx
<CompetencyProgress
  levels={{
    CC: 10, // Completed all 10 CC speeches
    AC: 5,  // Completed 5 AC speeches
    CL: 0,  // Not started CL yet
  }}
  currentPath="Advanced Communicator Bronze"
/>
```

---

### 3. Table Topics Session

**New Component**: `TableTopicsSession.tsx`

**Features**:
- Random topic generator (pre-loaded topics database)
- Timer (1-2 minutes)
- Speaker tracking (who spoke, topic, time)
- Export session report

**Georgetown Equivalent**: None

**Database Table**:
```sql
CREATE TABLE table_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic TEXT NOT NULL,
  category TEXT, -- e.g., "Leadership", "Personal Growth", "Fun"
  difficulty TEXT, -- easy, medium, hard
  times_used INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 4. Evaluation Form

**New Component**: `EvaluationForm.tsx`

**Features**:
- Speech content evaluation (1-5 stars)
- Delivery evaluation (body language, voice modulation)
- Strengths (multi-line text)
- Improvements (multi-line text)
- Print-friendly format

**Georgetown Equivalent**: None

**Integrates with**: `evaluations` table (see Database Schema section)

---

## Quick Start Implementation

### Day 1: Foundation (4 hours)

**1. Copy Georgetown reusable code** (30 minutes):
```bash
# From Georgetown knowledge-transfer directory:
cp docs/knowledge-transfer/reusable-utilities/* toastmasters-app/src/utils/
cp docs/knowledge-transfer/reusable-hooks/* toastmasters-app/src/hooks/
cp docs/knowledge-transfer/reusable-components/* toastmasters-app/src/components/
cp -r public/assets/fonts toastmasters-app/public/assets/
```

**2. Update branding** (15 minutes):
```bash
# Find/replace in all files:
#005daa → #004165
#f7a81b → #F47E3E

# Update tailwind.config.js with Toastmasters colors
# Update logo files
```

**3. Set up Supabase** (2 hours):
- Create Supabase project
- Create tables: `members`, `speeches`, `meetings`, `meeting_roles`, `evaluations`, `table_topics`
- Set up RLS policies (copy Georgetown pattern)
- Create Storage buckets: `portraits`, `meeting-photos`

**4. Initialize React app** (1 hour):
- Use Vite: `npm create vite@latest toastmasters-app -- --template react-ts`
- Install dependencies: `npm install @supabase/supabase-js @dnd-kit/* react-router-dom date-fns lucide-react`
- Copy Georgetown App.tsx structure (ErrorBoundary + code splitting)

---

### Day 2-3: Core Features (12 hours)

**1. Dashboard** (3 hours):
- Copy Georgetown Dashboard.tsx layout
- Replace speaker metrics with speech metrics:
  - Upcoming speeches (next 2 weeks)
  - Recent evaluations
  - Member competency progress
  - Meeting attendance trends

**2. Speech Board (Kanban)** (4 hours):
- Copy Georgetown KanbanBoard.tsx
- Adapt columns: Planned → Scheduled → Delivered → Evaluated
- Modify SpeechCard (show member, project, time range, evaluator)
- Integrate drag-and-drop (already working in Georgetown)

**3. Member Directory** (3 hours):
- Copy Georgetown MemberDirectory.tsx
- Add CompetencyProgress component
- Add award badges
- Add "Schedule Speech" quick action

**4. Meeting Planner** (2 hours):
- NEW feature (no Georgetown equivalent)
- Calendar view of upcoming meetings
- Assign roles drag-and-drop interface
- Copy Georgetown card layout pattern

---

### Day 4: Toastmasters-Specific (8 hours)

**1. Speech Timer** (2 hours):
- Implement traffic light system
- Add audio bells (Web Audio API)
- Mobile-friendly (44px touch targets)

**2. Evaluation Form** (3 hours):
- Form layout (copy Georgetown modal pattern)
- Star rating component
- Strengths/improvements text areas
- Print stylesheet

**3. Table Topics** (2 hours):
- Random topic generator
- Timer integration
- Session tracking

**4. Competency Progress** (1 hour):
- Progress bars for each path
- Badge components
- Next speech recommendation logic

---

### Day 5: Testing & Polish (4 hours)

**1. Mobile testing** (2 hours):
- Test on 320px (iPhone SE)
- Verify 44px touch targets
- Test offline mode
- Test real-time updates (open two browsers)

**2. Data migration** (1 hour):
- Import existing member data
- Import speech history
- Verify all relationships (member→speeches, speeches→evaluations)

**3. Documentation** (1 hour):
- User guide for officers
- Admin guide for VP Education
- Meeting role descriptions

---

## Migration Checklist

**Before starting Toastmasters app**:
- [ ] Read [react-spa-playbook.md](react-spa-playbook.md) thoroughly
- [ ] Copy all reusable utilities/hooks/components
- [ ] Set up Supabase project with new schema
- [ ] Update branding colors in all files
- [ ] Copy Georgetown App.tsx structure

**Development priorities**:
1. ✅ Dashboard (adapt Georgetown)
2. ✅ Speech Board (adapt KanbanBoard)
3. ✅ Member Directory (adapt Georgetown + add competency progress)
4. ✅ Meeting Planner (new, use card pattern)
5. ✅ Speech Timer (new, mobile-friendly)
6. ✅ Evaluation Form (new, use modal pattern)
7. ✅ Table Topics (new, use card pattern)

**Testing priorities**:
1. Mobile-first (320px-414px)
2. Offline detection
3. Real-time collaboration (2+ users editing)
4. Speech timer accuracy
5. Data persistence (refresh browser)

---

## Expected Timeline

**With Georgetown foundation**:
- Day 1: Setup + branding (4 hours)
- Day 2-3: Core features (12 hours)
- Day 4: Toastmasters-specific (8 hours)
- Day 5: Testing + polish (4 hours)

**Total**: ~28 hours (vs 120 hours from scratch)

**Savings**: 92 hours (77% reduction)

---

## Success Metrics

**Launch criteria** (copy Georgetown quality gates):
- ✅ Mobile-first responsive (320px-414px tested)
- ✅ 44px minimum touch targets
- ✅ Real-time collaboration working
- ✅ Offline detection + retry logic
- ✅ Zero TypeScript errors
- ✅ Code splitting (bundle < 400 KB)
- ✅ Self-hosted fonts
- ✅ ErrorBoundary prevents crashes

**Toastmasters-specific criteria**:
- ✅ Speech timer accurate to ±1 second
- ✅ Evaluation form prints correctly
- ✅ Competency progress calculated correctly (CC 1-10, AC 1-20, etc.)
- ✅ Meeting roles drag-and-drop works on mobile
- ✅ Table topics random selection (no repeats within 30 days)

---

## Support & Resources

**Georgetown Rotary codebase**: Reference for proven patterns
**Toastmasters International**: Official competency path requirements
**This Playbook**: react-spa-playbook.md for detailed implementation examples

---

**Created by**: CTO (Claude Code)
**Based on**: Georgetown Rotary Club Speaker Management System
**Last Updated**: 2025-10-18
**Version**: 1.0
