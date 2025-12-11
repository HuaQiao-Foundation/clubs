-- Migration 044: Add social media links to speakers table
-- Date: 2025-10-17
-- Description: Add JSONB column to store flexible social media platform links for speakers
--              Supports multinational social media platforms without schema migrations

-- Add social_media_links column as JSONB with default empty object
ALTER TABLE speakers
  ADD COLUMN IF NOT EXISTS social_media_links JSONB DEFAULT '{}'::jsonb;

-- Add GIN index for fast JSONB queries
CREATE INDEX IF NOT EXISTS idx_speakers_social_media_links
  ON speakers USING GIN (social_media_links);

-- Add constraint to ensure social_media_links is always an object (not array or primitive)
ALTER TABLE speakers
  ADD CONSTRAINT social_media_links_is_object
  CHECK (jsonb_typeof(social_media_links) = 'object');

-- Add comment for documentation
COMMENT ON COLUMN speakers.social_media_links IS 'Social media platform links stored as key-value pairs. Supports platforms like LinkedIn, Facebook, Instagram, WhatsApp, WeChat, Telegram, YouTube, Twitter, TikTok. Example: {"linkedin": "https://linkedin.com/in/speaker", "wechat": "speaker123"}';
