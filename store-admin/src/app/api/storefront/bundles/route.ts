import { NextRequest, NextResponse } from "next/server";
import type { Bundle, BundleProduct, Store } from "@prisma/client";
import { prisma } from "@/lib/prisma";
import { loadStoreForStorefront } from "@/lib/default-store";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";
import { enrichBundlesForStorefront } from "@/lib/storefront-bundles-enrich";

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
 * GET /api/storefront/bundles?storeId=<tiendanubeUserId>
 * Combos “globales” (sin página v2): categoría /combos, etc.
 * Los asignados a una ComboLandingPage v2 salen solo por /api/storefront/bundles/v2?slug=...
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
    where: { storeId: store.id, enabled: true, landingPageId: null },
    include: { products: { orderBy: { id: "asc" } } },
    orderBy: { createdAt: "desc" },
  })) as BundleWithProducts[];

  const enriched = await enrichBundlesForStorefront(store, bundles);

  return NextResponse.json({ bundles: enriched }, { headers: CORS });
}
