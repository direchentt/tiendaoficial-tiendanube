import { createHmac, timingSafeEqual } from "crypto";

const COOKIE_NAME = "sa_sess";
const SESSION_SALT = "store-admin-v1";

export { COOKIE_NAME };

export function getSessionToken(adminSecret: string): string {
  return createHmac("sha256", adminSecret).update(SESSION_SALT).digest("hex");
}

export function verifySession(
  adminSecret: string | undefined,
  cookieValue: string | undefined
): boolean {
  if (!adminSecret || !cookieValue) {
    return false;
  }
  const expected = getSessionToken(adminSecret);
  try {
    const a = Buffer.from(cookieValue, "utf8");
    const b = Buffer.from(expected, "utf8");
    return a.length === b.length && timingSafeEqual(a, b);
  } catch {
    return false;
  }
}
