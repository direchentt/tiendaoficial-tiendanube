import { NextRequest, NextResponse } from "next/server";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { z } from "zod";

const slugSchema = z
  .string()
  .min(1)
  .max(120)
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, "Solo minúsculas, números y guiones");

const patchSchema = z.object({
  slug: slugSchema.optional(),
  title: z.string().min(1).max(200).optional(),
  intro: z.string().max(8000).optional().nullable(),
  enabled: z.boolean().optional(),
});

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const row = await prisma.comboLandingPage.findFirst({
    where: { id: params.id, storeId: store.id },
    include: { _count: { select: { bundles: true } } },
  });
  if (!row) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(row);
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.comboLandingPage.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const body = await req.json().catch(() => ({}));
  const parsed = patchSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const data: {
    slug?: string;
    title?: string;
    intro?: string | null;
    enabled?: boolean;
  } = {};
  if (parsed.data.slug != null) data.slug = parsed.data.slug.trim().toLowerCase();
  if (parsed.data.title != null) data.title = parsed.data.title.trim();
  if (parsed.data.intro !== undefined) data.intro = parsed.data.intro?.trim() || null;
  if (parsed.data.enabled !== undefined) data.enabled = parsed.data.enabled;

  try {
    const row = await prisma.comboLandingPage.update({
      where: { id: params.id },
      data,
    });
    await logAdminAudit({
      storeId: store.id,
      action: "combo_landing.update",
      entityType: "ComboLandingPage",
      entityId: row.id,
      summary: `Actualizada página combos v2: /${row.slug}`,
      meta: { slug: row.slug },
    });
    return NextResponse.json(row);
  } catch (e: unknown) {
    const code = e && typeof e === "object" && "code" in e ? String((e as { code?: string }).code) : "";
    if (code === "P2002") {
      return NextResponse.json({ error: "Slug ya en uso." }, { status: 409 });
    }
    throw e;
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const existing = await prisma.comboLandingPage.findFirst({
    where: { id: params.id, storeId: store.id },
  });
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });

  await prisma.comboLandingPage.delete({ where: { id: params.id } });
  await logAdminAudit({
    storeId: store.id,
    action: "combo_landing.delete",
    entityType: "ComboLandingPage",
    entityId: params.id,
    summary: `Eliminada página combos v2: /${existing.slug}`,
  });
  return new NextResponse(null, { status: 204 });
}
