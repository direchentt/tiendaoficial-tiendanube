"use client";

import { useState } from "react";

export function AdminLoginForm() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const secret = (
      (e.currentTarget.elements.namedItem("secret") as HTMLInputElement).value
    ).trim();

    try {
      // Verificamos contra el API sin guardar cookie
      const res = await fetch("/api/admin/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ secret }),
      });

      if (res.ok) {
        // Guardamos el secret en sessionStorage — se manda como header en cada request
        sessionStorage.setItem("hs_admin_key", secret);
        window.location.href = "/admin";
      } else {
        setError("Clave incorrecta. Verificá ADMIN_SECRET en Railway.");
      }
    } catch {
      setError("Error de red. Intentá de nuevo.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={wrapperStyle}>
      <div style={{ textAlign: "center", marginBottom: "2rem" }}>
        <div style={logoStyle}>⬡</div>
        <h1 style={{ fontSize: "1.5rem", fontWeight: 700, letterSpacing: "-0.02em", marginBottom: "0.35rem" }}>
          Hache Suite
        </h1>
        <p style={{ color: "var(--text-muted)", fontSize: "0.85rem" }}>
          Business Rules Panel
        </p>
      </div>

      <div style={cardStyle}>
        <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "1.25rem" }}>
          <div>
            <label style={{ marginBottom: "0.45rem" }}>Contraseña de administrador</label>
            <input
              type="password"
              name="secret"
              required
              autoComplete="current-password"
              placeholder="••••••••"
              autoFocus
            />
          </div>
          {error && <div style={errorStyle}>✕ {error}</div>}
          <button type="submit" disabled={loading} style={btnPrimary}>
            {loading ? "Verificando..." : "Ingresar al panel →"}
          </button>
        </form>
      </div>

      <p style={{ textAlign: "center", fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "1.5rem" }}>
        Usá el valor de <code>ADMIN_SECRET</code> configurado en Railway.
      </p>
    </div>
  );
}

const wrapperStyle: React.CSSProperties = {
  minHeight: "100vh", display: "flex", flexDirection: "column",
  alignItems: "center", justifyContent: "center", padding: "1.5rem", background: "var(--bg)",
};
const logoStyle: React.CSSProperties = {
  fontSize: "3rem", background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", lineHeight: 1, marginBottom: "0.75rem",
};
const cardStyle: React.CSSProperties = {
  background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--radius)",
  padding: "2rem", width: "100%", maxWidth: "380px", boxShadow: "0 8px 40px rgba(0,0,0,0.4)",
};
const btnPrimary: React.CSSProperties = {
  width: "100%", padding: "0.75rem",
  background: "linear-gradient(135deg, var(--accent), var(--accent2))",
  color: "#fff", border: "none", borderRadius: "var(--radius-sm)",
  cursor: "pointer", fontWeight: 600, fontSize: "0.9rem", fontFamily: "inherit",
};
const errorStyle: React.CSSProperties = {
  padding: "0.65rem 0.9rem", background: "rgba(239,68,68,0.1)",
  border: "1px solid rgba(239,68,68,0.3)", color: "var(--danger)",
  borderRadius: "var(--radius-sm)", fontSize: "0.875rem",
};
