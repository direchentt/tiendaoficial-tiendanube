import type { Store } from "@prisma/client";
import { getCustomer, type TiendanubeClientConfig } from "@/lib/tiendanube-client";

function normalizeEmail(s: string): string {
  const t = s.trim().toLowerCase();
  try {
    return t.normalize("NFKC");
  } catch {
    return t;
  }
}

/** Config TN para esta fila Store (mismo token que el resto de integraciones). */
export function tnConfigFromStore(store: Store): TiendanubeClientConfig | null {
  const ua = process.env.TN_USER_AGENT?.trim();
  const token = store.accessToken?.trim();
  if (!ua || !token) return null;
  return {
    storeUserId: store.tiendanubeUserId,
    accessToken: token,
    userAgent: ua,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };
}

/**
 * Confirma que el cliente TN coincide con el email enviado desde el storefront (sesión TN).
 */
export async function wishlistVerifyCustomer(
  store: Store,
  customerId: number,
  email: string
): Promise<
  { ok: true } | { ok: false; reason: "tn_misconfigured" | "forbidden" | "tn_error" | "tn_scope" }
> {
  const config = tnConfigFromStore(store);
  if (!config) {
    return { ok: false, reason: "tn_misconfigured" };
  }
  const normalized = normalizeEmail(email);
  if (!normalized || !Number.isFinite(customerId) || customerId <= 0) {
    return { ok: false, reason: "forbidden" };
  }
  try {
    const c = await getCustomer(config, customerId);
    const em = c.email != null ? normalizeEmail(String(c.email)) : "";
    const apiId = Number(c.id);
    if (!Number.isFinite(apiId) || apiId !== customerId || !em || em !== normalized) {
      return { ok: false, reason: "forbidden" };
    }
    return { ok: true };
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    const m = msg.match(/\bTN API (\d{3})\b/);
    const status = m ? parseInt(m[1], 10) : 0;
    if (status === 401 || status === 403) {
      return { ok: false, reason: "tn_scope" };
    }
    if (status === 404) {
      return { ok: false, reason: "forbidden" };
    }
    return { ok: false, reason: "tn_error" };
  }
}
