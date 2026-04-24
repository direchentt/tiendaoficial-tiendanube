-- Estado de procesamiento por topic (worker ligero post-ingesta).
ALTER TABLE "TnWebhookEvent" ADD COLUMN "processedAt" TIMESTAMP(3);
ALTER TABLE "TnWebhookEvent" ADD COLUMN "processError" VARCHAR(500);

CREATE INDEX "TnWebhookEvent_processedAt_idx" ON "TnWebhookEvent"("processedAt");
