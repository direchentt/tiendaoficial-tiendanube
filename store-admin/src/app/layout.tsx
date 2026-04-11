import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Store rules admin",
  description: "Reglas avanzadas Tiendanube",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body style={{ fontFamily: "system-ui", margin: "2rem", maxWidth: "52rem" }}>
        {children}
      </body>
    </html>
  );
}
