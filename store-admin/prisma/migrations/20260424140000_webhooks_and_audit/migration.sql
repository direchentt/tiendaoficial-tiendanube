-- CreateTable
CREATE TABLE "TnWebhookEvent" (
    "id" TEXT NOT NULL,
    "tiendanubeUserId" VARCHAR(32),
    "topic" VARCHAR(160) NOT NULL,
    "payload" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TnWebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdminAuditLog" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "action" VARCHAR(120) NOT NULL,
    "entityType" VARCHAR(80),
    "entityId" VARCHAR(80),
    "summary" VARCHAR(500) NOT NULL,
    "meta" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdminAuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TnWebhookEvent_createdAt_idx" ON "TnWebhookEvent"("createdAt");

-- CreateIndex
CREATE INDEX "TnWebhookEvent_tiendanubeUserId_createdAt_idx" ON "TnWebhookEvent"("tiendanubeUserId", "createdAt");

-- CreateIndex
CREATE INDEX "AdminAuditLog_storeId_createdAt_idx" ON "AdminAuditLog"("storeId", "createdAt");

-- AddForeignKey
ALTER TABLE "AdminAuditLog" ADD CONSTRAINT "AdminAuditLog_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
