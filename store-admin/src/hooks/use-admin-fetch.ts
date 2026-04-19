/**
 * Hook que hace fetch a las APIs admin inyectando el header x-admin-secret
 * desde sessionStorage (guardado al hacer login).
 * 
 * Uso:
 *   const { adminFetch } = useAdminFetch();
 *   const r = await adminFetch("/api/admin/cart-gifts");
 */

export function useAdminFetch() {
  function getKey(): string {
    if (typeof window === "undefined") return "";
    return sessionStorage.getItem("hs_admin_key") ?? "";
  }

  function adminFetch(url: string, init: RequestInit = {}): Promise<Response> {
    const key = getKey();
    if (!key) {
      // No hay sesión — redirigir al login
      window.location.href = "/admin/login";
      return Promise.reject(new Error("No admin session"));
    }
    return fetch(url, {
      ...init,
      headers: {
        ...(init.headers ?? {}),
        "x-admin-secret": key,
        ...(init.body && !(init.body instanceof FormData)
          ? { "Content-Type": "application/json" }
          : {}),
      },
    }).then((res) => {
      if (res.status === 401) {
        // Sesión inválida — limpiar y redirigir
        sessionStorage.removeItem("hs_admin_key");
        window.location.href = "/admin/login";
      }
      return res;
    });
  }

  return { adminFetch };
}
