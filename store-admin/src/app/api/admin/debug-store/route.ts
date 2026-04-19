import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

/**
 * GET /api/admin/debug-store
 * Muestra el contenido de la tabla Store y DynamicPricingConfig para debug.
 */
export async function GET(req: NextRequest) {
  const secret = req.headers.get("x-admin-secret");
  if (secret !== process.env.ADMIN_SECRET) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const stores = await prisma.store.findMany({
    select: {
      id: true,
      tiendanubeUserId: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  const configs = await prisma.dynamicPricingConfig.findMany({
    select: {
      storeId: true,
      enabled: true,
      algorithm: true,
      minPct: true,
      maxPct: true,
    },
  });

  return NextResponse.json({
    stores,
    dynamicPricingConfigs: configs,
    envStoreId: process.env.TN_STORE_USER_ID,
    envTokenSet: !!process.env.TN_ACCESS_TOKEN,
  });
}
