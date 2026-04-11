import { prisma } from "./prisma";

/**
 * Una fila Store enlaza reglas Prisma con store_id del callback TN (payload.store_id).
 * Sincroniza token desde .env en cada upsert.
 */
export async function ensureDefaultStore() {
  const uid = process.env.TN_STORE_USER_ID;
  const token = process.env.TN_ACCESS_TOKEN;
  if (!uid?.trim() || !token?.trim()) {
    throw new Error(
      "Configura TN_STORE_USER_ID y TN_ACCESS_TOKEN en .env (ids de la tienda tras OAuth)."
    );
  }
  return prisma.store.upsert({
    where: { tiendanubeUserId: uid.trim() },
    create: {
      tiendanubeUserId: uid.trim(),
      accessToken: token.trim(),
    },
    update: { accessToken: token.trim() },
  });
}
