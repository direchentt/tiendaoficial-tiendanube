import { NextRequest, NextResponse } from "next/server";
import { COOKIE_NAME, verifySession } from "@/lib/admin-session";

/**
 * GET /api/admin/debug-auth
 * Diagnóstico de autenticación — SOLO para desarrollo/debugging.
 * Eliminar o proteger en producción luego de debuggear.
 */
export async function GET(req: NextRequest) {
  const cookieHeader = req.headers.get("cookie") ?? "";
  const adminSecret = req.headers.get("x-admin-secret");
  const envSecret = process.env.ADMIN_SECRET;

  // Parsear cookie
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
    // Auth state
    sessionValid,
    headerMatch,
    // Cookie info
    cookieName: COOKIE_NAME,
    cookiePresent: !!cookieVal,
    cookieLength: cookieVal?.length ?? 0,
    // Env info (sin revelar el valor real)
    envSecretConfigured: !!envSecret,
    envSecretLength: envSecret?.length ?? 0,
    // Headers
    host: req.headers.get("host"),
    proto: req.headers.get("x-forwarded-proto"),
    origin: req.headers.get("origin"),
    referer: req.headers.get("referer"),
    // Para verificar: si mandás x-admin-secret: TU_SECRET y ves headerMatch: true, el secret está OK
    // Si sessionValid es false pero cookiePresent es true, el token de la cookie no coincide con el secret actual
  });
}
