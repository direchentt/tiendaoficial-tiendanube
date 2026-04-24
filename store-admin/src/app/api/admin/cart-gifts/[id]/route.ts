import { NextRequest, NextResponse } from "next/server";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { z } from "zod";

const patchSchema = z.object({
  name: z.string().min(1).optional(),
  minTotal: z.number().positive().optional(),
  giftProductId: z.number().int().positive().optional(),
  giftVariantId: z.number().int().positive().optional(),
  giftQty: z.number().int().positive().optional(),
  enabled: z.boolean().optional(),
  publicBenefitTitle: z.string().max(200).optional().nullable(),
  publicBenefitMessage: z.string().max(2000).optional().nullable(),
});

export async function PATCH(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.cartGiftRule.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const body = await req.json().catch(() => ({}));
  const parsed = patchSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const updated = await prisma.cartGiftRule.update({
    where: { id: params.id },
    data: parsed.data,
  });
  await logAdminAudit({
    storeId: store.id,
    action: "cart_gift.update",
    entityType: "CartGiftRule",
    entityId: params.id,
    summary: `Regalo en carrito actualizado: ${updated.name}`,
    meta: parsed.data as Record<string, unknown>,
  });
  return NextResponse.json(updated);
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.cartGiftRule.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  await prisma.cartGiftRule.delete({ where: { id: params.id } });
  await logAdminAudit({
    storeId: store.id,
    action: "cart_gift.delete",
    entityType: "CartGiftRule",
    entityId: params.id,
    summary: `Eliminada regla regalo: ${existing.name}`,
  });
  return new NextResponse(null, { status: 204 });
}
