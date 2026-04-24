import { NextRequest, NextResponse } from "next/server";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";

function parseLimit(v: string | null, fallback: number, max: number): number {
  const n = parseInt(v ?? "", 10);
  if (!Number.isFinite(n)) return fallback;
  return Math.min(max, Math.max(1, n));
}

function parseOffset(v: string | null): number {
  const n = parseInt(v ?? "", 10);
  if (!Number.isFinite(n) || n < 0) return 0;
  return Math.min(10_000, n);
}

/**
 * GET /api/admin/audit-log?limit=80&offset=0
 * Historial de cambios en el panel para la tienda por defecto (TN_STORE_USER_ID).
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  let store;
  try {
    store = await ensureDefaultStore();
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Tienda no configurada";
    return NextResponse.json({ error: msg, items: [], total: 0 }, { status: 503 });
  }

  const { searchParams } = new URL(req.url);
  const limit = parseLimit(searchParams.get("limit"), 80, 200);
  const offset = parseOffset(searchParams.get("offset"));

  const where = { storeId: store.id };

  const [rows, total] = await Promise.all([
    prisma.adminAuditLog.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: limit,
      skip: offset,
    }),
    prisma.adminAuditLog.count({ where }),
  ]);

  return NextResponse.json({
    items: rows.map((r) => ({
      id: r.id,
      action: r.action,
      entityType: r.entityType,
      entityId: r.entityId,
      summary: r.summary,
      meta: r.meta,
      createdAt: r.createdAt.toISOString(),
    })),
    total,
    limit,
    offset,
  });
}
