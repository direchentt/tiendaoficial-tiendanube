import { NextResponse } from "next/server";
import { z } from "zod";
import { evaluatePaymentRules, type EngineRule } from "@/lib/payment-rule-engine";
import { prisma } from "@/lib/prisma";
import type {
  FilterPaymentsOptionsResponse,
  PaymentsBeforeFilterPayload,
} from "@/lib/tn-business-rules";

export const runtime = "nodejs";

const payloadSchema = z.object({
  store_id: z.string(),
  cart_id: z.number().optional(),
  currency: z.string(),
  details: z.object({
    event: z.literal("payments/before-filter"),
    action: z.literal("filter"),
    domain: z.literal("payments"),
    timestamp: z.number(),
  }),
  products: z.array(
    z.object({
      id: z.number(),
      product_id: z.number(),
      quantity: z.number(),
      stock: z.number(),
      variant_id: z.number(),
      price: z.string(),
      categories: z.array(
        z.object({
          id: z.number(),
          parent: z.number().nullable(),
          subcategories: z.array(z.number()),
        })
      ),
    })
  ),
  customer: z.object({ id: z.number().nullable() }),
  totals: z.object({
    subtotal: z.string(),
    total_discount: z.string(),
    total: z.string(),
  }),
});

/**
 * Callback para Business Rules (payments/before-filter).
 * Registrar URL en Partners + PUT .../business_rules/integrations/payments
 */
export async function POST(req: Request) {
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const parsed = payloadSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: "validation", issues: parsed.error.flatten() },
      { status: 422 }
    );
  }

  const payload = parsed.data as PaymentsBeforeFilterPayload;

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: payload.store_id },
    include: {
      paymentRules: {
        where: { enabled: true },
        orderBy: { priority: "asc" },
      },
    },
  });

  const empty: FilterPaymentsOptionsResponse = {
    command: "filter_payments_options",
    detail: { filtered_options: [] },
  };

  if (!store?.paymentRules.length) {
    return NextResponse.json(empty);
  }

  const engineRules: EngineRule[] = store.paymentRules.map((r) => {
    const conditions = JSON.parse(r.conditions) as EngineRule["conditions"];
    const excludePairs = JSON.parse(r.excludePairs) as EngineRule["excludePairs"];
    return {
      priority: r.priority,
      conditions,
      excludePairs,
    };
  });

  const filtered = evaluatePaymentRules(payload, engineRules);
  const res: FilterPaymentsOptionsResponse = {
    command: "filter_payments_options",
    detail: { filtered_options: filtered },
  };

  return NextResponse.json(res);
}
