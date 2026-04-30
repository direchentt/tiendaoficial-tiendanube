import { variantLabel } from "@/components/admin/tn-product-picker-utils";
import type { Bundle, BundleProduct, Store } from "@prisma/client";
import { normalizeTnProductDetail } from "@/lib/tn-products-admin-normalize";
import { getProduct, type ProductDetail } from "@/lib/tiendanube-client";
import { tnConfigFromStore } from "@/lib/wishlist-verify-customer";

export type StorefrontVariantChoice = {
  id: number;
  label: string;
  price: string;
};

export type StorefrontBundleProductLine = BundleProduct & {
  variantChoices?: StorefrontVariantChoice[];
  productPath?: string | null;
};

type BundleWithProducts = Bundle & { products: BundleProduct[] };

export type BundleStorefrontRow = Omit<BundleWithProducts, "products"> & {
  products: StorefrontBundleProductLine[];
};

function pickLocalizedUrl(v: string | Record<string, string> | undefined): string | null {
  if (!v) return null;
  if (typeof v === "string" && v.trim()) {
    const s = v.trim();
    return s.startsWith("http") || s.startsWith("/") ? s : null;
  }
  if (typeof v === "object") {
    const o = v as Record<string, string>;
    const s = (o.es ?? o.pt ?? o.en ?? Object.values(o).find((x) => typeof x === "string" && x.trim()))?.trim();
    if (!s) return null;
    return s.startsWith("http") || s.startsWith("/") ? s : null;
  }
  return null;
}

function productPathFromTnProduct(raw: ProductDetail): string | null {
  const abs =
    pickLocalizedUrl(raw.canonical_url as string | Record<string, string> | undefined) ??
    pickLocalizedUrl(raw.permalink as string | Record<string, string> | undefined);
  if (!abs) return null;
  if (abs.startsWith("/")) return abs.split("?")[0] || null;
  try {
    const u = new URL(abs);
    return u.pathname || null;
  } catch {
    return null;
  }
}

type CachedProduct = {
  tn: ReturnType<typeof normalizeTnProductDetail> | null;
  productPath: string | null;
};

/**
 * Resuelve variantId y variantChoices; adjunta productPath para fallback carrito en el theme.
 */
export async function enrichBundlesForStorefront(
  store: Store,
  bundles: BundleWithProducts[]
): Promise<BundleStorefrontRow[]> {
  const config = tnConfigFromStore(store);
  const cacheByProductId = new Map<number, CachedProduct>();

  async function loadProduct(productId: number): Promise<CachedProduct> {
    if (!config) {
      return { tn: null, productPath: null };
    }
    if (cacheByProductId.has(productId)) {
      return cacheByProductId.get(productId)!;
    }
    try {
      const raw = await getProduct(config, productId);
      const tn = normalizeTnProductDetail(raw);
      const productPath = productPathFromTnProduct(raw);
      const row: CachedProduct = { tn, productPath };
      cacheByProductId.set(productId, row);
      return row;
    } catch (e) {
      console.error("[storefront-bundles-enrich] getProduct", productId, e);
      const row: CachedProduct = { tn: null, productPath: null };
      cacheByProductId.set(productId, row);
      return row;
    }
  }

  const productIdsToFetch = new Set<number>();
  for (const b of bundles) {
    for (const line of b.products) {
      productIdsToFetch.add(line.productId);
    }
  }
  await Promise.all([...productIdsToFetch].map((id) => loadProduct(id)));

  return bundles.map((b) => ({
    ...b,
    products: b.products.map((line) => {
      const cached = cacheByProductId.get(line.productId);
      const tn = cached?.tn ?? null;
      const productPath = cached?.productPath ?? null;
      const variants = tn?.variants ?? [];

      let variantId = line.variantId;
      let variantChoices: StorefrontVariantChoice[] | undefined;

      if (line.customerPicksVariant && variants.length > 1) {
        variantChoices = variants.map((v) => ({
          id: v.id,
          label: variantLabel(v),
          price: v.price,
        }));
        const preferred =
          line.variantId > 0 && variantChoices.some((c) => c.id === line.variantId)
            ? line.variantId
            : variants.find((v) => v.id > 0)?.id;
        if (preferred) {
          variantId = preferred;
          variantChoices = [
            ...variantChoices.filter((c) => c.id === preferred),
            ...variantChoices.filter((c) => c.id !== preferred),
          ];
        }
      } else if (!variantId || variantId <= 0) {
        const first = variants.find((v) => v.id > 0)?.id;
        if (first) variantId = first;
      }

      const out: StorefrontBundleProductLine = {
        ...line,
        variantId,
        productPath,
      };
      if (variantChoices?.length) {
        out.variantChoices = variantChoices;
      }
      return out;
    }),
  }));
}
