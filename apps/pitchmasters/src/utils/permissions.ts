import { User, MemberWithProfile } from '../types';

/**
 * Permission levels for member profile access and editing
 */
export type PermissionLevel = 'public' | 'member' | 'profile_owner' | 'officer' | 'admin';

/**
 * Check if a user can edit a member's profile
 */
export function canEditProfile(
  currentUser?: User | MemberWithProfile,
  targetMember?: MemberWithProfile,
  isAuthenticated: boolean = false
): boolean {
  if (!currentUser || !targetMember || !isAuthenticated) {
    return false;
  }

  // Profile owner can always edit their own profile
  if (currentUser.id === targetMember.id) {
    return true;
  }

  // Admins can edit any profile
  if (currentUser.role === 'admin') {
    return true;
  }

  // Officers can edit member profiles (but not other officers/admins)
  if (currentUser.role === 'officer' &&
      (targetMember.role === 'member' || !targetMember.role)) {
    return true;
  }

  return false;
}

/**
 * Check if a user can view a member's profile
 */
export function canViewProfile(
  currentUser?: User | MemberWithProfile,
  targetMember?: MemberWithProfile,
  isAuthenticated: boolean = false
): boolean {
  // Suppress unused parameter warnings - these are used for extensibility
  void currentUser;
  void isAuthenticated;

  if (!targetMember) {
    return false;
  }

  // Public profiles are always viewable
  // (This would check privacy settings in a real implementation)
  return true;
}

/**
 * Check if a user can view sensitive member data (contact info, etc.)
 */
export function canViewSensitiveData(
  currentUser?: User | MemberWithProfile,
  targetMember?: MemberWithProfile,
  isAuthenticated: boolean = false
): boolean {
  if (!targetMember || !isAuthenticated) {
    return false;
  }

  // Profile owner can see their own sensitive data
  if (currentUser && currentUser.id === targetMember.id) {
    return true;
  }

  // Officers and admins can see member sensitive data
  if (currentUser && (currentUser.role === 'officer' || currentUser.role === 'admin')) {
    return true;
  }

  // Authenticated members can see basic contact info if privacy allows
  if (currentUser) {
    return true; // This would check privacy settings in real implementation
  }

  return false;
}

/**
 * Get the permission level for a user relative to a target member
 */
export function getUserPermissionLevel(
  currentUser?: User | MemberWithProfile,
  targetMember?: MemberWithProfile,
  isAuthenticated: boolean = false
): PermissionLevel {
  if (!currentUser || !isAuthenticated) {
    return 'public';
  }

  if (currentUser.role === 'admin') {
    return 'admin';
  }

  if (currentUser.role === 'officer') {
    return 'officer';
  }

  if (targetMember && currentUser.id === targetMember.id) {
    return 'profile_owner';
  }

  return 'member';
}

/**
 * Check if a user can perform a specific action on a profile
 */
export function hasPermission(
  action: 'view' | 'edit' | 'delete' | 'view_sensitive',
  currentUser?: User | MemberWithProfile,
  targetMember?: MemberWithProfile,
  isAuthenticated: boolean = false
): boolean {
  const permissionLevel = getUserPermissionLevel(currentUser, targetMember, isAuthenticated);

  switch (action) {
    case 'view':
      return canViewProfile(currentUser, targetMember, isAuthenticated);

    case 'edit':
      return canEditProfile(currentUser, targetMember, isAuthenticated);

    case 'delete':
      // Only admins can delete profiles
      return permissionLevel === 'admin';

    case 'view_sensitive':
      return canViewSensitiveData(currentUser, targetMember, isAuthenticated);

    default:
      return false;
  }
}

/**
 * Get display text for permission levels (for UI feedback)
 */
export function getPermissionDisplayText(level: PermissionLevel): string {
  switch (level) {
    case 'public':
      return 'Public Viewer';
    case 'member':
      return 'Club Member';
    case 'profile_owner':
      return 'Profile Owner';
    case 'officer':
      return 'Club Officer';
    case 'admin':
      return 'Administrator';
    default:
      return 'Unknown';
  }
}