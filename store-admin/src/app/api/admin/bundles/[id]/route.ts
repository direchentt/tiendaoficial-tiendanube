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

const patchSchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional(),
  comboPrice: z.number().positive().optional(),
  imageUrl: z.string().optional(),
  enabled: z.boolean().optional(),
  landingPageId: z.string().cuid().nullable().optional(),
  products: z.array(bundleProductSchema).min(1).optional(),
});

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const bundle = await prisma.bundle.findFirst({
    where: { id: params.id, storeId: store.id },
    include: { products: true },
  });
  if (!bundle) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(bundle);
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.bundle.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const body = await req.json().catch(() => ({}));
  const parsed = patchSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const { products, landingPageId, ...bundleData } = parsed.data;

  if (landingPageId !== undefined && landingPageId !== null) {
    const lp = await prisma.comboLandingPage.findFirst({
      where: { id: landingPageId, storeId: store.id },
    });
    if (!lp) {
      return NextResponse.json({ error: "landingPageId no válido" }, { status: 422 });
    }
  }

  const bundle = await prisma.$transaction(async (tx) => {
    if (products) {
      await tx.bundleProduct.deleteMany({ where: { bundleId: params.id } });
    }
    return tx.bundle.update({
      where: { id: params.id },
      data: {
        ...bundleData,
        ...(landingPageId !== undefined ? { landingPageId } : {}),
        ...(products ? { products: { create: products } } : {}),
      },
      include: { products: true },
    });
  });

  await logAdminAudit({
    storeId: store.id,
    action: "bundle.update",
    entityType: "Bundle",
    entityId: params.id,
    summary: `Combo actualizado: ${bundle.name}`,
    meta: { enabled: bundle.enabled },
  });

  return NextResponse.json(bundle);
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.bundle.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  await prisma.bundle.delete({ where: { id: params.id } });
  await logAdminAudit({
    storeId: store.id,
    action: "bundle.delete",
    entityType: "Bundle",
    entityId: params.id,
    summary: `Eliminado combo: ${existing.name}`,
  });
  return new NextResponse(null, { status: 204 });
}
