// Database Schema Configuration
// This file controls which fields are available based on database schema version

export const DATABASE_SCHEMA_VERSION = {
  // Set to true after running the database migration in supabase_migration.sql
  // Until then, the app will work with the basic schema
  HAS_MARKETING_FIELDS: true
}

export const AVAILABLE_FIELDS = {
  // Core fields (always available)
  name: true,
  email: true,
  phone: true,
  organization: true,
  topic: true,
  notes: true,
  status: true,
  scheduled_date: true,

  // Marketing fields (requires database migration)
  job_title: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  description: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  primary_url: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  additional_urls: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  linkedin_url: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  is_rotarian: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
  rotary_club: DATABASE_SCHEMA_VERSION.HAS_MARKETING_FIELDS,
}