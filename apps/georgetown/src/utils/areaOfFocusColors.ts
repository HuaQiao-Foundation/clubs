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
  'Water': '#00A2E0',           // Sky Blue (Water, Sanitation & Hygiene)
  'Maternal/Child': '#901F93',  // Violet (Maternal & Child Health)
  'Education': '#FF7600',       // Orange (Basic Education & Literacy)
  'Economy': '#00ADBB',         // Turquoise (Community Economic Development)
  'Environment': '#009739',     // Grass Green (Supporting the Environment)
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
