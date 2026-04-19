"use client";

import { useEffect, useState } from "react";

type GiftRule = {
  id: string;
  name: string;
  minTotal: number;
  giftProductId: number;
  giftVariantId: number;
  giftQty: number;
  enabled: boolean;
  createdAt: string;
};

const EMPTY_FORM = {
  name: "",
  minTotal: "",
  giftProductId: "",
  giftVariantId: "",
  giftQty: "1",
  enabled: true,
};

export default function GiftsPage() {
  const [rules, setRules] = useState<GiftRule[]>([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function fetchRules() {
    setLoading(true);
    try {
      const r = await fetch("/api/admin/cart-gifts", { credentials: "include" });
      if (r.ok) setRules(await r.json());
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { fetchRules(); }, []);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const body = {
        name: form.name,
        minTotal: parseFloat(form.minTotal),
        giftProductId: parseInt(form.giftProductId),
        giftVariantId: parseInt(form.giftVariantId),
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
        setError(JSON.stringify(err));
      } else {
        setSuccess("Regla creada exitosamente");
        setForm(EMPTY_FORM);
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
    if (!confirm("¿Eliminar esta regla de regalo?")) return;
    await fetch(`/api/admin/cart-gifts/${id}`, {
      method: "DELETE",
      credentials: "include",
    });
    fetchRules();
  }

  return (
    <div>
      {/* Header */}
      <div style={{ marginBottom: "1.75rem" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.35rem" }}>
          <span style={{ fontSize: "1.5rem" }}>🎁</span>
          <h1>Regalos en Carrito</h1>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
          Configurá productos que se agregan automáticamente al carrito cuando el total supera un monto.
          El JS del storefront verifica esto en cada cambio de carrito y agrega el regalo vía la Cart API de TN.
        </p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1.5rem", alignItems: "start" }}>
        {/* Form */}
        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1.25rem" }}>Nueva Regla</h2>
          <form onSubmit={handleCreate} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
            <Field label="Nombre de la regla">
              <input
                placeholder="Ej: Regalo por $50.000"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </Field>
            <Field label="Monto mínimo del carrito ($)">
              <input
                type="number"
                min="0"
                step="0.01"
                placeholder="50000"
                value={form.minTotal}
                onChange={(e) => setForm({ ...form, minTotal: e.target.value })}
                required
              />
            </Field>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "0.75rem" }}>
              <Field label="ID del producto regalo (TN)">
                <input
                  type="number"
                  placeholder="123456"
                  value={form.giftProductId}
                  onChange={(e) => setForm({ ...form, giftProductId: e.target.value })}
                  required
                />
              </Field>
              <Field label="ID de la variante">
                <input
                  type="number"
                  placeholder="789012"
                  value={form.giftVariantId}
                  onChange={(e) => setForm({ ...form, giftVariantId: e.target.value })}
                  required
                />
              </Field>
            </div>
            <Field label="Cantidad a regalar">
              <input
                type="number"
                min="1"
                value={form.giftQty}
                onChange={(e) => setForm({ ...form, giftQty: e.target.value })}
                required
              />
            </Field>
            <label style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontSize: "0.875rem", cursor: "pointer" }}>
              <input
                type="checkbox"
                checked={form.enabled}
                onChange={(e) => setForm({ ...form, enabled: e.target.checked })}
              />
              Activa inmediatamente
            </label>
            {error && <div style={alertStyle("danger")}>{error}</div>}
            {success && <div style={alertStyle("success")}>{success}</div>}
            <button type="submit" disabled={saving} style={btnPrimary}>
              {saving ? "Guardando..." : "+ Crear Regla"}
            </button>
          </form>
        </div>

        {/* Rules list */}
        <div style={cardStyle}>
          <h2 style={{ marginBottom: "1.25rem" }}>Reglas Configuradas</h2>
          {loading ? (
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Cargando...</p>
          ) : rules.length === 0 ? (
            <div style={emptyStyle}>
              <div style={{ fontSize: "2rem", marginBottom: "0.5rem" }}>🎁</div>
              <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
                No hay reglas configuradas aún.
              </p>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
              {rules.map((rule) => (
                <div key={rule.id} style={ruleCardStyle(rule.enabled)}>
                  <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: "0.5rem" }}>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: "0.9rem", marginBottom: "0.25rem" }}>
                        {rule.name}
                      </div>
                      <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                        Monto mínimo: <strong style={{ color: "var(--success)" }}>${rule.minTotal.toLocaleString()}</strong>
                      </div>
                      <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                        Producto TN: <code>#{rule.giftProductId}</code> · Variante: <code>#{rule.giftVariantId}</code>
                        {" "}· ×{rule.giftQty}
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "0.5rem", flexShrink: 0 }}>
                      <button
                        onClick={() => toggleEnabled(rule)}
                        style={btnToggle(rule.enabled)}
                        title={rule.enabled ? "Desactivar" : "Activar"}
                      >
                        {rule.enabled ? "ON" : "OFF"}
                      </button>
                      <button
                        onClick={() => handleDelete(rule.id)}
                        style={btnDanger}
                        title="Eliminar"
                      >
                        ✕
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* How it works */}
      <div style={{ ...cardStyle, marginTop: "1rem" }}>
        <h2 style={{ marginBottom: "0.75rem" }}>¿Cómo funciona?</h2>
        <ol style={{ paddingLeft: "1.25rem", lineHeight: 2, fontSize: "0.875rem", color: "var(--text-muted)" }}>
          <li>El cliente navega la tienda y agrega productos al carrito.</li>
          <li>En cada cambio de carrito, <code>hache-suite.js</code> llama a <code>/api/storefront/cart-gifts</code> con el total actual.</li>
          <li>Si el total supera el mínimo configurado, el JS agrega el producto regalo vía la Cart API de Tiendanube.</li>
          <li>El regalo se marca en <code>localStorage</code> para no duplicarlo en la misma sesión.</li>
          <li>Si el cliente reduce el carrito por debajo del mínimo, el regalo se elimina automáticamente.</li>
        </ol>
        <div style={{ marginTop: "0.75rem", padding: "0.75rem", background: "var(--surface2)", borderRadius: "var(--radius-sm)", fontSize: "0.8rem" }}>
          <strong>⚠️ Importante:</strong> El producto regalo debe existir en tu tienda con precio $0 (o con el precio que quieras cobrar). 
          Necesitás su <strong>Product ID</strong> y <strong>Variant ID</strong> desde el admin de Tiendanube.
        </div>
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
  transition: "opacity var(--transition)",
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

function ruleCardStyle(enabled: boolean): React.CSSProperties {
  return {
    padding: "0.9rem 1rem",
    background: "var(--surface2)",
    borderRadius: "var(--radius-sm)",
    border: `1px solid ${enabled ? "rgba(124,92,252,0.2)" : "var(--border)"}`,
    opacity: enabled ? 1 : 0.6,
    transition: "all var(--transition)",
  };
}

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
