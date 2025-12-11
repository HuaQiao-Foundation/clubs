# Multi-Club Database Architecture Protocol

## Overview
This document defines the database architecture for the Pitchmasters multi-club platform, ensuring tenant isolation, scalability, and compliance with Toastmasters International standards.

## Core Principles

### 1. Tenant Isolation
- **Club-level isolation**: Each club operates as an independent tenant
- **Row Level Security (RLS)**: Enforced at the database level
- **Data segregation**: Users can only access their own club's data
- **Cross-club features**: Controlled through explicit permissions

### 2. Scalability Design
- **UUID primary keys**: Enable distributed systems and avoid collisions
- **Indexed foreign keys**: Optimized for multi-club queries
- **Partitioning ready**: Schema supports future horizontal partitioning
- **Connection pooling**: Supabase handles connection management

### 3. Toastmasters Compliance
- **Standard roles**: Aligned with official Toastmasters meeting roles
- **Speech tracking**: Supports Pathways and traditional manuals
- **Meeting structure**: Follows official Toastmasters meeting format
- **Charter tracking**: Ready for official charter numbers

## Database Schema

### Tables Structure

#### clubs
- **Purpose**: Top-level tenant definition
- **Key fields**: id, name, charter_number, timezone
- **Isolation**: Root table for tenant boundaries

#### users
- **Purpose**: Club members and roles
- **Key fields**: id, email, full_name, club_id, role
- **Isolation**: Scoped to club_id via foreign key

#### meetings
- **Purpose**: Club meeting management
- **Key fields**: id, club_id, title, date, start_time, meeting_type
- **Isolation**: Scoped to club_id via foreign key

#### speeches
- **Purpose**: Speech tracking and evaluation
- **Key fields**: id, meeting_id, user_id, title, manual, project_number
- **Isolation**: Inherits from meetings via meeting_id

#### meeting_roles
- **Purpose**: Functional roles in meetings
- **Key fields**: id, meeting_id, user_id, role_type
- **Isolation**: Inherits from meetings via meeting_id

## Row Level Security Policies

### Read Policies
- Users can only view data from their own club
- Implemented through club_id matching in WHERE clauses
- Cascades through foreign key relationships

### Write Policies
- **Officers/Admins**: Can create meetings for their club
- **Members**: Can create speeches for themselves
- **All users**: Can update their own records (with restrictions)

### Cross-Club Features (Future)
- **Networking**: Controlled visibility between clubs
- **Inter-club contests**: Temporary elevated permissions
- **District reports**: Aggregated data with privacy controls

## Performance Considerations

### Indexing Strategy
```sql
-- Primary performance indexes
CREATE INDEX idx_users_club_id ON users(club_id);
CREATE INDEX idx_meetings_club_id ON meetings(club_id);
CREATE INDEX idx_meetings_date ON meetings(date);
```

### Query Patterns
- **Club-scoped queries**: Always include club_id filter
- **Date-based queries**: Leverage meeting date indexes
- **User activity**: Optimized for user_id lookups

## Data Types and Constraints

### UUID Usage
- All primary keys use UUID for global uniqueness
- Enables future multi-region deployments
- Prevents enumeration attacks

### Enum Constraints
- **User roles**: 'member', 'officer', 'admin'
- **Meeting types**: 'regular', 'special', 'demo'
- **Meeting status**: 'scheduled', 'in_progress', 'completed', 'cancelled'
- **Meeting roles**: Standard Toastmasters functional roles

### Timestamp Management
- All tables include created_at and updated_at
- Automated triggers maintain updated_at accuracy
- Timezone-aware TIMESTAMPTZ for global compatibility

## Security Implementation

### Authentication
- Supabase Auth handles user authentication
- JWT tokens include user and club context
- Row Level Security enforces data boundaries

### Authorization Levels
1. **Member**: Basic access to club data, can create speeches
2. **Officer**: Meeting management, member data access
3. **Admin**: Full club management, user role assignment

### Audit Trail
- All changes tracked via updated_at timestamps
- Future: Dedicated audit log table for sensitive operations

## Migration Strategy

### Phase 1: Single Club
- Complete schema implementation
- RLS policies for single club
- Full feature set within club boundaries

### Phase 2: Multi-Club
- Cross-club networking features
- District-level reporting
- Inter-club contest support

### Phase 3: Scale
- Horizontal partitioning by region
- Read replicas for reporting
- Advanced analytics and insights

## Monitoring and Maintenance

### Key Metrics
- Query performance by club size
- RLS policy execution time
- Cross-club query patterns
- Data growth rates per club

### Regular Tasks
- Index optimization based on usage patterns
- RLS policy review and updates
- Performance monitoring and alerting
- Backup and recovery testing

## Compliance Notes

### Toastmasters International
- Schema supports official meeting structure
- Role definitions match TI standards
- Ready for charter number integration
- Evaluation tracking capability

### Data Privacy
- GDPR-compliant data handling
- Right to erasure implementation ready
- Data portability through standard exports
- Consent management for cross-club features

This protocol ensures the database architecture supports the Pitchmasters vision of a scalable, compliant, and performance-optimized multi-club platform.