"use client";

import { useEffect, useState, useCallback } from "react";

type GiftRule = {
  id: string;
  name: string;
  minTotal: number;
  giftProductId: number;
  giftVariantId: number;
  giftQty: number;
  enabled: boolean;
};

type TNVariant = { id: number; price: string; values?: { es?: string }[] };
type TNProduct = {
  id: number;
  name: string;
  price: string;
  images: string[];
  variants: TNVariant[];
};

const EMPTY_FORM = {
  name: "",
  minTotal: "",
  giftQty: "1",
  enabled: true,
};

export default function GiftsPage() {
  const [rules, setRules] = useState<GiftRule[]>([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Product picker
  const [search, setSearch] = useState("");
  const [products, setProducts] = useState<TNProduct[]>([]);
  const [loadingProducts, setLoadingProducts] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<TNProduct | null>(null);
  const [selectedVariant, setSelectedVariant] = useState<TNVariant | null>(null);

  const fetchRules = useCallback(async () => {
    const r = await fetch("/api/admin/cart-gifts", { credentials: "include" });
    if (r.ok) setRules(await r.json());
    else if (r.status === 401) setError("Sesión expirada. Recargá la página.");
  }, []);

  useEffect(() => { fetchRules(); }, [fetchRules]);

  const searchProducts = useCallback(async (q: string) => {
    if (q.length < 2) { setProducts([]); return; }
    setLoadingProducts(true);
    try {
      const r = await fetch(`/api/admin/tn-products?q=${encodeURIComponent(q)}`, { credentials: "include" });
      if (r.ok) {
        const data = await r.json();
        setProducts(data.products ?? []);
      } else {
        setProducts([]);
      }
    } finally {
      setLoadingProducts(false);
    }
  }, []);

  useEffect(() => {
    const t = setTimeout(() => searchProducts(search), 400);
    return () => clearTimeout(t);
  }, [search, searchProducts]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedProduct || !selectedVariant) {
      setError("Seleccioná un producto y variante para el regalo.");
      return;
    }
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const body = {
        name: form.name,
        minTotal: parseFloat(form.minTotal),
        giftProductId: selectedProduct.id,
        giftVariantId: selectedVariant.id,
        giftQty: parseInt(form.giftQty),
        enabled: form.enabled,
      };
      const r = await fetch("/api/admin/cart-gifts", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      if (!r.ok) {
        const err = await r.json().catch(() => ({}));
        setError(err.error ?? JSON.stringify(err));
      } else {
        setSuccess("✓ Regla creada");
        setForm(EMPTY_FORM);
        setSelectedProduct(null);
        setSelectedVariant(null);
        setSearch("");
        setProducts([]);
        fetchRules();
      }
    } finally {
      setSaving(false);
    }
  }

  async function toggleEnabled(rule: GiftRule) {
    await fetch(`/api/admin/cart-gifts/${rule.id}`, {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ enabled: !rule.enabled }),
    });
    fetchRules();
  }

  async function handleDelete(id: string) {
    if (!confirm("¿Eliminar esta regla?")) return;
    await fetch(`/api/admin/cart-gifts/${id}`, { method: "DELETE", credentials: "include" });
    fetchRules();
  }

  return (
    <div>
      <div style={{ marginBottom: "1.75rem" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.35rem" }}>
          <span style={{ fontSize: "1.5rem" }}>🎁</span>
          <h1>Regalos en Carrito</h1>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
          Configurá productos que se agregan automáticamente cuando el carrito supera un monto.
        </p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1.5rem", alignItems: "start" }}>
        {/* FORM */}
        <div style={card}>
          <h2 style={{ marginBottom: "1.25rem" }}>Nueva Regla</h2>
          <form onSubmit={handleCreate} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>

            <div>
              <label>Nombre de la regla</label>
              <input placeholder="Ej: Regalo por $50.000" value={form.name}
                onChange={e => setForm({ ...form, name: e.target.value })} required />
            </div>

            <div>
              <label>Monto mínimo del carrito ($)</label>
              <input type="number" min="0" step="100" placeholder="50000" value={form.minTotal}
                onChange={e => setForm({ ...form, minTotal: e.target.value })} required />
            </div>

            {/* Product picker */}
            <div>
              <label>Buscar producto regalo</label>
              <input
                placeholder="Escribí el nombre del producto..."
                value={search}
                onChange={e => { setSearch(e.target.value); setSelectedProduct(null); setSelectedVariant(null); }}
              />
              {loadingProducts && (
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "0.35rem" }}>Buscando...</p>
              )}
              {products.length > 0 && !selectedProduct && (
                <div style={pickerDropdown}>
                  {products.map(p => (
                    <button
                      key={p.id}
                      type="button"
                      onClick={() => { setSelectedProduct(p); setSelectedVariant(p.variants[0] ?? null); setSearch(p.name); setProducts([]); }}
                      style={pickerItem}
                    >
                      {p.images[0] && (
                        <img src={p.images[0]} alt="" style={{ width: 36, height: 36, objectFit: "cover", borderRadius: 6, flexShrink: 0 }} />
                      )}
                      <div style={{ textAlign: "left" }}>
                        <div style={{ fontWeight: 600, fontSize: "0.85rem" }}>{p.name}</div>
                        <div style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>
                          {p.variants.length} variante{p.variants.length !== 1 ? "s" : ""} · desde ${p.price}
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Variant selector */}
            {selectedProduct && selectedProduct.variants.length > 1 && (
              <div>
                <label>Variante del producto</label>
                <select
                  value={selectedVariant?.id ?? ""}
                  onChange={e => {
                    const v = selectedProduct.variants.find(x => x.id === parseInt(e.target.value));
                    setSelectedVariant(v ?? null);
                  }}
                >
                  {selectedProduct.variants.map(v => (
                    <option key={v.id} value={v.id}>
                      {v.values?.map(x => x.es).join(" / ") || `Variante ${v.id}`} — ${v.price}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Selected product preview */}
            {selectedProduct && selectedVariant && (
              <div style={selectedPreview}>
                <span style={{ fontSize: "1.1rem" }}>✓</span>
                <div>
                  <div style={{ fontWeight: 600, fontSize: "0.875rem" }}>{selectedProduct.name}</div>
                  <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                    ID: {selectedProduct.id} · Variante: {selectedVariant.id} · ${selectedVariant.price}
                  </div>
                </div>
                <button type="button" onClick={() => { setSelectedProduct(null); setSelectedVariant(null); setSearch(""); }} style={btnClear}>✕</button>
              </div>
            )}

            <div>
              <label>Cantidad a regalar</label>
              <input type="number" min="1" value={form.giftQty}
                onChange={e => setForm({ ...form, giftQty: e.target.value })} />
            </div>

            <label style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontSize: "0.875rem", cursor: "pointer" }}>
              <input type="checkbox" checked={form.enabled} onChange={e => setForm({ ...form, enabled: e.target.checked })} />
              Activa inmediatamente
            </label>

            {error && <div style={alertDanger}>{error}</div>}
            {success && <div style={alertSuccess}>{success}</div>}

            <button type="submit" disabled={saving} style={btnPrimary}>
              {saving ? "Guardando..." : "+ Crear Regla"}
            </button>
          </form>
        </div>

        {/* LIST */}
        <div style={card}>
          <h2 style={{ marginBottom: "1.25rem" }}>Reglas Configuradas</h2>
          {rules.length === 0 ? (
            <div style={{ textAlign: "center", padding: "3rem 1rem", color: "var(--text-muted)" }}>
              <div style={{ fontSize: "2.5rem", marginBottom: "0.75rem" }}>🎁</div>
              <p style={{ fontSize: "0.875rem" }}>No hay reglas configuradas aún.</p>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
              {rules.map(rule => (
                <div key={rule.id} style={{ ...ruleCard, opacity: rule.enabled ? 1 : 0.6, borderColor: rule.enabled ? "rgba(124,92,252,0.2)" : "var(--border)" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: "0.5rem" }}>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: "0.9rem", marginBottom: "0.3rem" }}>{rule.name}</div>
                      <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                        Mínimo: <strong style={{ color: "var(--success)" }}>${rule.minTotal.toLocaleString()}</strong>
                        {" "}· Producto #{rule.giftProductId} · ×{rule.giftQty}
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "0.4rem" }}>
                      <button type="button" onClick={() => toggleEnabled(rule)} style={btnToggle(rule.enabled)}>
                        {rule.enabled ? "ON" : "OFF"}
                      </button>
                      <button type="button" onClick={() => handleDelete(rule.id)} style={btnDanger}>✕</button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* How it works */}
      <div style={{ ...card, marginTop: "1rem" }}>
        <h2 style={{ marginBottom: "0.75rem" }}>¿Cómo funciona?</h2>
        <ol style={{ paddingLeft: "1.25rem", lineHeight: 2, fontSize: "0.875rem", color: "var(--text-muted)" }}>
          <li>El cliente agrega productos al carrito de tu tienda.</li>
          <li><code>hache-suite.js</code> detecta el cambio de carrito y consulta <code>/api/storefront/cart-gifts</code>.</li>
          <li>Si el total supera el mínimo configurado, se agrega el producto regalo automáticamente.</li>
          <li>Se guarda en <code>localStorage</code> para no duplicarlo en la misma sesión.</li>
        </ol>
      </div>
    </div>
  );
}

// Styles
const card: React.CSSProperties = { background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--radius)", padding: "1.5rem" };
const ruleCard: React.CSSProperties = { padding: "0.9rem 1rem", background: "var(--surface2)", borderRadius: "var(--radius-sm)", border: "1px solid var(--border)" };
const pickerDropdown: React.CSSProperties = { position: "absolute", zIndex: 50, background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", marginTop: "4px", width: "100%", maxHeight: "260px", overflowY: "auto", boxShadow: "0 8px 24px rgba(0,0,0,0.4)" };
const pickerItem: React.CSSProperties = { display: "flex", alignItems: "center", gap: "0.65rem", width: "100%", padding: "0.65rem 0.9rem", background: "transparent", border: "none", cursor: "pointer", textAlign: "left", borderBottom: "1px solid var(--border)", color: "var(--text)" };
const selectedPreview: React.CSSProperties = { display: "flex", alignItems: "center", gap: "0.65rem", padding: "0.75rem 1rem", background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.25)", borderRadius: "var(--radius-sm)", fontSize: "0.875rem", color: "var(--success)" };
const btnPrimary: React.CSSProperties = { padding: "0.65rem 1.25rem", background: "linear-gradient(135deg, var(--accent), var(--accent2))", color: "#fff", border: "none", borderRadius: "var(--radius-sm)", cursor: "pointer", fontWeight: 600, fontSize: "0.875rem", fontFamily: "inherit" };
const btnDanger: React.CSSProperties = { padding: "0.35rem 0.65rem", background: "rgba(239,68,68,0.15)", color: "var(--danger)", border: "1px solid rgba(239,68,68,0.3)", borderRadius: "6px", cursor: "pointer", fontSize: "0.8rem" };
const btnClear: React.CSSProperties = { padding: "0.25rem 0.5rem", background: "transparent", border: "none", color: "var(--text-muted)", cursor: "pointer", marginLeft: "auto", fontSize: "0.9rem" };
const alertDanger: React.CSSProperties = { padding: "0.65rem 0.9rem", background: "rgba(239,68,68,0.1)", border: "1px solid rgba(239,68,68,0.3)", color: "var(--danger)", borderRadius: "var(--radius-sm)", fontSize: "0.8rem" };
const alertSuccess: React.CSSProperties = { padding: "0.65rem 0.9rem", background: "rgba(34,197,94,0.1)", border: "1px solid rgba(34,197,94,0.3)", color: "var(--success)", borderRadius: "var(--radius-sm)", fontSize: "0.8rem" };
function btnToggle(enabled: boolean): React.CSSProperties {
  return { padding: "0.35rem 0.65rem", background: enabled ? "rgba(34,197,94,0.15)" : "rgba(107,114,128,0.15)", color: enabled ? "var(--success)" : "var(--text-muted)", border: `1px solid ${enabled ? "rgba(34,197,94,0.3)" : "var(--border)"}`, borderRadius: "6px", cursor: "pointer", fontSize: "0.75rem", fontWeight: 600 };
}
