import Link from "next/link";
import { PaymentRuleForm } from "../rule-form";

export default function NewPaymentRulePage() {
  return (
    <main>
      <p>
        <Link href="/admin/payment-rules" style={{ fontSize: "0.9rem" }}>
          &larr; Volver
        </Link>
      </p>
      <h1 style={{ fontSize: "1.25rem" }}>Nueva regla de pago</h1>
      <PaymentRuleForm
        defaultExcludePairs={`[
  { "providerId": "mercadopago", "optionId": "mercadopago_transparent_card" }
]`}
      />
    </main>
  );
}
