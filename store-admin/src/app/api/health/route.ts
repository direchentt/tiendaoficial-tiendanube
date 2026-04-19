import { NextResponse } from "next/server";

/** Probe liviano para Railway / balanceadores (sin tocar DB). Debe ser 200 explícito. */
export async function GET() {
  return NextResponse.json(
    { status: "ok", ts: Date.now() },
    {
      status: 200,
      headers: {
        "Cache-Control": "no-store, no-cache, must-revalidate",
      },
    }
  );
}
