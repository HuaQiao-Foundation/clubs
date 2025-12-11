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

async function checkSchemaColumns() {
  console.log('🔍 Checking member_profiles table columns...\n');

  try {
    // Get a sample record to see current columns
    const { data, error } = await supabase
      .from('member_profiles')
      .select('*')
      .limit(1);

    if (error) {
      console.error('❌ Error checking schema:', error);
      return;
    }

    if (data && data.length > 0) {
      console.log('📊 Current member_profiles columns:');
      const columns = Object.keys(data[0]);
      columns.forEach(col => console.log(`   - ${col}`));

      console.log('\n🔍 Checking for new CSV fields...');
      const csvFields = [
        'city', 'country', 'citizenship', 'tm_member_number', 'member_type',
        'officer_role', 'team', 'level', 'completed_pathways', 'dtm',
        'organization', 'job_title', 'is_founder', 'is_rotarian',
        'joining_date', 'birthday_month', 'birthday_day', 'age_bracket',
        'introducer', 'mentor'
      ];

      const missingFields = csvFields.filter(field => !columns.includes(field));

      if (missingFields.length > 0) {
        console.log('❌ Missing fields:');
        missingFields.forEach(field => console.log(`   - ${field}`));
      } else {
        console.log('✅ All CSV fields present in schema');
      }
    } else {
      console.log('⚠️ No data in member_profiles table');
    }

  } catch (error) {
    console.error('💥 Error:', error);
  }
}

checkSchemaColumns();