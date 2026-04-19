import { COOKIE_NAME, verifySession } from "./admin-session";

/** Rutas API admin: header x-admin-secret o cookie de sesion del panel. */
export async function isAdminRequest(req: Request): Promise<boolean> {
  const secret = process.env.ADMIN_SECRET;
  if (!secret) {
    return false;
  }

  // 1. Header directo (para scripts/cron/testing)
  const hdr = req.headers.get("x-admin-secret");
  if (hdr === secret) {
    return true;
  }

  // 2. Cookie del browser — leemos del header Cookie del request directamente
  //    (más confiable que cookies() de next/headers en Route Handlers)
  const cookieHeader = req.headers.get("cookie") ?? "";
  const cookieVal = parseCookie(cookieHeader, COOKIE_NAME);
  if (cookieVal) {
    return verifySession(secret, cookieVal);
  }

  return false;
}

function parseCookie(header: string, name: string): string | undefined {
  for (const part of header.split(";")) {
    const [k, ...rest] = part.trim().split("=");
    if (k?.trim() === name) {
      return rest.join("=").trim();
    }
  }
  return undefined;
}
