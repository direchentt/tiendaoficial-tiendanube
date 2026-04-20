import { COOKIE_NAME, verifySession } from "./admin-session";

/** Extrae token de `Authorization: Bearer <token>` (Postman, integraciones). */
function bearerToken(authHeader: string | null): string | undefined {
  if (!authHeader) return undefined;
  const m = authHeader.match(/^\s*Bearer\s+(.+)$/i);
  return m?.[1]?.trim();
}

/**
 * Rutas API admin: `x-admin-secret`, `Authorization: Bearer` (mismo valor que ADMIN_SECRET),
 * o cookie httpOnly de sesión tras /admin/login.
 */
export async function isAdminRequest(req: Request): Promise<boolean> {
  const secret = process.env.ADMIN_SECRET?.trim();
  if (!secret) {
    return false;
  }

  const hdr = req.headers.get("x-admin-secret")?.trim();
  if (hdr === secret) {
    return true;
  }

  const bearer = bearerToken(req.headers.get("authorization"));
  if (bearer === secret) {
    return true;
  }

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
