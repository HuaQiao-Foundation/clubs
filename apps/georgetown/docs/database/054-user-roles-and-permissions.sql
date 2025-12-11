-- Migration 054: User Roles and Permission System
-- Purpose: Enable role-based access control for Rotary Club Manager
-- Date: 2025-12-02
-- Author: CTO (Claude Code)
-- Dependencies: Supabase Auth enabled

-- ============================================================================
-- OVERVIEW
-- ============================================================================
-- This migration establishes role-based access control (RBAC) for club members.
-- Roles: admin, officer, chair, member, readonly
-- Permissions: Granular CRUD control per resource (speakers, members, events, attendance)
-- RLS: Row-level security policies enforce permissions at database level

-- ============================================================================
-- 1. USER ROLES TABLE
-- ============================================================================
-- Links Supabase auth.users to members table with assigned roles

CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  member_id UUID REFERENCES members(id) ON DELETE SET NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'officer', 'chair', 'member', 'readonly')),
  club_id UUID, -- Future: For multi-club support (currently single club)
  granted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  UNIQUE(user_id), -- One role per user (can upgrade/downgrade, not multiple)
  UNIQUE(member_id) -- One user per member
);

-- Indexes for performance
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_member ON user_roles(member_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);

-- Comments
COMMENT ON TABLE user_roles IS 'Maps Supabase auth users to members with assigned roles for RBAC';
COMMENT ON COLUMN user_roles.user_id IS 'Reference to auth.users(id) from Supabase Auth';
COMMENT ON COLUMN user_roles.member_id IS 'Reference to members table (optional for non-member users)';
COMMENT ON COLUMN user_roles.role IS 'User role: admin (full access), officer (manage club), chair (limited), member (view + RSVP), readonly (view only)';
COMMENT ON COLUMN user_roles.club_id IS 'For future multi-club support (currently unused)';
COMMENT ON COLUMN user_roles.granted_by IS 'Which admin granted this role';

-- ============================================================================
-- 2. ROLE PERMISSIONS MATRIX
-- ============================================================================
-- Defines what each role can do with each resource

CREATE TABLE IF NOT EXISTS role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role TEXT NOT NULL,
  resource TEXT NOT NULL,
  can_create BOOLEAN DEFAULT FALSE,
  can_read BOOLEAN DEFAULT TRUE,
  can_update BOOLEAN DEFAULT FALSE,
  can_delete BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  UNIQUE(role, resource),
  CHECK (role IN ('admin', 'officer', 'chair', 'member', 'readonly')),
  CHECK (resource IN ('speakers', 'members', 'events', 'attendance', 'projects', 'partners', 'timeline', 'settings'))
);

-- Index for fast permission lookups
CREATE INDEX idx_role_permissions_lookup ON role_permissions(role, resource);

-- Comments
COMMENT ON TABLE role_permissions IS 'Permission matrix defining CRUD capabilities per role and resource';
COMMENT ON COLUMN role_permissions.resource IS 'Resource type: speakers, members, events, attendance, projects, partners, timeline, settings';

-- ============================================================================
-- 3. SEED DEFAULT PERMISSIONS
-- ============================================================================

-- Admin: Full access to everything
INSERT INTO role_permissions (role, resource, can_create, can_read, can_update, can_delete, notes) VALUES
  ('admin', 'speakers', true, true, true, true, 'Full speaker pipeline management'),
  ('admin', 'members', true, true, true, true, 'Manage club membership'),
  ('admin', 'events', true, true, true, true, 'Create and manage all events'),
  ('admin', 'attendance', true, true, true, true, 'Take attendance, view all records'),
  ('admin', 'projects', true, true, true, true, 'Manage service projects'),
  ('admin', 'partners', true, true, true, true, 'Manage club partners'),
  ('admin', 'timeline', true, true, true, true, 'Edit club history and timelines'),
  ('admin', 'settings', true, true, true, true, 'Configure club settings')
ON CONFLICT (role, resource) DO NOTHING;

