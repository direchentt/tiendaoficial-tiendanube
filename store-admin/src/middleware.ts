import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

/**
 * Middleware que:
 * 1. Redirige / → /admin/login en producción
 * 2. Fija el header x-forwarded-host para que Next.js RSC no use 0.0.0.0:8080
 */
export function middleware(req: NextRequest) {
  const res = NextResponse.next();

  // Propagar el host real al servidor para que RSC payloads usen el dominio correcto
  const host = req.headers.get("host") ?? "";
  const proto = req.headers.get("x-forwarded-proto") ?? "https";
  res.headers.set("x-forwarded-host", host);
  res.headers.set("x-forwarded-proto", proto);

  return res;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for:
     * - _next/static (static files)
     * - _next/image (image optimization)
     * - favicon.ico
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
