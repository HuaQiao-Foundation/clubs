import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || '';

console.log('=== Supabase Connection Debug ===\n');
console.log('URL:', supabaseUrl);
console.log('Anon Key:', supabaseAnonKey ? `${supabaseAnonKey.substring(0, 20)}...` : 'NOT SET');

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('\n❌ Missing environment variables!');
  console.error('Required: VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function debugDatabase() {
  console.log('\n=== Testing Database Connection ===\n');

  console.log('1. Testing users table...');
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('*')
    .limit(5);

  if (usersError) {
    console.error('❌ Users query failed:', usersError.message);
    console.error('Details:', usersError);
  } else {
    console.log(`✅ Users table accessible. Found ${users?.length || 0} rows`);
    if (users && users.length > 0) {
      console.log('Sample user:', JSON.stringify(users[0], null, 2));
    }
  }

  console.log('\n2. Testing member_profiles table...');
  const { data: profiles, error: profilesError } = await supabase
    .from('member_profiles')
    .select('*')
    .limit(5);

  if (profilesError) {
    console.error('❌ Member profiles query failed:', profilesError.message);
    console.error('Details:', profilesError);
  } else {
    console.log(`✅ Member profiles table accessible. Found ${profiles?.length || 0} rows`);
    if (profiles && profiles.length > 0) {
      console.log('Sample profile:', JSON.stringify(profiles[0], null, 2));
    }
  }

  console.log('\n3. Testing privacy_settings table...');
  const { data: privacy, error: privacyError } = await supabase
    .from('privacy_settings')
    .select('*')
    .limit(5);

  if (privacyError) {
    console.error('❌ Privacy settings query failed:', privacyError.message);
    console.error('Details:', privacyError);
  } else {
    console.log(`✅ Privacy settings table accessible. Found ${privacy?.length || 0} rows`);
    if (privacy && privacy.length > 0) {
      console.log('Sample privacy setting:', JSON.stringify(privacy[0], null, 2));
    }
  }

  console.log('\n4. Testing joined query (like MembersPage uses)...');
  const { data: joined, error: joinedError } = await supabase
    .from('users')
    .select(`
      *,
      profile:member_profiles(*),
      privacy_settings:privacy_settings(*)
    `)
    .limit(5);

  if (joinedError) {
    console.error('❌ Joined query failed:', joinedError.message);
    console.error('Details:', joinedError);
  } else {
    console.log(`✅ Joined query successful. Found ${joined?.length || 0} rows`);
    if (joined && joined.length > 0) {
      console.log('Sample joined data:', JSON.stringify(joined[0], null, 2));
    }
  }

  console.log('\n5. Testing ecosystem_partners table...');
  const { data: partners, error: partnersError } = await supabase
    .from('ecosystem_partners')
    .select('*')
    .limit(5);

  if (partnersError) {
    console.error('❌ Ecosystem partners query failed:', partnersError.message);
    console.error('Details:', partnersError);
  } else {
    console.log(`✅ Ecosystem partners table accessible. Found ${partners?.length || 0} rows`);
    if (partners && partners.length > 0) {
      console.log('Sample partner:', JSON.stringify(partners[0], null, 2));
    }
  }

  console.log('\n=== Debug Complete ===\n');
}

debugDatabase().catch(error => {
  console.error('\n💥 Fatal error:', error);
  process.exit(1);
});