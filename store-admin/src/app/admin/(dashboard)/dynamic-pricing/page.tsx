"use client";
import { adminFetch } from "@/lib/admin-fetch";
import { formatAdminApiError } from "@/lib/format-admin-api-error";

import { useEffect, useState } from "react";

type DPConfig = {
  enabled: boolean;
  algorithm: "seeded_random" | "demand_based" | "progressive";
  minPct: number;
  maxPct: number;
  cacheTtlHours: number;
  excludedCategoryIds: number[];
  commitOnAddToCart: boolean;
};

const ALGORITHMS = [
  {
    id: "seeded_random" as const,
    label: "Aleatorio Estable",
    icon: "🎲",
    desc: "El descuento es pseudo-aleatorio pero estable: el mismo producto muestra el mismo precio todo el día. Cambia cada 24h.",
  },
  {
    id: "demand_based" as const,
    label: "Basado en Demanda",
    icon: "⏰",
    desc: "El descuento varía según la hora del día: mayor descuento de madrugada (4–6 AM), menor al mediodía. Crea urgencia natural.",
  },
  {
    id: "progressive" as const,
    label: "Progresivo por Visitas",
    icon: "📈",
    desc: "El descuento aumenta con cada visita del usuario (guardado en localStorage). A más visitas, mejor precio hasta el máximo.",
  },
];

