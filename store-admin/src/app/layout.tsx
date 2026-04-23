import type { Metadata } from "next";

import "./globals.css";
import { Inter } from "next/font/google";
import { cn } from "@/lib/utils";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
  weight: ["300", "400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "Hache Suite — Panel Admin",
  description: "Panel de reglas de negocio avanzadas para tu tienda Tiendanube",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" className={cn("dark font-sans", inter.variable)} suppressHydrationWarning>
      <head />
      <body className={inter.className}>{children}</body>
    </html>
  );
}
