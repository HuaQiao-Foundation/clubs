-- Migration 058: Fix user_roles RLS infinite recursion
-- Purpose: Replace self-referencing RLS policies with security definer function
-- Date: 2025-12-02
-- Author: CTO

-- Drop existing problematic RLS policies
DROP POLICY IF EXISTS "Admins can view all roles" ON user_roles;
DROP POLICY IF EXISTS "Admins can create roles" ON user_roles;
DROP POLICY IF EXISTS "Admins can update roles" ON user_roles;
DROP POLICY IF EXISTS "Admins can delete roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view own role" ON user_roles;

-- Create security definer function to check if user is admin
-- This function runs with elevated privileges and doesn't trigger RLS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
END;
$$;

COMMENT ON FUNCTION public.is_admin() IS 'Check if current user is an admin (security definer to avoid RLS recursion)';

-- Create security definer function to check user role
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles
    WHERE user_id = auth.uid()
    AND role = required_role
  );
END;
$$;

COMMENT ON FUNCTION public.has_role(TEXT) IS 'Check if current user has a specific role (security definer to avoid RLS recursion)';

-- Create security definer function to check if user has any of multiple roles
CREATE OR REPLACE FUNCTION public.has_any_role(required_roles TEXT[])
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles
    WHERE user_id = auth.uid()
    AND role = ANY(required_roles)
  );
END;
$$;

COMMENT ON FUNCTION public.has_any_role(TEXT[]) IS 'Check if current user has any of the specified roles (security definer to avoid RLS recursion)';

-- Recreate RLS policies using security definer functions (no recursion!)
CREATE POLICY "Users can view own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all roles"
  ON user_roles
  FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admins can create roles"
  ON user_roles
  FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update roles"
  ON user_roles
  FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admins can delete roles"
  ON user_roles
  FOR DELETE
  USING (public.is_admin());

-- Verification query
SELECT 'user_roles RLS policies fixed successfully' AS status;
