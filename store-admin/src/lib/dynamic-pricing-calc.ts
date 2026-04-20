/**
 * Misma lógica que el storefront GET /dynamic-prices (mantener alineado).
 */

function seededRandom(seed: number): number {
  const x = Math.sin(seed) * 10000;
  return x - Math.floor(x);
}

function getDateSeed(): number {
  const d = new Date();
  return d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate();
}

export function calcSeededRandom(productId: number, minPct: number, maxPct: number): number {
  const seed = productId * 31337 + getDateSeed();
  const r = seededRandom(seed);
  return Math.round((minPct + r * (maxPct - minPct)) * 10) / 10;
}

export function calcDemandBased(productId: number, minPct: number, maxPct: number): number {
  const hour = new Date().getHours();
  const normalized = (Math.cos(((hour - 4) * Math.PI) / 12) + 1) / 2;
  const pct = minPct + normalized * (maxPct - minPct);
  const noise = seededRandom(productId * 9973) * 2 - 1;
  return Math.max(minPct, Math.min(maxPct, Math.round((pct + noise) * 10) / 10));
}

export function calcProgressive(
  productId: number,
  minPct: number,
  maxPct: number,
  visitCount: number
): number {
  const t = Math.min(visitCount, 10) / 10;
  const base = minPct + t * (maxPct - minPct);
  const noise = seededRandom(productId * 7919) * (maxPct - minPct) * 0.1;
  return Math.max(minPct, Math.min(maxPct, Math.round((base + noise) * 10) / 10));
}

export function calcDiscountPctForProduct(
  productId: number,
  algorithm: string,
  minPct: number,
  maxPct: number,
  visitCount: number
): number {
  switch (algorithm) {
    case "demand_based":
      return calcDemandBased(productId, minPct, maxPct);
    case "progressive":
      return calcProgressive(productId, minPct, maxPct, visitCount);
    default:
      return calcSeededRandom(productId, minPct, maxPct);
  }
}
