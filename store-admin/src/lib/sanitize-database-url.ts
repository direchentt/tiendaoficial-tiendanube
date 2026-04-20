/**
 * Railway / paneles a veces guardan DATABASE_URL con comillas como parte del valor,
 * o con typo `ppostgresql://`. Prisma exige `postgresql://` o `postgres://`.
 * Debe ejecutarse antes de `new PrismaClient()` (importar este módulo primero en prisma.ts).
 */
export function sanitizeDatabaseUrlInPlace(): void {
  const v = process.env.DATABASE_URL;
  if (typeof v !== "string" || !v) return;
  let u = v.trim();
  if ((u.startsWith('"') && u.endsWith('"')) || (u.startsWith("'") && u.endsWith("'"))) {
    u = u.slice(1, -1).trim();
  }
  if (u.startsWith("ppostgresql://")) {
    u = `postgresql://${u.slice("ppostgresql://".length)}`;
  }
  process.env.DATABASE_URL = u;
}

sanitizeDatabaseUrlInPlace();
