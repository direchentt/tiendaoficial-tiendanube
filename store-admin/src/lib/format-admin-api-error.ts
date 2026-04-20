/**
 * Mensaje legible para el panel cuando una API admin devuelve error (evita mostrar "{}" o [object Object]).
 */
export function formatAdminApiError(payload: unknown, status: number): string {
  if (payload && typeof payload === "object") {
    const o = payload as Record<string, unknown>;
    if (typeof o.error === "string" && o.error.trim()) return o.error.trim();
    if (typeof o.message === "string" && o.message.trim()) return o.message.trim();
    if (o.error && typeof o.error === "object") {
      const flat = o.error as {
        formErrors?: string[];
        fieldErrors?: Record<string, string[] | undefined>;
      };
      const lines: string[] = [...(flat.formErrors ?? [])];
      for (const [key, msgs] of Object.entries(flat.fieldErrors ?? {})) {
        if (msgs?.length) lines.push(`${key}: ${msgs.join(", ")}`);
      }
      if (lines.length) return lines.join(" · ");
    }
  }
  if (status === 401) return "Sesión no válida. Volvé a iniciar sesión en el panel.";
  if (status === 422) return "Revisá los datos del formulario.";
  if (status === 503) return "Falta configuración en el servidor (variables de entorno).";
  if (status >= 500) return "Error del servidor. Si persiste, revisá los logs del deploy.";
  return `Error ${status}`;
}
