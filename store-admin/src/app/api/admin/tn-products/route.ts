import { NextRequest, NextResponse } from "next/server";
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

  const params = new URLSearchParams();
  params.set("per_page", "20");
  params.set("page", page);
  if (q.trim()) params.set("q", q.trim());

  const config: TiendanubeClientConfig = {
    storeUserId,
    accessToken,
    userAgent,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  let products: TNProduct[];
  try {
    products = await tnFetch<TNProduct[]>(config, `/products?${params.toString()}`);
  } catch (e) {
    const detail = e instanceof Error ? e.message : String(e);
    return NextResponse.json(
      { error: "Error al consultar Tiendanube", ...devOnlyDetail(detail) },
      { status: 502 }
    );
  }

  const list = Array.isArray(products) ? products : [];

  const normalized = list.map((p: TNProduct) => ({
    id: p.id,
    name: typeof p.name === "object" ? (p.name.es ?? p.name.pt ?? Object.values(p.name)[0]) : p.name,
    variants: (p.variants ?? []).map((v: TNVariant) => ({
      id: v.id,
      price: v.price,
      stock: v.stock ?? null,
      values: v.values ?? [],
    })),
    images: (p.images ?? [])
      .slice(0, 1)
      .map((img: TNImage) => (typeof img.src === "string" ? img.src : ""))
      .filter(Boolean),
    price: p.variants?.[0]?.price ?? "0",
  }));

  return NextResponse.json({
    products: normalized.filter((p) => p.variants.length > 0),
  });
}

type TNImage = { src: string };
type TNVariant = { id: number; price: string; stock?: number | null; values?: { es?: string; pt?: string; en?: string }[] };
type TNProduct = {
  id: number;
  name: string | Record<string, string>;
  variants?: TNVariant[];
  images?: TNImage[];
};
