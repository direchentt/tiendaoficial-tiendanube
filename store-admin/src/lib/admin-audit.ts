import { prisma } from "@/lib/prisma";

export type AdminAuditParams = {
  storeId: string;
  action: string;
  entityType?: string;
  entityId?: string;
  summary: string;
  meta?: Record<string, unknown>;
};

/**
 * Registro append-only de acciones admin. No lanzar: errores solo a consola.
 */
export async function logAdminAudit(params: AdminAuditParams): Promise<void> {
  const summary = params.summary.trim().slice(0, 500) || params.action;
  try {
    await prisma.adminAuditLog.create({
      data: {
        storeId: params.storeId,
        action: params.action.slice(0, 120),
        entityType: params.entityType?.slice(0, 80) ?? null,
        entityId: params.entityId?.slice(0, 80) ?? null,
        summary,
        meta: params.meta ? JSON.stringify(params.meta).slice(0, 12000) : null,
      },
    });
  } catch (e) {
    console.error("[admin-audit]", e);
  }
}
