# Georgetown Rotary Reference Data

**Purpose**: Official Rotary International reference data for brand compliance, event planning, and content organization.

**Data Source**: Rotary International Brand Guidelines and Official Calendar
**Last Updated**: 2025-10-08

---

## Overview

This directory contains authoritative reference data for:
- Rotary's 7 Areas of Focus (official colors and identifiers)
- Rotary's monthly observance themes (2025-2026 Rotary year)
- Rotary International special days and anniversaries

**Usage**: These files are used throughout the Georgetown Rotary application for:
- Event categorization (Areas of Focus)
- Calendar color coding (monthly themes)
- Automatic event population (special days)
- Brand-compliant design (official colors)

---

## Files

### `rotary_areas_of_focus_colors.csv`

**Purpose**: Official Rotary International Areas of Focus with brand-standard colors

**Columns**:
- `Area of Focus` - Official name of Rotary's service focus area
- `Color Name` - Descriptive color name
- `PMS` - Pantone Matching System color code
- `HEX` - Hex color code for digital use
- `RGB` - RGB values for digital rendering

**Example**:
```csv
Area of Focus,Color Name,PMS,HEX,RGB
Peacebuilding & Conflict Prevention,Azure,PANTONE 2175 C,#0067C8,"0, 103, 200"
```

**Row Count**: 7 (one per Area of Focus)

**Data Authority**: Rotary International Brand Center
**Update Frequency**: Only when Rotary International changes official Areas of Focus (rare)

**Usage in Code**:
- Event categorization system
- Calendar event color coding
- Service project classification
- Reporting and analytics filtering

---

### `rotary_observances_2025_26.csv`

**Purpose**: Rotary International monthly observance themes for the 2025-2026 Rotary year

**Columns**:
- `Month` - Month and year (format: "Month YYYY")
- `Theme` - Official monthly observance theme

**Example**:
```csv
Month,Theme
July 2025,Maternal and Child Health Month
```

**Row Count**: 12 (one per month in Rotary year)

**Rotary Year**: July 1, 2025 - June 30, 2026

**Data Authority**: Rotary International Official Calendar
**Update Frequency**: Annually (new Rotary year begins July 1)

**Usage in Code**:
- Calendar event suggestions
- Monthly theme display on dashboard
- Program planning recommendations
- Educational content organization

**Update Schedule**:
- June each year: Create new file for upcoming Rotary year
- Format: `rotary_observances_YYYY_YY.csv` (e.g., `rotary_observances_2026_27.csv`)
- Archive previous year file (move to `docs/archive/`)

---

### `rotary_special_days.csv`

**Purpose**: Rotary International annual observances, anniversaries, and special days

**Columns**:
- `Date` - Date of observance (format: "DD Month" or descriptive)
- `Observance` - Official name and description of the special day

**Example**:
```csv
Date,Observance
23 February,"Rotary International Anniversary (Charter Day, 1905)"
```

**Row Count**: 7 special days/observances

**Data Authority**: Rotary International Official Calendar
**Update Frequency**: Rarely (only when RI adds new observances)

**Usage in Code**:
- Auto-populate calendar with Rotary observances
- Event type: "observance" (special category)
- Educational prompts for program committee
- Historical context for club communications

**Special Cases**:
- Variable dates (e.g., "Second week of August") require calculation logic
- "Date varies" entries need manual year-specific updates

---

## Data Maintenance

### Annual Update Process (June each year)

**For Monthly Observances:**

1. **Check Rotary International sources** (May/June):
   - Visit Rotary.org official calendar
   - Review brand center for theme changes
   - Verify no changes to monthly themes

2. **Create new file**:
   ```bash
   cp rotary_observances_2025_26.csv rotary_observances_2026_27.csv
   ```

3. **Update data**:
   - Change year in Month column (July 2026, August 2026, etc.)
   - Update any theme changes from Rotary International
   - Verify all 12 months present

4. **Archive old file**:
   ```bash
   mv rotary_observances_2025_26.csv ../archive/
   ```

5. **Update code references** (if filename hardcoded):
   - Search codebase for old filename
   - Update import/fetch statements
   - Test calendar event loading

---

### Ad-Hoc Updates

