/** Formato normalizado de GET /api/admin/tn-products (catálogo y búsqueda). */

export type TNVariant = {
  id: number;
  price: string;
  values?: { es?: string; pt?: string; en?: string }[];
};

export type TNProduct = {
  id: number;
  name: string;
  price: string;
  images: string[];
  variants: TNVariant[];
};

export function variantLabel(v: TNVariant): string {
  const parts = (v.values ?? [])
    .map((x) => x.es ?? x.pt ?? x.en ?? "")
    .filter(Boolean);
  return parts.join(" / ") || `Variante ${v.id}`;
}
