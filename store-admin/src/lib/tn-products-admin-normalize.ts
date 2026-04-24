import type { TNProduct, TNVariant } from "@/components/admin/tn-product-picker-utils";
import type { ProductDetail } from "@/lib/tiendanube-client";

type TNImage = { src?: string };
type TNListProduct = {
  id: number;
  name: string | Record<string, string>;
  variants?: Array<{
    id: number;
    price: string;
    stock?: number | null;
    values?: TNVariant["values"];
  }>;
  images?: TNImage[];
};

function pickName(name: string | Record<string, string> | undefined): string {
  if (typeof name === "string" && name.trim()) return name.trim();
  if (name && typeof name === "object") {
    const o = name as Record<string, string>;
    const v = o.es ?? o.pt ?? o.en ?? o.es_mx ?? Object.values(o).find((x) => typeof x === "string" && x.trim());
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return "Producto";
}

/** Normaliza respuesta de GET /products (listado admin). */
export function normalizeTnListProduct(p: TNListProduct): TNProduct | null {
  const variants = (p.variants ?? []).map((v) => ({
    id: v.id,
    price: String(v.price ?? "0"),
    stock: v.stock ?? null,
    values: v.values ?? [],
  }));
  if (variants.length === 0) return null;
  const images = (p.images ?? [])
    .slice(0, 1)
    .map((img) => (typeof img.src === "string" ? img.src : ""))
    .filter(Boolean);
  return {
    id: p.id,
    name: pickName(p.name),
    price: variants[0]?.price ?? "0",
    images,
    variants,
  };
}

/** Normaliza GET /products/{id} (detalle) al mismo shape que el picker. */
export function normalizeTnProductDetail(p: ProductDetail): TNProduct | null {
  const rawVariants = p.variants ?? [];
  const variants: TNVariant[] = rawVariants
    .filter((v) => typeof v.id === "number" && v.id > 0)
    .map((v) => {
      const ext = v as { values?: TNVariant["values"] };
      return {
        id: v.id,
        price: String(v.price ?? "0"),
        values: ext.values ?? [],
      };
    });
  if (variants.length === 0) return null;
  const name = pickName(p.name);
  const images = (p.images ?? [])
    .slice(0, 1)
    .map((img) => (typeof img.src === "string" ? img.src : ""))
    .filter(Boolean);
  return {
    id: p.id,
    name,
    price: variants[0]?.price ?? "0",
    images,
    variants,
  };
}
