-- Migration 041: Enhance Partners and Projects Tables with Additional Fields
-- Purpose: Add strategic fields for better partnership management and Rotary reporting
-- Date: 2025-10-17
-- Execute: CEO in Supabase SQL Editor
-- Branch: To be determined (can be added to any branch)

-- =====================================================
-- BACKUP VERIFICATION (Run First!)
-- =====================================================
-- CEO: Before running this migration, verify you have recent database backup

-- Check current record counts
SELECT
  (SELECT COUNT(*) FROM partners) as partner_count,
  (SELECT COUNT(*) FROM service_projects) as project_count;

-- =====================================================
-- PART 1: ENHANCE PARTNERS TABLE
-- =====================================================

-- Add partner description field
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS description TEXT;

COMMENT ON COLUMN partners.description IS 'Partner organization mission, background, and alignment with Rotary values';

-- Add primary Rotarian contact (club liaison)
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS primary_contact_rotarian_id UUID REFERENCES members(id) ON DELETE SET NULL;

COMMENT ON COLUMN partners.primary_contact_rotarian_id IS 'Club member responsible for managing this partnership';

-- Add collaboration areas (which Rotary Areas of Focus align with partner)
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS collaboration_areas TEXT[];

COMMENT ON COLUMN partners.collaboration_areas IS 'Array of Rotary Areas of Focus that align with partner work (e.g., ["Education", "Water"])';

-- Add contact person title/role
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS contact_title TEXT;

COMMENT ON COLUMN partners.contact_title IS 'Contact person role/title (e.g., "Executive Director", "Partnership Coordinator")';

-- Add partnership review date
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS next_review_date DATE;

COMMENT ON COLUMN partners.next_review_date IS 'Scheduled date for partnership effectiveness review';

-- Add MOU signed date
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS mou_signed_date DATE;

COMMENT ON COLUMN partners.mou_signed_date IS 'Date when Memorandum of Understanding was signed';

-- Add partnership value tracking
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS partnership_value_rm NUMERIC(12, 2);

COMMENT ON COLUMN partners.partnership_value_rm IS 'Total value of partnership in Malaysian Ringgit (donations, in-kind support, grants)';

-- =====================================================
-- PART 2: ENHANCE PROJECTS TABLE (service_projects)
-- =====================================================

-- Add volunteer hours tracking
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS volunteer_hours INTEGER;

COMMENT ON COLUMN service_projects.volunteer_hours IS 'Total volunteer hours contributed to project (required for Rotary reporting)';

-- Add funding source
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS funding_source TEXT;

COMMENT ON COLUMN service_projects.funding_source IS 'How project is funded (Club Funds, Global Grant, District Grant, etc.)';

-- Add funding source constraint (with safe duplicate check)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'service_projects_funding_source_check'
  ) THEN
    ALTER TABLE service_projects
      ADD CONSTRAINT service_projects_funding_source_check
      CHECK (
        funding_source IS NULL OR
        funding_source IN (
          'Club Funds',
          'Global Grant',
          'District Grant',
          'Fundraising',
          'Corporate Sponsor',
          'Mixed Funding'
        )
      );
  END IF;
END $$;

-- Add district grant number
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS district_grant_number TEXT;

COMMENT ON COLUMN service_projects.district_grant_number IS 'District grant tracking number (e.g., "DG2024-001")';

-- Add matching grant value
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS matching_grant_value_rm NUMERIC(12, 2);

COMMENT ON COLUMN service_projects.matching_grant_value_rm IS 'Matching funds received from Rotary Foundation or other sources';

-- Add project committee members
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS project_committee_members TEXT[];

COMMENT ON COLUMN service_projects.project_committee_members IS 'Array of member names involved beyond the project champion';

-- Add sustainability plan
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS sustainability_plan TEXT;

COMMENT ON COLUMN service_projects.sustainability_plan IS 'Post-project sustainability strategy (Rotary best practice)';

-- Add publicity/media coverage URLs
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS publicity_urls TEXT[];

COMMENT ON COLUMN service_projects.publicity_urls IS 'Array of media coverage links and PR materials';

-- Add collaboration type
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS collaboration_type TEXT;

COMMENT ON COLUMN service_projects.collaboration_type IS 'Partnership structure (Club-Led, Joint Multi-Club, Partner-Led, District-Wide)';

