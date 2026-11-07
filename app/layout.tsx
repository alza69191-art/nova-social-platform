import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NOVA — عالمك في مكان واحد",
  description: "منصة اجتماعية تجمع النشر والفيديو والمجتمعات والمراسلة في تجربة واحدة.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
