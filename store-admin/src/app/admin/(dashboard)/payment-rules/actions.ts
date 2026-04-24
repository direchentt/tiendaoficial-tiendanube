"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { logAdminAudit } from "@/lib/admin-audit";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";

const excludeSchema = z.array(
  z.object({
    providerId: z.string().min(1),
    optionId: z.string().min(1),
  })
);

function parseForm(formData: FormData) {
  const name = String(formData.get("name") ?? "").trim();
  const priority = parseInt(String(formData.get("priority") ?? "0"), 10);
  const enabled = formData.get("enabled") === "on";
  const minRaw = String(formData.get("minTotal") ?? "").trim();
  const maxRaw = String(formData.get("maxTotal") ?? "").trim();
  const catRaw = String(formData.get("categoryIdsAny") ?? "").trim();
  const excludeRaw = String(formData.get("excludePairs") ?? "").trim();

  const conditions: Record<string, unknown> = {};
  if (minRaw !== "") {
    const n = parseFloat(minRaw.replace(",", "."));
    if (Number.isFinite(n)) {
      conditions.minTotal = n;
    }
  }
  if (maxRaw !== "") {
    const n = parseFloat(maxRaw.replace(",", "."));
    if (Number.isFinite(n)) {
      conditions.maxTotal = n;
    }
  }
  if (catRaw !== "") {
    const ids = catRaw
      .split(/[\s,;]+/)
      .map((s) => parseInt(s.trim(), 10))
      .filter((n) => Number.isFinite(n));
    if (ids.length) {
      conditions.categoryIdsAny = ids;
    }
  }

  let excludePairs: z.infer<typeof excludeSchema>;
  try {
    const parsed = JSON.parse(excludeRaw || "[]");
    excludePairs = excludeSchema.parse(parsed);
  } catch {
    throw new Error("excludePairs debe ser JSON: [{\"providerId\":\"...\",\"optionId\":\"...\"},...]");
  }

  const mapped = excludePairs.map((p) => ({
    providerId: p.providerId,
    optionId: p.optionId,
  }));

  return {
    name,
    priority: Number.isFinite(priority) ? priority : 0,
    enabled,
    conditionsJson: JSON.stringify(conditions),
    excludeJson: JSON.stringify(mapped),
  };
}

export type RuleFormResult = { ok: true } | { ok: false; message: string };

export async function submitPaymentRuleForm(
  ruleId: string | undefined,
  _prev: RuleFormResult | undefined,
  formData: FormData
): Promise<RuleFormResult> {
  if (ruleId) {
    return updatePaymentRule(ruleId, formData);
  }
  return createPaymentRule(formData);
}

export async function createPaymentRule(formData: FormData): Promise<RuleFormResult> {
  try {
    const store = await ensureDefaultStore();
    const p = parseForm(formData);
    if (!p.name) {
      return { ok: false, message: "Nombre obligatorio" };
    }
    const created = await prisma.paymentRule.create({
      data: {
        storeId: store.id,
        name: p.name,
        priority: p.priority,
        enabled: p.enabled,
        conditions: p.conditionsJson,
        excludePairs: p.excludeJson,
      },
    });
    await logAdminAudit({
      storeId: store.id,
      action: "payment_rule.create",
      entityType: "PaymentRule",
      entityId: created.id,
      summary: `Nueva regla de pago: ${p.name}`,
      meta: { priority: p.priority, enabled: p.enabled },
    });
    revalidatePath("/admin/payment-rules");
    return { ok: true };
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { ok: false, message: msg };
  }
}

export async function updatePaymentRule(
  ruleId: string,
  formData: FormData
): Promise<RuleFormResult> {
  try {
    const store = await ensureDefaultStore();
    const p = parseForm(formData);
    if (!p.name) {
      return { ok: false, message: "Nombre obligatorio" };
    }
    await prisma.paymentRule.update({
      where: { id: ruleId },
      data: {
        name: p.name,
        priority: p.priority,
        enabled: p.enabled,
        conditions: p.conditionsJson,
        excludePairs: p.excludeJson,
      },
    });
    await logAdminAudit({
      storeId: store.id,
      action: "payment_rule.update",
      entityType: "PaymentRule",
      entityId: ruleId,
      summary: `Regla de pago actualizada: ${p.name}`,
      meta: { priority: p.priority, enabled: p.enabled },
    });
    revalidatePath("/admin/payment-rules");
    return { ok: true };
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { ok: false, message: msg };
  }
}

export async function deletePaymentRule(ruleId: string) {
  const store = await ensureDefaultStore();
  await prisma.paymentRule.delete({ where: { id: ruleId } });
  await logAdminAudit({
    storeId: store.id,
    action: "payment_rule.delete",
    entityType: "PaymentRule",
    entityId: ruleId,
    summary: `Eliminada regla de pago id ${ruleId}`,
  });
  revalidatePath("/admin/payment-rules");
}

export async function deletePaymentRuleForm(formData: FormData) {
  const id = formData.get("id");
  if (typeof id !== "string" || !id) {
    throw new Error("id invalido");
  }
  await deletePaymentRule(id);
}
