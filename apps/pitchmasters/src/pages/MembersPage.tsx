import { useState, useEffect } from 'react';
import MemberDirectory from '../components/MemberDirectory';
import { Users, Loader } from 'lucide-react';
import { MemberWithProfile, User } from '../types';
import { supabase } from '../lib/supabase';

export default function MembersPage() {
  const [members, setMembers] = useState<MemberWithProfile[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // For demo: simulating authenticated admin user
  const currentUser: User | undefined = undefined; // Set to undefined for unauthenticated demo
  const isAuthenticated = false; // Set to false for public view demo

  // Load data from Supabase on mount
  useEffect(() => {
    async function loadData() {
      try {
        setIsLoading(true);
        setError(null);

        // Load members with profiles and privacy settings
        const { data: usersData, error: usersError } = await supabase
          .from('users')
          .select(`
            *,
            profile:member_profiles(*),
            privacy_settings:privacy_settings(*)
          `);

        if (usersError) throw usersError;

        const membersWithProfiles: MemberWithProfile[] = (usersData || []).map((user: any) => ({
          ...user,
          profile: user.profile || null,
          privacy_settings: user.privacy_settings || null
        }));

        setMembers(membersWithProfiles);

      } catch (err: any) {
        console.error('Error loading data:', err);
        setError(err.message || 'Failed to load data');
      } finally {
        setIsLoading(false);
      }
    }

    loadData();
  }, []);

  // Loading state
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <Loader className="w-12 h-12 text-tm-blue animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Loading members...</p>
        </div>
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="max-w-2xl mx-auto mt-12 p-6 bg-red-50 border border-red-200 rounded-lg">
        <h2 className="text-xl font-bold text-red-900 mb-2">Error Loading Data</h2>
        <p className="text-red-700 mb-4">{error}</p>
        <button
          onClick={() => window.location.reload()}
          className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Page Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <div className="flex items-center gap-3 mb-4">
              <Users className="w-8 h-8 text-tm-blue" />
              <h1 className="text-3xl font-bold text-gray-900">Member Directory</h1>
            </div>
            <p className="text-gray-600 max-w-3xl">
              Connect with fellow entrepreneurs and club members. All member information shown
              respects individual privacy settings and visibility preferences.
            </p>
          </div>
        </div>
      </div>

      {/* Member Directory Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <MemberDirectory
          members={members}
          currentUser={currentUser}
          isAuthenticated={isAuthenticated}
        />
      </div>
    </div>
  );
}