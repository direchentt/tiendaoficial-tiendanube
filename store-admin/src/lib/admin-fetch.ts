/**
 * Función de fetch para el admin panel que inyecta x-admin-secret desde sessionStorage.
 * Funciona en funciones async (fuera de hooks de React).
 */
export function adminFetch(url: string, init: RequestInit = {}): Promise<Response> {
  const key = typeof window !== "undefined"
    ? (sessionStorage.getItem("hs_admin_key") ?? "")
    : "";

  if (!key && typeof window !== "undefined") {
    window.location.href = "/admin/login";
    return Promise.reject(new Error("No admin session"));
  }

  const headers: Record<string, string> = {
    "x-admin-secret": key,
    ...(init.headers as Record<string, string> ?? {}),
  };

  // Agregar Content-Type si hay body JSON
  if (init.body && typeof init.body === "string") {
    headers["Content-Type"] = "application/json";
  }

  return fetch(url, { ...init, headers }).then((res) => {
    if (res.status === 401) {
      sessionStorage.removeItem("hs_admin_key");
      window.location.href = "/admin/login";
    }
    return res;
  });
}
