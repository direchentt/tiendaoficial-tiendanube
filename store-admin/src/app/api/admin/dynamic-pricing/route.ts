import { NextRequest, NextResponse } from "next/server";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { z } from "zod";

function parseExcludedCategoryIds(raw: string | null | undefined): number[] {
  if (raw == null || raw.trim() === "") return [];
  try {
    const v = JSON.parse(raw) as unknown;
    if (!Array.isArray(v)) return [];
    return v.filter((x): x is number => typeof x === "number" && Number.isInteger(x) && x > 0);
  } catch {
    return [];
  }
}

/** JSON a veces manda `null` (p. ej. NaN serializado) — normalizamos antes de validar. */
const optPct = z.preprocess((v) => {
  if (v === undefined || v === null || v === "") return undefined;
  const n = typeof v === "number" ? v : parseFloat(String(v));
  return Number.isFinite(n) ? n : undefined;
}, z.number().min(0).max(99).optional());

const optCacheTtl = z.preprocess((v) => {
  if (v === undefined) return undefined;
  if (v === null || v === "") return 4;
  const n = typeof v === "number" ? v : parseInt(String(v), 10);
  if (!Number.isFinite(n)) return 4;
  return Math.min(168, Math.max(1, n));
}, z.number().int().min(1).max(168).optional());

const bodySchema = z.object({
  enabled: z.boolean().optional(),
  algorithm: z.enum(["seeded_random", "demand_based", "progressive"]).optional(),
  minPct: optPct,
  maxPct: optPct,
  cacheTtlHours: optCacheTtl,
  excludedCategoryIds: z.array(z.number().int()).optional(),
  commitOnAddToCart: z.boolean().optional(),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  let store;
  try {
    store = await ensureDefaultStore();
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Tienda no configurada";
    return NextResponse.json({ error: msg }, { status: 503 });
  }

  try {
    const config = await prisma.dynamicPricingConfig.findUnique({
      where: { storeId: store.id },
    });

    if (!config) {
      return NextResponse.json({
        enabled: false,
        algorithm: "seeded_random",
        minPct: 5,
        maxPct: 20,
        cacheTtlHours: 4,
        excludedCategoryIds: [],
        commitOnAddToCart: false,
      });
    }

    return NextResponse.json({
      enabled: config.enabled,
      algorithm: config.algorithm,
      minPct: config.minPct ?? 5,
      maxPct: config.maxPct ?? 20,
      cacheTtlHours: config.cacheTtlHours ?? 4,
      excludedCategoryIds: parseExcludedCategoryIds(config.excludedCategoryIds),
      commitOnAddToCart: config.commitOnAddToCart,
    });
  } catch (e) {
    const isDev = process.env.NODE_ENV === "development";
    const msg = e instanceof Error ? e.message : "Error al leer la configuración";
    return NextResponse.json(
      { error: isDev ? msg : "Error al leer la configuración." },
      { status: 500 }
    );
  }
}

export async function PUT(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  let store;
  try {
    store = await ensureDefaultStore();
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Tienda no configurada";
    return NextResponse.json({ error: msg }, { status: 503 });
  }

  const body = await req.json().catch(() => ({}));
  const parsed = bodySchema.safeParse(body);
  if (!parsed.success) {
    const msg = parsed.error.issues
      .map((i) => `${i.path.length ? i.path.join(".") : "dato"}: ${i.message}`)
      .join("; ");
    return NextResponse.json({ error: msg || "Datos inválidos" }, { status: 422 });
  }

  const { excludedCategoryIds, ...rest } = parsed.data;
  const data = {
    ...rest,
    ...(excludedCategoryIds !== undefined
      ? { excludedCategoryIds: JSON.stringify(excludedCategoryIds) }
      : {}),
  };

  try {
    const config = await prisma.dynamicPricingConfig.upsert({
      where: { storeId: store.id },
      create: { storeId: store.id, ...data },
      update: data,
    });

    await logAdminAudit({
      storeId: store.id,
      action: "dynamic_pricing.upsert",
      entityType: "DynamicPricingConfig",
      entityId: config.id,
      summary: `Precios dinámicos: ${config.enabled ? "activo" : "inactivo"} · ${config.algorithm}`,
      meta: {
        enabled: config.enabled,
        algorithm: config.algorithm,
        minPct: config.minPct,
        maxPct: config.maxPct,
        commitOnAddToCart: config.commitOnAddToCart,
      },
    });

    return NextResponse.json({
      enabled: config.enabled,
      algorithm: config.algorithm,
      minPct: config.minPct ?? 5,
      maxPct: config.maxPct ?? 20,
      cacheTtlHours: config.cacheTtlHours ?? 4,
      excludedCategoryIds: parseExcludedCategoryIds(config.excludedCategoryIds),
      commitOnAddToCart: config.commitOnAddToCart,
    });
  } catch (e) {
    const isDev = process.env.NODE_ENV === "development";
    const msg = e instanceof Error ? e.message : "Error al guardar";
    return NextResponse.json(
      { error: isDev ? msg : "No se pudo guardar la configuración." },
      { status: 500 }
    );
  }
}