-- Officer: Manage club operations (no delete members, limited settings)
INSERT INTO role_permissions (role, resource, can_create, can_read, can_update, can_delete, notes) VALUES
  ('officer', 'speakers', true, true, true, true, 'Full speaker management'),
  ('officer', 'members', false, true, true, false, 'Edit member info, cannot add/remove'),
  ('officer', 'events', true, true, true, true, 'Full event management'),
  ('officer', 'attendance', true, true, true, false, 'Take attendance, cannot delete records'),
  ('officer', 'projects', true, true, true, true, 'Manage service projects'),
  ('officer', 'partners', true, true, true, false, 'Add partners, cannot delete'),
  ('officer', 'timeline', false, true, true, false, 'Edit timeline narratives'),
  ('officer', 'settings', false, true, false, false, 'View settings only')
ON CONFLICT (role, resource) DO NOTHING;

-- Chair: Limited to specific areas (program chair, service chair, etc.)
INSERT INTO role_permissions (role, resource, can_create, can_read, can_update, can_delete, notes) VALUES
  ('chair', 'speakers', true, true, true, false, 'Program chair manages speakers'),
  ('chair', 'members', false, true, false, false, 'View member directory'),
  ('chair', 'events', false, true, true, false, 'Update own events'),
  ('chair', 'attendance', false, true, false, false, 'View attendance only'),
  ('chair', 'projects', true, true, true, false, 'Service chair manages projects'),
  ('chair', 'partners', false, true, true, false, 'Update partner info'),
  ('chair', 'timeline', false, true, false, false, 'View timeline'),
  ('chair', 'settings', false, true, false, false, 'View settings only')
ON CONFLICT (role, resource) DO NOTHING;

-- Member: View + RSVP + Update own profile
INSERT INTO role_permissions (role, resource, can_create, can_read, can_update, can_delete, notes) VALUES
  ('member', 'speakers', false, true, false, false, 'View speaker pipeline'),
  ('member', 'members', false, true, false, false, 'View member directory (own profile update via separate policy)'),
  ('member', 'events', false, true, false, false, 'View events, RSVP via meeting_rsvps table'),
  ('member', 'attendance', false, true, false, false, 'View own attendance record'),
  ('member', 'projects', false, true, false, false, 'View service projects'),
  ('member', 'partners', false, true, false, false, 'View club partners'),
  ('member', 'timeline', false, true, false, false, 'View club timeline'),
  ('member', 'settings', false, true, false, false, 'View public settings')
ON CONFLICT (role, resource) DO NOTHING;

-- Readonly: View-only access (for prospective members, guests)
INSERT INTO role_permissions (role, resource, can_create, can_read, can_update, can_delete, notes) VALUES
  ('readonly', 'speakers', false, true, false, false, 'View upcoming speakers'),
  ('readonly', 'members', false, false, false, false, 'Cannot view member directory'),
  ('readonly', 'events', false, true, false, false, 'View public events'),
  ('readonly', 'attendance', false, false, false, false, 'No attendance access'),
  ('readonly', 'projects', false, true, false, false, 'View service projects'),
  ('readonly', 'partners', false, true, false, false, 'View club partners'),
  ('readonly', 'timeline', false, true, false, false, 'View club history'),
  ('readonly', 'settings', false, false, false, false, 'No settings access')
ON CONFLICT (role, resource) DO NOTHING;

-- ============================================================================
-- 4. HELPER FUNCTIONS
-- ============================================================================

-- Function: Get user's role
CREATE OR REPLACE FUNCTION get_user_role(user_uuid UUID)
RETURNS TEXT AS $$
  SELECT role FROM user_roles WHERE user_id = user_uuid LIMIT 1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_user_role IS 'Returns the role of a given user (admin, officer, chair, member, readonly)';

-- Function: Check if user has permission
CREATE OR REPLACE FUNCTION user_has_permission(
  user_uuid UUID,
  resource_name TEXT,
  permission_type TEXT -- 'create', 'read', 'update', 'delete'
)
RETURNS BOOLEAN AS $$
DECLARE
  user_role TEXT;
  has_perm BOOLEAN;
BEGIN
  -- Get user's role
  user_role := get_user_role(user_uuid);

  -- If no role found, deny access
  IF user_role IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Check permission based on type
  CASE permission_type
    WHEN 'create' THEN
      SELECT can_create INTO has_perm FROM role_permissions WHERE role = user_role AND resource = resource_name;
    WHEN 'read' THEN
      SELECT can_read INTO has_perm FROM role_permissions WHERE role = user_role AND resource = resource_name;
    WHEN 'update' THEN
      SELECT can_update INTO has_perm FROM role_permissions WHERE role = user_role AND resource = resource_name;
    WHEN 'delete' THEN
      SELECT can_delete INTO has_perm FROM role_permissions WHERE role = user_role AND resource = resource_name;
    ELSE
      has_perm := FALSE;
  END CASE;

  RETURN COALESCE(has_perm, FALSE);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION user_has_permission IS 'Check if user has specific permission for a resource';

