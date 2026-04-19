import { NextResponse } from "next/server";

/** Probe liviano para Railway / balanceadores (sin tocar DB). */
export async function GET() {
  return NextResponse.json({ status: "ok", ts: Date.now() });
}
