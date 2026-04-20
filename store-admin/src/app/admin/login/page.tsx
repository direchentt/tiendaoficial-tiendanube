import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { COOKIE_NAME, verifySession } from "@/lib/admin-session";
import { AdminLoginForm } from "./login-form";

export const dynamic = "force-dynamic";

export default async function AdminLoginPage() {
  if (await verifySession(process.env.ADMIN_SECRET?.trim(), cookies().get(COOKIE_NAME)?.value)) {
    redirect("/admin");
  }
  return <AdminLoginForm />;
}
