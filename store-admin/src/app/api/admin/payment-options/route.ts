import { NextResponse } from "next/server";
import {
  getPaymentProviderOptions,
  type TiendanubeClientConfig,
} from "@/lib/tiendanube-client";

export const runtime = "nodejs";

/**
 * Lista ids reales de medios de pago (provider id + checkout_payment_options[].id) para armar reglas.
 * Scope: read_payments. Documentacion: Business Rules + payment_providers/options.
 */
export async function GET(req: Request) {
  const secret = req.headers.get("x-admin-secret");
  if (!process.env.ADMIN_SECRET || secret !== process.env.ADMIN_SECRET) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  const userId = process.env.TN_STORE_USER_ID;
  const token = process.env.TN_ACCESS_TOKEN;
  const ua = process.env.TN_USER_AGENT;
  if (!userId || !token || !ua) {
    return NextResponse.json(
      { error: "missing_env", need: ["TN_STORE_USER_ID", "TN_ACCESS_TOKEN", "TN_USER_AGENT"] },
      { status: 500 }
    );
  }

  const config: TiendanubeClientConfig = {
    storeUserId: userId,
    accessToken: token,
    userAgent: ua,
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  try {
    const rows = await getPaymentProviderOptions(config);
    const flat = rows.flatMap((r) =>
      (r.checkout_payment_options ?? []).map((opt) => ({
        providerId: r.id,
        providerName: r.name,
        optionId: opt.id,
        optionName: opt.name,
        types: opt.supported_payment_method_types,
      }))
    );
    return NextResponse.json({ options: flat });
  } catch (e) {
    return NextResponse.json({ error: String(e) }, { status: 502 });
  }
}
