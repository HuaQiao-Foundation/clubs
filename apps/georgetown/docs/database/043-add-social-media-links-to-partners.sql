-- Migration 043: Add Social Media Links to Partners Table
-- Date: 2025-10-17
-- Purpose: Add JSONB column for flexible social media platform links

-- Business Context:
-- Partners operate across multiple social media platforms globally
-- Multinational environment requires support for:
-- - Western platforms: LinkedIn, Facebook, Instagram, Twitter/X
-- - Asian platforms: WeChat, WhatsApp, Telegram, Line, KakaoTalk
-- - Emerging platforms: TikTok, YouTube, Threads, etc.
-- JSONB provides flexibility without requiring migrations for new platforms

-- Add social_media_links JSONB column
ALTER TABLE partners
  ADD COLUMN IF NOT EXISTS social_media_links JSONB DEFAULT '{}'::jsonb;

-- Add GIN index for performance (enables fast JSONB queries)
CREATE INDEX IF NOT EXISTS idx_partners_social_media_links
  ON partners USING GIN (social_media_links);

-- Add validation constraint (ensures data is a JSON object, not array or primitive)
ALTER TABLE partners
  ADD CONSTRAINT social_media_links_is_object
  CHECK (jsonb_typeof(social_media_links) = 'object');

-- Add column comment for documentation
COMMENT ON COLUMN partners.social_media_links IS 'Social media platform links stored as {"platform": "url/handle"}. Supported platforms: linkedin, facebook, instagram, twitter, whatsapp, wechat, telegram, youtube, tiktok, line, kakaotalk';

-- Example data structure:
-- {
--   "linkedin": "https://linkedin.com/company/rotary-international",
--   "facebook": "https://facebook.com/rotary",
--   "instagram": "https://instagram.com/rotary",
--   "wechat": "rotary_official",
--   "whatsapp": "+60123456789",
--   "telegram": "https://t.me/rotary",
--   "youtube": "https://youtube.com/@rotary",
--   "tiktok": "https://tiktok.com/@rotary"
-- }

-- Verification Query (Run after migration)
-- SELECT id, name, social_media_links FROM partners WHERE social_media_links != '{}'::jsonb ORDER BY name;

-- Query to check if any partner has LinkedIn
-- SELECT id, name, social_media_links->>'linkedin' as linkedin_url FROM partners WHERE social_media_links ? 'linkedin';

-- Query to count partners by platform
-- SELECT
--   COUNT(*) FILTER (WHERE social_media_links ? 'linkedin') as linkedin_count,
--   COUNT(*) FILTER (WHERE social_media_links ? 'facebook') as facebook_count,
--   COUNT(*) FILTER (WHERE social_media_links ? 'wechat') as wechat_count,
--   COUNT(*) FILTER (WHERE social_media_links ? 'whatsapp') as whatsapp_count,
--   COUNT(*) FILTER (WHERE social_media_links ? 'telegram') as telegram_count
-- FROM partners;
