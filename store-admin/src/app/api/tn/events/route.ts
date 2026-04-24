import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

const MAX_PAYLOAD = 50_000;

function extractTopic(req: NextRequest): string {
  const h =
    req.headers.get("x-tn-event") ||
    req.headers.get("x-event-name") ||
    req.headers.get("x-nuvemshop-event") ||
    "";
  const t = h.trim().slice(0, 160);
  return t || "unknown";
}

function extractStoreUserIdFromJson(raw: string): string | null {
  try {
    const j = JSON.parse(raw) as Record<string, unknown>;
    const sid = j.store_id ?? j.user_id ?? j.storeId;
    if (typeof sid === "number" && sid > 0) return String(sid);
    if (typeof sid === "string" && /^\d{1,24}$/.test(sid.trim())) return sid.trim();
  } catch {
    /* vacío o no JSON */
  }
  return null;
}

/**
 * POST /api/tn/events
 * Ingesta genérica de webhooks (pedidos, productos, etc.). Protegé con TN_WEBHOOK_SECRET.
 *
 * Headers soportados: `x-hache-webhook-secret` o `x-tn-webhook-secret` = valor de env.
 * Topic opcional: `x-tn-event`, `x-event-name`.
 */
export async function POST(req: NextRequest) {
  const secret = process.env.TN_WEBHOOK_SECRET?.trim();
  if (!secret) {
    return NextResponse.json(
      { error: "TN_WEBHOOK_SECRET no configurado en el servidor" },
      { status: 503 }
    );
  }

  const hdr =
    req.headers.get("x-hache-webhook-secret")?.trim() ||
    req.headers.get("x-tn-webhook-secret")?.trim() ||
    req.headers.get("authorization")?.replace(/^\s*Bearer\s+/i, "").trim();

  if (hdr !== secret) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const raw = await req.text();
  const topic = extractTopic(req);
  const tiendanubeUserId = extractStoreUserIdFromJson(raw);
  const payload = raw.length > MAX_PAYLOAD ? raw.slice(0, MAX_PAYLOAD) : raw;

  try {
    await prisma.tnWebhookEvent.create({
      data: {
        topic,
        tiendanubeUserId,
        payload,
      },
    });
  } catch (e) {
    console.error("[tn/events]", e);
    return NextResponse.json({ error: "persist_failed" }, { status: 500 });
  }

  return NextResponse.json({ ok: true });
}
