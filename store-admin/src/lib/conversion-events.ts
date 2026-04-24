/** Tipos permitidos en POST /api/storefront/conversion-events (embudo CVR). */

export const CONVERSION_EVENT_TYPES = [
  "home_view",
  "category_view",
  "product_view",
  "add_to_cart",
  "bundle_view",
] as const;

export type ConversionEventType = (typeof CONVERSION_EVENT_TYPES)[number];

export function isConversionEventType(s: string): s is ConversionEventType {
  return (CONVERSION_EVENT_TYPES as readonly string[]).includes(s);
}
