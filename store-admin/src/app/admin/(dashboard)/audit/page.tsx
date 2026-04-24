"use client";

import { adminFetch } from "@/lib/admin-fetch";
import { formatAdminApiError } from "@/lib/format-admin-api-error";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";

type Row = {
  id: string;
  action: string;
  entityType: string | null;
  entityId: string | null;
  summary: string;
  meta: string | null;
  createdAt: string;
};

export default function AuditLogPage() {
  const [items, setItems] = useState<Row[]>([]);
  const [total, setTotal] = useState(0);
  const [offset, setOffset] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const limit = 50;

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const r = await adminFetch(`/api/admin/audit-log?limit=${limit}&offset=${offset}`);
      const j = await r.json().catch(() => null);
      if (!r.ok) {
        setError(formatAdminApiError(j, r.status));
        setItems([]);
      } else {
        setItems(Array.isArray(j.items) ? j.items : []);
        setTotal(typeof j.total === "number" ? j.total : 0);
      }
    } catch (e) {
      setError(String(e));
    } finally {
      setLoading(false);
    }
  }, [offset]);

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
      <h1 style={{ marginBottom: "0.35rem" }}>Auditoría</h1>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "44rem", marginBottom: "1.25rem" }}>
        Registro de cambios en reglas de pago, precios dinámicos, regalos en carrito y combos (tienda por defecto /{" "}
        <code>TN_STORE_USER_ID</code>).
      </p>

      <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", marginBottom: "1rem", flexWrap: "wrap" }}>
        <span style={{ fontSize: "0.85rem", color: "var(--text-muted)" }}>
          {total} registro{total !== 1 ? "s" : ""}
        </span>
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
        <button
          type="button"
          disabled={offset === 0 || loading}
          onClick={() => setOffset((o) => Math.max(0, o - limit))}
          style={{
            padding: "0.35rem 0.75rem",
            borderRadius: 8,
            border: "1px solid var(--border)",
            background: "var(--surface2)",
            fontSize: "0.8rem",
            cursor: offset === 0 ? "not-allowed" : "pointer",
          }}
        >
          Anterior
        </button>
        <button
          type="button"
          disabled={offset + limit >= total || loading}
          onClick={() => setOffset((o) => o + limit)}
          style={{
            padding: "0.35rem 0.75rem",
            borderRadius: 8,
            border: "1px solid var(--border)",
            background: "var(--surface2)",
            fontSize: "0.8rem",
            cursor: offset + limit >= total ? "not-allowed" : "pointer",
          }}
        >
          Siguiente
        </button>
      </div>

      {error ? (
        <pre style={{ padding: "0.75rem", background: "rgba(239,68,68,0.1)", borderRadius: 8, fontSize: "0.8rem" }}>
          {error}
        </pre>
      ) : null}

      {loading && items.length === 0 ? (
        <p style={{ color: "var(--text-muted)" }}>Cargando…</p>
      ) : items.length === 0 ? (
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Sin registros todavía.</p>
      ) : (
        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", minWidth: "520px", borderCollapse: "collapse", fontSize: "0.82rem" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid var(--border)", textAlign: "left" }}>
                <th style={{ padding: "0.5rem 0.35rem" }}>Cuándo</th>
                <th style={{ padding: "0.5rem 0.35rem" }}>Acción</th>
                <th style={{ padding: "0.5rem 0.35rem" }}>Resumen</th>
              </tr>
            </thead>
            <tbody>
              {items.map((row) => (
                <tr key={row.id} style={{ borderBottom: "1px solid var(--border)", verticalAlign: "top" }}>
                  <td style={{ padding: "0.5rem 0.35rem", whiteSpace: "nowrap", color: "var(--text-muted)" }}>
                    {new Date(row.createdAt).toLocaleString()}
                  </td>
                  <td style={{ padding: "0.5rem 0.35rem" }}>
                    <code style={{ fontSize: "0.75rem" }}>{row.action}</code>
                    {row.entityId ? (
                      <div style={{ fontSize: "0.7rem", color: "var(--text-muted)" }}>
                        {row.entityType ?? "entidad"} · {row.entityId}
                      </div>
                    ) : null}
                  </td>
                  <td style={{ padding: "0.5rem 0.35rem" }}>
                    {row.summary}
                    {row.meta ? (
                      <details style={{ marginTop: "0.35rem" }}>
                        <summary style={{ cursor: "pointer", fontSize: "0.72rem" }}>Meta JSON</summary>
                        <pre
                          style={{
                            margin: "0.35rem 0 0",
                            fontSize: "0.68rem",
                            maxHeight: "10rem",
                            overflow: "auto",
                            background: "var(--surface2)",
                            padding: "0.4rem",
                            borderRadius: 4,
                          }}
                        >
                          {row.meta}
                        </pre>
                      </details>
                    ) : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
