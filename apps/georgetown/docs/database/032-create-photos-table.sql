-- Migration 032: Create Photos Table
-- Purpose: Create dedicated table for club photo gallery with rich metadata and relationships
-- Date: 2025-10-15
-- Execute: CEO in Supabase SQL Editor

-- =====================================================
-- PHOTOS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Storage reference
  url TEXT NOT NULL,                     -- Full URL from Supabase Storage
  storage_path TEXT,                     -- Path within bucket: 'events/2025/gala-001.jpg'
  thumbnail_url TEXT,                    -- Optional: smaller version for grid display

  -- Photo metadata
  title TEXT,                            -- Short title for the photo
  caption TEXT,                          -- Longer caption/description
  photo_date DATE,                       -- When photo was taken (not uploaded)
  photographer_name TEXT,                -- Photographer credit
  location TEXT,                         -- Where photo was taken

  -- Relationships (all nullable - photos can relate to multiple things)
  rotary_year_id UUID REFERENCES public.rotary_years(id) ON DELETE SET NULL,
  event_id UUID REFERENCES public.events(id) ON DELETE SET NULL,
  project_id UUID REFERENCES public.service_projects(id) ON DELETE SET NULL,

  -- Organization & categorization
  category TEXT DEFAULT 'general',       -- 'event', 'fellowship', 'service', 'community', 'members', 'general'
  tags TEXT[] DEFAULT '{}',              -- ['fundraising', 'youth', 'literacy']
  is_featured BOOLEAN DEFAULT false,     -- Featured on homepage/year highlights
  display_order INTEGER DEFAULT 0,       -- For manual ordering in galleries

  -- Permissions & visibility
  visibility TEXT DEFAULT 'public',      -- 'public', 'members_only', 'officers_only', 'private'
  approval_status TEXT DEFAULT 'approved', -- 'pending', 'approved', 'rejected'
  approval_notes TEXT,                   -- Why rejected or special notes

  -- Technical metadata
  width INTEGER,                         -- Image width in pixels
  height INTEGER,                        -- Image height in pixels
  file_size INTEGER,                     -- File size in bytes
  mime_type TEXT,                        -- 'image/jpeg', 'image/png', etc.

  -- Audit trail
  uploaded_by UUID REFERENCES public.members(id) ON DELETE SET NULL,
  approved_by UUID REFERENCES public.members(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Primary queries
CREATE INDEX idx_photos_rotary_year ON public.photos(rotary_year_id) WHERE rotary_year_id IS NOT NULL;
CREATE INDEX idx_photos_event ON public.photos(event_id) WHERE event_id IS NOT NULL;
CREATE INDEX idx_photos_project ON public.photos(project_id) WHERE project_id IS NOT NULL;
CREATE INDEX idx_photos_category ON public.photos(category);
CREATE INDEX idx_photos_photo_date ON public.photos(photo_date DESC);
CREATE INDEX idx_photos_created_at ON public.photos(created_at DESC);

-- Featured photos
CREATE INDEX idx_photos_featured ON public.photos(is_featured) WHERE is_featured = true;

-- Approval workflow
CREATE INDEX idx_photos_approval_status ON public.photos(approval_status);

-- Full-text search on title and caption
CREATE INDEX idx_photos_search ON public.photos USING GIN(to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(caption, '')));

-- Tags search
CREATE INDEX idx_photos_tags ON public.photos USING GIN(tags);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;

-- Policy 1: Everyone can view approved public photos
CREATE POLICY "Public can view approved public photos"
ON public.photos FOR SELECT
TO public
USING (
  approval_status = 'approved' AND
  visibility = 'public'
);

-- Policy 2: Authenticated members can view members_only photos
CREATE POLICY "Members can view members-only photos"
ON public.photos FOR SELECT
TO authenticated
USING (
  approval_status = 'approved' AND
  visibility IN ('public', 'members_only')
);

-- Policy 3: Officers and chairs can view all photos (including pending)
CREATE POLICY "Officers and chairs can view all photos"
ON public.photos FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.members
    WHERE members.email = auth.jwt()->>'email'
    AND members.roles && ARRAY[
      'President', 'President-Elect', 'Immediate Past President', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair', 'International Service Chair',
      'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

-- Policy 4: Authenticated users can upload photos (pending approval)
CREATE POLICY "Authenticated users can upload photos"
ON public.photos FOR INSERT
TO authenticated
WITH CHECK (
  uploaded_by IN (
    SELECT id FROM public.members WHERE email = auth.jwt()->>'email'
  )
);

-- Policy 5: Officers and chairs can update photos
CREATE POLICY "Officers and chairs can update photos"
ON public.photos FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.members
    WHERE members.email = auth.jwt()->>'email'
    AND members.roles && ARRAY[
      'President', 'President-Elect', 'Immediate Past President', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair', 'International Service Chair',
      'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

-- Policy 6: Officers and chairs can delete photos
CREATE POLICY "Officers and chairs can delete photos"
ON public.photos FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.members
    WHERE members.email = auth.jwt()->>'email'
    AND members.roles && ARRAY[
      'President', 'President-Elect', 'Immediate Past President', 'Vice President',
      'Secretary', 'Treasurer', 'Sergeant-at-Arms',
      'Club Service Chair', 'Foundation Chair', 'International Service Chair',
      'Membership Chair', 'Public Image Chair', 'Service Projects Chair', 'Youth Service Chair'
    ]
  )
);

-- =====================================================
-- UPDATED_AT TRIGGER
-- =====================================================

CREATE OR REPLACE FUNCTION update_photos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_photos_updated_at
BEFORE UPDATE ON public.photos
FOR EACH ROW
EXECUTE FUNCTION update_photos_updated_at();

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE public.photos IS 'Club photo gallery with rich metadata and relationships';
COMMENT ON COLUMN public.photos.url IS 'Full URL from Supabase Storage club-photos bucket';
COMMENT ON COLUMN public.photos.storage_path IS 'Path within bucket for storage management';
COMMENT ON COLUMN public.photos.category IS 'Photo category: event, fellowship, service, community, members, general';
COMMENT ON COLUMN public.photos.tags IS 'Array of tags for filtering and search';
COMMENT ON COLUMN public.photos.visibility IS 'Access level: public, members_only, officers_only, private';
COMMENT ON COLUMN public.photos.approval_status IS 'Workflow status: pending, approved, rejected';
COMMENT ON COLUMN public.photos.rotary_year_id IS 'Optional link to Rotary year for Timeline integration';
COMMENT ON COLUMN public.photos.event_id IS 'Optional link to specific event';
COMMENT ON COLUMN public.photos.project_id IS 'Optional link to service project';

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify table creation
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'photos'
ORDER BY ordinal_position;

-- Verify indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'photos'
  AND schemaname = 'public'
ORDER BY indexname;

-- Verify RLS policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'photos'
  AND schemaname = 'public'
ORDER BY policyname;

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Example: Insert a sample photo (replace with actual Supabase Storage URL)
/*
INSERT INTO public.photos (
  url,
  storage_path,
  title,
  caption,
  photo_date,
  category,
  tags,
  visibility,
  approval_status
) VALUES (
  'https://[project-id].supabase.co/storage/v1/object/public/club-photos/events/2025/gala-fundraiser-001.jpg',
  'events/2025/gala-fundraiser-001.jpg',
  'Annual Gala Fundraiser 2025',
  'Club members and guests enjoying our annual fundraising gala. Over $50,000 raised for literacy programs.',
  '2025-03-15',
  'event',
  ARRAY['fundraising', 'fellowship', 'literacy'],
  'public',
  'approved'
);
*/
