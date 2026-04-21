/**
 * Cliente minimo para la API REST Tiendanube / Nuvemshop.
 * Base y headers segun documentacion oficial (version en URL, User-Agent obligatorio).
 *
 * @see https://tiendanube.github.io/api-documentation/intro
 * @see https://tiendanube.github.io/api-documentation/resources/product
 */

export const TN_API_VERSION = "2025-03";

export type TiendanubeClientConfig = {
  storeUserId: string;
  accessToken: string;
  /** Nombre y contacto obligatorio en cada request */
  userAgent: string;
  /** api.tiendanube.com o api.nuvemshop.com.br */
  host?: "tiendanube" | "nuvemshop";
};

function baseUrl(config: TiendanubeClientConfig): string {
  const domain =
    config.host === "nuvemshop"
      ? "api.nuvemshop.com.br"
      : "api.tiendanube.com";
  return `https://${domain}/${TN_API_VERSION}/${config.storeUserId.trim()}`;
}

export async function tnFetch<T>(
  config: TiendanubeClientConfig,
  path: string,
  init?: RequestInit
): Promise<T> {
  const token = config.accessToken.trim();
  const ua = config.userAgent.trim();
  const url = `${baseUrl(config)}${path.startsWith("/") ? path : `/${path}`}`;
  const res = await fetch(url, {
    ...init,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      /* TN exige este header (no "Authorization"); bearer en minúsculas. */
      Authentication: `bearer ${token}`,
      "User-Agent": ua,
      ...init?.headers,
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`TN API ${res.status}: ${text.slice(0, 500)}`);
  }

  if (res.status === 204) {
    return undefined as T;
  }

  return res.json() as Promise<T>;
}

/** Opciones de pago para checkout (scope read_payments). Documentacion: Business Rules + Payment providers. */
export type CheckoutPaymentOption = {
  id: string;
  name: string;
  supported_payment_method_types: string[];
  integration_type?: string;
};

export type PaymentProviderOptionRow = {
  id: string;
  name: string;
  logo_url?: string;
  checkout_payment_options: CheckoutPaymentOption[];
};

export function getPaymentProviderOptions(
  config: TiendanubeClientConfig
): Promise<PaymentProviderOptionRow[]> {
  return tnFetch<PaymentProviderOptionRow[]>(
    config,
    "/payment_providers/options"
  );
}

export type StockPricePatchRow = {
  id: number;
  variants: { id: number; price?: string | number; promotional_price?: string | number | null }[];
};

/** Parche parcial de variantes (p. ej. solo `promotional_price`). Ver PATCH /products/{id}/variants. */
export type ProductVariantPatchPartial = {
  id: number;
  price?: string | null;
  promotional_price?: string | null;
};

/**
 * Actualiza precio y/o stock en lote (maximo 50 variantes por request).
 * @see https://tiendanube.github.io/api-documentation/resources/product
 */
/** Cuerpo del PATCH: array de productos; maximo 50 variantes en total entre todos. */
export function patchProductsStockPrice(
  config: TiendanubeClientConfig,
  body: StockPricePatchRow[]
): Promise<unknown> {
  return tnFetch(config, "/products/stock-price", {
    method: "PATCH",
    body: JSON.stringify(body),
  });
}

export type ProductListItem = {
  id: number;
  variants?: { id: number; price?: string | null }[];
};

/** Detalle de producto (campos extra opcionales para wishlist / admin). */
export type ProductDetail = {
  id: number;
  name?: string | Record<string, string>;
  handle?: string;
  canonical_url?: string;
  permalink?: string;
  images?: { src?: string }[];
  variants?: { id: number; price?: string | null; promotional_price?: string | null }[];
};

/**
 * Actualiza variantes existentes sin reemplazar el catálogo completo.
 * Usado p. ej. para fijar `promotional_price` manteniendo `price` como lista.
 */
export function patchProductVariants(
  config: TiendanubeClientConfig,
  productId: number,
  variants: ProductVariantPatchPartial[]
): Promise<unknown> {
  return tnFetch(config, `/products/${productId}/variants`, {
    method: "PATCH",
    body: JSON.stringify(variants),
  });
}

export function getProduct(config: TiendanubeClientConfig, productId: number): Promise<ProductDetail> {
  return tnFetch<ProductDetail>(config, `/products/${productId}`);
}

/** Cliente de tienda (verificación wishlist / datos mínimos). Requiere scope read_customers en el token. */
export type CustomerSummary = { id: number; email?: string | null };

export function getCustomer(
  config: TiendanubeClientConfig,
  customerId: number
): Promise<CustomerSummary> {
  return tnFetch<CustomerSummary>(config, `/customers/${customerId}`);
}

export function getProductsPage(
  config: TiendanubeClientConfig,
  page: number
): Promise<ProductListItem[]> {
  const q = new URLSearchParams({ page: String(page) });
  return tnFetch<ProductListItem[]>(config, `/products?${q.toString()}`);
}

/** Listado reciente para campana "novedades" (read_products). */
export type ProductRecentListItem = {
  id: number;
  name?: string | Record<string, string>;
  handle?: string | Record<string, string>;
  images?: { src?: string }[];
  created_at?: string;
};

export function getRecentPublishedProducts(
  config: TiendanubeClientConfig,
  opts: { days?: number; perPage?: number }
): Promise<ProductRecentListItem[]> {
  const days = Math.min(Math.max(opts.days ?? 30, 1), 365);
  const perPage = Math.min(Math.max(opts.perPage ?? 15, 1), 30);
  const since = new Date(Date.now() - days * 86400000).toISOString();
  const q = new URLSearchParams({
    page: "1",
    per_page: String(perPage),
    created_at_min: since,
    published: "true",
    sort_by: "created-at-descending",
    fields: "id,name,handle,images,created_at",
  });
  return tnFetch<ProductRecentListItem[]>(config, `/products?${q.toString()}`);
}
