import { describe, expect, it } from "vitest";
import {
  extractEventFromJson,
  extractStoreUserIdFromJson,
  extractTopicFromHeaders,
  resolveTnWebhookTopic,
} from "./tn-webhook-ingest";

describe("extractTopicFromHeaders", () => {
  it("lee x-tn-event con prioridad", () => {
    const topic = extractTopicFromHeaders((n) => {
      if (n === "x-tn-event") return "order/paid";
      if (n === "x-event-name") return "ignored";
      return null;
    });
    expect(topic).toBe("order/paid");
  });

  it("cae a x-event-name", () => {
    const topic = extractTopicFromHeaders((n) => (n === "x-event-name" ? "product/created" : null));
    expect(topic).toBe("product/created");
  });
});

describe("extractEventFromJson", () => {
  it("lee event del JSON", () => {
    expect(extractEventFromJson(`{"store_id":1,"event":"category/updated","id":2}`)).toBe("category/updated");
  });

  it("devuelve vacío si no hay event", () => {
    expect(extractEventFromJson("{}")).toBe("");
  });
});

describe("extractStoreUserIdFromJson", () => {
  it("lee store_id numérico", () => {
    expect(extractStoreUserIdFromJson(`{"store_id":999,"event":"x"}`)).toBe("999");
  });
});

describe("resolveTnWebhookTopic", () => {
  it("prioriza header sobre body", () => {
    const t = resolveTnWebhookTopic(
      (n) => (n === "x-tn-event" ? "header/topic" : null),
      `{"event":"body/topic"}`
    );
    expect(t).toBe("header/topic");
  });

  it("usa body si no hay header", () => {
    const t = resolveTnWebhookTopic(() => null, `{"event":"product/deleted"}`);
    expect(t).toBe("product/deleted");
  });

  it("usa unknown si no hay nada", () => {
    expect(resolveTnWebhookTopic(() => null, "{}")).toBe("unknown");
  });
});
