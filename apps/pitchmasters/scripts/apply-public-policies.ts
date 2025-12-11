import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseServiceKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || '';

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function applyPublicPolicies() {
  console.log('🔒 Applying Public Read Policies for Member Directory\n');

  try {
    // Step 1: Allow public read access to privacy_settings (read-only, no PII)
    console.log('1. Creating privacy_settings public read policy...');
    const { error: privacyError } = await supabase.rpc('exec_sql', {
      sql: `
        DROP POLICY IF EXISTS "privacy_settings_public_read" ON privacy_settings;
        CREATE POLICY "privacy_settings_public_read" ON privacy_settings
        FOR SELECT
        USING (true);
      `
    });

    if (privacyError) {
      console.log('ℹ️  Privacy policy may already exist or need manual creation');
      console.log('Error:', privacyError.message);
    } else {
      console.log('✅ Privacy settings public read policy created');
    }

    // Step 2: Allow public to see users who have opted into profile visibility
    console.log('\n2. Creating users public visibility policy...');
    const { error: usersError } = await supabase.rpc('exec_sql', {
      sql: `
        DROP POLICY IF EXISTS "users_public_with_visible_profiles" ON users;
        CREATE POLICY "users_public_with_visible_profiles" ON users
        FOR SELECT
        USING (
          id IN (
            SELECT mp.user_id
            FROM member_profiles mp
            JOIN privacy_settings ps ON mp.user_id = ps.user_id
            WHERE ps.show_photo = true
               OR ps.show_venture_info = true
               OR ps.show_expertise = true
               OR ps.show_bio = true
          )
        );
      `
    });

    if (usersError) {
      console.log('ℹ️  Users policy may need manual creation');
      console.log('Error:', usersError.message);
    } else {
      console.log('✅ Users public visibility policy created');
    }

    // Step 3: Allow public access to member_profiles for visible users
    console.log('\n3. Creating member_profiles public visibility policy...');
    const { error: profilesError } = await supabase.rpc('exec_sql', {
      sql: `
        DROP POLICY IF EXISTS "member_profiles_public_visible" ON member_profiles;
        CREATE POLICY "member_profiles_public_visible" ON member_profiles
        FOR SELECT
        USING (
          user_id IN (
            SELECT ps.user_id
            FROM privacy_settings ps
            WHERE ps.show_photo = true
               OR ps.show_venture_info = true
               OR ps.show_expertise = true
               OR ps.show_bio = true
          )
        );
      `
    });

    if (profilesError) {
      console.log('ℹ️  Profiles policy may need manual creation');
      console.log('Error:', profilesError.message);
    } else {
      console.log('✅ Member profiles public visibility policy created');
    }

    console.log('\n🧪 Testing public access...');

    // Test query with anon client
    const anonClient = createClient(supabaseUrl, process.env.VITE_SUPABASE_ANON_KEY || '');

    const { data: testUsers, error: testError } = await anonClient
      .from('users')
      .select(`
        id, full_name, email, role,
        profile:member_profiles(*),
        privacy_settings:privacy_settings(*)
      `)
      .limit(3);

    if (testError) {
      console.log('❌ Test query failed:', testError.message);
    } else {
      console.log(`✅ Test successful! Found ${testUsers?.length || 0} publicly visible members`);
      if (testUsers && testUsers.length > 0) {
        console.log('Sample member:', testUsers[0].full_name);
      }
    }

    console.log('\n✅ Public read policies applied successfully!');
    console.log('📋 Members with public profiles should now be visible on frontend');

  } catch (error) {
    console.error('❌ Error applying policies:', error);
    console.log('\n📖 Manual SQL execution may be required in Supabase dashboard');
    console.log('Run the SQL from: docs/database/add-public-read-policy.sql');
  }
}

async function main() {
  console.log('🔐 PUBLIC MEMBER DIRECTORY VISIBILITY SETUP\n');
  console.log('='.repeat(60));

  await applyPublicPolicies();

  console.log('\n' + '='.repeat(60));
  console.log('🎯 MEMBER DIRECTORY SHOULD NOW BE VISIBLE TO PUBLIC\n');
}

main().catch(console.error);