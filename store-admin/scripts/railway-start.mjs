#!/usr/bin/env node
/**
 * Railway: levantar Next antes del healthcheck externo; luego migraciones.
 * Usa `node` + entradas de paquete (evita shims .bin bajo Nix) y valida .next.
 */
import http from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const storeAdminRoot = path.resolve(__dirname, "..");
const nextEntry = path.join(storeAdminRoot, "node_modules", "next", "dist", "bin", "next");
const prismaEntry = path.join(storeAdminRoot, "node_modules", "prisma", "build", "index.js");
const buildIdPath = path.join(storeAdminRoot, ".next", "BUILD_ID");

const port = String(process.env.PORT ?? "3000");
const env = {
  ...process.env,
  NODE_ENV: process.env.NODE_ENV ?? "production",
};

function assertFile(p, label) {
  if (!fs.existsSync(p)) {
    console.error(`[railway-start] falta ${label}: ${p}`);
    process.exit(1);
  }
}

function waitForServer(pathname, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  return new Promise((resolve, reject) => {
    function ping() {
      if (Date.now() > deadline) {
        reject(new Error(`Timeout esperando ${pathname} en puerto ${port}`));
        return;
      }
      const req = http.get(
        `http://127.0.0.1:${port}${pathname}`,
        { timeout: 2000 },
        (res) => {
          res.resume();
          if (res.statusCode === 200) {
            resolve();
            return;
          }
          setTimeout(ping, 400);
        }
      );
      req.on("error", () => setTimeout(ping, 400));
      req.on("timeout", () => {
        req.destroy();
        setTimeout(ping, 400);
      });
    }
    ping();
  });
}

assertFile(buildIdPath, "build (.next/BUILD_ID)");
assertFile(nextEntry, "Next.js CLI (next/dist/bin/next)");
assertFile(prismaEntry, "Prisma CLI");

console.log(`[railway-start] cwd=${storeAdminRoot} PORT=${port} node=${process.execPath}`);

const node = process.execPath;

console.log("[railway-start] starting Next.js…");
const next = spawn(node, [nextEntry, "start", "-H", "0.0.0.0", "-p", port], {
  stdio: "inherit",
  env,
  cwd: storeAdminRoot,
});

next.on("error", (err) => {
  console.error("[railway-start] next spawn error:", err);
  process.exit(1);
});

for (const sig of ["SIGTERM", "SIGINT"]) {
  process.on(sig, () => {
    try {
      next.kill(sig);
    } catch (_) {}
  });
}

try {
  console.log("[railway-start] waiting for GET /api/health → 200…");
  await waitForServer("/api/health", 120_000);
  console.log("[railway-start] server up, running prisma migrate deploy…");
} catch (e) {
  console.error("[railway-start]", e);
  try {
    next.kill("SIGTERM");
  } catch (_) {}
  process.exit(1);
}

const m = spawnSync(node, [prismaEntry, "migrate", "deploy"], {
  stdio: "inherit",
  env,
  cwd: storeAdminRoot,
});

const migrateOk = m.status === 0;
const strictMigrate =
  env.MIGRATE_STRICT === "1" ||
  env.MIGRATE_STRICT === "true" ||
  env.RAILWAY_STRICT_MIGRATE === "1";

if (!migrateOk) {
  console.error(
    "[railway-start] prisma migrate deploy falló (status=%s). Revisá DATABASE_URL, red y migraciones.",
    m.status
  );
  if (strictMigrate) {
    try {
      next.kill("SIGTERM");
    } catch (_) {}
    process.exit(m.status ?? 1);
  }
  console.error(
    "[railway-start] La app sigue arriba (health ya pasó). Corregí la DB y redeploy, o poné MIGRATE_STRICT=1 para tumbar el proceso si migrate falla."
  );
} else {
  console.log("[railway-start] migrate ok");
}

console.log("[railway-start] keeping Next process…");

const exitCode = await new Promise((resolve) => {
  next.on("exit", (code) => resolve(code ?? 0));
});
process.exit(typeof exitCode === "number" ? exitCode : 0);
