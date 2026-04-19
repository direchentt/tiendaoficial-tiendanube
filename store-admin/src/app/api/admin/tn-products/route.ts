import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/lib/require-admin";

/**
 * GET /api/admin/tn-products?q=query&page=1
 * Searches products in the Tiendanube store via their API.
 * Used by the product picker in the admin panel.
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const storeId = process.env.TN_STORE_USER_ID;
  const token = process.env.TN_ACCESS_TOKEN;
  const userAgent = process.env.TN_USER_AGENT ?? "HacheSuite (admin@tienda.com)";

  if (!storeId || !token) {
    return NextResponse.json(
      { error: "TN_STORE_USER_ID y TN_ACCESS_TOKEN no configurados" },
      { status: 503 }
    );
  }

  const { searchParams } = new URL(req.url);
  const q = searchParams.get("q") ?? "";
  const page = searchParams.get("page") ?? "1";

  const tnUrl = new URL(`https://api.tiendanube.com/v1/${storeId}/products`);
  tnUrl.searchParams.set("per_page", "20");
  tnUrl.searchParams.set("page", page);
  if (q) tnUrl.searchParams.set("q", q);

  const tnRes = await fetch(tnUrl.toString(), {
    headers: {
      Authorization: `bearer ${token}`,
      "User-Agent": userAgent,
      "Content-Type": "application/json",
    },
    next: { revalidate: 60 },
  });

  if (!tnRes.ok) {
    const errText = await tnRes.text().catch(() => "");
    return NextResponse.json(
      { error: `TN API error ${tnRes.status}`, detail: errText },
      { status: tnRes.status }
    );
  }

  const products = await tnRes.json();

  // Normalizar para el frontend
  const normalized = products.map((p: TNProduct) => ({
    id: p.id,
    name: typeof p.name === "object" ? (p.name.es ?? p.name.pt ?? Object.values(p.name)[0]) : p.name,
    variants: (p.variants ?? []).map((v: TNVariant) => ({
      id: v.id,
      price: v.price,
      stock: v.stock ?? null,
      values: v.values ?? [],
    })),
    images: p.images?.slice(0, 1).map((img: TNImage) => img.src) ?? [],
    price: p.variants?.[0]?.price ?? "0",
  }));

  return NextResponse.json({ products: normalized });
}

// Tipos mínimos de la API de Tiendanube
type TNImage = { src: string };
type TNVariant = { id: number; price: string; stock?: number | null; values?: { es?: string }[] };
type TNProduct = {
  id: number;
  name: string | Record<string, string>;
  variants?: TNVariant[];
  images?: TNImage[];
};
