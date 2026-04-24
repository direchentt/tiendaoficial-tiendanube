import { NextRequest, NextResponse } from "next/server";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { z } from "zod";

const bodySchema = z.object({
  name: z.string().min(1),
  minTotal: z.number().positive(),
  giftProductId: z.number().int().positive(),
  giftVariantId: z.number().int().positive(),
  giftQty: z.number().int().positive().default(1),
  enabled: z.boolean().default(true),
  publicBenefitTitle: z.string().max(200).optional().nullable(),
  publicBenefitMessage: z.string().max(2000).optional().nullable(),
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

  let store;
  try {
    store = await ensureDefaultStore();
  } catch (e) {
    const msg = e instanceof Error ? e.message : "No se pudo cargar la tienda";
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

  try {
    const rule = await prisma.cartGiftRule.create({
      data: { storeId: store.id, ...parsed.data },
    });
    await logAdminAudit({
      storeId: store.id,
      action: "cart_gift.create",
      entityType: "CartGiftRule",
      entityId: rule.id,
      summary: `Regalo en carrito: ${rule.name} (mín. ${rule.minTotal})`,
      meta: { giftProductId: rule.giftProductId, enabled: rule.enabled },
    });
    return NextResponse.json(rule, { status: 201 });
  } catch (e) {
    const isDev = process.env.NODE_ENV === "development";
    const msg = e instanceof Error ? e.message : "Error al guardar";
    return NextResponse.json(
      { error: isDev ? msg : "No se pudo guardar la regla. Revisá la base de datos o los logs." },
      { status: 500 }
    );
  }
}
