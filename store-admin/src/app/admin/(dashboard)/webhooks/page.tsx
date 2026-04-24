"use client";

import { adminFetch } from "@/lib/admin-fetch";
import { formatAdminApiError } from "@/lib/format-admin-api-error";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";

type Row = {
  id: string;
  topic: string;
  tiendanubeUserId: string | null;
  createdAt: string;
  processedAt: string | null;
  processError: string | null;
  payloadPreview: string;
  payloadLength: number;
};

export default function WebhooksPage() {
  const [base, setBase] = useState("");
  const [items, setItems] = useState<Row[]>([]);
  const [total, setTotal] = useState(0);
  const [offset, setOffset] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [reprocessBusy, setReprocessBusy] = useState(false);
  const limit = 30;

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const r = await adminFetch(`/api/admin/webhook-events?limit=${limit}&offset=${offset}`);
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

  useEffect(() => {
    setBase(typeof window !== "undefined" ? window.location.origin.replace(/\/$/, "") : "");
  }, []);

  const reprocessPending = useCallback(async () => {
    setReprocessBusy(true);
    setError(null);
    try {
      const r = await adminFetch("/api/admin/webhook-reprocess", {
        method: "POST",
        body: JSON.stringify({ limit: 50 }),
      });
      const j = await r.json().catch(() => null);
      if (!r.ok) {
        setError(formatAdminApiError(j, r.status));
        return;
      }
      await load();
    } catch (e) {
      setError(String(e));
    } finally {
      setReprocessBusy(false);
    }
  }, [load]);

  return (
    <div>
      <p style={{ marginBottom: "1rem" }}>
        <Link href="/admin" style={{ fontSize: "0.9rem" }}>
          &larr; Inicio
        </Link>
      </p>
      <h1 style={{ marginBottom: "0.35rem" }}>Webhooks recibidos</h1>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "46rem", marginBottom: "1.25rem" }}>
        Registrá en Tiendanube / Nuvemshop (u otras integraciones) una URL que apunte a tu backend. Cada POST
        autenticado se guarda para diagnóstico y futuras automatizaciones. Es independiente del webhook de{" "}
        <strong>Business Rules</strong> (<code>/api/tn/payments-before-filter</code>).
      </p>

      <div
        style={{
          padding: "1rem",
          background: "var(--surface2)",
          borderRadius: "var(--radius-sm)",
          border: "1px solid var(--border)",
          marginBottom: "1.5rem",
        }}
      >
        <h2 style={{ fontSize: "0.95rem", marginBottom: "0.5rem" }}>URL de ingesta</h2>
        <pre style={{ margin: 0, fontSize: "0.78rem", wordBreak: "break-all" }}>
          {base ? `${base}/api/tn/events` : "…/api/tn/events"}
        </pre>
        <p style={{ fontSize: "0.78rem", color: "var(--text-muted)", marginTop: "0.65rem", marginBottom: 0 }}>
          <strong>Webhooks creados por API (Tiendanube):</strong> envían <code>x-linkedstore-hmac-sha256</code>; en
          Railway configurá <code>TN_WEBHOOK_APP_SECRET</code> con el secreto de la app (mismo que usa la doc oficial
          para verificar el HMAC). <strong>Integración custom:</strong>{" "}
          <code>x-hache-webhook-secret</code> o <code>x-tn-webhook-secret</code> = <code>TN_WEBHOOK_SECRET</code>. El
          topic puede venir en <code>x-tn-event</code> / <code>x-event-name</code> o en el JSON como{" "}
          <code>event</code>. <code>store_id</code> en el cuerpo se indexa por tienda.
        </p>
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", marginBottom: "1rem", flexWrap: "wrap" }}>
        <span style={{ fontSize: "0.85rem", color: "var(--text-muted)" }}>
          {total} evento{total !== 1 ? "s" : ""}
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
          onClick={() => void reprocessPending()}
          disabled={loading || reprocessBusy}
          title="Ejecuta de nuevo los handlers para eventos sin fecha de procesado (máx. 50 más viejos primero)"
          style={{
            padding: "0.35rem 0.75rem",
            borderRadius: 8,
            border: "1px solid var(--border)",
            background: "var(--surface2)",
            cursor: loading || reprocessBusy ? "wait" : "pointer",
            fontSize: "0.8rem",
          }}
        >
          {reprocessBusy ? "Procesando…" : "Procesar pendientes"}
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
        <p style={{ color: "var(--text-muted)", fontSize: "0.875rem" }}>Todavía no hay eventos registrados.</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "flex", flexDirection: "column", gap: "0.75rem" }}>
          {items.map((row) => (
            <li
              key={row.id}
              style={{
                border: "1px solid var(--border)",
                borderRadius: "var(--radius-sm)",
                padding: "0.75rem 1rem",
                background: "var(--surface)",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", gap: "0.5rem", flexWrap: "wrap" }}>
                <strong style={{ fontSize: "0.85rem" }}>{row.topic}</strong>
                <span style={{ fontSize: "0.72rem", color: "var(--text-muted)" }}>
                  {new Date(row.createdAt).toLocaleString()}
                </span>
              </div>
              {row.tiendanubeUserId ? (
                <div style={{ fontSize: "0.72rem", color: "var(--text-muted)", marginTop: "0.25rem" }}>
                  store_id: <code>{row.tiendanubeUserId}</code>
                </div>
              ) : null}
              <div style={{ fontSize: "0.72rem", color: "var(--text-muted)", marginTop: "0.25rem" }}>
                Procesado:{" "}
                {row.processedAt ? (
                  <>
                    <time dateTime={row.processedAt}>{new Date(row.processedAt).toLocaleString()}</time>
                    {row.processError ? (
                      <span style={{ color: "var(--danger, #b91c1c)", marginLeft: "0.35rem" }}>
                        (error: {row.processError})
                      </span>
                    ) : null}
                  </>
                ) : (
                  <span>pendiente…</span>
                )}
              </div>
              <pre
                style={{
                  margin: "0.5rem 0 0",
                  fontSize: "0.72rem",
                  maxHeight: "8rem",
                  overflow: "auto",
                  background: "var(--surface2)",
                  padding: "0.5rem",
                  borderRadius: 6,
                  whiteSpace: "pre-wrap",
                  wordBreak: "break-word",
                }}
              >
                {row.payloadPreview}
                {row.payloadLength > row.payloadPreview.length ? "…" : ""}
              </pre>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
