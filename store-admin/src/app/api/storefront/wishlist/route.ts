import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { loadStoreForStorefront } from "@/lib/default-store";
import { wishlistVerifyCustomer, tnConfigFromStore } from "@/lib/wishlist-verify-customer";
import { getProduct, type ProductDetail } from "@/lib/tiendanube-client";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

function parseIntParam(v: string | null): number | null {
  if (v == null || v === "") return null;
  const n = parseInt(v, 10);
  return Number.isFinite(n) && n > 0 ? n : null;
}

function pickProductName(p: ProductDetail): string {
  const n = pickLocalizedRecord(p.name ?? "");
  return n || "Producto";
}

function pickProductUrl(p: ProductDetail): string {
  if (typeof p.canonical_url === "string" && p.canonical_url.trim()) return p.canonical_url.trim();
  if (typeof p.permalink === "string" && p.permalink.trim()) {
    const u = p.permalink.trim();
    if (u.startsWith("http://") || u.startsWith("https://")) {
      try {
        return new URL(u).pathname || u;
      } catch {
        return u;
      }
    }
    return u.startsWith("/") ? u : `/${u}`;
  }
  if (typeof p.handle === "string" && p.handle.trim()) return `/productos/${p.handle.trim()}`;
  return "#";
}

function pickProductImage(p: ProductDetail): string | null {
  const src = p.images?.[0]?.src;
  return typeof src === "string" && src.trim() ? src.trim() : null;
}

