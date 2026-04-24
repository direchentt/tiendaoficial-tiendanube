import { NextRequest, NextResponse } from "next/server";
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
 * GET /api/admin/webhook-events?limit=40&offset=0
 * Últimos eventos webhook (filtrados por tienda env si hay store_id en payload).
 */
export async function GET(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const { searchParams } = new URL(req.url);
  const limit = parseLimit(searchParams.get("limit"), 40, 100);
  const offset = parseOffset(searchParams.get("offset"));
  const envUser = process.env.TN_STORE_USER_ID?.trim();

  const where =
    envUser != null && envUser !== ""
      ? {
          OR: [{ tiendanubeUserId: null }, { tiendanubeUserId: envUser }],
        }
      : {};

  const [rows, total] = await Promise.all([
    prisma.tnWebhookEvent.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: limit,
      skip: offset,
      select: {
        id: true,
        topic: true,
        tiendanubeUserId: true,
        createdAt: true,
        processedAt: true,
        processError: true,
        payload: true,
      },
    }),
    prisma.tnWebhookEvent.count({ where }),
  ]);

  const items = rows.map((r) => ({
    id: r.id,
    topic: r.topic,
    tiendanubeUserId: r.tiendanubeUserId,
    createdAt: r.createdAt.toISOString(),
    processedAt: r.processedAt?.toISOString() ?? null,
    processError: r.processError,
    payloadPreview: r.payload.slice(0, 400),
    payloadLength: r.payload.length,
  }));

  return NextResponse.json({ items, total, limit, offset });
}
