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
          'card-hover': 'var(--secondary)',
          border: 'var(--border)',
          primary: 'var(--primary)',
          'primary-hover': 'var(--primary-hover)',
          accent: 'var(--accent)',
          text: 'var(--foreground)',
          muted: 'var(--muted-foreground)',
          success: 'var(--success)',
          warning: 'var(--warning)',
          danger: 'var(--destructive)',
          // Canonical Brand Palette
          charcoal: '#2C2C2C',
          plum: '#853953',
          aubergine: '#612D53',
          mist: '#F3F4F4',
        },
      },
      backgroundImage: {
        'acedex-gradient': 'linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%)',
      },
    },
  },
  plugins: [],
};
