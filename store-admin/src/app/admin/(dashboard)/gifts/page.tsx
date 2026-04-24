"use client";
import { TnProductPicker } from "@/components/admin/TnProductPicker";
import type { TNProduct, TNVariant } from "@/components/admin/tn-product-picker-utils";
import { adminFetch } from "@/lib/admin-fetch";
import { formatAdminApiError } from "@/lib/format-admin-api-error";

import { useCallback, useEffect, useState } from "react";

type GiftRule = {
  id: string;
  name: string;
  minTotal: number;
  giftProductId: number;
  giftVariantId: number;
  giftQty: number;
  enabled: boolean;
  publicBenefitTitle?: string | null;
  publicBenefitMessage?: string | null;
};

const EMPTY_FORM = {
  name: "",
  minTotal: "",
  giftQty: "1",
  enabled: true,
  publicBenefitTitle: "",
  publicBenefitMessage: "",
};

export default function GiftsPage() {
  const [rules, setRules] = useState<GiftRule[]>([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const [selectedProduct, setSelectedProduct] = useState<TNProduct | null>(null);
  const [selectedVariant, setSelectedVariant] = useState<TNVariant | null>(null);

  /** Borradores del copy del popup por regla (sincroniza al cargar reglas nuevas). */
  const [benefitDrafts, setBenefitDrafts] = useState<Record<string, { t: string; m: string }>>({});
  const [savingCopyId, setSavingCopyId] = useState<string | null>(null);

  const fetchRules = useCallback(async () => {
    const r = await adminFetch("/api/admin/cart-gifts");
    if (r.ok) setRules(await r.json());
    else if (r.status === 401) setError("Sesión expirada. Recargá la página.");
  }, []);

  useEffect(() => { fetchRules(); }, [fetchRules]);

  useEffect(() => {
    setBenefitDrafts((prev) => {
      const next = { ...prev };
      for (const r of rules) {
        if (!(r.id in next)) {
          next[r.id] = { t: r.publicBenefitTitle ?? "", m: r.publicBenefitMessage ?? "" };
        }
      }
      return next;
    });
  }, [rules]);

  function handleGiftProductPick(p: TNProduct, v: TNVariant) {
    setSelectedProduct(p);
    setSelectedVariant(v);
  }

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
        publicBenefitTitle: form.publicBenefitTitle.trim() || null,
        publicBenefitMessage: form.publicBenefitMessage.trim() || null,
      };
      const r = await adminFetch("/api/admin/cart-gifts", {
        method: "POST",
        body: JSON.stringify(body),
      });
      if (!r.ok) {
        const err = await r.json().catch(() => null);
        setError(formatAdminApiError(err, r.status));
      } else {
        setSuccess("✓ Regla creada");
        setForm(EMPTY_FORM);
        setSelectedProduct(null);
        setSelectedVariant(null);
        fetchRules();
      }
    } finally {
      setSaving(false);
    }
  }

  async function toggleEnabled(rule: GiftRule) {
    await adminFetch(`/api/admin/cart-gifts/${rule.id}`, {
      method: "PATCH",
      body: JSON.stringify({ enabled: !rule.enabled }),
    });
    fetchRules();
  }

  async function saveRulePublicCopy(ruleId: string) {
    const d = benefitDrafts[ruleId];
    if (!d) return;
    setSavingCopyId(ruleId);
    setError(null);
    try {
      const r = await adminFetch(`/api/admin/cart-gifts/${ruleId}`, {
        method: "PATCH",
        body: JSON.stringify({
          publicBenefitTitle: d.t.trim() || null,
          publicBenefitMessage: d.m.trim() || null,
        }),
      });
      if (!r.ok) {
        const err = await r.json().catch(() => null);
        setError(formatAdminApiError(err, r.status));
      } else {
        const updated = (await r.json().catch(() => null)) as GiftRule | null;
        if (updated && updated.id) {
          setBenefitDrafts((prev) => ({
            ...prev,
            [updated.id]: {
              t: updated.publicBenefitTitle ?? "",
              m: updated.publicBenefitMessage ?? "",
            },
          }));
        }
        setSuccess("✓ Texto del popup actualizado");
        fetchRules();
      }
    } finally {
      setSavingCopyId(null);
    }
  }

  async function handleDelete(id: string) {
    if (!confirm("¿Eliminar esta regla?")) return;
    await adminFetch(`/api/admin/cart-gifts/${id}`, { method: "DELETE" });

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

            <div>
              <label>Título del popup en la tienda (opcional)</label>
              <input
                placeholder="Ej: ¡Desbloqueaste un regalo!"
                value={form.publicBenefitTitle}
                onChange={(e) => setForm({ ...form, publicBenefitTitle: e.target.value })}
                maxLength={200}
              />
              <p style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "0.35rem", marginBottom: 0 }}>
                Si lo dejás vacío, se usa el nombre de la regla como título.
              </p>
            </div>

            <div>
              <label>Mensaje del beneficio en la tienda (opcional)</label>
              <textarea
                placeholder="Ej: Por superar los $50.000 te sumamos una muestra exclusiva al carrito. ¡Gracias por elegirnos!"
                value={form.publicBenefitMessage}
                onChange={(e) => setForm({ ...form, publicBenefitMessage: e.target.value })}
                rows={4}
                maxLength={2000}
                style={{ width: "100%", resize: "vertical", fontFamily: "inherit", fontSize: "0.875rem" }}
              />
              <p style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "0.35rem", marginBottom: 0 }}>
                Se muestra en un popup cuando se agrega el regalo. Si está vacío, se arma un texto genérico con el mínimo.
              </p>
            </div>

            <div>
              <label style={{ marginBottom: "0.5rem", display: "block" }}>Producto regalo</label>
              <TnProductPicker onPick={handleGiftProductPick} />
            </div>

            {selectedProduct && selectedVariant && (
              <div style={selectedPreview}>
                <span style={{ fontSize: "1.1rem" }}>✓</span>
                <div>
                  <div style={{ fontWeight: 600, fontSize: "0.875rem" }}>{selectedProduct.name}</div>
                  <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                    ID: {selectedProduct.id} · Variante: {selectedVariant.id} · ${selectedVariant.price}
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    setSelectedProduct(null);
                    setSelectedVariant(null);
                  }}
                  style={btnClear}
                >
                  ✕
                </button>
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
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontWeight: 600, fontSize: "0.9rem", marginBottom: "0.3rem" }}>{rule.name}</div>
                      <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                        Mínimo: <strong style={{ color: "var(--success)" }}>${rule.minTotal.toLocaleString()}</strong>
                        {" "}· Producto #{rule.giftProductId} · ×{rule.giftQty}
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "0.4rem", flexShrink: 0 }}>
                      <button type="button" onClick={() => toggleEnabled(rule)} style={btnToggle(rule.enabled)}>
                        {rule.enabled ? "ON" : "OFF"}
                      </button>
                      <button type="button" onClick={() => handleDelete(rule.id)} style={btnDanger}>✕</button>
                    </div>
                  </div>
                  <div style={{ marginTop: "0.85rem", paddingTop: "0.85rem", borderTop: "1px solid var(--border)" }}>
                    <div style={{ fontSize: "0.72rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.04em", color: "var(--text-muted)", marginBottom: "0.5rem" }}>
                      Popup en la tienda
                    </div>
                    <label style={{ fontSize: "0.78rem" }}>Título (opcional)</label>
                    <input
                      style={{ marginTop: "0.25rem", marginBottom: "0.5rem", width: "100%" }}
                      value={benefitDrafts[rule.id]?.t ?? ""}
                      onChange={(e) =>
                        setBenefitDrafts((prev) => ({
                          ...prev,
                          [rule.id]: { t: e.target.value, m: prev[rule.id]?.m ?? "" },
                        }))
                      }
                      maxLength={200}
                      placeholder="Vacío = nombre de la regla"
                    />
                    <label style={{ fontSize: "0.78rem" }}>Mensaje (opcional)</label>
                    <textarea
                      style={{ marginTop: "0.25rem", width: "100%", resize: "vertical", fontFamily: "inherit", fontSize: "0.8rem", minHeight: "4rem" }}
                      value={benefitDrafts[rule.id]?.m ?? ""}
                      onChange={(e) =>
                        setBenefitDrafts((prev) => ({
                          ...prev,
                          [rule.id]: { t: prev[rule.id]?.t ?? "", m: e.target.value },
                        }))
                      }
                      maxLength={2000}
                      placeholder="Texto del beneficio que ve el cliente"
                    />
                    <button
                      type="button"
                      disabled={savingCopyId === rule.id}
                      onClick={() => saveRulePublicCopy(rule.id)}
                      style={{ ...btnPrimary, marginTop: "0.5rem", fontSize: "0.8rem", padding: "0.45rem 0.9rem" }}
                    >
                      {savingCopyId === rule.id ? "Guardando…" : "Guardar texto del popup"}
                    </button>
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
          <li>Al aplicarse la regla se abre un popup con el título y mensaje que configuraste (o valores por defecto).</li>
          <li>La línea del regalo en el carrito se marca con un distintivo visual.</li>
        </ol>
      </div>
    </div>
  );
}

