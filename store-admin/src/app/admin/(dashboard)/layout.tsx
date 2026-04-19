/**
 * El guard de sesión ahora es client-side via sessionStorage + x-admin-secret.
 * El layout server-side solo renderiza los children — la protección
 * la hace el dashboard client-side guard (AdminGuard) y cada API route
 * verifica el header x-admin-secret.
 */
export const dynamic = "force-dynamic";

export default function AdminDashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}
