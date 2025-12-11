/**
 * Rotary Areas of Focus - Official Colors
 * Source: Rotary International Brand Standards
 */

export type AreaOfFocus =
  | 'Peace'
  | 'Disease'
  | 'Water'
  | 'Maternal/Child'
  | 'Education'
  | 'Economy'
  | 'Environment'

export const AREA_OF_FOCUS_COLORS: Record<AreaOfFocus, string> = {
  'Peace': '#0067C8',           // Azure (Peacebuilding & Conflict Prevention)
  'Disease': '#E02927',         // Cardinal (Disease Prevention & Treatment)
  'Water': '#00ADBB',           // Turquoise (Water, Sanitation & Hygiene)
  'Maternal/Child': '#FF7600',  // Orange (Maternal & Child Health)
  'Education': '#00A2E0',       // Sky Blue (Basic Education & Literacy)
  'Economy': '#009739',         // Grass Green (Community Economic Development)
  'Environment': '#901F93',     // Violet (Supporting the Environment)
}

export const AREA_OF_FOCUS_LABELS: Record<AreaOfFocus, string> = {
  'Peace': 'Peacebuilding & Conflict Prevention',
  'Disease': 'Disease Prevention & Treatment',
  'Water': 'Water, Sanitation & Hygiene',
  'Maternal/Child': 'Maternal & Child Health',
  'Education': 'Basic Education & Literacy',
  'Economy': 'Community Economic Development',
  'Environment': 'Supporting the Environment',
}

export function getAreaOfFocusColor(area: AreaOfFocus): string {
  return AREA_OF_FOCUS_COLORS[area]
}

export function getAreaOfFocusLabel(area: AreaOfFocus): string {
  return AREA_OF_FOCUS_LABELS[area]
}