-- Add collaboration type constraint (with safe duplicate check)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'service_projects_collaboration_type_check'
  ) THEN
    ALTER TABLE service_projects
      ADD CONSTRAINT service_projects_collaboration_type_check
      CHECK (
        collaboration_type IS NULL OR
        collaboration_type IN (
          'Club-Led',
          'Joint (Multi-Club)',
          'Partner-Led (Club Support)',
          'District-Wide'
        )
      );
  END IF;
END $$;

-- Add beneficiary demographics (JSONB for structured data)
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS beneficiary_demographics JSONB;

COMMENT ON COLUMN service_projects.beneficiary_demographics IS 'Detailed impact data: age groups, gender, vulnerable populations (JSON structure)';

-- Add Rotary Citation eligibility flag
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS rotary_citation_eligible BOOLEAN DEFAULT false;

COMMENT ON COLUMN service_projects.rotary_citation_eligible IS 'Whether project meets Rotary Presidential Citation criteria';

-- Add follow-up date
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS follow_up_date DATE;

COMMENT ON COLUMN service_projects.follow_up_date IS 'Scheduled date for post-completion impact assessment (typically 6-12 months after)';

-- Add risk assessment
ALTER TABLE service_projects
  ADD COLUMN IF NOT EXISTS risk_assessment TEXT;

COMMENT ON COLUMN service_projects.risk_assessment IS 'Identified risks and challenges during planning phase';

-- =====================================================
-- PART 3: CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Partners indexes
CREATE INDEX IF NOT EXISTS idx_partners_primary_contact
  ON partners(primary_contact_rotarian_id)
  WHERE primary_contact_rotarian_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_partners_next_review
  ON partners(next_review_date)
  WHERE next_review_date IS NOT NULL;

-- Projects indexes
CREATE INDEX IF NOT EXISTS idx_projects_funding_source
  ON service_projects(funding_source)
  WHERE funding_source IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_projects_citation_eligible
  ON service_projects(rotary_citation_eligible)
  WHERE rotary_citation_eligible = true;

CREATE INDEX IF NOT EXISTS idx_projects_follow_up
  ON service_projects(follow_up_date)
  WHERE follow_up_date IS NOT NULL;

-- =====================================================
-- PART 4: VERIFICATION QUERIES
-- =====================================================
-- CEO: Run these after migration to verify success

-- Verify partners table columns
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'partners'
  AND column_name IN (
    'description',
    'primary_contact_rotarian_id',
    'collaboration_areas',
    'contact_title',
    'next_review_date',
    'mou_signed_date',
    'partnership_value_rm'
  )
ORDER BY column_name;

-- Verify service_projects table columns
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'service_projects'
  AND column_name IN (
    'volunteer_hours',
    'funding_source',
    'district_grant_number',
    'matching_grant_value_rm',
    'project_committee_members',
    'sustainability_plan',
    'publicity_urls',
    'collaboration_type',
    'beneficiary_demographics',
    'rotary_citation_eligible',
    'follow_up_date',
    'risk_assessment'
  )
ORDER BY column_name;

-- Verify indexes created
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('partners', 'service_projects')
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- Verify constraints
SELECT
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name IN ('partners', 'service_projects')
  AND tc.constraint_type IN ('CHECK', 'FOREIGN KEY')
ORDER BY tc.table_name, tc.constraint_name;

-- Verify all existing data is intact
SELECT
  (SELECT COUNT(*) FROM partners) as partner_count,
  (SELECT COUNT(*) FROM service_projects) as project_count;

-- =====================================================
-- PART 5: SAMPLE DATA EXAMPLES
-- =====================================================
-- Examples of how to use new fields (DO NOT EXECUTE - for reference only)

/*
-- Example: Update partner with new fields
UPDATE partners
SET
  description = 'Local NGO focused on education for underprivileged children in Penang',
  collaboration_areas = ARRAY['Education', 'Maternal/Child'],
  contact_title = 'Executive Director',
  next_review_date = '2025-06-01'
WHERE name = 'HuaQiao Foundation';

-- Example: Update project with new fields
UPDATE service_projects
SET
  volunteer_hours = 150,
  funding_source = 'Club Funds',
  project_committee_members = ARRAY['John Smith', 'Jane Doe', 'Bob Wilson'],
  sustainability_plan = 'Local school will maintain water filters with training provided',
  collaboration_type = 'Club-Led',
  rotary_citation_eligible = true,
  beneficiary_demographics = '{
    "children": 30,
    "adults": 20,
    "elderly": 10,
    "gender": {"male": 25, "female": 35},
    "vulnerable_groups": ["low_income", "rural"]
  }'::jsonb
WHERE project_name = 'Clean Water Initiative 2025';

-- Example: Find partners needing review
SELECT
  name,
  type,
  next_review_date,
  (next_review_date - CURRENT_DATE) as days_until_review
FROM partners
WHERE next_review_date IS NOT NULL
  AND next_review_date <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY next_review_date;

-- Example: Find citation-eligible projects
SELECT
  project_name,
  area_of_focus,
  project_value_rm,
  volunteer_hours,
  beneficiary_count
FROM service_projects
WHERE rotary_citation_eligible = true
  AND status = 'Completed'
ORDER BY completion_date DESC;
*/

