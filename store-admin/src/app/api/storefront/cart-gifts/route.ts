import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * GET /api/storefront/cart-gifts?storeId=<tiendanubeUserId>&total=<number>
 * Returns the active gift rules that apply to the given cart total.
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = searchParams.get("storeId");
  const totalRaw = searchParams.get("total");

  if (!storeUserId) {
    return NextResponse.json(
      { error: "storeId is required" },
      { status: 400, headers: CORS }
    );
  }

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
  });

  if (!store) {
    return NextResponse.json({ gifts: [] }, { headers: CORS });
  }

  const cartTotal = totalRaw ? parseFloat(totalRaw) : 0;

  const rules = await prisma.cartGiftRule.findMany({
    where: {
      storeId: store.id,
      enabled: true,
      minTotal: { lte: cartTotal },
    },
    orderBy: { minTotal: "asc" },
  });

  return NextResponse.json({ gifts: rules }, { headers: CORS });
}
