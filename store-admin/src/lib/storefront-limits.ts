/**
 * Límites y validación en rutas públicas `/api/storefront/*`
 * (coste acotado, menos abuso por query enorme).
 */

/** TN expone `LS.store.id` como string numérica. */
const STORE_USER_ID = /^\d{1,24}$/;

const DEFAULT_MAX_DYNAMIC_PRICE_PRODUCT_IDS = 150;
const ABSOLUTE_MAX_DYNAMIC_PRICE_PRODUCT_IDS = 500;

export function parseStorefrontStoreUserId(raw: string | null | undefined): string | null {
  const s = typeof raw === "string" ? raw.trim() : "";
  if (!s || !STORE_USER_ID.test(s)) return null;
  return s;
}

export function clampStorefrontVisitCount(raw: number): number {
  if (!Number.isFinite(raw) || raw < 1) return 1;
  return Math.min(Math.floor(raw), 1_000_000);
}

export function getMaxDynamicPriceProductIds(): number {
  const raw = process.env.STOREFRONT_MAX_PRODUCT_IDS_DYNAMIC_PRICES;
  if (raw == null || raw === "") return DEFAULT_MAX_DYNAMIC_PRICE_PRODUCT_IDS;
  const n = parseInt(String(raw).trim(), 10);
  if (!Number.isFinite(n)) return DEFAULT_MAX_DYNAMIC_PRICE_PRODUCT_IDS;
  return Math.min(ABSOLUTE_MAX_DYNAMIC_PRICE_PRODUCT_IDS, Math.max(1, n));
}

export type ParsedProductIds = { ids: number[]; truncated: boolean };

/**
 * Parsea `products=1,2,3`, deduplica preservando orden, aplica tope.
 */
export function parseProductIdsListCsv(productsParam: string, maxIds: number): ParsedProductIds {
  const seen = new Set<number>();
  const ids: number[] = [];
  let truncated = false;
  for (const part of productsParam.split(",")) {
    const n = parseInt(part.trim(), 10);
    if (!Number.isFinite(n) || n <= 0) continue;
    if (seen.has(n)) continue;
    if (ids.length >= maxIds) {
      truncated = true;
      break;
    }
    seen.add(n);
    ids.push(n);
  }
  return { ids, truncated };
}

/** Longitud máxima de contraseña en category-gate (evita payloads enormes a bcrypt). */
export const STOREFRONT_CATEGORY_GATE_PASSWORD_MAX = 256;
