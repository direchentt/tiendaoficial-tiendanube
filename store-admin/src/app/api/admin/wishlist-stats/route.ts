import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { ensureDefaultStore } from "@/lib/default-store";

/**
 * GET /api/admin/wishlist-stats
 * Top productos más guardados en favoritos (conteo por productId).
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const takeRaw = new URL(req.url).searchParams.get("take");
  const take = Math.min(100, Math.max(1, parseInt(takeRaw ?? "30", 10) || 30));

  const grouped = await prisma.wishlistItem.groupBy({
    by: ["productId"],
    where: { storeId: store.id },
    _count: { id: true },
  });

  const sorted = grouped
    .map((g) => ({ productId: g.productId, saves: g._count.id }))
    .sort((a, b) => b.saves - a.saves)
    .slice(0, take);

  const customers = await prisma.wishlistItem.groupBy({
    by: ["tnCustomerId"],
    where: { storeId: store.id },
    _count: { id: true },
  });

  return NextResponse.json({
    topProducts: sorted,
    customersWithWishlist: customers.length,
    totalItems: grouped.reduce((acc, g) => acc + g._count.id, 0),
  });
}