**Areas of Focus Colors:**
- Only update if Rotary International changes official Areas of Focus
- Verify changes via Rotary International Brand Center
- Update HEX/RGB values to match official Pantone conversions

**Special Days:**
- Add new observances as announced by Rotary International
- Update variable dates if RI provides specific dates
- Maintain CSV format consistency

---

## CSV Format Standards

### Encoding
- **UTF-8 with BOM** (for Excel compatibility)
- **Line endings**: LF (Unix-style)

### Quoting
- Quote fields containing commas: `"Water, Sanitation & Hygiene"`
- Quote RGB values: `"0, 103, 200"`
- Do not quote simple text fields

### Header Row
- Always include header row
- Use descriptive column names
- Match column names across related files where applicable

### Data Validation
- No trailing commas
- No empty rows (except final line break)
- Consistent date formats within each file

---

## Usage Examples

### JavaScript/TypeScript

**Load Areas of Focus:**

```typescript
import areasOfFocusCSV from '@/docs/reference-data/rotary_areas_of_focus_colors.csv';

// Parse CSV (using library like papaparse or csv-parser)
const areasOfFocus = parseCSV(areasOfFocusCSV);

// Use in event categorization
const eventColor = areasOfFocus.find(
  area => area['Area of Focus'] === 'Disease Prevention & Treatment'
)?.HEX; // Returns: #E02927
```

**Load Monthly Themes:**

```typescript
import observancesCSV from '@/docs/reference-data/rotary_observances_2025_26.csv';

const themes = parseCSV(observancesCSV);

// Display current month's theme
const currentMonth = 'October 2025';
const theme = themes.find(t => t.Month === currentMonth)?.Theme;
// Returns: "Community Economic Development Month"
```

---

### SQL Import (Supabase)

**Create reference table:**

```sql
CREATE TABLE rotary_areas_of_focus (
  id SERIAL PRIMARY KEY,
  area_name TEXT NOT NULL,
  color_name TEXT,
  pantone TEXT,
  hex_color TEXT,
  rgb_color TEXT
);
```

**Import CSV:**

```sql
COPY rotary_areas_of_focus(area_name, color_name, pantone, hex_color, rgb_color)
FROM '/path/to/rotary_areas_of_focus_colors.csv'
DELIMITER ','
CSV HEADER;
```

---

## Quality Assurance

### Before Committing CSV Changes

**Validation checklist:**
- ✅ File opens correctly in Excel/Google Sheets
- ✅ All rows have same number of columns
- ✅ Header row present and descriptive
- ✅ No trailing commas or empty rows
- ✅ Special characters properly quoted
- ✅ UTF-8 encoding preserved
- ✅ Data matches official Rotary International sources
- ✅ No duplicate entries
- ✅ Dates formatted consistently

**Test in application:**
- ✅ Import/parse succeeds without errors
- ✅ Data displays correctly in UI
- ✅ Colors render accurately (for color data)
- ✅ No broken references in code

---

## File History

| File | Created | Last Updated | Source |
|------|---------|--------------|--------|
| `rotary_areas_of_focus_colors.csv` | 2025-10-08 | 2025-10-08 | RI Brand Center |
| `rotary_observances_2025_26.csv` | 2025-10-08 | 2025-10-08 | RI Official Calendar |
| `rotary_special_days.csv` | 2025-10-08 | 2025-10-08 | RI Official Calendar |

---

## External Resources

**Rotary International Official Sources:**
- Brand Center: https://brandcenter.rotary.org
- My Rotary Calendar: https://my.rotary.org/en/news-media/calendar
- Areas of Focus: https://www.rotary.org/en/our-causes

**Brand Guidelines:**
- Official color specifications
- Logo usage standards
- Typography requirements

---

## Questions & Support

**Data Accuracy Issues:**
- Verify against Rotary International official sources
- Document discrepancies in this README
- Update CSV and note source/date in commit message

**Format Issues:**
- Ensure UTF-8 encoding
- Validate CSV structure with online tools
- Test import in application before committing

**Missing Data:**
- Check Rotary International sources for new additions
- Request clarification from Rotary district leadership if needed
- Document assumptions in commit messages

---

**Maintained by**: CTO (Claude Code)
**Review Frequency**: Annually (June, before new Rotary year)
**Next Review**: June 2026
