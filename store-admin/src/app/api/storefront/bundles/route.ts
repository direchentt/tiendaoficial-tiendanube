import { NextRequest, NextResponse } from "next/server";
import { variantLabel } from "@/components/admin/tn-product-picker-utils";
import type { Bundle, BundleProduct, Store } from "@prisma/client";
import { prisma } from "@/lib/prisma";
import { loadStoreForStorefront } from "@/lib/default-store";
import { normalizeTnProductDetail } from "@/lib/tn-products-admin-normalize";
import { getProduct } from "@/lib/tiendanube-client";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";
import { tnConfigFromStore } from "@/lib/wishlist-verify-customer";

type BundleWithProducts = Bundle & { products: BundleProduct[] };

export type StorefrontVariantChoice = {
  id: number;
  label: string;
  price: string;
};

export type StorefrontBundleProductLine = BundleProduct & {
  variantChoices?: StorefrontVariantChoice[];
};

type BundleStorefrontRow = Omit<BundleWithProducts, "products"> & {
  products: StorefrontBundleProductLine[];
};

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * Resuelve variantId cuando falta y, si customerPicksVariant, adjunta variantChoices desde TN.
 */
async function enrichBundlesForStorefront(
  store: Store,
  bundles: BundleWithProducts[]
): Promise<BundleStorefrontRow[]> {
  const config = tnConfigFromStore(store);
  const normalizedByProductId = new Map<
    number,
    ReturnType<typeof normalizeTnProductDetail> | null
  >();

  async function loadNormalized(productId: number) {
    if (!config) return null;
    if (normalizedByProductId.has(productId)) {
      return normalizedByProductId.get(productId)!;
    }
    try {
      const raw = await getProduct(config, productId);
      const n = normalizeTnProductDetail(raw);
      normalizedByProductId.set(productId, n);
      return n;
    } catch (e) {
      console.error("[storefront/bundles] getProduct", productId, e);
      normalizedByProductId.set(productId, null);
      return null;
    }
  }

  const productIdsToFetch = new Set<number>();
  for (const b of bundles) {
    for (const line of b.products) {
      if (!line.variantId || line.variantId <= 0 || line.customerPicksVariant) {
        productIdsToFetch.add(line.productId);
      }
    }
  }
  await Promise.all([...productIdsToFetch].map((id) => loadNormalized(id)));

  return bundles.map((b) => ({
    ...b,
    products: b.products.map((line) => {
      const tn = normalizedByProductId.get(line.productId) ?? null;
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
      };
      if (variantChoices?.length) {
        out.variantChoices = variantChoices;
      }
      return out;
    }),
  }));
}

/**
 * GET /api/storefront/bundles?storeId=<tiendanubeUserId>
 * Returns all enabled bundles with their products for the storefront.
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = parseStorefrontStoreUserId(searchParams.get("storeId"));

  if (!storeUserId) {
    return NextResponse.json(
      { error: "storeId is required", hint: "Id numérico de la tienda (LS.store.id)." },
      { status: 400, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);

  if (!store) {
    return NextResponse.json({ bundles: [] }, { headers: CORS });
  }

  const bundles = (await prisma.bundle.findMany({
    where: { storeId: store.id, enabled: true },
    include: { products: { orderBy: { id: "asc" } } },
    orderBy: { createdAt: "desc" },
  })) as BundleWithProducts[];

  const enriched = await enrichBundlesForStorefront(store, bundles);

  return NextResponse.json({ bundles: enriched }, { headers: CORS });
}
