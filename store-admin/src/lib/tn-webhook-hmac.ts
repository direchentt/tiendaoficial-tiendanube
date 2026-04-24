import { createHmac, timingSafeEqual } from "node:crypto";

/**
 * Firma oficial Nuvemshop / Tiendanube (PHP `hash_hmac('sha256', $data, $secret)` → hex).
 * @see https://tiendanube.github.io/api-documentation/resources/webhook
 */
export function linkedStoreHmacSha256Hex(rawBody: string, appSecret: string): string {
  return createHmac("sha256", appSecret).update(rawBody, "utf8").digest("hex");
}

export function verifyLinkedStoreHmacSha256(
  rawBody: string,
  headerValue: string | null | undefined,
  appSecret: string
): boolean {
  const h = typeof headerValue === "string" ? headerValue.trim() : "";
  if (!h || !appSecret) return false;
  const expected = linkedStoreHmacSha256Hex(rawBody, appSecret);
  if (expected.length !== h.length) return false;
  try {
    return timingSafeEqual(Buffer.from(expected, "utf8"), Buffer.from(h.toLowerCase(), "utf8"));
  } catch {
    return false;
  }
}
