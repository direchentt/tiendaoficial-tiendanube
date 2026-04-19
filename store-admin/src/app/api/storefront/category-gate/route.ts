import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcryptjs";

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
  const storeUserId = searchParams.get("storeId");
  const categoryId = parseInt(searchParams.get("categoryId") ?? "", 10);

  if (!storeUserId || isNaN(categoryId)) {
    return NextResponse.json(
      { error: "storeId and categoryId are required" },
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
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const ttlHours = (locked as any)?.accessTtlHours ?? 24;

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
  const { storeId: storeUserId, categoryId, password } = body as {
    storeId?: string;
    categoryId?: number;
    password?: string;
  };

  if (!storeUserId || !categoryId || !password) {
    return NextResponse.json(
      { error: "storeId, categoryId and password are required" },
      { status: 400, headers: CORS }
    );
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

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const ttl = (record as any).accessTtlHours ?? 24;
  const expiresAt = new Date(
    Date.now() + ttl * 60 * 60 * 1000
  ).toISOString();

  // Simple signed token: base64(storeId:categoryId:expiresAt)
  const token = Buffer.from(
    JSON.stringify({ storeId: storeUserId, categoryId, expiresAt })
  ).toString("base64");

  return NextResponse.json({ success: true, token, expiresAt }, { headers: CORS });
}
