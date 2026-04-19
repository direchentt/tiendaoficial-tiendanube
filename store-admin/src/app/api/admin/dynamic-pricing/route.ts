import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { ensureDefaultStore } from "@/lib/default-store";
import { z } from "zod";

const bodySchema = z.object({
  enabled: z.boolean().optional(),
  algorithm: z.enum(["seeded_random", "demand_based", "progressive"]).optional(),
  minPct: z.number().min(0).max(99).optional(),
  maxPct: z.number().min(0).max(99).optional(),
  cacheTtlHours: z.number().int().min(1).max(168).optional(),
  excludedCategoryIds: z.array(z.number().int()).optional(),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
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
    });
  }

  return NextResponse.json({
    ...config,
    excludedCategoryIds: JSON.parse(config.excludedCategoryIds),
  });
}

export async function PUT(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const body = await req.json().catch(() => ({}));
  const parsed = bodySchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const { excludedCategoryIds, ...rest } = parsed.data;
  const data = {
    ...rest,
    ...(excludedCategoryIds !== undefined
      ? { excludedCategoryIds: JSON.stringify(excludedCategoryIds) }
      : {}),
  };

  const config = await prisma.dynamicPricingConfig.upsert({
    where: { storeId: store.id },
    create: { storeId: store.id, ...data },
    update: data,
  });

  return NextResponse.json({
    ...config,
    excludedCategoryIds: JSON.parse(config.excludedCategoryIds),
  });
}
