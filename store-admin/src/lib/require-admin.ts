import { NextRequest, NextResponse } from "next/server";
import { isAdminRequest } from "./admin-api-auth";

/**
 * Convenience wrapper for API route handlers.
 * Usage: const unauth = await requireAdmin(req); if (unauth) return unauth;
 */
export async function requireAdmin(req: NextRequest): Promise<NextResponse | null> {
  const isDev = process.env.NODE_ENV === "development";

  if (!process.env.ADMIN_SECRET?.trim()) {
    return NextResponse.json(
      {
        error: "Server misconfiguration",
        ...(isDev && {
          detail:
            "ADMIN_SECRET no está definido en las variables de entorno del servicio (Railway / .env). Sin eso el panel y las APIs /api/admin/* no pueden autenticar.",
        }),
      },
      { status: 503 }
    );
  }

  const ok = await isAdminRequest(req);
  if (!ok) {
    return NextResponse.json(
      {
        error: "Unauthorized",
        ...(isDev && {
          detail:
            "Enviá el header x-admin-secret con el mismo valor que ADMIN_SECRET, o iniciá sesión en /admin/login desde el navegador (cookie de sesión). Las rutas /api/storefront/* no requieren este secreto.",
        }),
      },
      { status: 401 }
    );
  }
  return null;
}
