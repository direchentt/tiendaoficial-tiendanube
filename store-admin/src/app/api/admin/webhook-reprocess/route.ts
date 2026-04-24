import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAdmin } from "@/lib/require-admin";
import { processTnWebhookEventById } from "@/lib/tn-webhook-processor";

function parseLimit(v: unknown): number {
  if (typeof v !== "number" || !Number.isFinite(v)) return 25;
  return Math.min(100, Math.max(1, Math.floor(v)));
}

/**
 * POST /api/admin/webhook-reprocess
 * Reintenta handlers para filas con `processedAt` null (p. ej. deploy previo o error transitorio).
 */
export async function POST(req: NextRequest) {
  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  let limit = 25;
  try {
    const j = (await req.json().catch(() => ({}))) as { limit?: unknown };
    limit = parseLimit(j.limit);
  } catch {
    limit = 25;
  }

  const pending = await prisma.tnWebhookEvent.findMany({
    where: { processedAt: null },
    orderBy: { createdAt: "asc" },
    take: limit,
    select: { id: true },
  });

  let processed = 0;
  for (const row of pending) {
    await processTnWebhookEventById(row.id);
    processed += 1;
  }

  return NextResponse.json({
    ok: true,
    attempted: pending.length,
    processed,
  });
}
