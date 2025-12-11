import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { UserRole } from '../types/database'

/**
 * useAuth Hook
 * Purpose: Manage Supabase authentication state and user role
 *
 * IMPORTANT: This is a temporary mock implementation until Supabase Auth is fully configured.
 * For testing, it uses a hardcoded member_id. Replace with actual auth when ready.
 *
 * Usage:
 * const { user, userRole, memberId, isLoading } = useAuth()
 */

interface AuthUser {
  id: string
  email?: string
}

interface UseAuthReturn {
  user: AuthUser | null
  userRole: UserRole | null
  memberId: string | null
  isLoading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

export function useAuth(): UseAuthReturn {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [userRole, setUserRole] = useState<UserRole | null>(null)
  const [memberId, setMemberId] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Check current session
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) {
        setUser({
          id: session.user.id,
          email: session.user.email
        })
        await fetchUserRole(session.user.id)
      } else {
        // TEMPORARY MOCK: For testing without auth, use a hardcoded member
        // TODO: Remove this when Supabase Auth is fully configured
        await useMockAuth()
      }
      setIsLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        if (session?.user) {
          setUser({
            id: session.user.id,
            email: session.user.email
          })
          fetchUserRole(session.user.id)
        } else {
          setUser(null)
          setUserRole(null)
          setMemberId(null)
        }
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const fetchUserRole = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('user_roles')
        .select('*')
        .eq('user_id', userId)
        .single()

      if (error) throw error

      setUserRole(data)
      setMemberId(data.member_id || null)
    } catch (error) {
      console.error('Error fetching user role:', error)
      setUserRole(null)
      setMemberId(null)
    }
  }

  // TEMPORARY: Mock auth for testing (Phase 3)
  const useMockAuth = async () => {
    try {
      // Get the first active member for testing
      const { data: members, error } = await supabase
        .from('members')
        .select('id, name, email')
        .eq('active', true)
        .limit(1)
        .single()

      if (error) throw error

      if (members) {
        // Mock user with fixed UUID
        const mockUserId = '00000000-0000-0000-0000-000000000001'
        const mockUser: AuthUser = {
          id: mockUserId,
          email: members.email || 'mock@georgetown-rotary.org'
        }

        // Mock role (assuming officer role for testing)
        const mockRole: UserRole = {
          id: '00000000-0000-0000-0000-000000000002',
          user_id: mockUserId,
          member_id: members.id,
          role: 'officer',
          granted_at: new Date().toISOString(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }

        setUser(mockUser)
        setUserRole(mockRole)
        setMemberId(members.id)

        console.warn('⚠️ Using MOCK AUTH for testing. Member:', members.name, 'ID:', members.id)
      }
    } catch (error) {
      console.error('Error setting up mock auth:', error)
    }
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })

    if (error) throw error

    if (data.user) {
      setUser({
        id: data.user.id,
        email: data.user.email
      })
      await fetchUserRole(data.user.id)
    }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error

    setUser(null)
    setUserRole(null)
    setMemberId(null)
  }

  return {
    user,
    userRole,
    memberId,
    isLoading,
    signIn,
    signOut
  }
}
