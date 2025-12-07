/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Linear-inspired dark theme
        dark: {
          bg: '#0a0a0b',
          surface: '#141415',
          border: '#27272a',
          muted: '#3f3f46',
          text: '#fafafa',
          'text-secondary': '#a1a1aa',
        },
        accent: {
          DEFAULT: '#818cf8',
          hover: '#6366f1',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'SF Mono', 'monospace'],
      },
    },
  },
  plugins: [],
}
