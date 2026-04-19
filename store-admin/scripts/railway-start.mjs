#!/usr/bin/env node
/**
 * Railway: levantar Next lo antes posible para el healthcheck, luego migraciones.
 * Usa binarios de node_modules (evita npx + shell en imágenes mínimas).
 */
import http from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const storeAdminRoot = path.resolve(__dirname, "..");
const nextBin = path.join(storeAdminRoot, "node_modules", ".bin", "next");
const prismaBin = path.join(storeAdminRoot, "node_modules", ".bin", "prisma");

const port = process.env.PORT ?? "3000";
const env = { ...process.env, NODE_ENV: process.env.NODE_ENV ?? "production" };

function assertBin(p, name) {
  if (!fs.existsSync(p)) {
    console.error(`[railway-start] falta ${name} en ${p} (¿npm ci en store-admin?)`);
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
          if (res.statusCode && res.statusCode >= 200 && res.statusCode < 500) {
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

assertBin(nextBin, "next");
assertBin(prismaBin, "prisma");

console.log(`[railway-start] cwd=${storeAdminRoot} PORT=${port}`);
console.log("[railway-start] starting Next.js…");

const next = spawn(nextBin, ["start", "-H", "0.0.0.0", "-p", String(port)], {
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
  console.log("[railway-start] waiting for /api/health…");
  await waitForServer("/api/health", 120_000);
  console.log("[railway-start] server up, running prisma migrate deploy…");
} catch (e) {
  console.error("[railway-start]", e);
  try {
    next.kill("SIGTERM");
  } catch (_) {}
  process.exit(1);
}

const m = spawnSync(prismaBin, ["migrate", "deploy"], {
  stdio: "inherit",
  env,
  cwd: storeAdminRoot,
});

if (m.status !== 0 && m.status !== null) {
  console.error("[railway-start] migrate deploy failed:", m.status);
  try {
    next.kill("SIGTERM");
  } catch (_) {}
  process.exit(m.status ?? 1);
}

console.log("[railway-start] migrate ok, keeping Next process…");

const exitCode = await new Promise((resolve) => {
  next.on("exit", (code) => resolve(code ?? 0));
});
process.exit(typeof exitCode === "number" ? exitCode : 0);
