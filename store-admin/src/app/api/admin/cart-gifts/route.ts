import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { ensureDefaultStore } from "@/lib/default-store";
import { z } from "zod";

const bodySchema = z.object({
  name: z.string().min(1),
  minTotal: z.number().positive(),
  giftProductId: z.number().int().positive(),
  giftVariantId: z.number().int().positive(),
  giftQty: z.number().int().positive().default(1),
  enabled: z.boolean().default(true),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const rules = await prisma.cartGiftRule.findMany({
    where: { storeId: store.id },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json(rules);
}

export async function POST(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const body = await req.json().catch(() => ({}));
  const parsed = bodySchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const rule = await prisma.cartGiftRule.create({
    data: { storeId: store.id, ...parsed.data },
  });
  return NextResponse.json(rule, { status: 201 });
}
