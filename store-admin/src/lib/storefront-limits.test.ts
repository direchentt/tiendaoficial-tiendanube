import { afterEach, describe, expect, it, vi } from "vitest";
import {
  clampStorefrontVisitCount,
  getMaxDynamicPriceProductIds,
  parseProductIdsListCsv,
  parseStorefrontStoreUserId,
} from "./storefront-limits";

describe("parseStorefrontStoreUserId", () => {
  it("acepta ids numéricos razonables", () => {
    expect(parseStorefrontStoreUserId("12345")).toBe("12345");
  });

  it("rechaza vacío o no numérico", () => {
    expect(parseStorefrontStoreUserId("")).toBeNull();
    expect(parseStorefrontStoreUserId("abc")).toBeNull();
  });
});

describe("parseProductIdsListCsv", () => {
  it("deduplica y respeta el tope", () => {
    const { ids, truncated } = parseProductIdsListCsv("10,10,5,6", 2);
    expect(ids).toEqual([10, 5]);
    expect(truncated).toBe(true);
  });
});

describe("clampStorefrontVisitCount", () => {
  it("acota a rango válido", () => {
    expect(clampStorefrontVisitCount(0)).toBe(1);
    expect(clampStorefrontVisitCount(3.7)).toBe(3);
  });
});

describe("getMaxDynamicPriceProductIds", () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it("usa default sin env", () => {
    vi.stubEnv("STOREFRONT_MAX_PRODUCT_IDS_DYNAMIC_PRICES", "");
    expect(getMaxDynamicPriceProductIds()).toBe(150);
  });

  it("respeta env numérico y tope absoluto", () => {
    vi.stubEnv("STOREFRONT_MAX_PRODUCT_IDS_DYNAMIC_PRICES", "200");
    expect(getMaxDynamicPriceProductIds()).toBe(200);
    vi.stubEnv("STOREFRONT_MAX_PRODUCT_IDS_DYNAMIC_PRICES", "9999");
    expect(getMaxDynamicPriceProductIds()).toBe(500);
  });
});
