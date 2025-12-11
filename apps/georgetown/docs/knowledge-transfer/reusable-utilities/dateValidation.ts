export function validateScheduledDate(
  date: string | null | undefined,
  status: string
): string | null {
  if (!date) return null // Optional field

  const selected = new Date(date)
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  // For "Spoken" status, date should be in the past
  if (status === 'spoken' && selected > today) {
    return 'Scheduled date should be in the past for speakers who have already spoken'
  }

  // For "Scheduled" status, date should be in the future (or today)
  if (status === 'scheduled' && selected < today) {
    return 'Scheduled date should be today or in the future'
  }

  // For other statuses, any date is okay
  return null
}

export function validateDateRange(
  startDate: string | null,
  endDate: string | null
): string | null {
  if (!startDate || !endDate) return null

  const start = new Date(startDate)
  const end = new Date(endDate)

  if (end < start) {
    return 'End date must be after start date'
  }

  return null
}
