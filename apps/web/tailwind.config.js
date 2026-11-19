/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        acedex: {
          bg: '#0F172A',
          card: '#1E293B',
          'card-hover': '#243248',
          border: '#334155',
          primary: '#3B82F6',
          'primary-hover': '#2563EB',
          accent: '#8B5CF6',
          text: '#F8FAFC',
          muted: '#94A3B8',
          success: '#10B981',
          warning: '#F59E0B',
          danger: '#EF4444',
        },
      },
      backgroundImage: {
        'acedex-gradient': 'linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%)',
      },
    },
  },
  plugins: [],
};
