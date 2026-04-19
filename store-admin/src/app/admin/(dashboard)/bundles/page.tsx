"use client";
import { adminFetch } from "@/lib/admin-fetch";


import { useEffect, useState } from "react";

type BundleProduct = {
  id: string;
  productId: number;
  variantId: number;
  productName: string;
  unitPrice: number;
  quantity: number;
};

type Bundle = {
  id: string;
  name: string;
  description?: string;
  comboPrice: number;
  imageUrl?: string;
  enabled: boolean;
  products: BundleProduct[];
  createdAt: string;
};

type ProductRow = {
  id: string;
  productId: number;
  variantId: number;
  productName: string;
  unitPrice: string;
  quantity: string;
};

const mkProduct = (): ProductRow => ({
  id: Math.random().toString(36).slice(2),
  productId: 0,
  variantId: 0,
  productName: "",
  unitPrice: "0",
  quantity: "1",
});

const EMPTY_FORM = {
  name: "",
  description: "",
  comboPrice: "",
  imageUrl: "",
  enabled: true,
};

export default function BundlesPage() {
  const [bundles, setBundles] = useState<Bundle[]>([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [products, setProducts] = useState<ProductRow[]>([mkProduct()]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [expanded, setExpanded] = useState<string | null>(null);

  async function fetchBundles() {
    const r = await adminFetch("/api/admin/bundles");
    if (r.ok) setBundles(await r.json());
    setLoading(false);
  }

  useEffect(() => { fetchBundles(); }, []);

  function updateProduct(id: string, field: keyof ProductRow, value: string | number) {
    setProducts((prev) =>
      prev.map((p) => (p.id === id ? { ...p, [field]: value } : p))
    );
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const body = {
        ...form,
        comboPrice: parseFloat(form.comboPrice),
        products: products.map((p) => ({
          productId: Number(p.productId),
          variantId: Number(p.variantId),
          productName: p.productName,
          unitPrice: parseFloat(p.unitPrice) || 0,
          quantity: parseInt(p.quantity) || 1,
        })),
      };
      const r = await adminFetch("/api/admin/bundles", {
        method: "POST",
        body: JSON.stringify(body),
      });
      if (!r.ok) {
        const err = await r.json().catch(() => ({}));
        setError(JSON.stringify(err, null, 2));
      } else {
        setSuccess("Bundle creado exitosamente");
        setForm(EMPTY_FORM);
        setProducts([mkProduct()]);
        fetchBundles();
      }
    } finally {
      setSaving(false);
    }
  }

  async function toggleBundle(b: Bundle) {
    await adminFetch(`/api/admin/bundles/${b.id}`, {
      method: "PATCH",
      body: JSON.stringify({ enabled: !b.enabled }),
    });
    fetchBundles();
  }

  async function deleteBundle(id: string) {
    if (!confirm("¿Eliminar este bundle?")) return;
    await adminFetch(`/api/admin/bundles/${id}`, { method: "DELETE" });

    fetchBundles();
  }

  const totalUnitPrice = products.reduce(
    (acc, p) => acc + (parseFloat(p.unitPrice) || 0) * (parseInt(p.quantity) || 1),
    0
  );
  const comboPriceNum = parseFloat(form.comboPrice) || 0;
  const savingPct =
    totalUnitPrice > 0 ? Math.round((1 - comboPriceNum / totalUnitPrice) * 100) : 0;

  return (
    <div>
      {/* Header */}
      <div style={{ marginBottom: "1.75rem" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.35rem" }}>
          <span style={{ fontSize: "1.5rem" }}>📦</span>
          <h1>Bundles / Combos</h1>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
          Creá combos de productos con precio especial. Se muestran en la página <code>/pages/combos</code> de tu tienda
          y el JS permite agregarlos al carrito con un solo clic.
        </p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1.1fr 0.9fr", gap: "1.5rem", alignItems: "start" }}>
        {/* Form */}
        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1.25rem" }}>Crear Bundle</h2>
          <form onSubmit={handleCreate} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
            <Field label="Nombre del combo">
              <input
                placeholder="Ej: Kit de Verano"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </Field>
            <Field label="Descripción (opcional)">
              <textarea
                rows={2}
                placeholder="El combo perfecto para..."
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                style={{ resize: "vertical", minHeight: "60px" }}
              />
            </Field>
            <Field label="Imagen del combo (URL opcional)">
              <input
                placeholder="https://..."
                value={form.imageUrl}
                onChange={(e) => setForm({ ...form, imageUrl: e.target.value })}
              />
            </Field>

            {/* Products */}
            <div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.75rem" }}>
                <label style={{ marginBottom: 0 }}>Productos del combo</label>
                <button
                  type="button"
                  onClick={() => setProducts([...products, mkProduct()])}
                  style={btnSecondary}
                >
                  + Agregar producto
                </button>
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
                {products.map((p, idx) => (
                  <div key={p.id} style={productRowStyle}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.5rem" }}>
                      <span style={{ fontSize: "0.75rem", color: "var(--text-muted)", fontWeight: 600 }}>
                        Producto #{idx + 1}
                      </span>
                      {products.length > 1 && (
                        <button
                          type="button"
                          onClick={() => setProducts(products.filter((x) => x.id !== p.id))}
                          style={{ ...btnDanger, padding: "0.2rem 0.45rem", fontSize: "0.7rem" }}
                        >
                          ✕
                        </button>
                      )}
                    </div>
                    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "0.5rem" }}>
                      <Field label="Nombre visible">
                        <input
                          placeholder="Remera UV"
                          value={p.productName}
                          onChange={(e) => updateProduct(p.id, "productName", e.target.value)}
                          required
                        />
                      </Field>
                      <Field label="Precio unitario ($)">
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          placeholder="12000"
                          value={p.unitPrice}
                          onChange={(e) => updateProduct(p.id, "unitPrice", e.target.value)}
                        />
                      </Field>
                      <Field label="Product ID (TN)">
                        <input
                          type="number"
                          placeholder="123456"
                          value={p.productId || ""}
                          onChange={(e) => updateProduct(p.id, "productId", e.target.value)}
                          required
                        />
                      </Field>
                      <Field label="Variant ID (TN)">
                        <input
                          type="number"
                          placeholder="789012"
                          value={p.variantId || ""}
                          onChange={(e) => updateProduct(p.id, "variantId", e.target.value)}
                          required
                        />
                      </Field>
                    </div>
                    <Field label="Cantidad">
                      <input
                        type="number"
                        min="1"
                        value={p.quantity}
                        onChange={(e) => updateProduct(p.id, "quantity", e.target.value)}
                      />
                    </Field>
                  </div>
                ))}
              </div>
            </div>

            {/* Combo price */}
            <div style={previewBannerStyle}>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ fontSize: "0.8rem", color: "var(--text-muted)" }}>
                  Total productos por separado:
                </span>
                <strong>${totalUnitPrice.toLocaleString()}</strong>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <Field label="Precio del combo ($)">
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    placeholder="18000"
                    value={form.comboPrice}
                    onChange={(e) => setForm({ ...form, comboPrice: e.target.value })}
                    required
                    style={{ background: "var(--surface)" }}
                  />
                </Field>
                {savingPct > 0 && (
                  <div style={{ ...savingsBadge, marginTop: "1.1rem" }}>
                    Ahorro: {savingPct}%
                  </div>
                )}
              </div>
            </div>

            <label style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontSize: "0.875rem", cursor: "pointer" }}>
              <input
                type="checkbox"
                checked={form.enabled}
                onChange={(e) => setForm({ ...form, enabled: e.target.checked })}
              />
              Publicar inmediatamente
            </label>

            {error && <div style={alertStyle("danger")}><pre style={{ margin: 0, fontSize: "0.75rem" }}>{error}</pre></div>}
            {success && <div style={alertStyle("success")}>{success}</div>}
            <button type="submit" disabled={saving} style={btnPrimary}>
              {saving ? "Guardando..." : "📦 Crear Bundle"}
            </button>
          </form>
        </div>

        {/* Bundles list */}
        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1.25rem" }}>Bundles Configurados</h2>
          {loading ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Cargando...</p>
          ) : bundles.length === 0 ? (
            <div style={emptyStyle}>
              <div style={{ fontSize: "2.5rem", marginBottom: "0.5rem" }}>📦</div>
              <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
                No hay bundles creados aún.
              </p>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
              {bundles.map((b) => (
                <div key={b.id} style={bundleCardStyle(b.enabled)}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.3rem" }}>
                        <span style={{ fontWeight: 600, fontSize: "0.9rem" }}>{b.name}</span>
                        {!b.enabled && (
                          <span style={{ fontSize: "0.65rem", color: "var(--text-muted)", border: "1px solid var(--border)", padding: "0.1rem 0.4rem", borderRadius: "4px" }}>
                            Oculto
                          </span>
                        )}
                      </div>
                      <div style={{ fontSize: "0.8rem", color: "var(--success)", fontWeight: 600, marginBottom: "0.25rem" }}>
                        Combo: ${b.comboPrice.toLocaleString()}
                      </div>
                      <div style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>
                        {b.products.length} producto{b.products.length !== 1 ? "s" : ""}
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "0.4rem", flexShrink: 0 }}>
                      <button
                        onClick={() => setExpanded(expanded === b.id ? null : b.id)}
                        style={btnSecondary}
                        title="Ver productos"
                      >
                        {expanded === b.id ? "▲" : "▼"}
                      </button>
                      <button onClick={() => toggleBundle(b)} style={btnToggle(b.enabled)}>
                        {b.enabled ? "ON" : "OFF"}
                      </button>
                      <button onClick={() => deleteBundle(b.id)} style={btnDanger}>✕</button>
                    </div>
                  </div>
                  {expanded === b.id && (
                    <div style={{ marginTop: "0.75rem", paddingTop: "0.75rem", borderTop: "1px solid var(--border)" }}>
                      {b.products.map((p) => (
                        <div key={p.id} style={{ fontSize: "0.78rem", color: "var(--text-muted)", display: "flex", justifyContent: "space-between", padding: "0.2rem 0" }}>
                          <span>× {p.quantity} {p.productName}</span>
                          <span>${p.unitPrice.toLocaleString()}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Info */}
      <div style={{ ...cardStyle, marginTop: "1rem" }}>
        <h2 style={{ marginBottom: "0.75rem" }}>¿Cómo funciona la página de combos?</h2>
        <ol style={{ paddingLeft: "1.25rem", lineHeight: 2, fontSize: "0.875rem", color: "var(--text-muted)" }}>
          <li>Creás una página en Tiendanube llamada <strong>combos</strong> (slug: <code>/pages/combos</code>).</li>
          <li>El template <code>pages.combo.html.tpl</code> renderiza un contenedor vacío.</li>
          <li><code>hache-suite.js</code> detecta esa página y llama a <code>/api/storefront/bundles</code>.</li>
          <li>Renderiza las cards de bundles con el botón &quot;Agregar combo al carrito&quot;.</li>
          <li>Al hacer clic, todos los productos del bundle se agregan al carrito vía TN Cart API.</li>
        </ol>
      </div>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label>{label}</label>
      {children}
    </div>
  );
}

const cardStyle: React.CSSProperties = {
  background: "var(--surface)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius)",
  padding: "1.5rem",
};

const btnPrimary: React.CSSProperties = {
  padding: "0.65rem 1.25rem",
  background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  color: "#fff",
  border: "none",
  borderRadius: "var(--radius-sm)",
  cursor: "pointer",
  fontWeight: 600,
  fontSize: "0.875rem",
};

const btnSecondary: React.CSSProperties = {
  padding: "0.35rem 0.65rem",
  background: "var(--surface2)",
  color: "var(--text-muted)",
  border: "1px solid var(--border)",
  borderRadius: "6px",
  cursor: "pointer",
  fontSize: "0.78rem",
};

const btnDanger: React.CSSProperties = {
  padding: "0.35rem 0.65rem",
  background: "rgba(239,68,68,0.15)",
  color: "var(--danger)",
  border: "1px solid rgba(239,68,68,0.3)",
  borderRadius: "6px",
  cursor: "pointer",
  fontSize: "0.8rem",
};

function btnToggle(enabled: boolean): React.CSSProperties {
  return {
    padding: "0.35rem 0.65rem",
    background: enabled ? "rgba(34,197,94,0.15)" : "rgba(107,114,128,0.15)",
    color: enabled ? "var(--success)" : "var(--text-muted)",
    border: `1px solid ${enabled ? "rgba(34,197,94,0.3)" : "var(--border)"}`,
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "0.75rem",
    fontWeight: 600,
    letterSpacing: "0.05em",
  };
}

function bundleCardStyle(enabled: boolean): React.CSSProperties {
  return {
    padding: "0.9rem 1rem",
    background: "var(--surface2)",
    borderRadius: "var(--radius-sm)",
    border: `1px solid ${enabled ? "rgba(124,92,252,0.2)" : "var(--border)"}`,
    opacity: enabled ? 1 : 0.65,
  };
}

const productRowStyle: React.CSSProperties = {
  padding: "0.9rem",
  background: "var(--surface2)",
  borderRadius: "var(--radius-sm)",
  border: "1px solid var(--border)",
};

const previewBannerStyle: React.CSSProperties = {
  padding: "0.9rem 1rem",
  background: "var(--surface2)",
  borderRadius: "var(--radius-sm)",
  border: "1px solid var(--border)",
  display: "flex",
  flexDirection: "column",
  gap: "0.6rem",
};

const savingsBadge: React.CSSProperties = {
  padding: "0.3rem 0.65rem",
  background: "rgba(34,197,94,0.15)",
  color: "var(--success)",
  border: "1px solid rgba(34,197,94,0.3)",
  borderRadius: "99px",
  fontSize: "0.75rem",
  fontWeight: 700,
  flexShrink: 0,
};

function alertStyle(type: "success" | "danger"): React.CSSProperties {
  const colors = {
    success: { bg: "rgba(34,197,94,0.1)", border: "rgba(34,197,94,0.3)", text: "var(--success)" },
    danger: { bg: "rgba(239,68,68,0.1)", border: "rgba(239,68,68,0.3)", text: "var(--danger)" },
  };
  const c = colors[type];
  return {
    padding: "0.65rem 0.9rem",
    background: c.bg,
    border: `1px solid ${c.border}`,
    color: c.text,
    borderRadius: "var(--radius-sm)",
    fontSize: "0.8rem",
  };
}

const emptyStyle: React.CSSProperties = {
  textAlign: "center",
  padding: "2.5rem 1rem",
};