-- =====================================================
-- PART 6: ROLLBACK PROCEDURE (If needed)
-- =====================================================
-- If something goes wrong, execute these commands:

/*
-- Drop indexes
DROP INDEX IF EXISTS idx_partners_primary_contact;
DROP INDEX IF EXISTS idx_partners_next_review;
DROP INDEX IF EXISTS idx_projects_funding_source;
DROP INDEX IF EXISTS idx_projects_citation_eligible;
DROP INDEX IF EXISTS idx_projects_follow_up;

-- Drop constraints
ALTER TABLE service_projects DROP CONSTRAINT IF EXISTS service_projects_funding_source_check;
ALTER TABLE service_projects DROP CONSTRAINT IF EXISTS service_projects_collaboration_type_check;

-- Remove partners columns
ALTER TABLE partners DROP COLUMN IF EXISTS description;
ALTER TABLE partners DROP COLUMN IF EXISTS primary_contact_rotarian_id;
ALTER TABLE partners DROP COLUMN IF EXISTS collaboration_areas;
ALTER TABLE partners DROP COLUMN IF EXISTS contact_title;
ALTER TABLE partners DROP COLUMN IF EXISTS next_review_date;
ALTER TABLE partners DROP COLUMN IF EXISTS mou_signed_date;
ALTER TABLE partners DROP COLUMN IF EXISTS partnership_value_rm;

-- Remove service_projects columns
ALTER TABLE service_projects DROP COLUMN IF EXISTS volunteer_hours;
ALTER TABLE service_projects DROP COLUMN IF EXISTS funding_source;
ALTER TABLE service_projects DROP COLUMN IF EXISTS district_grant_number;
ALTER TABLE service_projects DROP COLUMN IF EXISTS matching_grant_value_rm;
ALTER TABLE service_projects DROP COLUMN IF EXISTS project_committee_members;
ALTER TABLE service_projects DROP COLUMN IF EXISTS sustainability_plan;
ALTER TABLE service_projects DROP COLUMN IF EXISTS publicity_urls;
ALTER TABLE service_projects DROP COLUMN IF EXISTS collaboration_type;
ALTER TABLE service_projects DROP COLUMN IF EXISTS beneficiary_demographics;
ALTER TABLE service_projects DROP COLUMN IF EXISTS rotary_citation_eligible;
ALTER TABLE service_projects DROP COLUMN IF EXISTS follow_up_date;
ALTER TABLE service_projects DROP COLUMN IF EXISTS risk_assessment;
*/

-- =====================================================
-- POST-MIGRATION NOTES FOR CEO
-- =====================================================
-- After successful migration:
-- 1. Confirm all verification queries return expected results
-- 2. Notify CTO to update TypeScript types and UI forms
-- 3. All existing data remains intact (new fields are nullable)
-- 4. New fields can be populated gradually as records are edited
-- 5. Archive this file in docs/database/

-- =====================================================
-- CTO ACTION ITEMS AFTER MIGRATION
-- =====================================================
-- 1. Update src/types/database.ts:
--    - Add new fields to Partner type
--    - Add new fields to ServiceProject type
-- 2. Update UI forms as needed:
--    - PartnerModal.tsx (add new partner fields)
--    - ServiceProjectModal.tsx (add new project fields)
-- 3. Consider creating helper components:
--    - RotarianPicker (for primary_contact_rotarian_id)
--    - AreaOfFocusPicker (for collaboration_areas multi-select)
--    - ProjectCommitteePicker (for project_committee_members)
-- 4. Update documentation:
--    - System architecture diagram
--    - Database schema documentation
-- 5. Create dev journal entry documenting the enhancement

-- Migration 041 Complete
