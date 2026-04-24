import { NextRequest, NextResponse } from "next/server";
import { normalizeTnListProduct } from "@/lib/tn-products-admin-normalize";
import { requireAdmin } from "@/lib/require-admin";
import { devOnlyDetail } from "@/lib/safe-client-message";
import { tnFetch, type TiendanubeClientConfig } from "@/lib/tiendanube-client";

/**
 * GET /api/admin/tn-products?q=query&page=1
 * Busca productos en la tienda vía API Tiendanube (mismos headers/versión que tiendanube-client).
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

  const { searchParams } = new URL(req.url);
  const q = searchParams.get("q") ?? "";
  const page = searchParams.get("page") ?? "1";
  const perPageRaw = parseInt(searchParams.get("per_page") ?? "20", 10);
  const perPage = Math.min(48, Math.max(8, Number.isFinite(perPageRaw) ? perPageRaw : 20));

  const params = new URLSearchParams();
  params.set("per_page", String(perPage));
  params.set("page", page);
  if (q.trim()) params.set("q", q.trim());

  const config: TiendanubeClientConfig = {
    storeUserId,
    accessToken,
    userAgent,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  let products: unknown[];
  try {
    products = await tnFetch<unknown[]>(config, `/products?${params.toString()}`);
  } catch (e) {
    const detail = e instanceof Error ? e.message : String(e);
    return NextResponse.json(
      { error: "Error al consultar Tiendanube", ...devOnlyDetail(detail) },
      { status: 502 }
    );
  }

  const list = Array.isArray(products) ? products : [];

  const normalized = list
    .map((p) => normalizeTnListProduct(p as never))
    .filter((p): p is NonNullable<typeof p> => p != null);

  return NextResponse.json({
    products: normalized,
  });
}
