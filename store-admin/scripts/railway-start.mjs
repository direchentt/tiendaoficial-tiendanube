#!/usr/bin/env node
/**
 * Arranque en Railway: PORT viene del entorno (sin ${PORT} dentro de package.json).
 * 1) prisma migrate deploy  2) next start en 0.0.0.0:PORT
 */
import { spawnSync } from "node:child_process";

const port = process.env.PORT ?? "3000";
const env = { ...process.env };

function sh(cmd) {
  console.log(`[railway-start] ${cmd}`);
  const r = spawnSync(cmd, {
    stdio: "inherit",
    env,
    shell: true,
  });
  if (r.status !== 0 && r.status !== null) {
    console.error(`[railway-start] exited with code ${r.status}`);
    process.exit(r.status ?? 1);
  }
}

sh("npx prisma migrate deploy");
sh(`npx next start -H 0.0.0.0 -p ${port}`);
