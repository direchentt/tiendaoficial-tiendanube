import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { calcDiscountPctForProduct } from "@/lib/dynamic-pricing-calc";
import {
  clampStorefrontVisitCount,
  getMaxDynamicPriceProductIds,
  parseProductIdsListCsv,
  parseStorefrontStoreUserId,
} from "@/lib/storefront-limits";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * GET /api/storefront/dynamic-prices?storeId=<id>&products=1,2,3&visitCount=<n>
 * Returns { [productId]: { pct, multiplier, cacheTtlHours } }
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserIdRaw = searchParams.get("storeId");
  const storeUserId = parseStorefrontStoreUserId(storeUserIdRaw);
  const productsParam = searchParams.get("products") ?? "";
  const visitCount = clampStorefrontVisitCount(
    parseInt(searchParams.get("visitCount") ?? "1", 10)
  );

  if (!storeUserId) {
    return NextResponse.json(
      { error: "storeId is required", hint: "Debe ser el id numérico de la tienda (LS.store.id)." },
      { status: 400, headers: CORS }
    );
  }

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
  });

  if (!store) {
    return NextResponse.json({ prices: {}, enabled: false, commitOnAddToCart: false }, { headers: CORS });
  }

  const config = await prisma.dynamicPricingConfig.findUnique({
    where: { storeId: store.id },
  });

  if (!config || !config.enabled) {
    return NextResponse.json(
      {
        prices: {},
        enabled: false,
        commitOnAddToCart: Boolean(config?.commitOnAddToCart),
      },
      { headers: CORS }
    );
  }

  const maxProductIds = getMaxDynamicPriceProductIds();
  const { ids: productIds, truncated: productIdsTruncated } = parseProductIdsListCsv(
    productsParam,
    maxProductIds
  );

  /**
   * Campo Prisma `excludedCategoryIds` (JSON): puede contener IDs de **producto** a excluir
   * del motor aunque el nombre sea histórico; mantener alineado con el panel y con dynamic-price-commit.
   */
  let excludedProductIds: number[] = [];
  try {
    const raw = JSON.parse(config.excludedCategoryIds || "[]");
    excludedProductIds = Array.isArray(raw) ? raw.filter((x: unknown) => typeof x === "number" && x > 0) : [];
  } catch {
    excludedProductIds = [];
  }

  const prices: Record<string, { pct: number; multiplier: number }> = {};

  for (const pid of productIds) {
    if (excludedProductIds.includes(pid)) continue;

    const pct = calcDiscountPctForProduct(
      pid,
      config.algorithm,
      config.minPct,
      config.maxPct,
      visitCount
    );

    prices[String(pid)] = {
      pct,
      multiplier: Math.round((1 - pct / 100) * 10000) / 10000,
    };
  }

  return NextResponse.json(
    {
      prices,
      enabled: true,
      cacheTtlHours: config.cacheTtlHours,
      algorithm: config.algorithm,
      commitOnAddToCart: config.commitOnAddToCart,
      ...(productIdsTruncated
        ? { productIdsTruncated: true as const, maxProductIdsPerRequest: maxProductIds }
        : {}),
    },
    { headers: CORS }
  );
}
