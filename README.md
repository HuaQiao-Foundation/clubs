# Clubs Monorepo

A monorepo containing multiple React applications for club management.

## Apps

- **Georgetown** (`apps/georgetown`) - Rotary speakers and event management
- **Pitchmasters** (`apps/pitchmasters`) - Club management application

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0

### Installation

```bash
# Install all dependencies for all apps
npm install
```

### Development

```bash
# Run both apps simultaneously
npm run dev

# Run individual apps
npm run dev:georgetown      # Runs on http://localhost:5180
npm run dev:pitchmasters    # Runs on http://localhost:5190
```

### Build

```bash
# Build all apps
npm run build

# Build individual apps
npm run build:georgetown
npm run build:pitchmasters
```

### Other Commands

```bash
# Lint all apps
npm run lint

# Type check all apps
npm run typecheck

# Clean all node_modules and build artifacts
npm run clean
```

## Tech Stack

- React 19
- TypeScript 5.x
- Vite 7
- Tailwind CSS
- Supabase
- React Router 7

## Structure

```
clubs/
├── apps/
│   ├── georgetown/      # Rotary speakers app
│   └── pitchmasters/    # Club management app
├── package.json         # Root workspace config
└── README.md
```
