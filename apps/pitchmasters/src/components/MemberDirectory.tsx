import { useState, useMemo } from 'react';
import { Search, Filter, User as UserIcon, Briefcase, Target, Phone, Mail, ExternalLink, MapPin, Award, Building } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useDebounce } from '../hooks/useDebounce';
import { MemberWithProfile, User } from '../types';
import { getVisibleMemberData, memberMatchesSearch, getPrivacyAwareSearchSuggestions } from '../utils/privacy';

interface MemberDirectoryProps {
  members: MemberWithProfile[];
  currentUser?: MemberWithProfile | User;
  isAuthenticated: boolean;
}

interface FilterOptions {
  industry: string;
  pathLevel: string;
  ventureStage: string;
  lookingFor: string;
  location: string;
  isFounder: string;
  memberType: string;
}

export default function MemberDirectory({ members, currentUser, isAuthenticated }: MemberDirectoryProps) {

  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState<FilterOptions>({
    industry: '',
    pathLevel: '',
    ventureStage: '',
    lookingFor: '',
    location: '',
    isFounder: '',
    memberType: ''
  });
  const [showFilters, setShowFilters] = useState(false);

  const debouncedSearchTerm = useDebounce(searchTerm, 300);

  // Get unique filter options from members data (privacy-aware)
  const filterOptions = useMemo(() => {
    const privacyAwareSuggestions = getPrivacyAwareSearchSuggestions(members, currentUser, isAuthenticated);
    const pathLevels = new Set<string>();
    const locations = new Set<string>();
    const memberTypes = new Set<string>();

    members.forEach(member => {
      const visibleData = getVisibleMemberData(member, currentUser, isAuthenticated);
      if (visibleData) {
        pathLevels.add(visibleData.pathLevel);
      }

      // Location from CSV fields (city, country)
      if (member.profile?.city && member.profile?.country) {
        locations.add(`${member.profile.city}, ${member.profile.country}`);
      } else if (member.profile?.country) {
        locations.add(member.profile.country);
      }

      // Member type from CSV
      if (member.profile?.member_type) {
        memberTypes.add(member.profile.member_type);
      }
    });

    return {
      industries: privacyAwareSuggestions.industries,
      pathLevels: Array.from(pathLevels).sort(),
      ventureStages: privacyAwareSuggestions.ventureStages,
      lookingForOptions: privacyAwareSuggestions.networkingInterests,
      locations: Array.from(locations).sort(),
      memberTypes: Array.from(memberTypes).sort()
    };
  }, [members, currentUser, isAuthenticated]);

  // Filter and search members based on search term and filters (privacy-aware)
  const filteredMembers = useMemo(() => {
    return members.filter(member => {
      const visibleData = getVisibleMemberData(member, currentUser, isAuthenticated);
      if (!visibleData) return false;

      // Search term filtering (privacy-aware)
      if (debouncedSearchTerm) {
        if (!memberMatchesSearch(member, debouncedSearchTerm, currentUser, isAuthenticated)) {
          return false;
        }
      }

      // Filter by industry (using visible data)
      if (filters.industry && visibleData.industry !== filters.industry) return false;

      // Filter by path level (always visible)
      if (filters.pathLevel && visibleData.pathLevel !== filters.pathLevel) return false;

      // Filter by venture stage (using visible data)
      if (filters.ventureStage && visibleData.venture?.stage !== filters.ventureStage) return false;

      // Filter by looking for (only if networking data is visible)
      if (filters.lookingFor && visibleData.networking) {
        if (!visibleData.networking.lookingFor.includes(filters.lookingFor)) return false;
      } else if (filters.lookingFor) {
        // If looking for filter is set but networking data is not visible, exclude
        return false;
      }

      // Filter by location (city, country)
      if (filters.location) {
        const memberLocation = member.profile?.city && member.profile?.country
          ? `${member.profile.city}, ${member.profile.country}`
          : member.profile?.country || '';
        if (memberLocation !== filters.location) return false;
      }

      // Filter by founder status
      if (filters.isFounder) {
        const isFounder = member.profile?.is_founder || false;
        if (filters.isFounder === 'yes' && !isFounder) return false;
        if (filters.isFounder === 'no' && isFounder) return false;
      }

      // Filter by member type
      if (filters.memberType && member.profile?.member_type !== filters.memberType) return false;

      return true;
    });
  }, [members, debouncedSearchTerm, filters, currentUser, isAuthenticated]);


  const resetFilters = () => {
    setFilters({
      industry: '',
      pathLevel: '',
      ventureStage: '',
      lookingFor: '',
      location: '',
      isFounder: '',
      memberType: ''
    });
  };

  return (
    <div className="w-full max-w-7xl mx-auto">
      {/* Search Header */}
      <div className="mb-6">
        <div className="flex flex-col sm:flex-row gap-4 items-center">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
            <input
              type="text"
              placeholder="Search members by name, venture, expertise, or industry..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tm-blue focus:border-transparent text-base min-h-touch"
            />
          </div>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2 px-4 py-3 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors min-h-touch min-w-touch"
          >
            <Filter className="h-5 w-5" />
            <span className="hidden sm:inline">Filters</span>
          </button>
        </div>

        {/* Filter Panel */}
        {showFilters && (
          <div className="mt-4 p-4 bg-white border border-gray-200 rounded-lg">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Industry</label>
                <select
                  value={filters.industry}
                  onChange={(e) => setFilters(prev => ({ ...prev, industry: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Industries</option>
                  {filterOptions.industries.map(industry => (
                    <option key={industry} value={industry}>{industry}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Path Level</label>
                <select
                  value={filters.pathLevel}
                  onChange={(e) => setFilters(prev => ({ ...prev, pathLevel: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Levels</option>
                  {filterOptions.pathLevels.map(level => (
                    <option key={level} value={level}>{level}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Venture Stage</label>
                <select
                  value={filters.ventureStage}
                  onChange={(e) => setFilters(prev => ({ ...prev, ventureStage: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Stages</option>
                  {filterOptions.ventureStages.map(stage => (
                    <option key={stage} value={stage}>{stage.charAt(0).toUpperCase() + stage.slice(1)}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Looking For</label>
                <select
                  value={filters.lookingFor}
                  onChange={(e) => setFilters(prev => ({ ...prev, lookingFor: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Needs</option>
                  {filterOptions.lookingForOptions.map(option => (
                    <option key={option} value={option}>{option}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
                <select
                  value={filters.location}
                  onChange={(e) => setFilters(prev => ({ ...prev, location: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Locations</option>
                  {filterOptions.locations.map(location => (
                    <option key={location} value={location}>{location}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Founder Status</label>
                <select
                  value={filters.isFounder}
                  onChange={(e) => setFilters(prev => ({ ...prev, isFounder: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Members</option>
                  <option value="yes">Founders</option>
                  <option value="no">Non-Founders</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Member Type</label>
                <select
                  value={filters.memberType}
                  onChange={(e) => setFilters(prev => ({ ...prev, memberType: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-tm-blue focus:border-transparent"
                >
                  <option value="">All Types</option>
                  {filterOptions.memberTypes.map(type => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="mt-4 flex justify-end">
              <button
                onClick={resetFilters}
                className="px-4 py-2 text-sm text-gray-600 hover:text-gray-800 transition-colors"
              >
                Clear Filters
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-sm text-gray-600">
          Showing {filteredMembers.length} of {members.length} members
        </p>
      </div>

      {/* Member Cards Grid - Mobile-First Optimized */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
        {filteredMembers.map(member => {
          const visibleData = getVisibleMemberData(member, currentUser, isAuthenticated);
          if (!visibleData) return null;

          return (
            <Link
              key={member.id}
              to={`/members/${member.id}`}
              className="block bg-white rounded-lg shadow-sm border border-gray-200 p-4 sm:p-6 hover:shadow-md hover:border-tm-blue hover:border-opacity-50 transition-all cursor-pointer active:scale-[0.98] active:bg-gray-50 min-h-touch"
            >
              {/* Header - Mobile Optimized */}
              <div className="flex items-start gap-3 sm:gap-4 mb-3 sm:mb-4">
                <div className="flex-shrink-0">
                  {visibleData.photo ? (
                    <img
                      src={visibleData.photo}
                      alt={visibleData.name}
                      className="w-14 h-14 sm:w-16 sm:h-16 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-gray-200 flex items-center justify-center">
                      <UserIcon className="w-7 h-7 sm:w-8 sm:h-8 text-gray-400" />
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-base sm:text-lg font-semibold text-gray-900 truncate leading-tight">{visibleData.name}</h3>
                  <p className="text-sm text-gray-600 leading-tight">{visibleData.pathLevel} • {visibleData.currentPath}</p>
                  {visibleData.industry && (
                    <p className="text-sm text-gray-500 leading-tight">{visibleData.industry}</p>
                  )}

                  {/* Location from CSV data */}
                  {(member.profile?.city || member.profile?.country) && (
                    <div className="flex items-center gap-1 mt-1">
                      <MapPin className="w-3 h-3 text-gray-400" />
                      <p className="text-xs text-gray-500">
                        {member.profile?.city && member.profile?.country
                          ? `${member.profile.city}, ${member.profile.country}`
                          : member.profile?.country || member.profile?.city}
                      </p>
                    </div>
                  )}

                  {/* Officer Role from CSV data */}
                  {member.profile?.officer_role && (
                    <div className="flex items-center gap-1 mt-1">
                      <Award className="w-3 h-3 text-tm-blue" />
                      <span className="text-xs px-2 py-1 bg-tm-blue bg-opacity-10 text-tm-blue rounded-full">
                        {member.profile.officer_role}
                      </span>
                    </div>
                  )}

                  {/* Founder Status */}
                  {member.profile?.is_founder && (
                    <div className="flex items-center gap-1 mt-1">
                      <span className="text-xs px-2 py-1 bg-green-100 text-green-700 rounded-full">
                        Founder
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Venture/Organization Info */}
              {(visibleData.venture || member.profile?.organization) && (
                <div className="mb-4">
                  <div className="flex items-center gap-2 mb-2">
                    <Briefcase className="w-4 h-4 text-gray-400" />
                    <span className="font-medium text-gray-900">
                      {visibleData.venture?.name || member.profile?.organization}
                    </span>
                    {visibleData.venture?.stage && (
                      <span className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
                        {visibleData.venture.stage}
                      </span>
                    )}
                  </div>
                  {member.profile?.job_title && (
                    <div className="flex items-center gap-2 mb-1">
                      <Building className="w-3 h-3 text-gray-400" />
                      <p className="text-sm text-gray-600">{member.profile.job_title}</p>
                    </div>
                  )}
                  {visibleData.venture?.description && (
                    <p className="text-sm text-gray-600 line-clamp-2">{visibleData.venture.description}</p>
                  )}
                </div>
              )}

              {/* Bio */}
              {visibleData.bio && (
                <div className="mb-4">
                  <p className="text-sm text-gray-600 line-clamp-3">{visibleData.bio}</p>
                </div>
              )}

              {/* Expertise Areas */}
              {visibleData.expertise.length > 0 && (
                <div className="mb-4">
                  <div className="flex flex-wrap gap-2">
                    {visibleData.expertise.slice(0, 3).map((area, index) => (
                      <span key={index} className="text-xs px-2 py-1 bg-tm-blue bg-opacity-10 text-tm-blue rounded-full">
                        {area}
                      </span>
                    ))}
                    {visibleData.expertise.length > 3 && (
                      <span className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
                        +{visibleData.expertise.length - 3} more
                      </span>
                    )}
                  </div>
                </div>
              )}

              {/* Networking Info (Members Only) */}
              {visibleData.networking && (
                <div className="mb-4 space-y-2">
                  {visibleData.networking.lookingFor.length > 0 && (
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <Target className="w-4 h-4 text-green-500" />
                        <span className="text-sm font-medium text-gray-700">Looking for:</span>
                      </div>
                      <div className="flex flex-wrap gap-1">
                        {visibleData.networking.lookingFor.slice(0, 2).map((item, index) => (
                          <span key={index} className="text-xs px-2 py-1 bg-green-50 text-green-700 rounded-full">
                            {item}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {visibleData.networking.offering.length > 0 && (
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <Target className="w-4 h-4 text-tm-blue" />
                        <span className="text-sm font-medium text-gray-700">Offering:</span>
                      </div>
                      <div className="flex flex-wrap gap-1">
                        {visibleData.networking.offering.slice(0, 2).map((item, index) => (
                          <span key={index} className="text-xs px-2 py-1 bg-tm-blue bg-opacity-10 text-tm-blue rounded-full">
                            {item}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Speech Progress (Members Only) */}
              {visibleData.speechProgress && (
                <div className="mb-4">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-gray-600">Speeches: {visibleData.speechProgress.speechCount}</span>
                    <span className="text-gray-600">Evaluations: {visibleData.speechProgress.evaluationCount}</span>
                  </div>
                </div>
              )}

              {/* Contact Actions - Mobile Touch Optimized */}
              <div className="flex flex-wrap gap-2 sm:gap-3 mt-3">
                {visibleData.contact?.email && (
                  <button
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      window.location.href = `mailto:${visibleData.contact?.email}`;
                    }}
                    className="flex items-center gap-2 px-3 py-2 text-sm text-tm-blue hover:bg-tm-blue hover:bg-opacity-10 rounded-lg transition-all min-h-touch min-w-touch active:scale-95"
                    aria-label="Send email"
                  >
                    <Mail className="w-4 h-4" />
                    <span className="hidden sm:inline">Email</span>
                  </button>
                )}

                {visibleData.contact?.phone && (
                  <button
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      window.location.href = `tel:${visibleData.contact?.phone}`;
                    }}
                    className="flex items-center gap-2 px-3 py-2 text-sm text-tm-blue hover:bg-tm-blue hover:bg-opacity-10 rounded-lg transition-all min-h-touch min-w-touch active:scale-95"
                    aria-label="Call phone number"
                  >
                    <Phone className="w-4 h-4" />
                    <span className="hidden sm:inline">Call</span>
                  </button>
                )}

                {visibleData.socialLinks?.linkedin && (
                  <button
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      window.open(visibleData.socialLinks?.linkedin, '_blank');
                    }}
                    className="flex items-center gap-2 px-3 py-2 text-sm text-tm-blue hover:bg-tm-blue hover:bg-opacity-10 rounded-lg transition-all min-h-touch min-w-touch active:scale-95"
                    aria-label="View LinkedIn profile"
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span className="hidden sm:inline">LinkedIn</span>
                  </button>
                )}

                {visibleData.socialLinks?.website && (
                  <button
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      window.open(visibleData.socialLinks?.website, '_blank');
                    }}
                    className="flex items-center gap-2 px-3 py-2 text-sm text-tm-blue hover:bg-tm-blue hover:bg-opacity-10 rounded-lg transition-all min-h-touch min-w-touch active:scale-95"
                    aria-label="Visit website"
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span className="hidden sm:inline">Website</span>
                  </button>
                )}
              </div>
            </Link>
          );
        })}
      </div>

      {/* Empty State */}
      {filteredMembers.length === 0 && (
        <div className="text-center py-12">
          <UserIcon className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No members found</h3>
          <p className="text-gray-600">Try adjusting your search terms or filters.</p>
        </div>
      )}
    </div>
  );
}