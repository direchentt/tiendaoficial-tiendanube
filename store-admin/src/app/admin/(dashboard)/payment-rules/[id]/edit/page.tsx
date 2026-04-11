import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { PaymentRuleForm } from "../../rule-form";

type Props = { params: Promise<{ id: string }> };

export default async function EditPaymentRulePage({ params }: Props) {
  const { id } = await params;
  const rule = await prisma.paymentRule.findUnique({ where: { id } });
  if (!rule) {
    notFound();
  }

  let conditions: Record<string, unknown> = {};
  try {
    conditions = JSON.parse(rule.conditions) as Record<string, unknown>;
  } catch {
    /* empty */
  }
  const minTotal =
    typeof conditions.minTotal === "number" ? String(conditions.minTotal) : "";
  const maxTotal =
    typeof conditions.maxTotal === "number" ? String(conditions.maxTotal) : "";
  const catAny = Array.isArray(conditions.categoryIdsAny)
    ? (conditions.categoryIdsAny as number[]).join(", ")
    : "";

  let excludePretty = "[]";
  try {
    excludePretty = JSON.stringify(JSON.parse(rule.excludePairs || "[]"), null, 2);
  } catch {
    excludePretty = rule.excludePairs || "[]";
  }

  return (
    <main>
      <p>
        <Link href="/admin/payment-rules" style={{ fontSize: "0.9rem" }}>
          &larr; Volver
        </Link>
      </p>
      <h1 style={{ fontSize: "1.25rem" }}>Editar regla</h1>
      <PaymentRuleForm
        ruleId={rule.id}
        defaultName={rule.name}
        defaultPriority={rule.priority}
        defaultEnabled={rule.enabled}
        defaultMinTotal={minTotal}
        defaultMaxTotal={maxTotal}
        defaultCategoryIds={catAny}
        defaultExcludePairs={excludePretty}
      />
    </main>
  );
}
