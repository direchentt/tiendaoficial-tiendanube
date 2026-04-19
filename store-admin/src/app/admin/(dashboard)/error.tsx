"use client";

import { useEffect } from "react";

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("[HacheSuite]", error);
  }, [error]);

  const isMissingConfig =
    error.message?.includes("TN_STORE_USER_ID") ||
    error.message?.includes("TN_ACCESS_TOKEN") ||
    error.message?.includes("Configura");

  return (
    <div style={wrapperStyle}>
      <div style={iconStyle}>{isMissingConfig ? "⚙️" : "⚠️"}</div>
      <h2 style={{ fontSize: "1.1rem", fontWeight: 700, marginBottom: "0.5rem" }}>
        {isMissingConfig ? "Configuración incompleta" : "Error del servidor"}
      </h2>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", maxWidth: "420px", textAlign: "center", lineHeight: 1.6 }}>
        {isMissingConfig ? (
          <>
            Falta configurar las variables de entorno en Railway:{" "}
            <code>TN_STORE_USER_ID</code> y <code>TN_ACCESS_TOKEN</code>.
            <br />
            <br />
            Andá a <strong>Railway → tu servicio → Variables</strong> y agregalas.
          </>
        ) : (
          error.message || "Ocurrió un error inesperado."
        )}
      </p>

      {isMissingConfig && (
        <div style={stepBoxStyle}>
          <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginBottom: "0.75rem", fontWeight: 600 }}>
            Variables requeridas en Railway:
          </p>
          {[
            ["TN_STORE_USER_ID", "El ID numérico de tu tienda (ej: 1234567)"],
            ["TN_ACCESS_TOKEN", "El token OAuth de tu app en Tiendanube"],
            ["TN_USER_AGENT", "Ej: HacheSuite (tu@email.com)"],
            ["ADMIN_SECRET", "Contraseña del panel (cambiá el 5639 por algo seguro)"],
            ["DATABASE_URL", "URL de Supabase session pooler"],
          ].map(([name, desc]) => (
            <div key={name} style={{ marginBottom: "0.5rem" }}>
              <code style={{ fontSize: "0.8rem" }}>{name}</code>
              <span style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginLeft: "0.5rem" }}>
                — {desc}
              </span>
            </div>
          ))}
        </div>
      )}

      <div style={{ display: "flex", gap: "0.75rem", marginTop: "1.5rem" }}>
        <button onClick={reset} style={btnPrimary}>
          Reintentar
        </button>
        <a href="/admin" style={btnSecondary}>
          Volver al inicio
        </a>
      </div>
    </div>
  );
}

const wrapperStyle: React.CSSProperties = {
  display: "flex",
  flexDirection: "column",
  alignItems: "center",
  justifyContent: "center",
  minHeight: "calc(100vh - 4rem)",
  textAlign: "center",
  padding: "2rem",
};

const iconStyle: React.CSSProperties = {
  fontSize: "3rem",
  marginBottom: "1rem",
};

const stepBoxStyle: React.CSSProperties = {
  marginTop: "1.5rem",
  padding: "1.25rem 1.5rem",
  background: "var(--surface2)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius)",
  textAlign: "left",
  width: "100%",
  maxWidth: "480px",
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
  fontFamily: "inherit",
};

const btnSecondary: React.CSSProperties = {
  padding: "0.65rem 1.25rem",
  background: "var(--surface2)",
  color: "var(--text-muted)",
  border: "1px solid var(--border)",
  borderRadius: "var(--radius-sm)",
  cursor: "pointer",
  fontWeight: 500,
  fontSize: "0.875rem",
  textDecoration: "none",
};
