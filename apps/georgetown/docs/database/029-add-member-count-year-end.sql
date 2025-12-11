-- Migration 029: Add member_count_year_end field to rotary_years table
-- Purpose: Track the total number of members at the end of each Rotary year
-- This provides a key statistic for year-over-year growth tracking

ALTER TABLE public.rotary_years
ADD COLUMN IF NOT EXISTS member_count_year_end INTEGER NULL;

COMMENT ON COLUMN public.rotary_years.member_count_year_end IS 'Total number of members at the end of the Rotary year (June 30)';
