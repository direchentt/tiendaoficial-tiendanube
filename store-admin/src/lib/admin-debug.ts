/**
 * Rutas /api/admin/debug-* solo deben usarse en desarrollo o con flag explícito en producción.
 */
export function adminDebugEndpointsDisabled(): boolean {
  return process.env.NODE_ENV === "production" && process.env.ALLOW_ADMIN_DEBUG !== "1";
}
