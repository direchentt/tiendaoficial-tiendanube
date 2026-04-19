/**
 * Función de fetch para el admin panel.
 * - Si hay clave en sessionStorage (post-login), se envía como x-admin-secret.
 * - Siempre se envían cookies (sesión httpOnly del POST /api/admin/login).
 * No redirigir antes del fetch: en una pestaña nueva sessionStorage puede estar vacío
 * pero la cookie sigue válida — antes eso dejaba "Cargando..." o rompía subrutas del panel.
 */
export function adminFetch(url: string, init: RequestInit = {}): Promise<Response> {
  const key =
    typeof window !== "undefined" ? (sessionStorage.getItem("hs_admin_key") ?? "").trim() : "";

  const headers: Record<string, string> = {
    ...(init.headers as Record<string, string> ?? {}),
  };

  if (key) {
    headers["x-admin-secret"] = key;
  }

  if (init.body && typeof init.body === "string" && !headers["Content-Type"] && !headers["content-type"]) {
    headers["Content-Type"] = "application/json";
  }

  return fetch(url, {
    ...init,
    credentials: "include",
    headers,
  }).then((res) => {
    if (res.status === 401 && typeof window !== "undefined") {
      sessionStorage.removeItem("hs_admin_key");
      window.location.href = "/admin/login";
    }
    return res;
  });
}
