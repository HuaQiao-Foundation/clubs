/**
 * Rotary Year Utilities
 *
 * Utility functions for working with Rotary years (July 1 - June 30).
 * Handles date calculations, year determination, and auto-linking logic.
 */

import { isWithinInterval, parseISO } from 'date-fns'

/**
 * Determine which Rotary year a date falls into.
 * Rotary year runs July 1 - June 30.
 *
 * Examples:
 * - June 15, 2025 → "2024-2025"
 * - July 1, 2025 → "2025-2026"
 * - December 31, 2025 → "2025-2026"
 *
 * @param date - Date object or ISO date string
 * @returns Rotary year in "YYYY-YYYY" format
 */
export function getRotaryYearFromDate(date: Date | string): string {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  const year = dateObj.getFullYear()
  const month = dateObj.getMonth() // 0-indexed (0 = January, 6 = July)

  // July (6) through December (11) = current year - next year
  // January (0) through June (5) = previous year - current year
  if (month >= 6) {
    return `${year}-${year + 1}`
  } else {
    return `${year - 1}-${year}`
  }
}

/**
 * Get the current Rotary year.
 *
 * @returns Current Rotary year in "YYYY-YYYY" format
 */
export function getCurrentRotaryYear(): string {
  return getRotaryYearFromDate(new Date())
}

/**
 * Get date range for a Rotary year.
 *
 * @param rotaryYear - Rotary year string (e.g., "2025-2026")
 * @returns Object with start and end dates
 */
export function getRotaryYearDates(rotaryYear: string): { start: Date; end: Date } {
  const [startYear, endYear] = rotaryYear.split('-').map(Number)
  return {
    start: new Date(startYear, 6, 1),  // July 1 (month 6 is July in 0-indexed)
    end: new Date(endYear, 5, 30, 23, 59, 59)  // June 30 at end of day
  }
}

/**
 * Check if a date is within a specific Rotary year.
 *
 * @param date - Date object or ISO date string
 * @param rotaryYear - Rotary year string (e.g., "2025-2026")
 * @returns True if date falls within the Rotary year
 */
export function isDateInRotaryYear(date: Date | string, rotaryYear: string): boolean {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  const { start, end } = getRotaryYearDates(rotaryYear)
  return isWithinInterval(dateObj, { start, end })
}

/**
 * Generate a list of Rotary years for dropdowns.
 * Returns years from current year back to the specified start year.
 *
 * @param startYear - First year to include (default: 2020)
 * @returns Array of Rotary year strings, most recent first
 */
export function getAvailableRotaryYears(startYear: number = 2020): string[] {
  const currentYear = getCurrentRotaryYear()
  const [currentStartYear] = currentYear.split('-').map(Number)
  const years: string[] = []

  for (let year = currentStartYear; year >= startYear; year--) {
    years.push(`${year}-${year + 1}`)
  }

  return years
}

/**
 * Format a Rotary year for display.
 *
 * @param rotaryYear - Rotary year string (e.g., "2025-2026")
 * @param includePrefix - Whether to include "Rotary Year" prefix
 * @returns Formatted string
 */
export function formatRotaryYear(rotaryYear: string, includePrefix: boolean = false): string {
  if (includePrefix) {
    return `Rotary Year ${rotaryYear}`
  }
  return rotaryYear
}

/**
 * Get the previous Rotary year.
 *
 * @param rotaryYear - Current Rotary year string (e.g., "2025-2026")
 * @returns Previous Rotary year string
 */
export function getPreviousRotaryYear(rotaryYear: string): string {
  const [startYear] = rotaryYear.split('-').map(Number)
  return `${startYear - 1}-${startYear}`
}

/**
 * Get the next Rotary year.
 *
 * @param rotaryYear - Current Rotary year string (e.g., "2025-2026")
 * @returns Next Rotary year string
 */
export function getNextRotaryYear(rotaryYear: string): string {
  const [startYear] = rotaryYear.split('-').map(Number)
  return `${startYear + 1}-${startYear + 2}`
}

/**
 * Check if a Rotary year is the current year.
 *
 * @param rotaryYear - Rotary year string (e.g., "2025-2026")
 * @returns True if it's the current Rotary year
 */
export function isCurrentRotaryYear(rotaryYear: string): boolean {
  return rotaryYear === getCurrentRotaryYear()
}

/**
 * Parse a Rotary year string into start and end years.
 *
 * @param rotaryYear - Rotary year string (e.g., "2025-2026")
 * @returns Object with startYear and endYear as numbers
 */
export function parseRotaryYear(rotaryYear: string): { startYear: number; endYear: number } {
  const [startYear, endYear] = rotaryYear.split('-').map(Number)
  return { startYear, endYear }
}

/**
 * Validate a Rotary year string format.
 *
 * @param rotaryYear - String to validate
 * @returns True if valid format (e.g., "2025-2026")
 */
export function isValidRotaryYear(rotaryYear: string): boolean {
  const pattern = /^\d{4}-\d{4}$/
  if (!pattern.test(rotaryYear)) {
    return false
  }

  const { startYear, endYear } = parseRotaryYear(rotaryYear)
  return endYear === startYear + 1
}

/**
 * Create a Rotary year string from a start year.
 *
 * @param startYear - Starting year (e.g., 2025)
 * @returns Rotary year string (e.g., "2025-2026")
 */
export function createRotaryYear(startYear: number): string {
  return `${startYear}-${startYear + 1}`
}
