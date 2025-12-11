/**
 * YearSelector Component
 * Dropdown for selecting which Rotary year to view in the timeline
 */

import { Calendar } from 'lucide-react'
import { getAvailableRotaryYears, getCurrentRotaryYear } from '../lib/rotary-year-utils'

type YearSelectorProps = {
  selectedYear: string
  onYearChange: (year: string) => void
  availableYears?: string[]
}

export default function YearSelector({
  selectedYear,
  onYearChange,
  availableYears
}: YearSelectorProps) {
  // Use provided years or generate default list from 2020
  const years = availableYears || getAvailableRotaryYears(2020)
  const currentYear = getCurrentRotaryYear()

  return (
    <div className="year-selector">
      <label htmlFor="rotary-year" className="year-selector-label">
        <Calendar size={20} />
        <span>Rotary Year</span>
      </label>
      <select
        id="rotary-year"
        value={selectedYear}
        onChange={(e) => onYearChange(e.target.value)}
        className="year-selector-dropdown"
      >
        {years.map((year) => (
          <option key={year} value={year}>
            {year} {year === currentYear && '(Current)'}
          </option>
        ))}
      </select>
    </div>
  )
}
