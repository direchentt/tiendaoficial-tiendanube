import { NextRequest, NextResponse } from "next/server";
import { loadStoreForStorefront } from "@/lib/default-store";
import { getRecentPublishedProducts, type ProductRecentListItem } from "@/lib/tiendanube-client";
import { tnConfigFromStore } from "@/lib/wishlist-verify-customer";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

function parseIntParam(v: string | null, fallback: number, min: number, max: number): number {
  if (v == null || v === "") return fallback;
  const n = parseInt(v, 10);
  if (!Number.isFinite(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}

function pickName(n: ProductRecentListItem["name"]): string {
  if (typeof n === "string" && n.trim()) return n.trim();
  if (n && typeof n === "object") {
    const o = n as Record<string, string>;
    const v = o.es || o.pt || o.en || o.es_mx || Object.values(o).find((x) => typeof x === "string" && x.trim());
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return "Producto";
}

function pickHandle(h: ProductRecentListItem["handle"]): string {
  if (typeof h === "string" && h.trim()) return h.trim();
  if (h && typeof h === "object") {
    const o = h as Record<string, string>;
    const v = o.es || o.pt || o.en || o.es_mx || Object.values(o).find((x) => typeof x === "string" && x.trim());
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return "";
}

function pickUrl(p: ProductRecentListItem): string {
  const handle = pickHandle(p.handle);
  if (handle) return `/productos/${handle}`;
  return "#";
}

function pickImage(p: ProductRecentListItem): string | null {
  const src = p.images?.[0]?.src;
  return typeof src === "string" && src.trim() ? src.trim() : null;
}

/**
 * GET /api/storefront/recent-products?storeId=&days=30&limit=12
 * Productos publicados creados en los ultimos `days` dias (mas nuevos primero).
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = parseStorefrontStoreUserId(searchParams.get("storeId"));
  const days = parseIntParam(searchParams.get("days"), 30, 1, 90);
  const limit = parseIntParam(searchParams.get("limit"), 12, 1, 30);

  if (!storeUserId) {
    return NextResponse.json(
      {
        error: "missing_params",
        need: ["storeId"],
        hint: "storeId debe ser el id numérico de la tienda (LS.store.id).",
      },
      { status: 400, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return NextResponse.json({ error: "store_not_found", items: [] }, { status: 404, headers: CORS });
  }

  const config = tnConfigFromStore(store);
  if (!config) {
    return NextResponse.json({ error: "tn_misconfigured", items: [] }, { status: 503, headers: CORS });
  }

  try {
    const rows = await getRecentPublishedProducts(config, { days, perPage: limit });
    const items = rows.map((p) => ({
      productId: p.id,
      name: pickName(p.name),
      url: pickUrl(p),
      image: pickImage(p),
      createdAt: typeof p.created_at === "string" ? p.created_at : null,
    }));
    return NextResponse.json({ items }, { headers: CORS });
  } catch (e) {
    const detail = e instanceof Error ? e.message : String(e);
    console.error("[recent-products]", detail);
    return NextResponse.json({ error: "tn_error", items: [] }, { status: 503, headers: CORS });
  }
}
