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
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, "Solo minúsculas, números y guiones (ej. bundle, combos-verano)");

const createSchema = z.object({
  slug: slugSchema,
  title: z.string().min(1).max(200),
  intro: z.string().max(8000).optional().nullable(),
  enabled: z.boolean().optional().default(true),
});

export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const store = await ensureDefaultStore();
  const rows = await prisma.comboLandingPage.findMany({
    where: { storeId: store.id },
    orderBy: { updatedAt: "desc" },
    include: { _count: { select: { bundles: true } } },
  });
  return NextResponse.json(rows);
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

  const slug = parsed.data.slug.trim().toLowerCase();

  try {
    const row = await prisma.comboLandingPage.create({
      data: {
        storeId: store.id,
        slug,
        title: parsed.data.title.trim(),
        intro: parsed.data.intro?.trim() || null,
        enabled: parsed.data.enabled ?? true,
      },
    });
    await logAdminAudit({
      storeId: store.id,
      action: "combo_landing.create",
      entityType: "ComboLandingPage",
      entityId: row.id,
      summary: `Página combos v2: /${row.slug} — ${row.title}`,
      meta: { slug: row.slug },
    });
    return NextResponse.json(row, { status: 201 });
  } catch (e: unknown) {
    const code = e && typeof e === "object" && "code" in e ? String((e as { code?: string }).code) : "";
    if (code === "P2002") {
      return NextResponse.json(
        { error: "Ya existe una página con ese slug para esta tienda." },
        { status: 409 }
      );
    }
    throw e;
  }
}
