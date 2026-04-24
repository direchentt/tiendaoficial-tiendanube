import { describe, expect, it } from "vitest";
import { linkedStoreHmacSha256Hex, verifyLinkedStoreHmacSha256 } from "./tn-webhook-hmac";

describe("verifyLinkedStoreHmacSha256", () => {
  it("acepta firma hex igual a PHP hash_hmac sha256", () => {
    const secret = "my_app_secret";
    const body = `{"store_id":123,"event":"product/created","id":1}`;
    const hex = linkedStoreHmacSha256Hex(body, secret);
    expect(hex).toMatch(/^[0-9a-f]{64}$/);
    expect(verifyLinkedStoreHmacSha256(body, hex, secret)).toBe(true);
  });

  it("rechaza firma incorrecta", () => {
    const body = "{}";
    expect(verifyLinkedStoreHmacSha256(body, "00".repeat(32), "secret")).toBe(false);
  });

  it("rechaza header vacío o secreto vacío", () => {
    expect(verifyLinkedStoreHmacSha256("{}", "", "s")).toBe(false);
    expect(verifyLinkedStoreHmacSha256("{}", "abc", "")).toBe(false);
  });

  it("acepta hex en mayúsculas en el header", () => {
    const secret = "x";
    const body = "payload";
    const hex = linkedStoreHmacSha256Hex(body, secret);
    expect(verifyLinkedStoreHmacSha256(body, hex.toUpperCase(), secret)).toBe(true);
  });
});
