/**
 * Parsing puro para ingesta de webhooks (testeable sin NextRequest).
 */

export type HeaderGetter = (name: string) => string | null;

export function extractTopicFromHeaders(getHeader: HeaderGetter): string {
  const h =
    getHeader("x-tn-event") ||
    getHeader("x-event-name") ||
    getHeader("x-nuvemshop-event") ||
    getHeader("x-tiendanube-event") ||
    "";
  return h.trim().slice(0, 160);
}

export function extractEventFromJson(raw: string): string {
  try {
    const j = JSON.parse(raw) as Record<string, unknown>;
    const ev = j.event;
    if (typeof ev === "string" && ev.trim()) return ev.trim().slice(0, 160);
  } catch {
    /* no JSON */
  }
  return "";
}

export function extractStoreUserIdFromJson(raw: string): string | null {
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

export function resolveTnWebhookTopic(getHeader: HeaderGetter, rawBody: string): string {
  const headerTopic = extractTopicFromHeaders(getHeader);
  const bodyEvent = extractEventFromJson(rawBody);
  return (headerTopic || bodyEvent || "unknown").slice(0, 160);
}
