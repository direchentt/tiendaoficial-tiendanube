"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const linkStyle: React.CSSProperties = {
  color: "#111",
  textDecoration: "none",
  fontSize: "0.9rem",
};

export function AdminNav() {
  const pathname = usePathname();
  if (pathname === "/admin/login") {
    return null;
  }

  return (
    <header
      style={{
        borderBottom: "1px solid #e5e5e5",
        paddingBottom: "0.75rem",
        marginBottom: "1.25rem",
        display: "flex",
        flexWrap: "wrap",
        gap: "1rem",
        alignItems: "center",
      }}
    >
      <strong style={{ marginRight: "0.5rem" }}>Store admin</strong>
      <Link href="/admin" style={linkStyle}>
        Inicio
      </Link>
      <Link href="/admin/payment-rules" style={linkStyle}>
        Reglas de pago
      </Link>
      <Link href="/admin/payment-options" style={linkStyle}>
        Medios de pago (TN)
      </Link>
      <Link href="/admin/price" style={linkStyle}>
        Precios %
      </Link>
      <Link href="/admin/categories" style={linkStyle}>
        Categorias bloqueadas
      </Link>
      <Link href="/admin/logout" style={{ ...linkStyle, marginLeft: "auto", color: "#666" }}>
        Salir
      </Link>
    </header>
  );
}
