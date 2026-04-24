import { describe, expect, it } from "vitest";
import { CONVERSION_EVENT_TYPES, isConversionEventType } from "./conversion-events";

describe("isConversionEventType", () => {
  it("acepta tipos conocidos", () => {
    for (const t of CONVERSION_EVENT_TYPES) {
      expect(isConversionEventType(t)).toBe(true);
    }
  });

  it("rechaza tipos inválidos", () => {
    expect(isConversionEventType("checkout")).toBe(false);
    expect(isConversionEventType("")).toBe(false);
  });
});
