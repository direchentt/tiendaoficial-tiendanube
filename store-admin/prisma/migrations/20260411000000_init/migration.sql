-- CreateTable
CREATE TABLE "Store" (
    "id" TEXT NOT NULL,
    "tiendanubeUserId" TEXT NOT NULL,
    "accessToken" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Store_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Store_tiendanubeUserId_key" ON "Store"("tiendanubeUserId");

CREATE TABLE "PaymentRule" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "conditions" TEXT NOT NULL,
    "excludePairs" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentRule_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "PaymentRule_storeId_idx" ON "PaymentRule"("storeId");

CREATE TABLE "PricePreset" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "percent" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PricePreset_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "PricePreset_storeId_idx" ON "PricePreset"("storeId");

CREATE TABLE "LockedCategory" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "categoryId" INTEGER NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LockedCategory_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "LockedCategory_storeId_categoryId_key" ON "LockedCategory"("storeId", "categoryId");

ALTER TABLE "PaymentRule" ADD CONSTRAINT "PaymentRule_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PricePreset" ADD CONSTRAINT "PricePreset_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "LockedCategory" ADD CONSTRAINT "LockedCategory_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
