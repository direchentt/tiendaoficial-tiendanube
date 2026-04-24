import { NextRequest, NextResponse } from "next/server";
import type { Bundle, BundleProduct, Store } from "@prisma/client";
import { prisma } from "@/lib/prisma";
import { loadStoreForStorefront } from "@/lib/default-store";
import { getProduct } from "@/lib/tiendanube-client";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";
import { tnConfigFromStore } from "@/lib/wishlist-verify-customer";

type BundleWithProducts = Bundle & { products: BundleProduct[] };

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * Si guardaron variantId=0, TN exige el id real de variante para LS.Cart.addItem.
 */
async function enrichBundleProductsDefaultVariants(
  store: Store,
  bundles: BundleWithProducts[]
): Promise<BundleWithProducts[]> {
  const config = tnConfigFromStore(store);
  const defaultVariantByProduct = new Map<number, number>();

  if (config) {
    const productIds = new Set<number>();
    for (const b of bundles) {
      for (const line of b.products) {
        if (!line.variantId || line.variantId <= 0) {
          productIds.add(line.productId);
        }
      }
    }
    await Promise.all(
      [...productIds].map(async (pid) => {
        try {
          const p = await getProduct(config, pid);
          const first = p.variants?.map((v) => v.id).find((id) => id > 0);
          if (first) defaultVariantByProduct.set(pid, first);
        } catch (e) {
          console.error("[storefront/bundles] getProduct", pid, e);
        }
      })
    );
  }

  return bundles.map((b) => ({
    ...b,
    products: b.products.map((line) => {
      const resolved =
        line.variantId > 0
          ? line.variantId
          : (defaultVariantByProduct.get(line.productId) ?? line.variantId);
      return { ...line, variantId: resolved };
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

  const enriched = await enrichBundleProductsDefaultVariants(store, bundles);

  return NextResponse.json({ bundles: enriched }, { headers: CORS });
}
