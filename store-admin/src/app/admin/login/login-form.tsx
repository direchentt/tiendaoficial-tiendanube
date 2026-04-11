"use client";

import { useFormState, useFormStatus } from "react-dom";
import { loginAction, type LoginState } from "./actions";

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending} style={btnPrimary}>
      {pending ? "Entrando..." : "Entrar"}
    </button>
  );
}

const initial: LoginState = {};

export function AdminLoginForm() {
  const [state, formAction] = useFormState(loginAction, initial);

  return (
    <main style={{ maxWidth: "22rem" }}>
      <h1 style={{ fontSize: "1.25rem" }}>Panel de reglas</h1>
      <p style={{ color: "#555", fontSize: "0.9rem" }}>
        Usa el mismo valor que <code>ADMIN_SECRET</code> en <code>.env</code>.
      </p>
      <form action={formAction} style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
        <label>
          <span style={{ display: "block", fontSize: "0.8rem", marginBottom: "0.25rem" }}>
            Clave de administrador
          </span>
          <input
            type="password"
            name="secret"
            required
            autoComplete="current-password"
            style={inputStyle}
          />
        </label>
        {state?.error ? (
          <p role="alert" style={{ color: "#b00020", fontSize: "0.875rem", margin: 0 }}>
            {state.error}
          </p>
        ) : null}
        <SubmitButton />
      </form>
    </main>
  );
}

const inputStyle: React.CSSProperties = {
  width: "100%",
  padding: "0.5rem 0.65rem",
  fontSize: "1rem",
  border: "1px solid #ccc",
  borderRadius: "6px",
};

const btnPrimary: React.CSSProperties = {
  padding: "0.55rem 1rem",
  fontWeight: 600,
  border: "none",
  borderRadius: "6px",
  background: "#111",
  color: "#fff",
  cursor: "pointer",
};
