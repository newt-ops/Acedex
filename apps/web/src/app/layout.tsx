import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Acedex Admin Portal',
  description: 'Internal Educational & Assessment Management Portal for Acedex',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
