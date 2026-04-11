"use server";

import { createHash } from "crypto";
import { revalidatePath } from "next/cache";
import { ensureDefaultStore } from "@/lib/default-store";
import { prisma } from "@/lib/prisma";

export async function createLockedCategoryForm(formData: FormData) {
  const store = await ensureDefaultStore();
  const catRaw = String(formData.get("categoryId") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const categoryId = parseInt(catRaw, 10);
  if (!Number.isFinite(categoryId) || categoryId <= 0) {
    throw new Error("ID de categoria invalido");
  }
  if (password.length < 4) {
    throw new Error("Contrasena demasiado corta");
  }
  const passwordHash = createHash("sha256").update(password, "utf8").digest("hex");
  await prisma.lockedCategory.create({
    data: {
      storeId: store.id,
      categoryId,
      passwordHash,
    },
  });
  revalidatePath("/admin/categories");
}

export async function deleteLockedCategoryForm(formData: FormData) {
  const id = formData.get("id");
  if (typeof id !== "string" || !id) {
    throw new Error("id invalido");
  }
  await prisma.lockedCategory.delete({ where: { id } });
  revalidatePath("/admin/categories");
}
