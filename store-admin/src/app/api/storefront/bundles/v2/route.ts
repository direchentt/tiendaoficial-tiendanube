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

function normalizeSlug(raw: string | null): string | null {
  if (!raw) return null;
  const s = raw.trim().toLowerCase();
  if (!s) return null;
  const noSlash = s.replace(/^\/+|\/+$/g, "");
  return noSlash || null;
}

/**
 * GET /api/storefront/bundles/v2?storeId=<tiendanubeUserId>&slug=<handle TN>
 * P.ej. slug=bundle para la página estática /bundle/ (mismo handle en Mi Tiendanube > Páginas).
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = parseStorefrontStoreUserId(searchParams.get("storeId"));
  const slug = normalizeSlug(searchParams.get("slug"));

  if (!storeUserId) {
    return NextResponse.json(
      { error: "storeId is required", hint: "Id numérico de la tienda (LS.store.id)." },
      { status: 400, headers: CORS }
    );
  }
  if (!slug) {
    return NextResponse.json(
      { error: "slug is required", hint: "Handle de la página TN (ej. bundle)." },
      { status: 400, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return NextResponse.json(
      { landing: null, bundles: [] },
      { status: 200, headers: CORS }
    );
  }

  const landing = await prisma.comboLandingPage.findFirst({
    where: { storeId: store.id, slug, enabled: true },
  });

  if (!landing) {
    return NextResponse.json(
      {
        landing: null,
        bundles: [],
        hint: "No hay página de combos v2 con ese slug. Creala en el panel Hache → Combos v2 (páginas).",
      },
      { headers: CORS }
    );
  }

  const bundles = (await prisma.bundle.findMany({
    where: { storeId: store.id, enabled: true, landingPageId: landing.id },
    include: { products: { orderBy: { id: "asc" } } },
    orderBy: { createdAt: "desc" },
  })) as BundleWithProducts[];

  const enriched = await enrichBundlesForStorefront(store, bundles);

  return NextResponse.json(
    {
      landing: {
        slug: landing.slug,
        title: landing.title,
        intro: landing.intro ?? null,
      },
      bundles: enriched,
    },
    { headers: CORS }
  );
}
