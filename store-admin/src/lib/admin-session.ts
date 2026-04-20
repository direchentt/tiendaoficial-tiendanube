const COOKIE_NAME = "sa_sess";
const SESSION_SALT = "store-admin-v1";

export { COOKIE_NAME };

/**
 * HMAC-SHA256 en hex (Web Crypto, compatible con Node en Server Components y route handlers).
 */
export async function getSessionToken(adminSecret: string): Promise<string> {
  const secret = adminSecret.trim();
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(SESSION_SALT));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function timingSafeEqualUtf8(a: string, b: string): boolean {
  const enc = new TextEncoder();
  const ba = enc.encode(a);
  const bb = enc.encode(b);
  if (ba.length !== bb.length) {
    return false;
  }
  let diff = 0;
  for (let i = 0; i < ba.length; i++) {
    diff |= ba[i]! ^ bb[i]!;
  }
  return diff === 0;
}

export async function verifySession(
  adminSecret: string | undefined,
  cookieValue: string | undefined
): Promise<boolean> {
  const s = adminSecret?.trim();
  const c = cookieValue?.trim();
  if (!s || !c) {
    return false;
  }
  const expected = await getSessionToken(s);
  return timingSafeEqualUtf8(c, expected);
}
