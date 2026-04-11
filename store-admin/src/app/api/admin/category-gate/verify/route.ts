import { NextResponse } from "next/server";
import { createHash, timingSafeEqual } from "crypto";
import { z } from "zod";
import { prisma } from "@/lib/prisma";

export const runtime = "nodejs";

const bodySchema = z.object({
  storeUserId: z.string(),
  categoryId: z.number().int().positive(),
  password: z.string().min(1).max(200),
});

function hash(pw: string): string {
  return createHash("sha256").update(pw, "utf8").digest("hex");
}

/**
 * Verificacion de contrasena para categorias bloqueadas en tu capa.
 * El tema (Script + fetch a esta URL) puede guardar un token en sessionStorage.
 * Sustituir SHA256 por bcrypt en produccion.
 */
export async function POST(req: Request) {
  let json: unknown;
  try {
    json = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }
  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 422 });
  }
  const { storeUserId, categoryId, password } = parsed.data;

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
    include: {
      lockedCategories: { where: { categoryId } },
    },
  });

  const lock = store?.lockedCategories[0];
  if (!lock) {
    return NextResponse.json({ ok: false }, { status: 403 });
  }

  const a = Buffer.from(hash(password), "utf8");
  const b = Buffer.from(lock.passwordHash, "utf8");
  if (a.length !== b.length || !timingSafeEqual(a, b)) {
    return NextResponse.json({ ok: false }, { status: 403 });
  }

  return NextResponse.json({ ok: true, categoryId });
}