function pickLocalizedRecord(
  field: string | Record<string, string> | undefined
): string {
  if (typeof field === "string" && field.trim()) return field.trim();
  if (field && typeof field === "object") {
    const o = field as Record<string, string>;
    const v =
      o.es ||
      o.pt ||
      o.en ||
      o.es_mx ||
      Object.values(o).find((x) => typeof x === "string" && x.trim());
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return "";
}

function stripHtml(html: string): string {
  return html
    .replace(/<script[\s\S]*?>[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?>[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/** Texto plano corto para la tarjeta de favoritos (sin HTML). */
function pickProductExcerpt(p: ProductDetail, maxLen: number): string {
  const raw = pickLocalizedRecord(p.description);
  if (!raw) return "";
  const plain = stripHtml(raw);
  if (plain.length <= maxLen) return plain;
  return `${plain.slice(0, maxLen - 1).trim()}…`;
}

function parseMoney(s: string | null | undefined): number | null {
  if (s == null || s === "") return null;
  const n = parseFloat(String(s).replace(",", "."));
  return Number.isFinite(n) && n >= 0 ? n : null;
}

function pickFirstVariant(p: ProductDetail): {
  variantId: number | null;
  salePrice: number | null;
  listPrice: number | null;
} {
  const v = p.variants?.[0];
  if (!v || typeof v.id !== "number" || v.id <= 0) {
    return { variantId: null, salePrice: null, listPrice: null };
  }
  const list = parseMoney(v.price ?? null);
  const promo = parseMoney(v.promotional_price ?? null);
  if (list != null && promo != null && promo < list) {
    return { variantId: v.id, salePrice: promo, listPrice: list };
  }
  return { variantId: v.id, salePrice: list ?? promo, listPrice: null };
}

/**
 * GET /api/storefront/wishlist?storeId=<tiendanubeUserId>&customerId=<n>&email=<urlencoded>&details=1
 * details=1 agrega `items` con nombre, url e imagen vía API de productos (read_products).
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = parseStorefrontStoreUserId(searchParams.get("storeId"));
  const customerId = parseIntParam(searchParams.get("customerId"));
  const email = searchParams.get("email") ?? "";
  const withDetails = searchParams.get("details") === "1";

  if (!storeUserId || !customerId || !email.trim()) {
    return NextResponse.json(
      {
        error: "missing_params",
        need: ["storeId", "customerId", "email"],
        hint: "storeId debe ser el id numérico de la tienda (LS.store.id).",
      },
      { status: 400, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return NextResponse.json(
      { error: "store_not_found", productIds: [], items: [] },
      { status: 404, headers: CORS }
    );
  }

  const v = await wishlistVerifyCustomer(store, customerId, email);
  if (!v.ok) {
    console.warn("[wishlist GET] verify", v.reason, { customerId });
    const status =
      v.reason === "forbidden" ? 403 : v.reason === "tn_scope" ? 403 : 503;
    return NextResponse.json({ error: v.reason, productIds: [] }, { status, headers: CORS });
  }

  const rows = await prisma.wishlistItem.findMany({
    where: { storeId: store.id, tnCustomerId: customerId },
    select: { productId: true },
  });

  const productIds = rows.map((r) => r.productId);

  if (!withDetails) {
    return NextResponse.json({ productIds }, { headers: CORS });
  }

  const config = tnConfigFromStore(store);
  if (!config) {
    return NextResponse.json(
      { error: "tn_misconfigured", productIds, items: [] },
      { status: 503, headers: CORS }
    );
  }

  const max = 40;
  const items: {
    productId: number;
    name: string;
    url: string;
    image: string | null;
    excerpt: string;
    variantId: number | null;
    salePrice: number | null;
    listPrice: number | null;
  }[] = [];
  for (const productId of productIds.slice(0, max)) {
    try {
      const p = await getProduct(config, productId);
      const { variantId, salePrice, listPrice } = pickFirstVariant(p);
      items.push({
        productId,
        name: pickProductName(p),
        url: pickProductUrl(p),
        image: pickProductImage(p),
        excerpt: pickProductExcerpt(p, 200),
        variantId,
        salePrice,
        listPrice,
      });
    } catch {
      items.push({
        productId,
        name: `Producto #${productId}`,
        url: "#",
        image: null,
        excerpt: "",
        variantId: null,
        salePrice: null,
        listPrice: null,
      });
    }
  }

  return NextResponse.json({ productIds, items }, { headers: CORS });
}

type ToggleBody = {
  storeId?: string;
  customerId?: number;
  customerEmail?: string;
  productId?: number;
};

/**
 * POST /api/storefront/wishlist
 * Body: { storeId, customerId, customerEmail, productId }
 * Toggle: si ya está guardado, lo quita; si no, lo agrega.
 */
export async function POST(req: NextRequest) {
  let body: ToggleBody;
  try {
    body = (await req.json()) as ToggleBody;
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400, headers: CORS });
  }

  const storeUserId = parseStorefrontStoreUserId(body.storeId ?? null);
  const customerId = Number(body.customerId);
  const customerEmail = body.customerEmail?.trim() ?? "";
  const productId = Number(body.productId);

  if (!storeUserId || !customerEmail || !Number.isFinite(customerId) || customerId <= 0) {
    return NextResponse.json(
      {
        error: "missing_fields",
        need: ["storeId", "customerId", "customerEmail", "productId"],
        hint: "storeId debe ser el id numérico de la tienda (LS.store.id).",
      },
      { status: 400, headers: CORS }
    );
  }
  if (!Number.isFinite(productId) || productId <= 0) {
    return NextResponse.json({ error: "invalid_product" }, { status: 400, headers: CORS });
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return NextResponse.json({ error: "store_not_found" }, { status: 404, headers: CORS });
  }

  const v = await wishlistVerifyCustomer(store, customerId, customerEmail);
  if (!v.ok) {
    console.warn("[wishlist POST] verify", v.reason, { customerId });
    const status =
      v.reason === "forbidden" ? 403 : v.reason === "tn_scope" ? 403 : 503;
    return NextResponse.json({ error: v.reason }, { status, headers: CORS });
  }

  try {
    const existing = await prisma.wishlistItem.findUnique({
      where: {
        storeId_tnCustomerId_productId: {
          storeId: store.id,
          tnCustomerId: customerId,
          productId,
        },
      },
    });

    if (existing) {
      await prisma.wishlistItem.delete({ where: { id: existing.id } });
      return NextResponse.json({ inWishlist: false, productId }, { headers: CORS });
    }

    await prisma.wishlistItem.create({
      data: {
        storeId: store.id,
        tnCustomerId: customerId,
        customerEmail,
        productId,
      },
    });

    return NextResponse.json({ inWishlist: true, productId }, { headers: CORS });
  } catch (e) {
    const detail = e instanceof Error ? e.message : String(e);
    console.error("[wishlist POST]", detail);
    return NextResponse.json({ error: "db_write_failed" }, { status: 500, headers: CORS });
  }
}
