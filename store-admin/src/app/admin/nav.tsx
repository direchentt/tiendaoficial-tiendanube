"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const NAV_ITEMS = [
  { href: "/admin", label: "Dashboard", icon: "⬡" },
  { href: "/admin/conversion", label: "Conversión (CVR)", icon: "📈" },
  { href: "/admin/webhooks", label: "Webhooks TN", icon: "🔗" },
  { href: "/admin/audit", label: "Auditoría", icon: "📜" },
  { href: "/admin/gifts", label: "Regalos en Carrito", icon: "🎁" },
  { href: "/admin/dynamic-pricing", label: "Precios Dinámicos", icon: "💰" },
  { href: "/admin/bundles", label: "Bundles / Combos", icon: "📦" },
  { href: "/admin/bundles/v2", label: "Combos v2 (páginas)", icon: "📄" },
  { href: "/admin/payment-rules", label: "Reglas de Pago", icon: "⚡" },
  { href: "/admin/categories", label: "Categorías Privadas", icon: "🔒" },
  { href: "/admin/price", label: "Precios Masivos", icon: "📊" },
  { href: "/admin/payment-options", label: "Medios de Pago", icon: "💳" },
];

function longestNavMatch(pathname: string): string | null {
  const candidates = NAV_ITEMS.filter(
    (x) => pathname === x.href || (x.href !== "/admin" && pathname.startsWith(x.href + "/"))
  );
  if (candidates.length === 0) return null;
  return candidates.reduce((a, b) => (a.href.length >= b.href.length ? a : b)).href;
}

export function AdminNav() {
  const pathname = usePathname();
  if (pathname === "/admin/login") return null;

  const activeHref = longestNavMatch(pathname);

  return (
    <nav style={navStyle}>
      {/* Logo / Brand */}
      <div style={brandStyle}>
        <span style={logoStyle}>⬡</span>
        <div>
          <div style={{ fontWeight: 700, fontSize: "0.95rem", letterSpacing: "-0.01em" }}>
            Hache Suite
          </div>
          <div style={{ fontSize: "0.7rem", color: "var(--text-muted)", marginTop: "1px" }}>
            Business Rules Panel
          </div>
        </div>
      </div>

      {/* Divider */}
      <div style={dividerStyle} />

      {/* Nav items */}
      <div style={{ flex: 1, overflowY: "auto" }}>
        {NAV_ITEMS.map(({ href, label, icon }) => {
          const isActive = activeHref === href;
          return (
            <Link key={href} href={href} style={navLinkStyle(isActive)}>
              <span style={iconStyle}>{icon}</span>
              <span>{label}</span>
              {isActive && <span style={activeBarStyle} />}
            </Link>
          );
        })}
      </div>

      {/* Footer */}
      <div style={dividerStyle} />
      <Link
        href="/admin/logout"
        style={{ ...navLinkStyle(false), color: "var(--text-muted)" }}
      >
        <span style={iconStyle}>↪</span>
        <span>Salir</span>
      </Link>
    </nav>
  );
}

const navStyle: React.CSSProperties = {
  width: "220px",
  minHeight: "100vh",
  background: "var(--surface)",
  borderRight: "1px solid var(--border)",
  display: "flex",
  flexDirection: "column",
  padding: "1.25rem 0.75rem",
  position: "fixed",
  top: 0,
  left: 0,
  bottom: 0,
  overflowY: "auto",
  zIndex: 100,
};

const brandStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.65rem",
  padding: "0.25rem 0.5rem 1rem",
};

const logoStyle: React.CSSProperties = {
  fontSize: "1.6rem",
  background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  WebkitBackgroundClip: "text",
  WebkitTextFillColor: "transparent",
  lineHeight: 1,
};

const dividerStyle: React.CSSProperties = {
  height: "1px",
  background: "var(--border)",
  margin: "0.5rem 0",
};

function navLinkStyle(active: boolean): React.CSSProperties {
  return {
    display: "flex",
    alignItems: "center",
    gap: "0.65rem",
    padding: "0.6rem 0.75rem",
    borderRadius: "var(--radius-sm)",
    fontSize: "0.825rem",
    fontWeight: active ? 600 : 400,
    color: active ? "var(--accent2)" : "var(--text-muted)",
    background: active ? "rgba(124,92,252,0.12)" : "transparent",
    marginBottom: "2px",
    transition: "all var(--transition)",
    textDecoration: "none",
    position: "relative",
    overflow: "hidden",
  };
}

const iconStyle: React.CSSProperties = {
  fontSize: "1rem",
  width: "20px",
  textAlign: "center",
  flexShrink: 0,
};

const activeBarStyle: React.CSSProperties = {
  position: "absolute",
  left: 0,
  top: "20%",
  height: "60%",
  width: "3px",
  background: "var(--accent)",
  borderRadius: "0 4px 4px 0",
};
