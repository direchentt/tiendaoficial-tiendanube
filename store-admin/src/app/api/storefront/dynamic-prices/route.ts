import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * Seeded pseudo-random: stable by productId + date string (same product = same price all day).
 */
function seededRandom(seed: number): number {
  const x = Math.sin(seed) * 10000;
  return x - Math.floor(x);
}

function getDateSeed(): number {
  const d = new Date();
  return d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate();
}

function calcSeededRandom(productId: number, minPct: number, maxPct: number): number {
  const seed = productId * 31337 + getDateSeed();
  const r = seededRandom(seed);
  return Math.round((minPct + r * (maxPct - minPct)) * 10) / 10;
}

/**
 * Demand-based: discount highest at 4–6am, lowest at midday.
 * Maps hour of day to a curve: hour 4 = max, hour 12 = min.
 */
function calcDemandBased(productId: number, minPct: number, maxPct: number): number {
  const hour = new Date().getHours();
  // Cosine wave: peaks at hour=4, troughs at hour=16
  const normalized = (Math.cos(((hour - 4) * Math.PI) / 12) + 1) / 2; // 0-1
  const pct = minPct + normalized * (maxPct - minPct);
  // Add small per-product variation so products don't all show same price
  const noise = seededRandom(productId * 9973) * 2 - 1; // -1 to +1
  return Math.max(minPct, Math.min(maxPct, Math.round((pct + noise) * 10) / 10));
}

/**
 * Progressive: discount increases by increments for returning visitors.
 * The "visit count" is passed as a query param from localStorage.
 */
function calcProgressive(
  productId: number,
  minPct: number,
  maxPct: number,
  visitCount: number
): number {
  // Caps at 10 visits for max discount
  const t = Math.min(visitCount, 10) / 10;
  const base = minPct + t * (maxPct - minPct);
  const noise = seededRandom(productId * 7919) * (maxPct - minPct) * 0.1;
  return Math.max(minPct, Math.min(maxPct, Math.round((base + noise) * 10) / 10));
}

/**
 * GET /api/storefront/dynamic-prices?storeId=<id>&products=1,2,3&visitCount=<n>
 * Returns { [productId]: { pct, multiplier, cacheTtlHours } }
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = searchParams.get("storeId");
  const productsParam = searchParams.get("products") ?? "";
  const visitCount = parseInt(searchParams.get("visitCount") ?? "1", 10);

  if (!storeUserId) {
    return NextResponse.json(
      { error: "storeId is required" },
      { status: 400, headers: CORS }
    );
  }

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
  });

  if (!store) {
    return NextResponse.json({ prices: {}, enabled: false }, { headers: CORS });
  }

  const config = await prisma.dynamicPricingConfig.findUnique({
    where: { storeId: store.id },
  });

  if (!config || !config.enabled) {
    return NextResponse.json({ prices: {}, enabled: false }, { headers: CORS });
  }

  const productIds = productsParam
    .split(",")
    .map((s) => parseInt(s.trim(), 10))
    .filter((n) => !isNaN(n) && n > 0);

  /** Lista guardada en Prisma como `excludedCategoryIds`; hoy se interpreta como IDs de producto TN a omitir. */
  const excludedProductIds: number[] = JSON.parse(config.excludedCategoryIds || "[]");

  const prices: Record<string, { pct: number; multiplier: number }> = {};

  for (const pid of productIds) {
    if (excludedProductIds.includes(pid)) continue;

    let pct: number;
    switch (config.algorithm) {
      case "demand_based":
        pct = calcDemandBased(pid, config.minPct, config.maxPct);
        break;
      case "progressive":
        pct = calcProgressive(pid, config.minPct, config.maxPct, visitCount);
        break;
      default:
        pct = calcSeededRandom(pid, config.minPct, config.maxPct);
    }

    prices[String(pid)] = {
      pct,
      multiplier: Math.round((1 - pct / 100) * 10000) / 10000,
    };
  }

  return NextResponse.json(
    { prices, enabled: true, cacheTtlHours: config.cacheTtlHours, algorithm: config.algorithm },
    { headers: CORS }
  );
}
