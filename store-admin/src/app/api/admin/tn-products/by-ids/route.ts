import { NextRequest, NextResponse } from "next/server";
import { normalizeTnProductDetail } from "@/lib/tn-products-admin-normalize";
import { requireAdmin } from "@/lib/require-admin";
import { getProduct, type TiendanubeClientConfig } from "@/lib/tiendanube-client";

const MAX_IDS = 24;
const CONCURRENCY = 5;

function parseIds(raw: string | null): number[] {
  if (raw == null || raw.trim() === "") return [];
  const seen = new Set<number>();
  const out: number[] = [];
  for (const part of raw.split(/[\s,;]+/)) {
    const n = parseInt(part.trim(), 10);
    if (!Number.isFinite(n) || n <= 0) continue;
    if (seen.has(n)) continue;
    seen.add(n);
    out.push(n);
    if (out.length >= MAX_IDS) break;
  }
  return out;
}

async function mapPool<T, R>(items: T[], limit: number, fn: (item: T) => Promise<R>): Promise<R[]> {
  const out: R[] = [];
  for (let i = 0; i < items.length; i += limit) {
    const chunk = items.slice(i, i + limit);
    out.push(...(await Promise.all(chunk.map(fn))));
  }
  return out;
}

/**
 * GET /api/admin/tn-products/by-ids?ids=1,2,3
 * Resuelve varios productos por ID (para pegar IDs en el picker). Máximo 24.
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const storeUserId = process.env.TN_STORE_USER_ID;
  const accessToken = process.env.TN_ACCESS_TOKEN;
  const userAgent = process.env.TN_USER_AGENT ?? "HacheSuite (admin@tienda.com)";

  if (!storeUserId || !accessToken) {
    return NextResponse.json(
      { error: "TN_STORE_USER_ID y TN_ACCESS_TOKEN no configurados" },
      { status: 503 }
    );
  }

  const ids = parseIds(new URL(req.url).searchParams.get("ids"));
  if (ids.length === 0) {
    return NextResponse.json(
      { error: "Indicá ids numéricos en el query: ?ids=1,2,3", products: [], failed: [] },
      { status: 400 }
    );
  }

  const config: TiendanubeClientConfig = {
    storeUserId,
    accessToken,
    userAgent,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  const failed: { id: number; error: string }[] = [];

  const settled = await mapPool(ids, CONCURRENCY, async (id) => {
    try {
      const detail = await getProduct(config, id);
      const norm = normalizeTnProductDetail(detail);
      return { ok: true as const, id, norm };
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return { ok: false as const, id, error: msg.slice(0, 200) };
    }
  });

  const products = [];
  for (const row of settled) {
    if (row.ok) {
      if (row.norm) products.push(row.norm);
      else failed.push({ id: row.id, error: "Sin variantes" });
    } else {
      failed.push({ id: row.id, error: row.error });
    }
  }

  products.sort((a, b) => ids.indexOf(a.id) - ids.indexOf(b.id));

  return NextResponse.json({
    products,
    failed,
    maxIds: MAX_IDS,
  });
}