-- ============================================================================
-- 5. ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Enable RLS on user_roles table
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own role
CREATE POLICY "Users can view own role"
  ON user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Admins can view all roles
CREATE POLICY "Admins can view all roles"
  ON user_roles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Admins can create roles
CREATE POLICY "Admins can create roles"
  ON user_roles FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Admins can update roles
CREATE POLICY "Admins can update roles"
  ON user_roles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Admins can delete roles (careful!)
CREATE POLICY "Admins can delete roles"
  ON user_roles FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Enable RLS on role_permissions table (read-only for all authenticated users)
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view all permissions
CREATE POLICY "Authenticated users view permissions"
  ON role_permissions FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Policy: Only admins can modify permissions
CREATE POLICY "Admins modify permissions"
  ON role_permissions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- 6. UPDATE EXISTING TABLES WITH RLS
-- ============================================================================

-- Add RLS policies to speakers table (example - repeat for all resources)
ALTER TABLE speakers ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone with 'read' permission can view speakers
CREATE POLICY "Users with read permission view speakers"
  ON speakers FOR SELECT
  USING (user_has_permission(auth.uid(), 'speakers', 'read'));

-- Policy: Users with 'create' permission can add speakers
CREATE POLICY "Users with create permission add speakers"
  ON speakers FOR INSERT
  WITH CHECK (user_has_permission(auth.uid(), 'speakers', 'create'));

-- Policy: Users with 'update' permission can edit speakers
CREATE POLICY "Users with update permission edit speakers"
  ON speakers FOR UPDATE
  USING (user_has_permission(auth.uid(), 'speakers', 'update'));

-- Policy: Users with 'delete' permission can remove speakers
CREATE POLICY "Users with delete permission remove speakers"
  ON speakers FOR DELETE
  USING (user_has_permission(auth.uid(), 'speakers', 'delete'));

-- ============================================================================
-- 7. AUDIT LOG (OPTIONAL - FOR FUTURE)
-- ============================================================================
-- Track role changes for accountability

CREATE TABLE IF NOT EXISTS role_change_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  previous_role TEXT,
  new_role TEXT NOT NULL,
  changed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_role_change_log_user ON role_change_log(user_id);
CREATE INDEX idx_role_change_log_date ON role_change_log(created_at DESC);

COMMENT ON TABLE role_change_log IS 'Audit log of all role changes for accountability';

-- ============================================================================
-- 8. TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To rollback this migration:
-- DROP TRIGGER IF EXISTS update_user_roles_updated_at ON user_roles;
-- DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
-- DROP TABLE IF EXISTS role_change_log CASCADE;
-- DROP POLICY "Users with delete permission remove speakers" ON speakers;
-- DROP POLICY "Users with update permission edit speakers" ON speakers;
-- DROP POLICY "Users with create permission add speakers" ON speakers;
-- DROP POLICY "Users with read permission view speakers" ON speakers;
-- DROP POLICY "Admins modify permissions" ON role_permissions;
-- DROP POLICY "Authenticated users view permissions" ON role_permissions;
-- DROP POLICY "Admins can delete roles" ON user_roles;
-- DROP POLICY "Admins can update roles" ON user_roles;
-- DROP POLICY "Admins can create roles" ON user_roles;
-- DROP POLICY "Admins can view all roles" ON user_roles;
-- DROP POLICY "Users can view own role" ON user_roles;
-- DROP FUNCTION IF EXISTS user_has_permission(UUID, TEXT, TEXT);
-- DROP FUNCTION IF EXISTS get_user_role(UUID);
-- DROP TABLE IF EXISTS role_permissions CASCADE;
-- DROP TABLE IF EXISTS user_roles CASCADE;
-- ALTER TABLE speakers DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after migration to verify success:
-- SELECT * FROM user_roles;
-- SELECT * FROM role_permissions ORDER BY role, resource;
-- SELECT get_user_role('00000000-0000-0000-0000-000000000000'::UUID);
-- SELECT user_has_permission('00000000-0000-0000-0000-000000000000'::UUID, 'speakers', 'read');
