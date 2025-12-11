import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || '';

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('❌ Missing Supabase credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function verifyImportedData() {
  console.log('🔍 Verifying imported member data...\n');

  try {
    // Get all users with profiles
    const { data: members, error } = await supabase
      .from('users')
      .select(`
        *,
        profile:member_profiles(*),
        privacy_settings:privacy_settings(*)
      `);

    if (error) {
      console.error('❌ Error fetching members:', error);
      return;
    }

    console.log(`📊 Total members found: ${members?.length || 0}\n`);

    if (members && members.length > 0) {
      console.log('👥 Member List:');
      members.forEach((member, index) => {
        const profile = member.profile;
        console.log(`${index + 1}. ${member.full_name}`);
        console.log(`   - Email: ${member.email}`);
        console.log(`   - Role: ${member.role}`);
        if (profile) {
          console.log(`   - Industry: ${profile.industry}`);
          console.log(`   - Venture: ${profile.venture_name || 'N/A'}`);
          console.log(`   - Bio: ${profile.bio?.substring(0, 80)}...`);
          console.log(`   - Path Level: ${profile.path_level}`);
          console.log(`   - Phone: ${profile.phone || 'N/A'}`);
        }
        console.log('');
      });

      // Check for real vs dummy data
      const realMembers = members.filter(m =>
        !m.email.includes('placeholder.com') &&
        !m.email.includes('pitchmasters.club') &&
        !m.full_name.includes('Sarah') &&
        !m.full_name.includes('John') &&
        !m.full_name.includes('Maria')
      );

      console.log(`✅ Real imported members: ${realMembers.length}`);
      console.log(`📋 Dummy/test members: ${members.length - realMembers.length}`);

      if (realMembers.length > 0) {
        console.log('\n🎉 Sample real member data:');
        const sample = realMembers[0];
        console.log(`   Name: ${sample.full_name}`);
        console.log(`   Email: ${sample.email}`);
        console.log(`   Venture: ${sample.profile?.venture_name || 'N/A'}`);
        console.log(`   Industry: ${sample.profile?.industry}`);
      }
    }

  } catch (error) {
    console.error('💥 Error:', error);
  }
}

verifyImportedData();