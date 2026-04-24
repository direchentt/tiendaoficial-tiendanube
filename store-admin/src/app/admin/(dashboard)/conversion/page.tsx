"use client";

import { adminFetch } from "@/lib/admin-fetch";
import { formatAdminApiError } from "@/lib/format-admin-api-error";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";

type StatsResponse = {
  days: number;
  since: string;
  storeTiendanubeUserId?: string;
  counts: Record<string, number>;
  funnel: {
    productViews: number;
    addToCart: number;
    pdpViewToAddCartPct: number | null;
    homeViews: number;
    categoryViews: number;
    bundleViews: number;
  } | null;
  hint?: string;
};

const LABELS: Record<string, string> = {
  home_view: "Vistas inicio",
  category_view: "Vistas categoría",
  product_view: "Vistas PDP",
  add_to_cart: "Agregar al carrito",
  bundle_view: "Vistas página combos",
};

export default function ConversionDashboardPage() {
  const [days, setDays] = useState(30);
  const [data, setData] = useState<StatsResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const r = await adminFetch(`/api/admin/conversion-stats?days=${days}`);
      const j = (await r.json().catch(() => null)) as StatsResponse | null;
      if (!r.ok) {
        setError(formatAdminApiError(j, r.status));
        setData(null);
      } else {
        setData(j);
      }
    } catch (e) {
      setError(String(e));
      setData(null);
    } finally {
      setLoading(false);
    }
  }, [days]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div>
      <p style={{ marginBottom: "1rem" }}>
        <Link href="/admin" style={{ fontSize: "0.9rem" }}>
          &larr; Inicio
        </Link>
      </p>
      <h1 style={{ marginBottom: "0.35rem" }}>Conversión (CVR)</h1>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "42rem", marginBottom: "1.25rem" }}>
        Embudo mínimo alimentado por <code>hache-suite.js</code>: vistas de inicio, categoría, PDP, página de combos y
        clics que agregan al carrito. Los datos son orientativos (sesión / duplicados no deduplicados en servidor salvo
        dedupe en cliente en PDP).
      </p>

      <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", marginBottom: "1.25rem", flexWrap: "wrap" }}>
        <span style={{ fontSize: "0.85rem", color: "var(--text-muted)" }}>Período:</span>
        {[7, 30, 90].map((d) => (
          <button
            key={d}
            type="button"
            onClick={() => setDays(d)}
            style={{
              padding: "0.35rem 0.75rem",
              borderRadius: 8,
              border: `1px solid ${days === d ? "var(--accent)" : "var(--border)"}`,
              background: days === d ? "rgba(124,92,252,0.15)" : "var(--surface2)",
              color: days === d ? "var(--accent2)" : "var(--text-muted)",
              cursor: "pointer",
              fontSize: "0.8rem",
              fontWeight: days === d ? 600 : 400,
            }}
          >
            {d} días
          </button>
        ))}
        <button
          type="button"
          onClick={() => void load()}
          disabled={loading}
          style={{
            padding: "0.35rem 0.75rem",
            borderRadius: 8,
            border: "1px solid var(--border)",
            background: "var(--surface2)",
            cursor: loading ? "wait" : "pointer",
            fontSize: "0.8rem",
          }}
        >
          Actualizar
        </button>
      </div>

      {error ? (
        <pre
          style={{
            padding: "0.75rem",
            background: "rgba(239,68,68,0.1)",
            borderRadius: 8,
            fontSize: "0.8rem",
            color: "var(--danger)",
            overflow: "auto",
          }}
        >
          {error}
        </pre>
      ) : null}

      {loading && !data ? (
        <p style={{ color: "var(--text-muted)" }}>Cargando…</p>
      ) : data ? (
        <>
          {data.hint ? (
            <p style={{ color: "#d97706", fontSize: "0.85rem", marginBottom: "1rem" }}>{data.hint}</p>
          ) : null}
          <p style={{ fontSize: "0.78rem", color: "var(--text-muted)", marginBottom: "1rem" }}>
            Desde {new Date(data.since).toLocaleString()} · tienda env <code>{data.storeTiendanubeUserId ?? "—"}</code>
          </p>

          {data.funnel && (
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fill, minmax(11rem, 1fr))",
                gap: "0.75rem",
                marginBottom: "1.5rem",
              }}
            >
              <MetricCard title="Vistas PDP" value={data.funnel.productViews} />
              <MetricCard title="Add to cart" value={data.funnel.addToCart} />
              <MetricCard
                title="CVR PDP → carrito"
                value={data.funnel.pdpViewToAddCartPct == null ? "—" : `${data.funnel.pdpViewToAddCartPct}%`}
                highlight
              />
              <MetricCard title="Vistas inicio" value={data.funnel.homeViews} />
              <MetricCard title="Vistas categoría" value={data.funnel.categoryViews} />
              <MetricCard title="Vistas combos" value={data.funnel.bundleViews} />
            </div>
          )}

          <h2 style={{ fontSize: "1rem", marginBottom: "0.65rem" }}>Detalle por tipo</h2>
          <table style={{ width: "100%", maxWidth: "28rem", borderCollapse: "collapse", fontSize: "0.85rem" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid var(--border)", textAlign: "left" }}>
                <th style={{ padding: "0.5rem 0" }}>Evento</th>
                <th style={{ padding: "0.5rem 0", textAlign: "right" }}>Cantidad</th>
              </tr>
            </thead>
            <tbody>
              {Object.entries(data.counts)
                .sort((a, b) => b[1] - a[1])
                .map(([type, n]) => (
                  <tr key={type} style={{ borderBottom: "1px solid var(--border)" }}>
                    <td style={{ padding: "0.45rem 0" }}>{LABELS[type] ?? type}</td>
                    <td style={{ padding: "0.45rem 0", textAlign: "right", fontVariantNumeric: "tabular-nums" }}>{n}</td>
                  </tr>
                ))}
              {Object.keys(data.counts).length === 0 ? (
                <tr>
                  <td colSpan={2} style={{ padding: "0.75rem 0", color: "var(--text-muted)" }}>
                    Sin eventos en este período. Verificá que el tema cargue <code>hache-suite.js</code> y que haya
                    tráfico.
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </>
      ) : null}
    </div>
  );
}

function MetricCard({
  title,
  value,
  highlight,
}: {
  title: string;
  value: string | number;
  highlight?: boolean;
}) {
  return (
    <div
      style={{
        padding: "0.9rem 1rem",
        borderRadius: "var(--radius-sm)",
        border: `1px solid ${highlight ? "rgba(124,92,252,0.35)" : "var(--border)"}`,
        background: highlight ? "rgba(124,92,252,0.08)" : "var(--surface2)",
      }}
    >
      <div style={{ fontSize: "0.72rem", color: "var(--text-muted)", marginBottom: "0.35rem" }}>{title}</div>
      <div style={{ fontSize: "1.35rem", fontWeight: 700, fontVariantNumeric: "tabular-nums" }}>{value}</div>
    </div>
  );
}
