import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { calcDiscountPctForProduct } from "@/lib/dynamic-pricing-calc";
import {
  getProduct,
  patchProductsStockPrice,
  type TiendanubeClientConfig,
} from "@/lib/tiendanube-client";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const bodySchema = z.object({
  storeId: z.string().min(1),
  productId: z.number().int().positive(),
  variantId: z.number().int().positive().optional(),
  visitCount: z.number().int().min(1).max(999).optional(),
});

function parsePrice(p: string | null | undefined): number {
  if (p == null || p === "") return 0;
  const n = parseFloat(String(p).replace(",", "."));
  return Number.isFinite(n) ? n : 0;
}

function roundPrice(n: number): string {
  return (Math.round(n * 100) / 100).toFixed(2);
}

/** Rate limit muy simple por IP (evita abuso del PATCH público). */
const rl = new Map<string, number[]>();
function rateOk(ip: string): boolean {
  const now = Date.now();
  const windowMs = 60_000;
  const max = 20;
  const arr = (rl.get(ip) ?? []).filter((t) => now - t < windowMs);
  if (arr.length >= max) return false;
  arr.push(now);
  rl.set(ip, arr);
  return true;
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * POST /api/storefront/dynamic-price-commit
 * Escribe en Tiendanube el precio con el % dinámico actual (misma fórmula que GET /dynamic-prices).
 * Solo si `commitOnAddToCart` está activo en la config. Afecta el catálogo para todos los usuarios.
 */
export async function POST(req: NextRequest) {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() || "unknown";
  if (!rateOk(ip)) {
    return NextResponse.json({ error: "rate_limited" }, { status: 429, headers: CORS });
  }

  let json: unknown;
  try {
    json = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400, headers: CORS });
  }

  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422, headers: CORS });
  }

  const { storeId, productId, variantId, visitCount } = parsed.data;
  const visits = visitCount ?? 1;

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeId },
  });
  if (!store) {
    return NextResponse.json({ error: "store_not_found" }, { status: 404, headers: CORS });
  }

  const config = await prisma.dynamicPricingConfig.findUnique({
    where: { storeId: store.id },
  });

  if (!config || !config.enabled || !config.commitOnAddToCart) {
    return NextResponse.json({ error: "commit_disabled" }, { status: 403, headers: CORS });
  }

  let excluded: number[] = [];
  try {
    excluded = JSON.parse(config.excludedCategoryIds || "[]") as number[];
    if (!Array.isArray(excluded)) excluded = [];
  } catch {
    excluded = [];
  }
  if (excluded.includes(productId)) {
    return NextResponse.json({ error: "product_excluded" }, { status: 400, headers: CORS });
  }

  const ua = process.env.TN_USER_AGENT?.trim();
  if (!ua) {
    return NextResponse.json({ error: "server_misconfigured", need: ["TN_USER_AGENT"] }, { status: 500, headers: CORS });
  }

  const pct = calcDiscountPctForProduct(
    productId,
    config.algorithm,
    config.minPct,
    config.maxPct,
    visits
  );

  const tn: TiendanubeClientConfig = {
    storeUserId: store.tiendanubeUserId,
    accessToken: store.accessToken.trim(),
    userAgent: ua,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  let product;
  try {
    product = await getProduct(tn, productId);
  } catch (e) {
    return NextResponse.json({ error: "tn_fetch_failed", message: String(e) }, { status: 502, headers: CORS });
  }

  const variants = product.variants ?? [];
  if (!variants.length) {
    return NextResponse.json({ error: "no_variants" }, { status: 400, headers: CORS });
  }

  const v =
    variantId != null
      ? variants.find((x) => x.id === variantId) ?? null
      : variants[0] ?? null;
  if (!v) {
    return NextResponse.json({ error: "variant_not_found" }, { status: 400, headers: CORS });
  }

  const base = parsePrice(v.price ?? null);
  if (base <= 0) {
    return NextResponse.json({ error: "invalid_variant_price" }, { status: 400, headers: CORS });
  }

  const next = base * (1 - pct / 100);
  const nextStr = roundPrice(next);
  if (parseFloat(nextStr) <= 0 || parseFloat(nextStr) >= base) {
    return NextResponse.json({ error: "noop_price" }, { status: 400, headers: CORS });
  }

  try {
    await patchProductsStockPrice(tn, [{ id: productId, variants: [{ id: v.id, price: nextStr }] }]);
  } catch (e) {
    return NextResponse.json({ error: "tn_patch_failed", message: String(e) }, { status: 502, headers: CORS });
  }

  return NextResponse.json(
    { ok: true, productId, variantId: v.id, pct, previousPrice: base, newPrice: parseFloat(nextStr) },
    { headers: CORS }
  );
}
