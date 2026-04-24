import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { loadStoreForStorefront } from "@/lib/default-store";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";

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

  const bundles = await prisma.bundle.findMany({
    where: { storeId: store.id, enabled: true },
    include: { products: { orderBy: { id: "asc" } } },
    orderBy: { createdAt: "desc" },
  });

  return NextResponse.json({ bundles }, { headers: CORS });
}
