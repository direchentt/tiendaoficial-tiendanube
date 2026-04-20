import { NextRequest, NextResponse } from "next/server";
import { COOKIE_NAME, verifySession } from "@/lib/admin-session";
import { requireAdmin } from "@/lib/require-admin";
import { adminDebugEndpointsDisabled } from "@/lib/admin-debug";

/**
 * GET /api/admin/debug-auth
 * Solo en desarrollo, o en producción con ALLOW_ADMIN_DEBUG=1 (y sesión admin válida).
 */
export async function GET(req: NextRequest) {
  if (adminDebugEndpointsDisabled()) {
    return new NextResponse(null, { status: 404 });
  }

  const unauth = await requireAdmin(req);
  if (unauth) return unauth;

  const cookieHeader = req.headers.get("cookie") ?? "";
  const adminSecret = req.headers.get("x-admin-secret");
  const envSecret = process.env.ADMIN_SECRET;

  function parseCookie(header: string, name: string): string | undefined {
    for (const part of header.split(";")) {
      const [k, ...rest] = part.trim().split("=");
      if (k?.trim() === name) return rest.join("=").trim();
    }
  }

  const cookieVal = parseCookie(cookieHeader, COOKIE_NAME);
  const sessionValid = await verifySession(envSecret, cookieVal);
  const headerMatch = adminSecret === envSecret;

  return NextResponse.json({
    sessionValid,
    headerMatch,
    cookieName: COOKIE_NAME,
    cookiePresent: !!cookieVal,
    envSecretConfigured: !!envSecret,
    host: req.headers.get("host"),
    proto: req.headers.get("x-forwarded-proto"),
  });
}
