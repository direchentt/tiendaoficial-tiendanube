import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { COOKIE_NAME } from "@/lib/admin-session";

export async function GET(req: Request) {
  cookies().delete(COOKIE_NAME);
  const url = new URL(req.url);
  url.pathname = "/admin/login";
  return NextResponse.redirect(url);
}
