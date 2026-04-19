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
    const key = getKey().trim();
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
      if (res.status === 401) {
        sessionStorage.removeItem("hs_admin_key");
        window.location.href = "/admin/login";
      }
      return res;
    });
  }

  return { adminFetch };
}
