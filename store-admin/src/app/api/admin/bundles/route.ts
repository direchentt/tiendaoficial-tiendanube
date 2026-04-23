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

const createSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  comboPrice: z.number().positive(),
  imageUrl: z.string().optional(),
  enabled: z.boolean().default(true),
  products: z.array(bundleProductSchema).min(1),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const bundles = await prisma.bundle.findMany({
    where: { storeId: store.id },
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

  const { products, imageUrl, ...bundleData } = parsed.data;

  const bundle = await prisma.bundle.create({
    data: {
      storeId: store.id,
      ...bundleData,
      imageUrl: imageUrl || null,
      products: { create: products },
    },
    include: { products: true },
  });

  return NextResponse.json(bundle, { status: 201 });
}
