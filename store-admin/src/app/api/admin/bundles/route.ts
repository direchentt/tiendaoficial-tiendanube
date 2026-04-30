import { NextRequest, NextResponse } from "next/server";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { z } from "zod";

const bundleProductSchema = z.object({
  productId: z.number().int().positive(),
  variantId: z.number().int().default(0),
  customerPicksVariant: z.boolean().optional().default(false),
  productName: z.string().min(1),
  thumbnailUrl: z.string().max(2000).optional().nullable(),
  unitPrice: z.number().default(0),
  quantity: z.number().int().positive().default(1),
});

const createSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  comboPrice: z.number().positive(),
  imageUrl: z.string().optional(),
  enabled: z.boolean().default(true),
  /** ComboLandingPage v2 (opcional). Si se omite, el combo es “global” (/combos). */
  landingPageId: z.string().cuid().optional().nullable(),
  products: z.array(bundleProductSchema).min(1),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const { searchParams } = new URL(req.url);
  const lp = searchParams.get("landingPageId");
  const where: { storeId: string; landingPageId?: string | null } = { storeId: store.id };
  if (lp === "__none__") {
    where.landingPageId = null;
  } else if (lp && lp.length > 0) {
    where.landingPageId = lp;
  }

  const bundles = await prisma.bundle.findMany({
    where,
    include: { products: true },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json(bundles);
}

export async function POST(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const body = await req.json().catch(() => ({}));
  const parsed = createSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const { products, imageUrl, landingPageId, ...bundleData } = parsed.data;

  if (landingPageId) {
    const lp = await prisma.comboLandingPage.findFirst({
      where: { id: landingPageId, storeId: store.id },
    });
    if (!lp) {
      return NextResponse.json({ error: "landingPageId no válido para esta tienda" }, { status: 422 });
    }
  }

  const bundle = await prisma.bundle.create({
    data: {
      storeId: store.id,
      ...bundleData,
      landingPageId: landingPageId ?? null,
      imageUrl: imageUrl || null,
      products: { create: products },
    },
    include: { products: true },
  });

  await logAdminAudit({
    storeId: store.id,
    action: "bundle.create",
    entityType: "Bundle",
    entityId: bundle.id,
    summary: `Nuevo combo: ${bundle.name}`,
    meta: { enabled: bundle.enabled, comboPrice: bundle.comboPrice },
  });

  return NextResponse.json(bundle, { status: 201 });
}
