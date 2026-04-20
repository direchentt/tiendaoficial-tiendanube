"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { COOKIE_NAME, getSessionToken } from "@/lib/admin-session";

export type LoginState = { error?: string };

export async function loginAction(
  _prev: LoginState | undefined,
  formData: FormData
): Promise<LoginState> {
  const secret = String(formData.get("secret") ?? "").trim();
  const envSecret = process.env.ADMIN_SECRET?.trim();
  if (!envSecret) {
    return { error: "ADMIN_SECRET no configurado en el servidor." };
  }
  if (secret !== envSecret) {
    return { error: "Clave incorrecta." };
  }
  const token = await getSessionToken(envSecret);
  const secure =
    process.env.NODE_ENV === "production" || Boolean(process.env.RAILWAY_ENVIRONMENT);
  cookies().set(COOKIE_NAME, token, {
    httpOnly: true,
    sameSite: "lax",
    path: "/",
    secure,
    maxAge: 60 * 60 * 24 * 7,
  });
  redirect("/admin");
}
