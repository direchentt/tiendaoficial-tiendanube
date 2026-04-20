import { NextRequest, NextResponse } from "next/server";
import { loadStoreForStorefront } from "@/lib/default-store";
import { tnConfigFromStore } from "@/lib/wishlist-verify-customer";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const BASE = {
  endpoint: "wishlist-ping",
  version: 1,
} as const;

/**
 * Diagnóstico storefront (JSON siempre, HTTP 200) para no confundirse con el 404 HTML de Next
 * cuando la ruta no está desplegada o el id no coincide con Railway.
 *
 * GET .../api/storefront/wishlist-ping?storeId=<LS.store.id>
 */
export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: CORS });
}

export async function GET(req: NextRequest) {
  const storeUserId = new URL(req.url).searchParams.get("storeId")?.trim() ?? "";
  const envId = process.env.TN_STORE_USER_ID?.trim();

  if (!storeUserId) {
    return NextResponse.json(
      {
        ...BASE,
        ok: false,
        matchedEnv: false,
        hint: "Falta el query ?storeId= — debe ser el mismo número que LS.store.id en la consola del navegador (F12).",
      },
      { status: 200, headers: CORS }
    );
  }

  if (!envId) {
    return NextResponse.json(
      {
        ...BASE,
        ok: false,
        matchedEnv: false,
        hint: "En Railway no está definido TN_STORE_USER_ID (o está vacío).",
      },
      { status: 200, headers: CORS }
    );
  }

  if (storeUserId !== envId) {
    return NextResponse.json(
      {
        ...BASE,
        ok: false,
        matchedEnv: false,
        hint:
          "El storeId de la URL no coincide con TN_STORE_USER_ID del servidor. En Railway abrí TN_STORE_USER_ID y comparalo con LS.store.id (mismo número, sin espacios).",
      },
      { status: 200, headers: CORS }
    );
  }

  const store = await loadStoreForStorefront(storeUserId);
  if (!store) {
    return NextResponse.json(
      {
        ...BASE,
        ok: false,
        matchedEnv: true,
        storeInDatabase: false,
        tnApiConfigOk: false,
        hint: "No se pudo crear/sincronizar Store (DATABASE_URL, TN_ACCESS_TOKEN o logs de Prisma).",
      },
      { status: 200, headers: CORS }
    );
  }

  const cfg = tnConfigFromStore(store);
  return NextResponse.json(
    {
      ...BASE,
      ok: Boolean(cfg),
      matchedEnv: true,
      storeInDatabase: true,
      tnApiConfigOk: Boolean(cfg),
      hint: cfg
        ? "Panel listo. Si favoritos falla: token sin read_customers, o email de sesión distinto al de GET /customers/{id} en TN."
        : "Falta TN_USER_AGENT en Railway o el accessToken quedó vacío en la fila Store.",
    },
    { status: 200, headers: CORS }
  );
}
