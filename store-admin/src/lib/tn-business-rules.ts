/**
 * Tipos alineados a Business Rules API (payments/before-filter).
 * La plataforma POSTea el payload a tu callback; respondes con opciones a filtrar.
 *
 * Timeout 800ms en el lado Tiendanube: mantener la logica ligera.
 *
 * @see https://tiendanube.github.io/api-documentation/resources/business-rules
 */

export type PaymentsBeforeFilterPayload = {
  store_id: string;
  cart_id?: number;
  currency: string;
  details: {
    event: "payments/before-filter";
    action: "filter";
    domain: "payments";
    timestamp: number;
  };
  products: Array<{
    id: number;
    product_id: number;
    quantity: number;
    stock: number;
    variant_id: number;
    price: string;
    categories: Array<{
      id: number;
      parent: number | null;
      subcategories: number[];
    }>;
  }>;
  customer: { id: number | null };
  totals: {
    subtotal: string;
    total_discount: string;
    total: string;
  };
};

export type FilterPaymentsOptionsResponse = {
  command: "filter_payments_options";
  detail: {
    filtered_options: Array<{
      id: string;
      option_id: string;
    }>;
  };
};
