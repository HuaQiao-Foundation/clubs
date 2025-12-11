-- Migration 030: Populate member_count_year_end for recent Rotary years
-- Purpose: Set historical member counts for year-end statistics

-- Update 2025-2026 (current year)
UPDATE public.rotary_years
SET member_count_year_end = 21
WHERE rotary_year = '2025-2026';

-- Update 2024-2025
UPDATE public.rotary_years
SET member_count_year_end = 18
WHERE rotary_year = '2024-2025';

-- Update 2023-2024
UPDATE public.rotary_years
SET member_count_year_end = 20
WHERE rotary_year = '2023-2024';
