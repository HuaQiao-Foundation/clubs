# Pitchmasters Database Setup Guide

**Purpose**: Step-by-step Supabase database initialization
**Time Required**: 30-45 minutes
**Prerequisites**: Supabase account (free tier works)

---

## Table of Contents

1. [Create Supabase Project](#create-supabase-project)
2. [Run Migrations](#run-migrations)
3. [Configure Environment Variables](#configure-environment-variables)
4. [Verify Installation](#verify-installation)
5. [Load Sample Data (Optional)](#load-sample-data-optional)
6. [Troubleshooting](#troubleshooting)

---

## Create Supabase Project

### Step 1: Sign Up for Supabase

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub or email
4. Free tier includes:
   - 500MB database
   - 1GB file storage
   - 2GB bandwidth
   - Unlimited API requests

### Step 2: Create New Project

1. Click "New Project" in dashboard
2. Fill in project details:
   - **Project Name**: `pitchmasters-toastmasters`
   - **Database Password**: Generate strong password (save securely!)
   - **Region**: Choose closest to your club location
     - Singapore: `ap-southeast-1` (recommended for Asia)
     - US East: `us-east-1`
     - Europe: `eu-west-1`
   - **Pricing Plan**: Free (sufficient for Phase 1)

3. Click "Create new project"
4. Wait 2-3 minutes for provisioning

### Step 3: Save Connection Details

Once project is ready:

1. Go to **Settings** → **API**
2. Save these values (you'll need them later):
   - **Project URL**: `https://[project-id].supabase.co`
   - **Anon public key**: `eyJ...` (long JWT token)
   - **Service role key**: `eyJ...` (keep this secret!)

---

## Run Migrations

### Migration Order

**IMPORTANT**: Run migrations in sequential order (001 → 007)

```
001-initial-schema.sql          → Core tables
002-member-profiles-extension.sql → Extended profiles
003-add-csv-fields.sql          → Additional fields
004-fix-rls-policies.sql        → RLS fixes
005-add-public-read-policy.sql  → Public access
006-fix-users-rls-recursion.sql → Recursion fixes
007-rebuild-schema.sql          → Full rebuild (alternative)
```

### Option A: Incremental Migrations (Recommended)

**Use this if**: Starting fresh or need to understand each migration

1. Go to **SQL Editor** in Supabase dashboard
2. Click "New query"
3. Open `docs/database/sql-scripts/001-initial-schema.sql`
4. Copy entire contents
5. Paste into SQL Editor
6. Click "Run" (bottom right)
7. Verify success message: "Success. No rows returned"
8. Repeat for migrations 002-006 in order

**After Each Migration**:
- Check for error messages
- Verify tables created in **Database** → **Tables**
- Note any warnings or issues

### Option B: Full Rebuild (Quick Start)

**Use this if**: Want to set up entire schema at once

1. Go to **SQL Editor** in Supabase dashboard
2. Click "New query"
3. Open `docs/database/sql-scripts/007-rebuild-schema.sql`
4. Copy entire contents
5. Paste into SQL Editor
6. Click "Run"
7. Verify all tables created

**WARNING**: This drops all existing tables. Only use for fresh setup.

### Verify Tables Created

After running migrations, check **Database** → **Tables**:

**Expected Tables**:
- ✅ clubs
- ✅ users
- ✅ meetings
- ✅ speeches
- ✅ meeting_roles
- ✅ member_profiles
- ✅ privacy_settings

**Expected Functions**:
- ✅ update_updated_at_column()
- ✅ get_current_user_club_id()

---

## Configure Environment Variables

### Step 1: Create Local Environment File

1. In project root, copy `.env.example` to `.env.local`:
   ```bash
   cp .env.example .env.local
   ```

2. Open `.env.local` in editor

### Step 2: Add Supabase Credentials

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://[your-project-id].supabase.co
VITE_SUPABASE_ANON_KEY=eyJ[your-anon-key]...

# Environment
VITE_APP_ENV=development
```

**Where to find these**:
- Go to Supabase dashboard
- **Settings** → **API**
- Copy "Project URL" and "anon public" key

### Step 3: Verify Configuration

```bash
# Test that environment variables load
npm run dev

# Check browser console for Supabase connection
# Should see no errors related to Supabase client
```

---

## Verify Installation

### Step 1: Check Database Schema

1. Go to **Database** → **Schema Visualizer** in Supabase
2. Verify tables and relationships
3. Should see club_id foreign keys linking tables

### Step 2: Test Row Level Security

1. Go to **Authentication** → **Policies**
2. Verify RLS enabled on all tables
3. Check policies exist:
   - `clubs_view_own` on clubs
   - `users_view_same_club` on users
   - `users_own_profile` on member_profiles

### Step 3: Run Test Queries

Go to **SQL Editor** and run:

```sql
-- Should return 2 sample clubs
SELECT * FROM clubs;

-- Should show RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;

-- Should show helper function exists
SELECT proname FROM pg_proc
WHERE proname = 'get_current_user_club_id';
```

**Expected Results**:
- ✅ 2 clubs returned (Pitchmasters, Tech Speakers)
- ✅ 7 tables with RLS enabled
- ✅ Helper function found

---

## Load Sample Data (Optional)

### Option 1: Use Provided Sample Data

Sample data is included in `001-initial-schema.sql`:

```sql
-- Already included in migration
INSERT INTO clubs (name, charter_number, timezone) VALUES
('Pitchmasters Toastmasters', '12345', 'Asia/Singapore'),
('Tech Speakers Club', '67890', 'America/New_York');
```

### Option 2: Add Custom Club Data

```sql
-- Insert your actual club
INSERT INTO clubs (name, charter_number, timezone)
VALUES ('Your Club Name', 'YOUR_CHARTER', 'Your/Timezone');

-- Get club_id (note the UUID returned)
SELECT id, name FROM clubs WHERE name = 'Your Club Name';
```

### Option 3: CSV Import (for member data)

See [image-management-guide.md](../../brand/image-management-guide.md) for CSV import instructions.

---

## Troubleshooting

### Error: "relation 'clubs' does not exist"

**Cause**: Migration not run or failed silently

**Fix**:
1. Go to **SQL Editor**
2. Run: `SELECT * FROM pg_tables WHERE schemaname = 'public';`
3. If empty, re-run migrations from step 001
4. Check for error messages in SQL Editor output

---

### Error: "infinite recursion detected in policy"

**Cause**: RLS policies have circular dependency

**Fix**:
1. Run migration `006-fix-users-rls-recursion.sql`
2. This creates security definer function to break recursion
3. Verify with: `SELECT * FROM users LIMIT 1;` (should not error)

---

### Error: "permission denied for schema public"

**Cause**: Using service_role key instead of anon key

**Fix**:
1. Check `.env.local` uses `VITE_SUPABASE_ANON_KEY`
2. Do NOT use service_role key in client code
3. Service role key is only for admin operations

---

### Error: "row level security policy violation"

**Cause**: User not associated with a club

**Fix**:
1. Ensure users created through proper authentication flow
2. User must have club_id set
3. For testing, insert test user:
   ```sql
   INSERT INTO users (email, full_name, club_id, role)
   VALUES ('test@example.com', 'Test User',
           (SELECT id FROM clubs LIMIT 1), 'member');
   ```

---

### Tables Created but Empty

**Cause**: Sample data insert failed

**Fix**:
1. Check **SQL Editor** for error messages
2. Manually insert club:
   ```sql
   INSERT INTO clubs (name, charter_number, timezone)
   VALUES ('Pitchmasters', '12345', 'Asia/Singapore')
   RETURNING *;
   ```
3. Verify timezone is valid PostgreSQL timezone

---

### Cannot Connect from Application

**Cause**: Environment variables not loaded

**Fix**:
1. Restart development server: `npm run dev`
2. Verify `.env.local` file exists in project root
3. Check variable names start with `VITE_`
4. Ensure no quotes around values in `.env.local`

---

## Next Steps

After successful setup:

1. **Configure Authentication**: Set up Supabase Auth providers
2. **Create First User**: Add yourself as admin
3. **Test Application**: Run `npm run dev` and verify database connection
4. **Review Schema**: Familiarize yourself with [schema-design.md](../schema-design.md)

---

## Quick Reference

### Useful Supabase Dashboard Links

- **Tables**: Database → Tables (view/edit data)
- **SQL Editor**: SQL Editor (run queries)
- **Authentication**: Authentication → Users (manage users)
- **Policies**: Authentication → Policies (RLS policies)
- **API Docs**: Settings → API (auto-generated API reference)

### Common SQL Queries

```sql
-- Check migration status
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Count records in each table
SELECT 'clubs' as table_name, COUNT(*) FROM clubs
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'meetings', COUNT(*) FROM meetings;

-- View all RLS policies
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public';
```

---

## Support Resources

- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **SQL Reference**: [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- **Schema Details**: [schema-design.md](../schema-design.md)
- **Database Protocol**: [database-protocol.md](../database-protocol.md)

---

**Created**: 2025-10-08
**Maintained by**: Claude Code (CTO)
**Estimated Setup Time**: 30-45 minutes
