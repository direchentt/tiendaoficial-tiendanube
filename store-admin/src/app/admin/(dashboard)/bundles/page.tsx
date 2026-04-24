"use client";

import { TnProductPicker } from "@/components/admin/TnProductPicker";
import type { TNProduct, TNVariant } from "@/components/admin/tn-product-picker-utils";
import { variantLabel } from "@/components/admin/tn-product-picker-utils";
import { adminFetch } from "@/lib/admin-fetch";
import { useEffect, useState } from "react";

type BundleProduct = {
  id: string;
  productId: number;
  variantId: number;
  customerPicksVariant?: boolean;
  productName: string;
  unitPrice: number;
  quantity: number;
  thumbnailUrl?: string | null;
};

type Bundle = {
  id: string;
  name: string;
  description?: string | null;
  comboPrice: number;
  imageUrl?: string | null;
  enabled: boolean;
  products: BundleProduct[];
  createdAt: string;
};

type ProductRow = {
  id: string;
  productId: number;
  variantId: number;
  customerPicksVariant: boolean;
  productName: string;
  unitPrice: string;
  quantity: string;
  thumbnailUrl?: string;
};

const mkProduct = (): ProductRow => ({
  id: Math.random().toString(36).slice(2),
  productId: 0,
  variantId: 0,
  customerPicksVariant: false,
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
  const [products, setProducts] = useState<ProductRow[]>([]);
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

  useEffect(() => {
    fetchBundles();
  }, []);

  function addProductFromTn(p: TNProduct, v: TNVariant) {
    const thumb = p.images[0] ?? "";
    const newRow: ProductRow = {
      id: Math.random().toString(36).slice(2),
      productId: p.id,
      variantId: v.id,
      customerPicksVariant: false,
      productName:
        p.name + (p.variants.length > 1 ? ` (${variantLabel(v)})` : ""),
      unitPrice: v.price,
      quantity: "1",
      thumbnailUrl: thumb || undefined,
    };
    setProducts((prev) => [...prev, newRow]);
  }

  function addProductFromTnCustomerChoice(p: TNProduct) {
    if (p.variants.length === 0) return;
    const first = p.variants[0];
    const nums = p.variants.map((v) => {
      const n = parseFloat(String(v.price).replace(/\s/g, "").replace(",", "."));
      return Number.isFinite(n) ? n : 0;
    });
    const minP = nums.length ? Math.min(...nums) : parseFloat(String(first.price).replace(",", ".")) || 0;
    const multi = p.variants.length > 1;
    const thumb = p.images[0] ?? "";
    const newRow: ProductRow = {
      id: Math.random().toString(36).slice(2),
      productId: p.id,
      variantId: first.id,
      customerPicksVariant: multi,
      productName: multi ? `${p.name} (cliente elige variante)` : p.name,
      unitPrice: String(multi ? minP : parseFloat(String(first.price).replace(",", ".")) || 0),
      quantity: "1",
      thumbnailUrl: thumb || undefined,
    };
    setProducts((prev) => [...prev, newRow]);
  }

  function updateProduct(id: string, field: keyof ProductRow, value: string | number | boolean) {
    setProducts((prev) =>
      prev.map((p) => (p.id === id ? { ...p, [field]: value } : p))
    );
  }

  function moveProduct(index: number, delta: number) {
    const j = index + delta;
    if (j < 0 || j >= products.length) return;
    setProducts((prev) => {
      const next = [...prev];
      const [row] = next.splice(index, 1);
      next.splice(j, 0, row);
      return next;
    });
  }

  function applyFirstImageAsCover() {
    const first = products.find((p) => p.thumbnailUrl);
    const url = first?.thumbnailUrl;
    if (!url) return;
    setForm((f) => ({ ...f, imageUrl: url }));
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const validProducts = products.filter((p) => p.productId > 0);
      if (validProducts.length === 0) {
        setError("Agregá al menos un producto desde el catálogo o el buscador.");
        setSaving(false);
        return;
      }

      const finalTotalPrice = validProducts.reduce(
        (acc, p) => acc + (parseFloat(p.unitPrice) || 0) * (parseInt(p.quantity) || 1),
        0
      );
      const parsedComboPrice = parseFloat(form.comboPrice);

      const body = {
        ...form,
        comboPrice: !isNaN(parsedComboPrice) ? parsedComboPrice : finalTotalPrice,
        products: validProducts.map((p) => ({
          productId: Number(p.productId),
          variantId: Number(p.variantId),
          customerPicksVariant: Boolean(p.customerPicksVariant),
          productName: p.productName,
          unitPrice: parseFloat(p.unitPrice) || 0,
          quantity: parseInt(p.quantity) || 1,
          thumbnailUrl: p.thumbnailUrl || null,
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
        setSuccess("Combo creado correctamente.");
        setForm(EMPTY_FORM);
        setProducts([]);
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
    if (!confirm("¿Eliminar este combo?")) return;
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
      <div style={{ marginBottom: "1.75rem" }}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "0.5rem",
            marginBottom: "0.35rem",
          }}
        >
          <span style={{ fontSize: "1.5rem" }}>📦</span>
          <h1>Combos / Bundles</h1>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "52rem" }}>
          Armá combos con el <strong>catálogo visual</strong> o la búsqueda. El precio de cada variante viene de
          Tiendanube; podés reordenar ítems y usar la primera foto como portada. En la tienda se muestran en la ruta{" "}
          <code>/combos</code> (p. ej.{" "}
          <a href="https://www.direchentt.com.ar/combos" target="_blank" rel="noreferrer">
            direchentt.com.ar/combos
          </a>
          ) con el mismo look que tu marca. Si en Tiendanube <strong>/combos</strong> es una{" "}
          <strong>categoría</strong> (sin productos), el tema igual muestra los combos de este panel ahí. Páginas
          institucionales: <code>/pages/combos</code> o <code>/paginas/combos</code>.
        </p>
      </div>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "minmax(0, 1.15fr) minmax(0, 0.85fr)",
          gap: "1.5rem",
          alignItems: "start",
        }}
      >
        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1rem" }}>Nuevo combo</h2>

          <div style={stepRail}>
            <span style={stepDot}>1</span>
            <span style={stepLabel}>Datos</span>
            <span style={stepLine} />
            <span style={stepDot}>2</span>
            <span style={stepLabel}>Productos</span>
            <span style={stepLine} />
            <span style={stepDot}>3</span>
            <span style={stepLabel}>Precio</span>
          </div>

          <form
            onSubmit={handleCreate}
            style={{ display: "flex", flexDirection: "column", gap: "1.1rem", marginTop: "1rem" }}
          >
            <Field label="Nombre del combo">
              <input
                placeholder="Ej: Kit de verano"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </Field>
            <Field label="Descripción (opcional)">
              <textarea
                rows={2}
                placeholder="Breve texto que verá el cliente en la grilla de combos…"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                style={{ resize: "vertical", minHeight: "60px" }}
              />
            </Field>
            <Field label="Imagen del combo (URL opcional)">
              <input
                placeholder="https://… (o usá “Portada desde ítem” abajo)"
                value={form.imageUrl}
                onChange={(e) => setForm({ ...form, imageUrl: e.target.value })}
              />
              <div style={{ marginTop: "0.45rem", display: "flex", flexWrap: "wrap", gap: "0.5rem" }}>
                <button
                  type="button"
                  style={btnGhost}
                  disabled={!products.some((p) => p.thumbnailUrl)}
                  onClick={applyFirstImageAsCover}
                >
                  Portada desde primer ítem con foto
                </button>
              </div>
            </Field>

            <div>
              <label style={{ marginBottom: "0.5rem", display: "block" }}>
                Elegí productos
              </label>
              <TnProductPicker onPick={addProductFromTn} onPickCustomerChoice={addProductFromTnCustomerChoice} />
            </div>

            <div>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  marginBottom: "0.75rem",
                }}
              >
                <label style={{ marginBottom: 0 }}>Ítems del combo ({products.length})</label>
              </div>
              {products.length === 0 ? (
                <div
                  style={{
                    padding: "1.25rem",
                    background: "var(--surface2)",
                    borderRadius: 8,
                    fontSize: "0.85rem",
                    color: "var(--text-muted)",
                    textAlign: "center",
                    border: "1px dashed var(--border)",
                  }}
                >
                  Elegí una variante fija, o <strong>“Todas las variantes (elige el cliente)”</strong> para que en la
                  tienda puedan elegir talle/color. Podés reordenar con las flechas.
                </div>
              ) : (
                <div style={{ display: "flex", flexDirection: "column", gap: "0.65rem" }}>
                  {products.map((p, idx) => (
                    <div key={p.id} style={productRowStyle}>
                      <div style={{ display: "flex", gap: "0.65rem", alignItems: "flex-start" }}>
                        {p.thumbnailUrl ? (
                          <img
                            src={p.thumbnailUrl}
                            alt=""
                            style={{
                              width: 44,
                              height: 44,
                              objectFit: "cover",
                              borderRadius: 8,
                              flexShrink: 0,
                            }}
                          />
                        ) : (
                          <div
                            style={{
                              width: 44,
                              height: 44,
                              borderRadius: 8,
                              background: "var(--surface)",
                              flexShrink: 0,
                            }}
                          />
                        )}
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div
                            style={{
                              display: "flex",
                              justifyContent: "space-between",
                              gap: "0.5rem",
                              alignItems: "flex-start",
                            }}
                          >
                            <span style={{ fontSize: "0.82rem", fontWeight: 600, lineHeight: 1.35 }}>{p.productName}</span>
                            <button
                              type="button"
                              onClick={() => setProducts(products.filter((x) => x.id !== p.id))}
                              style={{ ...btnDanger, padding: "0.2rem 0.45rem", fontSize: "0.7rem", flexShrink: 0 }}
                            >
                              Quitar
                            </button>
                          </div>
                          <div style={{ display: "flex", flexWrap: "wrap", gap: "0.75rem", marginTop: "0.5rem", alignItems: "flex-end" }}>
                            <Field label="Cantidad">
                              <input
                                type="number"
                                min={1}
                                value={p.quantity}
                                onChange={(e) => updateProduct(p.id, "quantity", e.target.value)}
                                style={{ width: "72px" }}
                              />
                            </Field>
                            <Field label="Precio unitario (referencia)">
                              <input
                                type="number"
                                value={p.unitPrice}
                                onChange={(e) => updateProduct(p.id, "unitPrice", e.target.value)}
                                style={{ width: "110px" }}
                                title="Podés ajustarlo si el valor de TN no coincide con lo que cobrás en el combo"
                              />
                            </Field>
                            <div style={{ display: "flex", gap: "0.25rem", marginLeft: "auto" }}>
                              <button
                                type="button"
                                style={btnReorder}
                                disabled={idx === 0}
                                onClick={() => moveProduct(idx, -1)}
                                title="Subir"
                              >
                                ↑
                              </button>
                              <button
                                type="button"
                                style={btnReorder}
                                disabled={idx === products.length - 1}
                                onClick={() => moveProduct(idx, 1)}
                                title="Bajar"
                              >
                                ↓
                              </button>
                            </div>
                          </div>
                          <label
                            style={{
                              display: "flex",
                              alignItems: "center",
                              gap: "0.4rem",
                              marginTop: "0.55rem",
                              fontSize: "0.78rem",
                              color: "var(--text-muted)",
                              cursor: "pointer",
                            }}
                          >
                            <input
                              type="checkbox"
                              checked={p.customerPicksVariant}
                              onChange={(e) =>
                                updateProduct(p.id, "customerPicksVariant", e.target.checked)
                              }
                            />
                            Cliente elige variante en la tienda (todas las opciones de TN)
                          </label>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div style={previewBannerStyle}>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ fontSize: "0.8rem", color: "var(--text-muted)" }}>Suma referencia (ítems × cantidad):</span>
                <strong>${totalUnitPrice.toLocaleString()}</strong>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "0.75rem" }}>
                <Field label="Precio final del combo ($) — opcional">
                  <input
                    type="number"
                    min={0}
                    step="0.01"
                    placeholder={`Default: ${totalUnitPrice}`}
                    value={form.comboPrice}
                    onChange={(e) => setForm({ ...form, comboPrice: e.target.value })}
                    style={{ background: "var(--surface)", maxWidth: "12rem" }}
                  />
                </Field>
                {savingPct > 0 && (
                  <div style={{ ...savingsBadge, marginTop: "1.1rem" }}>Ahorro: {savingPct}%</div>
                )}
              </div>
            </div>

            <label style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontSize: "0.875rem", cursor: "pointer" }}>
              <input
                type="checkbox"
                checked={form.enabled}
                onChange={(e) => setForm({ ...form, enabled: e.target.checked })}
              />
              Publicar en la tienda
            </label>

            {error && (
              <div style={alertStyle("danger")}>
                <pre style={{ margin: 0, fontSize: "0.75rem", whiteSpace: "pre-wrap" }}>{error}</pre>
              </div>
            )}
            {success && <div style={alertStyle("success")}>{success}</div>}
            <button type="submit" disabled={saving} style={btnPrimary}>
              {saving ? "Guardando…" : "Crear combo"}
            </button>
          </form>
        </div>

        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1.25rem" }}>Combos publicados</h2>
          {loading ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Cargando…</p>
          ) : bundles.length === 0 ? (
            <div style={emptyStyle}>
              <div style={{ fontSize: "2.5rem", marginBottom: "0.5rem" }}>📦</div>
              <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Todavía no hay combos.</p>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
              {bundles.map((b) => (
                <div key={b.id} style={bundleCardStyle(b.enabled)}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: "0.5rem" }}>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.3rem", flexWrap: "wrap" }}>
                        <span style={{ fontWeight: 600, fontSize: "0.9rem" }}>{b.name}</span>
                        {!b.enabled && (
                          <span
                            style={{
                              fontSize: "0.65rem",
                              color: "var(--text-muted)",
                              border: "1px solid var(--border)",
                              padding: "0.1rem 0.4rem",
                              borderRadius: "4px",
                            }}
                          >
                            Oculto
                          </span>
                        )}
                      </div>
                      <div style={{ fontSize: "0.8rem", color: "var(--success)", fontWeight: 600, marginBottom: "0.25rem" }}>
                        Precio combo: ${b.comboPrice.toLocaleString()}
                      </div>
                      <div style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>
                        {b.products.length} ítem{b.products.length !== 1 ? "s" : ""}
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "0.35rem", flexShrink: 0 }}>
                      <button onClick={() => setExpanded(expanded === b.id ? null : b.id)} style={btnSecondary} type="button" title="Detalle">
                        {expanded === b.id ? "▲" : "▼"}
                      </button>
                      <button onClick={() => toggleBundle(b)} style={btnToggle(b.enabled)} type="button">
                        {b.enabled ? "ON" : "OFF"}
                      </button>
                      <button onClick={() => deleteBundle(b.id)} style={btnDanger} type="button">
                        ✕
                      </button>
                    </div>
                  </div>
                  {expanded === b.id && (
                    <div style={{ marginTop: "0.75rem", paddingTop: "0.75rem", borderTop: "1px solid var(--border)" }}>
                      {b.products.map((p) => (
                        <div
                          key={p.id}
                          style={{
                            fontSize: "0.78rem",
                            color: "var(--text-muted)",
                            display: "flex",
                            justifyContent: "space-between",
                            gap: "0.5rem",
                            padding: "0.25rem 0",
                            alignItems: "center",
                          }}
                        >
                          <span>
                            × {p.quantity} {p.productName}
                            {p.customerPicksVariant ? (
                              <span
                                style={{
                                  marginLeft: "0.35rem",
                                  fontSize: "0.65rem",
                                  color: "var(--accent2)",
                                  fontWeight: 600,
                                }}
                              >
                                · elige cliente
                              </span>
                            ) : null}
                          </span>
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

      <div style={{ ...cardStyle, marginTop: "1rem" }}>
        <h2 style={{ marginBottom: "0.75rem" }}>En la tienda</h2>
        <ol style={{ paddingLeft: "1.25rem", lineHeight: 1.85, fontSize: "0.875rem", color: "var(--text-muted)" }}>
          <li>
            Ruta pública <code>/combos</code> — en producción:{" "}
            <a href="https://www.direchentt.com.ar/combos" target="_blank" rel="noreferrer">
              https://www.direchentt.com.ar/combos
            </a>
            . Otras tiendas pueden usar <code>/pages/combos</code> o <code>/paginas/combos</code>.
          </li>
          <li>
            El script <code>hache-suite.js</code> pide <code>/api/storefront/bundles</code> y dibuja la grilla con colores del tema.
          </li>
          <li>
            Si un ítem tiene <strong>“cliente elige variante”</strong>, en la tarjeta del combo aparece un selector
            antes de agregar al carrito; el resto se agrega con la variante fijada en el panel.
          </li>
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

const btnGhost: React.CSSProperties = {
  ...btnSecondary,
  fontSize: "0.78rem",
};

const btnReorder: React.CSSProperties = {
  width: "2rem",
  height: "2rem",
  padding: 0,
  background: "var(--surface2)",
  border: "1px solid var(--border)",
  borderRadius: "6px",
  cursor: "pointer",
  color: "var(--text-muted)",
  fontSize: "0.85rem",
  lineHeight: 1,
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
  padding: "0.75rem",
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

const stepRail: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.35rem",
  flexWrap: "wrap",
  fontSize: "0.72rem",
  color: "var(--text-muted)",
};

const stepDot: React.CSSProperties = {
  width: "1.35rem",
  height: "1.35rem",
  borderRadius: "999px",
  background: "var(--accent)",
  color: "#fff",
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  fontWeight: 700,
};

const stepLabel: React.CSSProperties = { fontWeight: 600, color: "var(--text)" };
const stepLine: React.CSSProperties = {
  flex: "1 1 1.5rem",
  height: "1px",
  background: "var(--border)",
  minWidth: "0.5rem",
};
