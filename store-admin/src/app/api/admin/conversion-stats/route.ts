import { NextRequest, NextResponse } from "next/server";
import { loadStoreForStorefront } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";

function parseDays(raw: string | null): number {
  if (raw == null || raw === "") return 30;
  const n = parseInt(raw, 10);
  if (!Number.isFinite(n)) return 30;
  return Math.min(90, Math.max(1, n));
}

/**
 * GET /api/admin/conversion-stats?days=30
 * Agregados de eventos CVR para la tienda enlazada a TN_STORE_USER_ID (env).
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const envUserId = process.env.TN_STORE_USER_ID?.trim();
  if (!envUserId) {
    return NextResponse.json(
      { error: "TN_STORE_USER_ID no configurado", counts: {}, funnel: null },
      { status: 503 }
    );
  }

  const days = parseDays(new URL(req.url).searchParams.get("days"));
  const since = new Date(Date.now() - days * 86400000);

  const store = await loadStoreForStorefront(envUserId);
  if (!store) {
    return NextResponse.json({
      days,
      since: since.toISOString(),
      counts: {},
      funnel: null,
      hint: "No hay fila Store sincronizada (DATABASE_URL / OAuth).",
    });
  }

  const grouped = await prisma.conversionEvent.groupBy({
    by: ["type"],
    where: { storeId: store.id, createdAt: { gte: since } },
    _count: { id: true },
  });

  const counts: Record<string, number> = {};
  for (const row of grouped) {
    counts[row.type] = row._count.id;
  }

  const pv = counts.product_view ?? 0;
  const atc = counts.add_to_cart ?? 0;
  const cv = pv > 0 ? Math.round((atc / pv) * 1000) / 10 : null;

  const home = counts.home_view ?? 0;
  const cat = counts.category_view ?? 0;
  const bundle = counts.bundle_view ?? 0;

  return NextResponse.json({
    days,
    since: since.toISOString(),
    storeTiendanubeUserId: envUserId,
    counts,
    funnel: {
      productViews: pv,
      addToCart: atc,
      /** % add_to_cart sobre product_view (PDP). */
      pdpViewToAddCartPct: cv,
      homeViews: home,
      categoryViews: cat,
      bundleViews: bundle,
    },
  });
}
