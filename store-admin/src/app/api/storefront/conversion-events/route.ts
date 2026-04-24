import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { isConversionEventType } from "@/lib/conversion-events";
import { loadStoreForStorefront } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { parseStorefrontStoreUserId } from "@/lib/storefront-limits";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const bodySchema = z.object({
  storeId: z.string().min(1),
  type: z.string().refine(isConversionEventType, "invalid type"),
  productId: z.number().int().positive().optional(),
  categoryId: z.number().int().positive().optional(),
  path: z.string().max(512).optional(),
});

const rl = new Map<string, number[]>();
function rateOk(ip: string, maxPerMinute: number): boolean {
  const now = Date.now();
  const windowMs = 60_000;
  const arr = (rl.get(ip) ?? []).filter((t) => now - t < windowMs);
  if (arr.length >= maxPerMinute) return false;
  arr.push(now);
  rl.set(ip, arr);
  return true;
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * POST /api/storefront/conversion-events
 * Ingesta ligera para embudo CVR (hache-suite.js). Requiere fila Store conocida.
 */
export async function POST(req: NextRequest) {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() || "unknown";
  if (!rateOk(ip, 300)) {
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
    return NextResponse.json({ error: "validation", details: parsed.error.flatten() }, { status: 422, headers: CORS });
  }

  const storeUserId = parseStorefrontStoreUserId(parsed.data.storeId);
  if (!storeUserId) {
    return NextResponse.json(
      { error: "invalid_store_id", hint: "Id numérico de la tienda (LS.store.id)." },
      { status: 400, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return new NextResponse(null, { status: 204, headers: CORS });
  }

  const { type, productId, categoryId, path } = parsed.data;

  try {
    await prisma.conversionEvent.create({
      data: {
        storeId: store.id,
        type,
        productId: productId ?? null,
        categoryId: categoryId ?? null,
        path: path?.trim() || null,
      },
    });
  } catch (e) {
    console.error("[conversion-events]", e);
    return NextResponse.json({ error: "persist_failed" }, { status: 500, headers: CORS });
  }

  return NextResponse.json({ ok: true }, { headers: CORS });
}