export default function DynamicPricingPage() {
  const [config, setConfig] = useState<DPConfig>({
    enabled: false,
    algorithm: "seeded_random",
    minPct: 5,
    maxPct: 20,
    cacheTtlHours: 4,
    excludedCategoryIds: [],
    commitOnAddToCart: false,
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savedOk, setSavedOk] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [excludeInput, setExcludeInput] = useState("");

  useEffect(() => {
    let cancelled = false;
    adminFetch("/api/admin/dynamic-pricing")
      .then(async (r) => {
        const data = await r.json().catch(() => null);
        if (cancelled) return;
        if (!r.ok) {
          setLoadError(formatAdminApiError(data, r.status));
          return;
        }
        if (data && typeof data.enabled === "boolean") {
          setLoadError(null);
          setConfig({
            ...data,
            commitOnAddToCart: Boolean(data.commitOnAddToCart),
          });
          setExcludeInput((data.excludedCategoryIds ?? []).join(", "));
        }
      })
      .catch(() => {
        if (!cancelled) setLoadError("No se pudo conectar con el servidor.");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setSavedOk(false);
    setError(null);
    try {
      const excludedCategoryIds = excludeInput
        .split(",")
        .map((s) => parseInt(s.trim()))
        .filter((n) => !Number.isNaN(n) && n > 0);

      const r = await adminFetch("/api/admin/dynamic-pricing", {
        method: "PUT",
        body: JSON.stringify({ ...config, excludedCategoryIds }),
      });
      if (!r.ok) {
        const err = await r.json().catch(() => null);
        setError(formatAdminApiError(err, r.status));
      } else {
        const saved = await r.json();
        setConfig(saved);
        setSavedOk(true);
        setTimeout(() => setSavedOk(false), 3000);
      }
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
    return <div style={{ color: "var(--text-muted)", padding: "2rem" }}>Cargando configuración...</div>;
  }

  const discountPreview = {
    min: (100 - config.maxPct).toFixed(1),
    max: (100 - config.minPct).toFixed(1),
  };

  return (
    <div>
      {loadError && (
        <div
          style={{
            padding: "1rem 1.25rem",
            marginBottom: "1.25rem",
            background: "rgba(239,68,68,0.1)",
            border: "1px solid rgba(239,68,68,0.35)",
            borderRadius: "var(--radius-sm)",
            color: "var(--danger)",
            fontSize: "0.9rem",
            lineHeight: 1.5,
          }}
        >
          <strong>No se cargó la configuración.</strong> {loadError}{" "}
          <a href="/admin/login" style={{ color: "var(--accent)", fontWeight: 600 }}>
            Ir al login
          </a>
        </div>
      )}
      {/* Header */}
      <div style={{ marginBottom: "1.75rem" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.35rem" }}>
          <span style={{ fontSize: "1.5rem" }}>💰</span>
          <h1>Precios Dinámicos</h1>
          <div style={enabledBadge(config.enabled)}>{config.enabled ? "ACTIVO" : "INACTIVO"}</div>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>
          Mostrá precios con descuento en el storefront según el algoritmo elegido. Los precios se cachean en{" "}
          <code>localStorage</code> para una experiencia fluida sin requests repetidas.
        </p>
        <div
          style={{
            marginTop: "1rem",
            padding: "0.9rem 1rem",
            fontSize: "0.82rem",
            lineHeight: 1.55,
            color: "var(--text)",
            background: "rgba(234,179,8,0.12)",
            border: "1px solid rgba(234,179,8,0.35)",
            borderRadius: "var(--radius-sm)",
          }}
        >
          <strong>Importante — checkout:</strong> este motor solo cambia lo que se ve en el tema (listado y ficha).
          Tiendanube cobra en el checkout el precio real del producto en el catálogo. Si necesitás que el cliente pague
          menos, usá promos / cupones nativos, o el endpoint{" "}
          <code style={{ fontSize: "0.78rem" }}>POST /api/admin/apply-price-percent</code> (API oficial{" "}
          <code>PATCH /products/stock-price</code>) para escribir precios reales en la tienda, con cuidado por stock y
          límites de la API.
        </div>
      </div>

      <form onSubmit={handleSave}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1.5rem" }}>
          {/* Config left */}
          <div style={{ display: "flex", flexDirection: "column", gap: "1.25rem" }}>
            {/* Master toggle */}
            <div style={cardStyle}>
              <h2 style={{ marginBottom: "1rem" }}>Estado del Motor</h2>
              <label
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.75rem",
                  cursor: "pointer",
                  padding: "0.9rem 1rem",
                  background: config.enabled ? "rgba(124,92,252,0.08)" : "var(--surface2)",
                  borderRadius: "var(--radius-sm)",
                  border: `1px solid ${config.enabled ? "rgba(124,92,252,0.3)" : "var(--border)"}`,
                  transition: "all var(--transition)",
                }}
              >
                <input
                  type="checkbox"
                  checked={config.enabled}
                  onChange={(e) => setConfig({ ...config, enabled: e.target.checked })}
                />
                <div>
                  <div style={{ fontWeight: 600, fontSize: "0.9rem" }}>
                    {config.enabled ? "Motor activo" : "Motor inactivo"}
                  </div>
                  <div style={{ fontSize: "0.78rem", color: "var(--text-muted)" }}>
                    {config.enabled
                      ? "Los precios dinámicos se están aplicando en el storefront."
                      : "Activá para empezar a mostrar precios con descuento."}
                  </div>
                </div>
              </label>
            </div>

            <div style={cardStyle}>
              <h2 style={{ marginBottom: "0.75rem" }}>Sincronizar con Tiendanube (opcional)</h2>
              <label
                style={{
                  display: "flex",
                  alignItems: "flex-start",
                  gap: "0.75rem",
                  cursor: "pointer",
                  fontSize: "0.88rem",
                  lineHeight: 1.45,
                }}
              >
                <input
                  type="checkbox"
                  checked={config.commitOnAddToCart}
                  onChange={(e) => setConfig({ ...config, commitOnAddToCart: e.target.checked })}
                />
                <span>
                  Antes de <strong>Agregar al carrito</strong>, escribir en Tiendanube el precio con el descuento
                  dinámico (API <code style={{ fontSize: "0.78rem" }}>PATCH /products/stock-price</code>). Así el
                  checkout coincide con lo que vio el cliente.{" "}
                  <strong style={{ color: "var(--danger)" }}>
                    Cambia el precio del catálogo para todos los visitantes
                  </strong>
                  ; conviene con algoritmo estable (p. ej. seeded por día) y token OAuth con{" "}
                  <code>write_products</code>. Listados con solo “compra rápida” y varias variantes pueden no disparar
                  bien el hook: probá en PDP o productos sin variantes.
                </span>
              </label>
            </div>

            {/* Range */}
            <div style={cardStyle}>
              <h2 style={{ marginBottom: "1rem" }}>Rango de Descuento</h2>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "0.75rem", marginBottom: "1rem" }}>
                <div>
                  <label>Descuento mínimo (%)</label>
                  <input
                    type="number"
                    min={0}
                    max={99}
                    step={0.5}
                    value={config.minPct}
                    onChange={(e) => setConfig({ ...config, minPct: parseFloat(e.target.value) })}
                  />
                </div>
                <div>
                  <label>Descuento máximo (%)</label>
                  <input
                    type="number"
                    min={0}
                    max={99}
                    step={0.5}
                    value={config.maxPct}
                    onChange={(e) => setConfig({ ...config, maxPct: parseFloat(e.target.value) })}
                  />
                </div>
              </div>
              <div style={previewBannerStyle}>
                <span>Vista previa:</span>
                <span>
                  Un producto de <strong>$100.000</strong> mostraría entre{" "}
                  <strong style={{ color: "var(--success)" }}>${(100000 * (1 - config.maxPct / 100)).toLocaleString()}</strong>
                  {" "}y{" "}
                  <strong style={{ color: "var(--accent2)" }}>${(100000 * (1 - config.minPct / 100)).toLocaleString()}</strong>
                </span>
              </div>
              <div>
                <label>Cache en localStorage (horas)</label>
                <input
                  type="number"
                  min={1}
                  max={168}
                  value={config.cacheTtlHours}
                  onChange={(e) => setConfig({ ...config, cacheTtlHours: parseInt(e.target.value) })}
                />
                <p style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "0.4rem" }}>
                  Los precios calculados se guardan {config.cacheTtlHours}h en localStorage antes de recalcular.
                </p>
              </div>
              <div style={{ marginTop: "0.75rem" }}>
                <label>IDs de productos excluidos (Tiendanube, separados por coma)</label>
                <input
                  value={excludeInput}
                  onChange={(e) => setExcludeInput(e.target.value)}
                  placeholder="1234, 5678, 9012"
                />
                <p style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "0.4rem" }}>
                  Esos IDs de producto no reciben descuento dinámico en el listado (el resto del catálogo en Tiendanube no
                  cambia).
                </p>
              </div>
            </div>
          </div>

          {/* Algorithm selector */}
          <div style={cardStyle}>
            <h2 style={{ marginBottom: "1rem" }}>Algoritmo de Descuento</h2>
            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
              {ALGORITHMS.map((alg) => {
                const isSelected = config.algorithm === alg.id;
                return (
                  <label
                    key={alg.id}
                    style={{
                      display: "flex",
                      alignItems: "flex-start",
                      gap: "0.75rem",
                      padding: "1rem",
                      background: isSelected ? "rgba(124,92,252,0.1)" : "var(--surface2)",
                      border: `1px solid ${isSelected ? "var(--accent)" : "var(--border)"}`,
                      borderRadius: "var(--radius-sm)",
                      cursor: "pointer",
                      transition: "all var(--transition)",
                    }}
                  >
                    <input
                      type="radio"
                      name="algorithm"
                      value={alg.id}
                      checked={isSelected}
                      onChange={() => setConfig({ ...config, algorithm: alg.id })}
                      style={{ marginTop: "2px" }}
                    />
                    <div>
                      <div style={{ fontWeight: 600, fontSize: "0.9rem", marginBottom: "0.3rem" }}>
                        {alg.icon} {alg.label}
                      </div>
                      <div style={{ fontSize: "0.78rem", color: "var(--text-muted)", lineHeight: 1.5 }}>
                        {alg.desc}
                      </div>
                    </div>
                  </label>
                );
              })}
            </div>

            {/* Storefront note */}
            <div style={{ ...infoBox, marginTop: "1rem" }}>
              <strong>📍 Solo Visual:</strong> Los precios dinámicos se muestran en el storefront pero el precio en
              Tiendanube no cambia. El cliente paga el precio original al hacer checkout.
              Para descuentos reales usá el módulo de <strong>Precios Masivos</strong>.
            </div>
          </div>
        </div>

        {/* Save */}
        <div style={{ display: "flex", alignItems: "center", gap: "1rem", marginTop: "1.5rem" }}>
          <button type="submit" disabled={saving} style={btnPrimary}>
            {saving ? "Guardando..." : "💾 Guardar Configuración"}
          </button>
          {savedOk && (
            <span style={{ color: "var(--success)", fontSize: "0.875rem", fontWeight: 500 }}>
              ✓ Configuración guardada
            </span>
          )}
          {error && (
            <span style={{ color: "var(--danger)", fontSize: "0.875rem" }}>{error}</span>
          )}
        </div>
      </form>
    </div>
  );
}

