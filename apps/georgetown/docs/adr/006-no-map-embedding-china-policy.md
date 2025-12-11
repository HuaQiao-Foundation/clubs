# ADR 006: Exclude Map Link Embedding to Maintain China-Friendly Policy

**Status**: Accepted
**Date**: 2025-12-02
**Deciders**: CTO, CEO
**Related ADRs**: [004-self-hosted-fonts.md](004-self-hosted-fonts.md) (China accessibility)

## Context

Georgetown Rotary Club maintains a **China-friendly policy** ensuring all features work without restrictions in mainland China. This policy prevents reliance on services blocked by the Great Firewall.

During development of the location management system, we explored adding map link functionality to help members find meeting venues. Two options were evaluated:
1. **Google Maps** - Most accurate, widely used globally
2. **OpenStreetMap (OSM)** - Open-source, China-accessible alternative

### Initial Implementation

We initially implemented OpenStreetMap integration with:
- `google_maps_link` field in locations table (naming kept for backward compatibility)
- "View on Map" buttons in LocationSelect and EventViewModal components
- Helper text encouraging OSM usage as China-friendly alternative

### Discovery of Data Quality Issues

During testing with real venue data (e.g., Nona Bali restaurant in Penang), we discovered that **OpenStreetMap data for Malaysia locations is significantly outdated**. The map links pointed to incorrect or non-existent locations, making the feature unreliable and potentially misleading for members.

## Decision

We will **remove map link functionality entirely** from the user interface until a reliable, China-accessible mapping solution can be identified.

**Specific actions:**
1. Remove map link input field from LocationSelect component
2. Remove "View on Map" buttons from EventViewModal and LocationSelect
3. Keep `google_maps_link` database field (nullable) for potential future use
4. Document this decision in an ADR for future reference

## Consequences

### Positive

- **Maintains China-friendly policy compliance** - No risk of inadvertently embedding blocked services
- **Prevents user confusion** - Removes unreliable/outdated map links that could misdirect members
- **Data integrity** - No misleading location data stored in system
- **Clean user experience** - UI only shows features that work reliably
- **Future flexibility** - Database field remains for future implementation

### Negative

- **Reduced convenience** - Members must manually search for venue addresses
- **No visual map reference** - Text addresses only, no geographic context
- **Feature gap** - Competitive systems may offer map integration
- **Manual directions** - Members need to copy/paste addresses into their preferred map apps

### Neutral

- **Database schema unchanged** - Field remains but is not used by UI
- **Minimal code change** - Removal is straightforward, can be restored if solution found
- **No impact on core functionality** - Location management works independently of maps

## Alternatives Considered

### Alternative 1: Keep Google Maps Links

**Description**: Implement Google Maps links for best data quality

**Pros**:
- Most accurate map data for Malaysia
- Widely used and familiar to members
- Best mobile integration (Google Maps app)
- Reliable directions and venue photos

**Cons**:
- **Blocked in mainland China** - Violates core China-friendly policy
- External dependency on Google services
- Privacy considerations with Google tracking

**Reason for rejection**: Directly violates established China-friendly policy. This is a non-negotiable constraint for the Georgetown Rotary system.

### Alternative 2: Continue with OpenStreetMap

**Description**: Keep OSM implementation despite data quality issues

**Pros**:
- China-accessible
- Open-source, no vendor lock-in
- No privacy concerns
- Adheres to China-friendly policy

**Cons**:
- **Outdated data for Malaysian locations** - Core reliability issue
- Poor user experience when links are incorrect
- Members may lose trust in system accuracy
- No clear path to data quality improvement

**Reason for rejection**: Data quality is too poor for production use. Providing unreliable map links is worse than providing no map links.

### Alternative 3: Baidu Maps (China-specific)

**Description**: Use Baidu Maps API for China accessibility

**Pros**:
- Works in mainland China
- Good data quality for Chinese locations
- Native Chinese language support

**Cons**:
- **Poor data quality for Malaysian locations** - Members primarily in Malaysia
- Requires API key and potential costs
- Chinese-language focused interface
- External dependency on Baidu services
- Complex integration requirements

**Reason for rejection**: Optimizes for China access at expense of Malaysia accuracy, which is backwards for our primary user base.

### Alternative 4: Conditional Map Links (User Preference)

**Description**: Let users choose their preferred map provider

**Pros**:
- Flexibility for different regions
- Users can pick what works for them
- Could support multiple providers

**Cons**:
- Increased UI complexity
- Configuration burden on users
- Still doesn't solve OSM data quality issue
- Risk of users accidentally choosing blocked services
- Maintenance overhead for multiple integrations

**Reason for rejection**: Adds complexity without solving core data quality problem. Over-engineers a feature that should be simple.

## Implementation Notes

**Completed Actions** (2025-12-02):
1. Removed `google_maps_link` from LocationSelect formData state
2. Removed map link input field and helper text from form UI
3. Removed "View on Map" button from LocationSelect location cards
4. Removed "View on Map" button from EventViewModal location display
5. Removed field from all database insert/update operations
6. Database field `locations.google_maps_link` remains (nullable, unused)
7. Verified TypeScript compilation with no errors
8. Tested UI - location management works correctly without map links

**Migration Strategy**:
- No database migration needed (field already nullable)
- Existing map link data preserved in database but not displayed
- Can restore functionality if reliable solution found

**Rollback Plan**:
- Git history contains full implementation (commit before removal)
- Database field intact, can re-add UI components
- No data loss, straightforward to restore

## References

- [CLAUDE.md](../../CLAUDE.md) - China-friendly design constraints
- [Migration 066](../database/066-add-google-maps-link-to-locations.sql) - Original field addition
- [China Great Firewall Services List](https://en.wikipedia.org/wiki/List_of_websites_blocked_in_mainland_China)
- User feedback: "OSM was outdated for nona bali" (2025-12-02)

## Review Schedule

**Next review date**: When reliable China-accessible mapping solution is identified

**Trigger for review**:
- Discovery of mapping provider with accurate Malaysia data AND China accessibility
- Significant improvement in OpenStreetMap Malaysia coverage
- Development of self-hosted mapping solution
- User feedback requesting map functionality (with proposed solution)
- China policy change (unlikely)

**Evaluation criteria for future solutions**:
1. **China accessibility** - Must work without VPN in mainland China
2. **Malaysia data quality** - Accurate, current venue locations in Penang/Malaysia
3. **Reliability** - 95%+ accuracy for user-entered locations
4. **Maintenance burden** - Reasonable integration and upkeep effort
5. **Cost** - Free or low-cost for club usage level
