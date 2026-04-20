import type { Store } from "@prisma/client";
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

/**
 * Resuelve la tienda para endpoints storefront (wishlist, etc.).
 * Si `storeId` coincide con `TN_STORE_USER_ID`, siempre corre `ensureDefaultStore`:
 * crea la fila si no existía y **actualiza el accessToken** desde env (evita token viejo en BD).
 * Si no coincide, solo busca en Postgres (multi-tienda con filas ya creadas).
 */
export async function loadStoreForStorefront(storeUserId: string): Promise<Store | null> {
  const id = storeUserId.trim();
  if (!id) return null;
  const envId = process.env.TN_STORE_USER_ID?.trim();
  if (envId && envId === id) {
    try {
      return await ensureDefaultStore();
    } catch (e) {
      console.error("[loadStoreForStorefront] ensureDefaultStore:", e);
      return null;
    }
  }
  return prisma.store.findUnique({ where: { tiendanubeUserId: id } });
}
