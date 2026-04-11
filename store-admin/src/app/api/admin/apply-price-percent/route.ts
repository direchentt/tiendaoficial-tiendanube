import { NextResponse } from "next/server";
import { z } from "zod";
import { isAdminRequest } from "@/lib/admin-api-auth";
import {
  getProductsPage,
  patchProductsStockPrice,
  type ProductListItem,
  type StockPricePatchRow,
  type TiendanubeClientConfig,
} from "@/lib/tiendanube-client";

export const runtime = "nodejs";
export const maxDuration = 300;

const bodySchema = z.object({
  percent: z.number().min(-99).max(1000),
  dryRun: z.boolean().optional(),
  maxPages: z.number().min(1).max(500).optional(),
});

function roundPrice(n: number): string {
  return (Math.round(n * 100) / 100).toFixed(2);
}

function parsePrice(p: string | null | undefined): number {
  if (p == null || p === "") {
    return 0;
  }
  const n = parseFloat(String(p).replace(",", "."));
  return Number.isFinite(n) ? n : 0;
}

/**
 * Aplica un porcentaje sobre el precio actual de cada variante (lee GET /products paginado, PATCH /products/stock-price en lotes de 50 variantes).
 * Proteger con ADMIN_SECRET; en produccion usar cola (Inngest, Bull) por rate limits de TN.
 */
export async function POST(req: Request) {
  if (!(await isAdminRequest(req))) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  const userId = process.env.TN_STORE_USER_ID;
  const token = process.env.TN_ACCESS_TOKEN;
  const ua = process.env.TN_USER_AGENT;
  if (!userId || !token || !ua) {
    return NextResponse.json(
      { error: "missing_env", need: ["TN_STORE_USER_ID", "TN_ACCESS_TOKEN", "TN_USER_AGENT"] },
      { status: 500 }
    );
  }

  let json: unknown;
  try {
    json = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const { percent, dryRun, maxPages } = parsed.data;
  const factor = 1 + percent / 100;

  const config: TiendanubeClientConfig = {
    storeUserId: userId,
    accessToken: token,
    userAgent: ua,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  const allVariants: { productId: number; variantId: number; nextPrice: string }[] = [];
  const limitPages = maxPages ?? 200;

  for (let page = 1; page <= limitPages; page += 1) {
    let products: ProductListItem[];
    try {
      products = await getProductsPage(config, page);
    } catch (e) {
      return NextResponse.json(
        { error: "tn_fetch_failed", page, message: String(e) },
        { status: 502 }
      );
    }
    if (!products.length) {
      break;
    }
    for (const p of products) {
      const variants = p.variants ?? [];
      for (const v of variants) {
        if (v.id == null) {
          continue;
        }
        const base = parsePrice(v.price ?? null);
        if (base <= 0) {
          continue;
        }
        allVariants.push({
          productId: p.id,
          variantId: v.id,
          nextPrice: roundPrice(base * factor),
        });
      }
    }
    if (products.length < 30) {
      break;
    }
  }

  if (dryRun) {
    return NextResponse.json({
      dryRun: true,
      variantCount: allVariants.length,
      sample: allVariants.slice(0, 15),
    });
  }

  const patchBodies: StockPricePatchRow[][] = [];
  let currentBody: StockPricePatchRow[] = [];
  let variantsInBody = 0;

  const flushBody = () => {
    if (currentBody.length) {
      patchBodies.push(currentBody);
      currentBody = [];
      variantsInBody = 0;
    }
  };

  const addVariant = (productId: number, variantId: number, price: string) => {
    if (variantsInBody >= 50) {
      flushBody();
    }
    let row = currentBody.find((r) => r.id === productId);
    if (!row) {
      row = { id: productId, variants: [] };
      currentBody.push(row);
    }
    row.variants.push({ id: variantId, price });
    variantsInBody += 1;
  };

  for (const row of allVariants) {
    addVariant(row.productId, row.variantId, row.nextPrice);
  }
  flushBody();

  let patchesSent = 0;
  for (const body of patchBodies) {
    try {
      await patchProductsStockPrice(config, body);
      patchesSent += 1;
    } catch (e) {
      return NextResponse.json(
        {
          error: "patch_failed",
          patchesSent,
          message: String(e),
          failedPatch: body,
        },
        { status: 502 }
      );
    }
  }

  return NextResponse.json({
    ok: true,
    variantsUpdated: allVariants.length,
    patchesSent,
  });
}
