-- Add extended fields to locations table for Georgetown Rotary
-- Migration to add contact details and social media links

ALTER TABLE locations ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS whatsapp TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS website TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS facebook TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS instagram TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS youtube TEXT;
ALTER TABLE locations ADD COLUMN IF NOT EXISTS key_contact TEXT;

-- Note: The 'address' and 'notes' columns already exist from the initial migration
-- This migration only adds the new contact and social media fields
