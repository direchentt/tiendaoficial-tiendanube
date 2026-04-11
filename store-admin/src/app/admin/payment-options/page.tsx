import Link from "next/link";
import {
  getPaymentProviderOptions,
  type TiendanubeClientConfig,
} from "@/lib/tiendanube-client";

export const dynamic = "force-dynamic";

export default async function PaymentOptionsPage() {
  const userId = process.env.TN_STORE_USER_ID;
  const token = process.env.TN_ACCESS_TOKEN;
  const ua = process.env.TN_USER_AGENT;

  if (!userId?.trim() || !token?.trim() || !ua?.trim()) {
    return (
      <main>
        <p style={{ color: "#b00020" }}>
          Falta TN_STORE_USER_ID, TN_ACCESS_TOKEN o TN_USER_AGENT en .env
        </p>
      </main>
    );
  }

  const config: TiendanubeClientConfig = {
    storeUserId: userId.trim(),
    accessToken: token.trim(),
    userAgent: ua.trim(),
    host: process.env.TN_API_HOST === "nuvemshop" ? "nuvemshop" : "tiendanube",
  };

  let rows: Awaited<ReturnType<typeof getPaymentProviderOptions>>;
  let err: string | null = null;
  try {
    rows = await getPaymentProviderOptions(config);
  } catch (e) {
    err = String(e);
    rows = [];
  }

  const flat = rows.flatMap((r) =>
    (r.checkout_payment_options ?? []).map((opt) => ({
      providerId: r.id,
      providerName: r.name,
      optionId: opt.id,
      optionName: opt.name,
      types: opt.supported_payment_method_types,
    }))
  );

  return (
    <main>
      <p>
        <Link href="/admin" style={{ fontSize: "0.9rem" }}>
          &larr; Inicio
        </Link>
      </p>
      <h1 style={{ fontSize: "1.25rem" }}>Medios de pago (API Tiendanube)</h1>
      <p style={{ color: "#555", fontSize: "0.9rem", maxWidth: "42rem" }}>
        Endpoint oficial <code>GET /payment_providers/options</code> (scope <code>read_payments</code>). Usa{" "}
        <code>providerId</code> + <code>optionId</code> en las reglas de exclusion.
      </p>
      {err ? (
        <p role="alert" style={{ color: "#b00020" }}>
          {err}
        </p>
      ) : null}
      <div style={{ overflowX: "auto" }}>
        <table style={{ borderCollapse: "collapse", fontSize: "0.85rem", width: "100%" }}>
          <thead>
            <tr style={{ borderBottom: "2px solid #ddd", textAlign: "left" }}>
              <th style={{ padding: "0.5rem" }}>providerId</th>
              <th style={{ padding: "0.5rem" }}>optionId</th>
              <th style={{ padding: "0.5rem" }}>Nombre</th>
              <th style={{ padding: "0.5rem" }}>Tipos</th>
            </tr>
          </thead>
          <tbody>
            {flat.map((o) => (
              <tr key={`${o.providerId}-${o.optionId}`} style={{ borderBottom: "1px solid #eee" }}>
                <td style={{ padding: "0.45rem", fontFamily: "monospace" }}>{o.providerId}</td>
                <td style={{ padding: "0.45rem", fontFamily: "monospace" }}>{o.optionId}</td>
                <td style={{ padding: "0.45rem" }}>
                  {o.providerName} — {o.optionName}
                </td>
                <td style={{ padding: "0.45rem" }}>{(o.types ?? []).join(", ")}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}
