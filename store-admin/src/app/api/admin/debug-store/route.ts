import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { adminDebugEndpointsDisabled } from "@/lib/admin-debug";

/**
 * GET /api/admin/debug-store
 * Solo en desarrollo, o en producción con ALLOW_ADMIN_DEBUG=1.
 */
export async function GET(req: NextRequest) {
  if (adminDebugEndpointsDisabled()) {
    return new NextResponse(null, { status: 404 });
  }

  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

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
    envStoreIdConfigured: !!process.env.TN_STORE_USER_ID?.trim(),
    envTokenConfigured: !!process.env.TN_ACCESS_TOKEN?.trim(),
  });
}