// Styles
const card: React.CSSProperties = { background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--radius)", padding: "1.5rem" };
const ruleCard: React.CSSProperties = { padding: "0.9rem 1rem", background: "var(--surface2)", borderRadius: "var(--radius-sm)", border: "1px solid var(--border)" };
const selectedPreview: React.CSSProperties = { display: "flex", alignItems: "center", gap: "0.65rem", padding: "0.75rem 1rem", background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.25)", borderRadius: "var(--radius-sm)", fontSize: "0.875rem", color: "var(--success)" };
const btnPrimary: React.CSSProperties = { padding: "0.65rem 1.25rem", background: "linear-gradient(135deg, var(--accent), var(--accent2))", color: "#fff", border: "none", borderRadius: "var(--radius-sm)", cursor: "pointer", fontWeight: 600, fontSize: "0.875rem", fontFamily: "inherit" };
const btnDanger: React.CSSProperties = { padding: "0.35rem 0.65rem", background: "rgba(239,68,68,0.15)", color: "var(--danger)", border: "1px solid rgba(239,68,68,0.3)", borderRadius: "6px", cursor: "pointer", fontSize: "0.8rem" };
const btnClear: React.CSSProperties = { padding: "0.25rem 0.5rem", background: "transparent", border: "none", color: "var(--text-muted)", cursor: "pointer", marginLeft: "auto", fontSize: "0.9rem" };
const alertDanger: React.CSSProperties = { padding: "0.65rem 0.9rem", background: "rgba(239,68,68,0.1)", border: "1px solid rgba(239,68,68,0.3)", color: "var(--danger)", borderRadius: "var(--radius-sm)", fontSize: "0.8rem" };
const alertSuccess: React.CSSProperties = { padding: "0.65rem 0.9rem", background: "rgba(34,197,94,0.1)", border: "1px solid rgba(34,197,94,0.3)", color: "var(--success)", borderRadius: "var(--radius-sm)", fontSize: "0.8rem" };
function btnToggle(enabled: boolean): React.CSSProperties {
  return { padding: "0.35rem 0.65rem", background: enabled ? "rgba(34,197,94,0.15)" : "rgba(107,114,128,0.15)", color: enabled ? "var(--success)" : "var(--text-muted)", border: `1px solid ${enabled ? "rgba(34,197,94,0.3)" : "var(--border)"}`, borderRadius: "6px", cursor: "pointer", fontSize: "0.75rem", fontWeight: 600 };
}
