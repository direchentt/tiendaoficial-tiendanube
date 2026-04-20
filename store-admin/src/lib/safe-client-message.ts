/**
 * Detalle de error solo en desarrollo (evita filtrar respuestas de APIs externas en producción).
 */
export function devOnlyDetail(detail: string): { detail: string } | Record<string, never> {
  if (process.env.NODE_ENV !== "development") return {};
  const t = detail.trim();
  if (!t) return {};
  return { detail: t.slice(0, 800) };
}