function enabledBadge(enabled: boolean): React.CSSProperties {
  return {
    fontSize: "0.65rem",
    fontWeight: 700,
    padding: "0.2rem 0.55rem",
    borderRadius: "99px",
    letterSpacing: "0.08em",
    background: enabled ? "rgba(34,197,94,0.15)" : "rgba(107,114,128,0.15)",
    color: enabled ? "var(--success)" : "var(--text-muted)",
    border: `1px solid ${enabled ? "rgba(34,197,94,0.3)" : "var(--border)"}`,
    marginLeft: "0.5rem",
  };
}

const cardStyle: React.CSSProperties = {
  background: "var(--surface)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius)",
  padding: "1.5rem",
};

const btnPrimary: React.CSSProperties = {
  padding: "0.7rem 1.5rem",
  background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  color: "#fff",
  border: "none",
  borderRadius: "var(--radius-sm)",
  cursor: "pointer",
  fontWeight: 600,
  fontSize: "0.9rem",
};

const previewBannerStyle: React.CSSProperties = {
  padding: "0.65rem 1rem",
  background: "var(--surface2)",
  borderRadius: "var(--radius-sm)",
  fontSize: "0.8rem",
  color: "var(--text-muted)",
  display: "flex",
  flexDirection: "column",
  gap: "0.25rem",
  marginBottom: "1rem",
};

const infoBox: React.CSSProperties = {
  padding: "0.75rem 1rem",
  background: "rgba(245,158,11,0.08)",
  border: "1px solid rgba(245,158,11,0.25)",
  borderRadius: "var(--radius-sm)",
  fontSize: "0.8rem",
  color: "var(--text-muted)",
  lineHeight: 1.5,
};
