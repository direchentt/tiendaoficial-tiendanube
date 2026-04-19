import { NextRequest, NextResponse } from "next/server";
import { isAdminRequest } from "./admin-api-auth";

/**
 * Convenience wrapper for API route handlers.
 * Usage: const unauth = await requireAdmin(req); if (unauth) return unauth;
 */
export async function requireAdmin(req: NextRequest): Promise<NextResponse | null> {
  const ok = await isAdminRequest(req);
  if (!ok) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  return null;
}
