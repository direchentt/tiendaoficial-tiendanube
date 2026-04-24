import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcryptjs";
import {
  parseStorefrontStoreUserId,
  STOREFRONT_CATEGORY_GATE_PASSWORD_MAX,
} from "@/lib/storefront-limits";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

/**
 * GET /api/storefront/category-gate?storeId=<id>&categoryId=<int>
 * Returns whether a category is locked.
 */
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const storeUserId = parseStorefrontStoreUserId(searchParams.get("storeId"));
  const categoryId = parseInt(searchParams.get("categoryId") ?? "", 10);

  if (!storeUserId || isNaN(categoryId)) {
    return NextResponse.json(
      {
        error: "storeId and categoryId are required",
        hint: "storeId debe ser el id numérico de la tienda (LS.store.id).",
      },
      { status: 400, headers: CORS }
    );
  }

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
  });

  if (!store) {
    return NextResponse.json({ locked: false }, { headers: CORS });
  }

  const locked = await prisma.lockedCategory.findUnique({
    where: { storeId_categoryId: { storeId: store.id, categoryId } },
  });
  const ttlHours = (locked as Record<string, unknown>)?.accessTtlHours ?? 24;

  return NextResponse.json(
    { locked: !!locked, ttlHours },
    { headers: CORS }
  );
}

/**
 * POST /api/storefront/category-gate
 * Body: { storeId, categoryId, password }
 * Returns { success: true, token, expiresAt } or { success: false }
 */
export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const { storeId: storeIdRaw, categoryId: categoryIdRaw, password: passwordRaw } = body as {
    storeId?: string;
    categoryId?: number | string;
    password?: string;
  };

  const storeUserId = parseStorefrontStoreUserId(storeIdRaw ?? null);
  const categoryId =
    typeof categoryIdRaw === "number"
      ? categoryIdRaw
      : parseInt(String(categoryIdRaw ?? ""), 10);
  const password = typeof passwordRaw === "string" ? passwordRaw : "";

  if (!storeUserId || !Number.isFinite(categoryId) || categoryId <= 0 || !password) {
    return NextResponse.json(
      { error: "storeId, categoryId and password are required" },
      { status: 400, headers: CORS }
    );
  }

  if (password.length > STOREFRONT_CATEGORY_GATE_PASSWORD_MAX) {
    return NextResponse.json({ error: "password_too_long" }, { status: 400, headers: CORS });
  }

  const store = await prisma.store.findUnique({
    where: { tiendanubeUserId: storeUserId },
  });

  if (!store) {
    return NextResponse.json({ success: false }, { headers: CORS });
  }

  const record = await prisma.lockedCategory.findUnique({
    where: { storeId_categoryId: { storeId: store.id, categoryId } },
  });

  if (!record) {
    return NextResponse.json({ success: false }, { headers: CORS });
  }

  const valid = await bcrypt.compare(password, record.passwordHash);
  if (!valid) {
    return NextResponse.json({ success: false }, { headers: CORS });
  }

  const ttl = ((record as Record<string, unknown>).accessTtlHours as number) ?? 24;
  const expiresAt = new Date(
    Date.now() + ttl * 60 * 60 * 1000
  ).toISOString();

  // Simple signed token: base64(storeId:categoryId:expiresAt)
  const token = Buffer.from(
    JSON.stringify({ storeId: storeUserId, categoryId, expiresAt })
  ).toString("base64");

  return NextResponse.json({ success: true, token, expiresAt }, { headers: CORS });
}
