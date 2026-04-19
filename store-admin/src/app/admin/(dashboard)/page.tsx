import Link from "next/link";

const MODULES = [
  {
    href: "/admin/gifts",
    icon: "🎁",
    title: "Regalos en Carrito",
    desc: "Agrega productos gratis cuando el carrito supera un monto mínimo.",
    color: "#22c55e",
  },
  {
    href: "/admin/dynamic-pricing",
    icon: "💰",
    title: "Precios Dinámicos",
    desc: "Descuentos automáticos del 5–20% según el algoritmo elegido.",
    color: "#f59e0b",
  },
  {
    href: "/admin/bundles",
    icon: "📦",
    title: "Bundles / Combos",
    desc: "Creá combos de productos con precio especial y página dedicada.",
    color: "#7c5cfc",
  },
  {
    href: "/admin/categories",
    icon: "🔒",
    title: "Categorías Privadas",
    desc: "Bloqueá categorías con contraseña. Acceso con TTL configurable.",
    color: "#60a5fa",
  },
  {
    href: "/admin/payment-rules",
    icon: "⚡",
    title: "Reglas de Pago",
    desc: "Excluí medios de pago según monto o categorías en el carrito.",
    color: "#f43f5e",
  },
  {
    href: "/admin/price",
    icon: "📊",
    title: "Precios Masivos",
    desc: "Aplicá un ajuste % a todos los productos de la tienda.",
    color: "#a78bfa",
  },
];

export default function AdminHomePage() {
  const base =
    process.env.NEXT_PUBLIC_APP_URL?.replace(/\/$/, "") ??
    "https://tu-dominio.com";

  return (
    <div>
      {/* Header */}
      <div style={{ marginBottom: "2rem" }}>
        <h1 style={{ marginBottom: "0.35rem" }}>Dashboard</h1>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
          Tu motor de reglas de negocio para Tiendanube. Configurá cada módulo desde el panel lateral.
        </p>
      </div>

      {/* Module cards grid */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
          gap: "1rem",
          marginBottom: "2.5rem",
        }}
      >
        {MODULES.map(({ href, icon, title, desc, color }) => (
          <Link href={href} key={href} style={{ textDecoration: "none" }}>
            <div style={cardStyle(color)}>
              <div style={cardIconStyle(color)}>{icon}</div>
              <h3 style={{ fontSize: "0.95rem", marginBottom: "0.35rem", color: "var(--text)" }}>
                {title}
              </h3>
              <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", lineHeight: 1.5 }}>
                {desc}
              </p>
              <div
                style={{
                  marginTop: "auto",
                  paddingTop: "1rem",
                  fontSize: "0.75rem",
                  color,
                  fontWeight: 500,
                }}
              >
                Configurar →
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Webhook info */}
      <div style={sectionStyle}>
        <h2 style={{ marginBottom: "0.75rem" }}>🔗 URL del Webhook (Business Rules)</h2>
        <p style={{ fontSize: "0.85rem", color: "var(--text-muted)", marginBottom: "0.75rem" }}>
          Registrá esta URL en el Partnership Portal de Tiendanube:
        </p>
        <pre style={{ margin: 0 }}>{`${base}/api/tn/payments-before-filter`}</pre>
        <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "0.75rem" }}>
          Para desarrollo local usá{" "}
          <code>ngrok http 3010</code> o <code>cloudflared tunnel</code>.
        </p>
      </div>

      {/* Storefront APIs */}
      <div style={{ ...sectionStyle, marginTop: "1rem" }}>
        <h2 style={{ marginBottom: "0.75rem" }}>🌐 APIs Públicas del Storefront</h2>
        <p style={{ fontSize: "0.85rem", color: "var(--text-muted)", marginBottom: "0.75rem" }}>
          El script <code>hache-suite.js</code> en tu tema llama a estas URLs:
        </p>
        <div style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}>
          {[
            ["GET", "/api/storefront/cart-gifts?storeId=...&total=...", "Regalos activos"],
            ["GET/POST", "/api/storefront/category-gate", "Validar contraseña de categoría"],
            ["GET", "/api/storefront/dynamic-prices?storeId=...&products=...", "Precios dinámicos"],
            ["GET", "/api/storefront/bundles?storeId=...", "Bundles activos"],
          ].map(([method, path, label]) => (
            <div key={path} style={apiRowStyle}>
              <span style={methodBadge}>{method}</span>
              <code style={{ fontSize: "0.78rem", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                {path}
              </code>
              <span style={{ fontSize: "0.75rem", color: "var(--text-muted)", flexShrink: 0 }}>
                {label}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function cardStyle(accentColor: string): React.CSSProperties {
  return {
    background: "var(--surface)",
    border: `1px solid var(--border)`,
    borderRadius: "var(--radius)",
    padding: "1.25rem",
    display: "flex",
    flexDirection: "column",
    minHeight: "160px",
    transition: "border-color var(--transition), box-shadow var(--transition), transform var(--transition)",
    cursor: "pointer",
    // Hover via CSS would need class; inline approximation:
    boxShadow: "none",
  };
}

function cardIconStyle(color: string): React.CSSProperties {
  return {
    fontSize: "1.75rem",
    marginBottom: "0.75rem",
    width: "2.5rem",
    height: "2.5rem",
    borderRadius: "10px",
    background: `${color}18`,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    lineHeight: 1,
  };
}

const sectionStyle: React.CSSProperties = {
  background: "var(--surface)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius)",
  padding: "1.5rem",
};

const apiRowStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.75rem",
  background: "var(--surface2)",
  padding: "0.5rem 0.75rem",
  borderRadius: "var(--radius-sm)",
  overflow: "hidden",
};

const methodBadge: React.CSSProperties = {
  fontSize: "0.65rem",
  fontWeight: 700,
  padding: "0.2rem 0.45rem",
  borderRadius: "4px",
  background: "rgba(124,92,252,0.2)",
  color: "var(--accent2)",
  flexShrink: 0,
  letterSpacing: "0.05em",
};
