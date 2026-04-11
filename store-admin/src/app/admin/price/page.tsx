"use client";

import Link from "next/link";
import { useState } from "react";

export default function PriceToolPage() {
  const [percent, setPercent] = useState("0");
  const [dryRun, setDryRun] = useState(true);
  const [maxPages, setMaxPages] = useState("50");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function run() {
    setLoading(true);
    setResult(null);
    setError(null);
    try {
      const res = await fetch("/api/admin/apply-price-percent", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          percent: parseFloat(percent.replace(",", ".")),
          dryRun,
          maxPages: parseInt(maxPages, 10) || 50,
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(JSON.stringify(data, null, 2));
      } else {
        setResult(JSON.stringify(data, null, 2));
      }
    } catch (e) {
      setError(String(e));
    } finally {
      setLoading(false);
    }
  }

  return (
    <main>
      <p>
        <Link href="/admin" style={{ fontSize: "0.9rem" }}>
          &larr; Inicio
        </Link>
      </p>
      <h1 style={{ fontSize: "1.25rem" }}>Ajuste de precios por %</h1>
      <p style={{ color: "#555", fontSize: "0.9rem", maxWidth: "40rem" }}>
        Usa <code>PATCH /products/stock-price</code> (hasta 50 variantes por request). Probar primero con simulacion.
      </p>
      <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem", maxWidth: "22rem" }}>
        <label>
          <span style={{ display: "block", fontSize: "0.8rem" }}>Porcentaje (ej. 10 o -5)</span>
          <input
            value={percent}
            onChange={(e) => setPercent(e.target.value)}
            style={inp}
          />
        </label>
        <label style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
          <input type="checkbox" checked={dryRun} onChange={(e) => setDryRun(e.target.checked)} />
          Simulacion (dryRun)
        </label>
        <label>
          <span style={{ display: "block", fontSize: "0.8rem" }}>Max paginas de productos</span>
          <input
            value={maxPages}
            onChange={(e) => setMaxPages(e.target.value)}
            type="number"
            min={1}
            max={500}
            style={inp}
          />
        </label>
        <button type="button" onClick={run} disabled={loading} style={btn}>
          {loading ? "Procesando..." : "Ejecutar"}
        </button>
      </div>
      {error ? (
        <pre
          style={{
            marginTop: "1rem",
            padding: "0.75rem",
            background: "#fff0f0",
            fontSize: "0.8rem",
            overflow: "auto",
          }}
        >
          {error}
        </pre>
      ) : null}
      {result ? (
        <pre
          style={{
            marginTop: "1rem",
            padding: "0.75rem",
            background: "#f6f6f6",
            fontSize: "0.8rem",
            overflow: "auto",
          }}
        >
          {result}
        </pre>
      ) : null}
    </main>
  );
}

const inp: React.CSSProperties = {
  width: "100%",
  padding: "0.45rem 0.55rem",
  borderRadius: "6px",
  border: "1px solid #ccc",
  boxSizing: "border-box",
};

const btn: React.CSSProperties = {
  padding: "0.5rem 1rem",
  background: "#111",
  color: "#fff",
  border: "none",
  borderRadius: "6px",
  cursor: "pointer",
  fontWeight: 600,
};
