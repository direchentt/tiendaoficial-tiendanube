"use client";

import { useFormState, useFormStatus } from "react-dom";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import {
  submitPaymentRuleForm,
  type RuleFormResult,
} from "./actions";

type Props = {
  ruleId?: string;
  defaultName?: string;
  defaultPriority?: number;
  defaultEnabled?: boolean;
  defaultMinTotal?: string;
  defaultMaxTotal?: string;
  defaultCategoryIds?: string;
  defaultExcludePairs?: string;
};

function SubmitRow({ label }: { label: string }) {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending} style={btn}>
      {pending ? "Guardando..." : label}
    </button>
  );
}

export function PaymentRuleForm({
  ruleId,
  defaultName = "",
  defaultPriority = 0,
  defaultEnabled = true,
  defaultMinTotal = "",
  defaultMaxTotal = "",
  defaultCategoryIds = "",
  defaultExcludePairs = "[]",
}: Props) {
  const router = useRouter();
  const bound = submitPaymentRuleForm.bind(null, ruleId);
  const [state, formAction] = useFormState(bound, undefined as RuleFormResult | undefined);

  useEffect(() => {
    if (state?.ok) {
      router.push("/admin/payment-rules");
    }
  }, [state, router]);

  return (
    <form action={formAction} style={{ display: "flex", flexDirection: "column", gap: "0.75rem", maxWidth: "36rem" }}>
      {state && !state.ok ? (
        <p role="alert" style={{ color: "#b00020", margin: 0 }}>
          {state.message}
        </p>
      ) : null}
      <label>
        <span style={labelSpan}>Nombre</span>
        <input name="name" required defaultValue={defaultName} style={input} />
      </label>
      <label>
        <span style={labelSpan}>Priority (menor = antes)</span>
        <input name="priority" type="number" defaultValue={defaultPriority} style={input} />
      </label>
      <label style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
        <input name="enabled" type="checkbox" defaultChecked={defaultEnabled} />
        Activa
      </label>
      <label>
        <span style={labelSpan}>Total minimo (opcional, mismo formato que el carrito)</span>
        <input name="minTotal" defaultValue={defaultMinTotal} placeholder="ej. 0" style={input} />
      </label>
      <label>
        <span style={labelSpan}>Total maximo (opcional)</span>
        <input name="maxTotal" defaultValue={defaultMaxTotal} style={input} />
      </label>
      <label>
        <span style={labelSpan}>IDs de categoria (cualquiera en el carrito), separados por coma</span>
        <input name="categoryIdsAny" defaultValue={defaultCategoryIds} placeholder="123, 456" style={input} />
      </label>
      <label>
        <span style={labelSpan}>
          Excluir pares JSON (copiar desde Medios de pago TN):{" "}
          <code>[{`{"providerId":"...","optionId":"..."}`}]</code>
        </span>
        <textarea
          name="excludePairs"
          required
          rows={8}
          defaultValue={defaultExcludePairs}
          style={{ ...input, fontFamily: "monospace", fontSize: "0.8rem" }}
        />
      </label>
      <SubmitRow label={ruleId ? "Guardar cambios" : "Crear regla"} />
    </form>
  );
}

const labelSpan: React.CSSProperties = {
  display: "block",
  fontSize: "0.8rem",
  marginBottom: "0.25rem",
  color: "#333",
};

const input: React.CSSProperties = {
  width: "100%",
  padding: "0.45rem 0.55rem",
  borderRadius: "6px",
  border: "1px solid #ccc",
  boxSizing: "border-box",
};

const btn: React.CSSProperties = {
  alignSelf: "flex-start",
  padding: "0.5rem 1rem",
  background: "#111",
  color: "#fff",
  border: "none",
  borderRadius: "6px",
  cursor: "pointer",
  fontWeight: 600,
};
