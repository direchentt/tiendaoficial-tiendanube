import type { PaymentsBeforeFilterPayload } from "./tn-business-rules";

export type RuleConditions = {
  minTotal?: number;
  maxTotal?: number;
  /** Si el carrito tiene al menos un producto en alguna de estas categorias */
  categoryIdsAny?: number[];
};

export type ExcludePair = { providerId: string; optionId: string };

export type EngineRule = {
  priority: number;
  conditions: RuleConditions;
  excludePairs: ExcludePair[];
};

function parseTotal(payload: PaymentsBeforeFilterPayload): number {
  const raw = payload.totals?.total ?? "0";
  const n = parseFloat(String(raw).replace(",", "."));
  return Number.isFinite(n) ? n : 0;
}

function cartCategoryIds(payload: PaymentsBeforeFilterPayload): Set<number> {
  const ids = new Set<number>();
  for (const line of payload.products ?? []) {
    for (const c of line.categories ?? []) {
      ids.add(c.id);
      for (const sub of c.subcategories ?? []) {
        ids.add(sub);
      }
    }
  }
  return ids;
}

function matches(cond: RuleConditions, payload: PaymentsBeforeFilterPayload): boolean {
  const total = parseTotal(payload);
  if (cond.minTotal != null && total < cond.minTotal) {
    return false;
  }
  if (cond.maxTotal != null && total > cond.maxTotal) {
    return false;
  }
  if (cond.categoryIdsAny?.length) {
    const have = cartCategoryIds(payload);
    const any = cond.categoryIdsAny.some((id) => have.has(id));
    if (!any) {
      return false;
    }
  }
  return true;
}

/**
 * Acumula exclusiones de todas las reglas que matchean, ordenadas por priority asc.
 * Cada par (provider id + option_id) debe coincidir con IDs reales del checkout (ver GET payment_providers/options).
 */
export function evaluatePaymentRules(
  payload: PaymentsBeforeFilterPayload,
  rules: EngineRule[]
): Array<{ id: string; option_id: string }> {
  const sorted = [...rules].sort((a, b) => a.priority - b.priority);
  const out: Array<{ id: string; option_id: string }> = [];
  const seen = new Set<string>();

  for (const rule of sorted) {
    if (!matches(rule.conditions, payload)) {
      continue;
    }
    for (const p of rule.excludePairs) {
      const key = `${p.providerId}\0${p.optionId}`;
      if (seen.has(key)) {
        continue;
      }
      seen.add(key);
      out.push({ id: p.providerId, option_id: p.optionId });
    }
  }
  return out;
}
