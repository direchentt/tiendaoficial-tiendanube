import { NextRequest, NextResponse } from "next/server";
import { COOKIE_NAME, getSessionToken, verifySession } from "@/lib/admin-session";

/**
 * POST /api/admin/login
 * Body: { secret: string }
 * Sets the sa_sess cookie and returns { ok: true }
 */
export async function POST(req: NextRequest) {
  const envSecret = process.env.ADMIN_SECRET;
  if (!envSecret) {
    return NextResponse.json({ error: "ADMIN_SECRET not configured" }, { status: 500 });
  }

  const body = await req.json().catch(() => ({})) as { secret?: string };
  const secret = (body.secret ?? "").trim();

  if (secret !== envSecret) {
    return NextResponse.json({ error: "Invalid credentials" }, { status: 401 });
  }

  const token = await getSessionToken(envSecret);
  const res = NextResponse.json({ ok: true });

  // Set cookie — sin depender de Server Actions
  res.cookies.set(COOKIE_NAME, token, {
    httpOnly: true,
    path: "/",
    sameSite: "lax",
    secure: req.headers.get("x-forwarded-proto") === "https",
    maxAge: 60 * 60 * 24 * 7, // 7 días
  });

  return res;
}

/**
 * GET /api/admin/login — verifica si la sesión activa es válida
 */
export async function GET(req: NextRequest) {
  const envSecret = process.env.ADMIN_SECRET;
  const cookieHeader = req.headers.get("cookie") ?? "";
  const cookieVal = parseCookie(cookieHeader, COOKIE_NAME);
  const valid = await verifySession(envSecret, cookieVal);
  return NextResponse.json({ authenticated: valid });
}

function parseCookie(header: string, name: string): string | undefined {
  for (const part of header.split(";")) {
    const [k, ...rest] = part.trim().split("=");
    if (k?.trim() === name) return rest.join("=").trim();
  }
  return undefined;
}
