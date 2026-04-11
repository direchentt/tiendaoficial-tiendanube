import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { COOKIE_NAME, verifySession } from "@/lib/admin-session";

export const dynamic = "force-dynamic";

/**
 * Rutas bajo /admin excepto /admin/login y /admin/logout.
 * Auth en Node (sin middleware Edge) para evitar fallos en produccion.
 */
export default async function AdminDashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const secret = process.env.ADMIN_SECRET;
  const token = cookies().get(COOKIE_NAME)?.value;
  if (!(await verifySession(secret, token))) {
    redirect("/admin/login");
  }
  return <>{children}</>;
}
