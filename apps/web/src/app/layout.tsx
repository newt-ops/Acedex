import type { Metadata, Viewport } from 'next';
import './globals.css';
import { AuthProvider } from '../context/AuthContext';

export const metadata: Metadata = {
  title: 'ACEDEX — Question Collector & Admin Review Portal',
  description:
    'Dedicated question ingestion, auto-sanitization, and curriculum management platform for Grades 9–12.',
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  themeColor: '#FAFAF9',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="light">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&family=Plus+Jakarta+Sans:wght@700;800&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="bg-[#FBFBFD] text-[#0F172A] min-h-screen antialiased flex flex-col font-sans selection:bg-purple-500/15 selection:text-purple-700">
        <AuthProvider>
          <div className="flex-1 flex flex-col">{children}</div>
        </AuthProvider>
      </body>
    </html>
  );
}
