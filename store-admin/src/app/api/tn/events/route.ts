import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { verifyLinkedStoreHmacSha256 } from "@/lib/tn-webhook-hmac";
import { processTnWebhookEventById } from "@/lib/tn-webhook-processor";

const MAX_PAYLOAD = 50_000;

function extractTopicFromHeaders(req: NextRequest): string {
  const h =
    req.headers.get("x-tn-event") ||
    req.headers.get("x-event-name") ||
    req.headers.get("x-nuvemshop-event") ||
    req.headers.get("x-tiendanube-event") ||
    "";
  const t = h.trim().slice(0, 160);
  return t;
}

function extractEventFromJson(raw: string): string {
  try {
    const j = JSON.parse(raw) as Record<string, unknown>;
    const ev = j.event;
    if (typeof ev === "string" && ev.trim()) return ev.trim().slice(0, 160);
  } catch {
    /* no JSON */
  }
  return "";
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

function getLinkedStoreHmacHeader(req: NextRequest): string | null {
  return req.headers.get("x-linkedstore-hmac-sha256");
}

/**
 * POST /api/tn/events
 * Ingesta de webhooks Nuvemshop (API) o integraciones custom.
 *
 * **Oficial (app OAuth):** header `x-linkedstore-hmac-sha256` + env `TN_WEBHOOK_APP_SECRET`
 * (secreto de la app, mismo que usa la doc de TN para `hash_hmac`).
 *
 * **Custom (sin HMAC TN):** `x-hache-webhook-secret` o `x-tn-webhook-secret` = `TN_WEBHOOK_SECRET`.
 *
 * Topic: headers `x-tn-event` / `x-event-name`, o campo JSON `event` (ej. `product/created`).
 */
export async function POST(req: NextRequest) {
  const raw = await req.text();
  const hmacHeader = getLinkedStoreHmacHeader(req)?.trim() || null;
  const appSecret = process.env.TN_WEBHOOK_APP_SECRET?.trim();

  if (hmacHeader) {
    if (!appSecret) {
      return NextResponse.json(
        {
          error:
            "TN_WEBHOOK_APP_SECRET no configurado (obligatorio cuando el request incluye x-linkedstore-hmac-sha256)",
        },
        { status: 503 }
      );
    }
    if (!verifyLinkedStoreHmacSha256(raw, hmacHeader, appSecret)) {
      return NextResponse.json({ error: "Invalid HMAC" }, { status: 401 });
    }
  } else {
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
  }

  const headerTopic = extractTopicFromHeaders(req);
  const bodyEvent = extractEventFromJson(raw);
  const topic = (headerTopic || bodyEvent || "unknown").slice(0, 160);
  const tiendanubeUserId = extractStoreUserIdFromJson(raw);
  const payload = raw.length > MAX_PAYLOAD ? raw.slice(0, MAX_PAYLOAD) : raw;

  try {
    const row = await prisma.tnWebhookEvent.create({
      data: {
        topic,
        tiendanubeUserId,
        payload,
      },
    });
    void processTnWebhookEventById(row.id).catch((e) => {
      console.error("[tn/events] processTnWebhookEventById", row.id, e);
    });
  } catch (e) {
    console.error("[tn/events]", e);
    return NextResponse.json({ error: "persist_failed" }, { status: 500 });
  }

  return NextResponse.json({ ok: true });
}
