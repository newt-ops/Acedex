/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: 'var(--background)',
        foreground: 'var(--foreground)',
        card: {
          DEFAULT: 'var(--card)',
          foreground: 'var(--card-foreground)',
        },
        popover: {
          DEFAULT: 'var(--popover)',
          foreground: 'var(--popover-foreground)',
        },
        primary: {
          DEFAULT: 'var(--primary)',
          foreground: 'var(--primary-foreground)',
          hover: 'var(--primary-hover)',
        },
        secondary: {
          DEFAULT: 'var(--secondary)',
          foreground: 'var(--secondary-foreground)',
        },
        muted: {
          DEFAULT: 'var(--muted)',
          foreground: 'var(--muted-foreground)',
        },
        accent: {
          DEFAULT: 'var(--accent)',
          foreground: 'var(--accent-foreground)',
        },
        destructive: {
          DEFAULT: 'var(--destructive)',
          foreground: 'var(--destructive-foreground)',
        },
        success: {
          DEFAULT: 'var(--success)',
          foreground: 'var(--success-foreground)',
        },
        warning: {
          DEFAULT: 'var(--warning)',
          foreground: 'var(--warning-foreground)',
        },
        info: {
          DEFAULT: 'var(--info)',
          foreground: 'var(--info-foreground)',
        },
        border: 'var(--border)',
        input: 'var(--input)',
        ring: 'var(--ring)',
        acedex: {
          bg: 'var(--background)',
          card: 'var(--card)',
          'card-raised': 'var(--card-raised)',
          'card-hover': 'var(--secondary)',
          border: 'var(--border)',
          primary: 'var(--primary)',
          'primary-hover': 'var(--primary-hover)',
          accent: 'var(--accent)',
          'accent-soft': 'var(--accent-soft)',
          'on-accent': 'var(--primary-foreground)',
          text: 'var(--foreground)',
          'secondary-text': 'var(--muted-foreground)',
          muted: 'var(--muted-foreground)',
          success: 'var(--success)',
          warning: 'var(--warning)',
          danger: 'var(--destructive)',
          // Canonical Brand Palette (Royal Purple System)
          purple: '#8A2BA3',
          purpleLight: '#B866CF',
          accent: '#8A2BA3',
          accentLight: '#B866CF',
          accentSoft: '#EFE1F2',
          accentSoftDark: '#271A2C',
          surface: '#F4F4F6',
          surfaceDark: '#1B1B1F',
          raised: '#FFFFFF',
          raisedDark: '#2B2B31',
          textDark: '#1C1C1E',
          textLight: '#F5F5F7',
          secondaryTextDark: '#6C6C72',
          secondaryTextLight: '#9A9AA2',
          line: '#E4E4E8',
          lineDark: '#2B2B31',
        },
      },
      backgroundImage: {
        'acedex-gradient': 'linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%)',
      },
    },
  },
  plugins: [],
};
