import Link from "next/link";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";
import { deletePaymentRuleForm } from "./actions";

export const dynamic = "force-dynamic";

export default async function PaymentRulesPage() {
  const store = await ensureDefaultStore();
  const rules = await prisma.paymentRule.findMany({
    where: { storeId: store.id },
    orderBy: [{ priority: "asc" }, { createdAt: "desc" }],
  });

  return (
    <main>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ fontSize: "1.25rem" }}>Reglas de pago</h1>
        <Link
          href="/admin/payment-rules/new"
          style={{
            background: "#111",
            color: "#fff",
            padding: "0.45rem 0.9rem",
            borderRadius: "6px",
            textDecoration: "none",
            fontSize: "0.875rem",
          }}
        >
          Nueva regla
        </Link>
      </div>
      <p style={{ color: "#555", fontSize: "0.9rem", maxWidth: "40rem" }}>
        Si el carrito cumple la condicion, se excluyen los pares providerId + optionId del checkout (ver doc Business
        Rules). Orden por <code>priority</code> ascendente.
      </p>
      {rules.length === 0 ? (
        <p>No hay reglas todavia.</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0 }}>
          {rules.map((r) => (
            <li
              key={r.id}
              style={{
                border: "1px solid #e8e8e8",
                borderRadius: "8px",
                padding: "1rem",
                marginBottom: "0.75rem",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", gap: "1rem", flexWrap: "wrap" }}>
                <div>
                  <strong>{r.name}</strong>{" "}
                  <span style={{ color: "#888", fontSize: "0.85rem" }}>
                    priority {r.priority} {r.enabled ? "" : "(off)"}
                  </span>
                  <pre
                    style={{
                      fontSize: "0.75rem",
                      background: "#f8f8f8",
                      padding: "0.5rem",
                      marginTop: "0.5rem",
                      overflow: "auto",
                    }}
                  >
                    {`conditions: ${r.conditions}\nexclude: ${r.excludePairs}`}
                  </pre>
                </div>
                <div style={{ display: "flex", gap: "0.5rem", alignItems: "flex-start" }}>
                  <Link href={`/admin/payment-rules/${r.id}/edit`} style={{ fontSize: "0.875rem" }}>
                    Editar
                  </Link>
                  <form action={deletePaymentRuleForm}>
                    <input type="hidden" name="id" value={r.id} />
                    <button
                      type="submit"
                      style={{
                        fontSize: "0.875rem",
                        color: "#b00020",
                        background: "none",
                        border: "none",
                        cursor: "pointer",
                        textDecoration: "underline",
                      }}
                    >
                      Borrar
                    </button>
                  </form>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}
