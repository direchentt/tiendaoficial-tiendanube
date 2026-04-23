import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { ensureDefaultStore } from "@/lib/default-store";
import { z } from "zod";

const bundleProductSchema = z.object({
  productId: z.number().int().positive(),
  variantId: z.number().int().default(0),
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

  const { products, ...bundleData } = parsed.data;

  const bundle = await prisma.$transaction(async (tx) => {
    if (products) {
      await tx.bundleProduct.deleteMany({ where: { bundleId: params.id } });
    }
    return tx.bundle.update({
      where: { id: params.id },
      data: {
        ...bundleData,
        ...(products ? { products: { create: products } } : {}),
      },
      include: { products: true },
    });
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
  return new NextResponse(null, { status: 204 });
}
