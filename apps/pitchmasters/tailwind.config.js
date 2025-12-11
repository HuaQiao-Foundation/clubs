/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'toastmasters': {
          'blue': '#004165',
          'maroon': '#772432',
          'gray': '#A9B2B1',
        }
      },
      fontFamily: {
        'montserrat': ['Montserrat', 'sans-serif'],
        'source': ['Source Sans 3', 'sans-serif'],
      },
      spacing: {
        '11': '2.75rem',
      },
      minHeight: {
        'touch': '44px',
      },
      minWidth: {
        'touch': '44px',
      }
    },
  },
  plugins: [],
}