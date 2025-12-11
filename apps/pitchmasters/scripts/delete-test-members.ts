import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseServiceKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || '';

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function deleteTestMembers() {
  console.log('🗑️ Deleting test member cards...\n');

  const testEmails = [
    'founder@pitchmasters.club',
    'member1@startup.com',
    'member2@venture.io',
    'member3@tech.com'
  ];

  try {
    for (const email of testEmails) {
      // Get user ID first
      const { data: user, error: userError } = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .single();

      if (userError) {
        console.log(`⚠️ User ${email} not found or already deleted`);
        continue;
      }

      if (user) {
        // Delete privacy settings
        const { error: privacyError } = await supabase
          .from('privacy_settings')
          .delete()
          .eq('user_id', user.id);

        if (privacyError) {
          console.error(`❌ Error deleting privacy settings for ${email}:`, privacyError);
        }

        // Delete member profile
        const { error: profileError } = await supabase
          .from('member_profiles')
          .delete()
          .eq('user_id', user.id);

        if (profileError) {
          console.error(`❌ Error deleting profile for ${email}:`, profileError);
        }

        // Delete user
        const { error: deleteError } = await supabase
          .from('users')
          .delete()
          .eq('id', user.id);

        if (deleteError) {
          console.error(`❌ Error deleting user ${email}:`, deleteError);
        } else {
          console.log(`✅ Deleted test member: ${email}`);
        }
      }
    }

    // Verify deletion
    const { data: remainingUsers, error: countError } = await supabase
      .from('users')
      .select('email')
      .order('email');

    if (countError) {
      console.error('❌ Error counting remaining users:', countError);
    } else {
      console.log(`\n📊 Remaining members: ${remainingUsers?.length || 0}`);
      console.log('\n👥 Current member list:');
      remainingUsers?.forEach((user, index) => {
        console.log(`${index + 1}. ${user.email}`);
      });
    }

    console.log('\n🎉 Test member deletion completed!');

  } catch (error) {
    console.error('💥 Error during deletion:', error);
    process.exit(1);
  }
}

deleteTestMembers();