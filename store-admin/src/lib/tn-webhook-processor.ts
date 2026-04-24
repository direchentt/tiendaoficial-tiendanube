import { prisma } from "@/lib/prisma";

function normalizeTopic(topic: string): string {
  return topic.trim().toLowerCase();
}

function truncateErr(msg: string): string {
  const s = msg.trim();
  return s.length > 500 ? s.slice(0, 497) + "…" : s;
}

/**
 * Hooks por topic: idempotencia por fila (`processedAt`); ampliar con side-effects cuando haga falta.
 * LGPD / redact: no borramos datos automáticamente sin flujo explícito del comercio.
 */
async function handleWebhookPayload(topicNorm: string, payload: string, tiendanubeUserId: string | null): Promise<void> {
  if (topicNorm === "store/redact" || topicNorm === "customers/redact" || topicNorm === "customers/data_request") {
    console.info("[tn-webhook]", topicNorm, { tiendanubeUserId, payloadBytes: payload.length });
    return;
  }
  if (topicNorm === "app/uninstalled") {
    console.info("[tn-webhook] app/uninstalled", { tiendanubeUserId });
    return;
  }
  if (topicNorm.startsWith("order/") || topicNorm.startsWith("product/")) {
    return;
  }
  if (topicNorm.startsWith("app/") || topicNorm.startsWith("category/") || topicNorm.startsWith("customer/")) {
    return;
  }
}

export async function processTnWebhookEventById(id: string): Promise<void> {
  const row = await prisma.tnWebhookEvent.findUnique({ where: { id } });
  if (!row || row.processedAt) return;

  const topicNorm = normalizeTopic(row.topic);
  let processError: string | null = null;
  try {
    await handleWebhookPayload(topicNorm, row.payload, row.tiendanubeUserId);
  } catch (e) {
    processError = truncateErr(e instanceof Error ? e.message : String(e));
    console.error("[tn-webhook] handler error", id, e);
  }

  try {
    await prisma.tnWebhookEvent.update({
      where: { id },
      data: {
        processedAt: new Date(),
        processError,
      },
    });
  } catch (e) {
    console.error("[tn-webhook] failed to mark processed", id, e);
  }
}
