-- Migration: add-gifts-bundles-dynamic-pricing
-- Agrega: CartGiftRule, DynamicPricingConfig, Bundle, BundleProduct
-- Modifica: LockedCategory (agrega accessTtlHours)

-- Alter LockedCategory: agregar campo accessTtlHours
ALTER TABLE "LockedCategory" ADD COLUMN IF NOT EXISTS "accessTtlHours" INTEGER NOT NULL DEFAULT 24;

-- CreateTable CartGiftRule
CREATE TABLE IF NOT EXISTS "CartGiftRule" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "minTotal" DOUBLE PRECISION NOT NULL,
    "giftProductId" INTEGER NOT NULL,
    "giftVariantId" INTEGER NOT NULL,
    "giftQty" INTEGER NOT NULL DEFAULT 1,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CartGiftRule_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "CartGiftRule_storeId_idx" ON "CartGiftRule"("storeId");

ALTER TABLE "CartGiftRule" ADD CONSTRAINT "CartGiftRule_storeId_fkey"
    FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- CreateTable DynamicPricingConfig
CREATE TABLE IF NOT EXISTS "DynamicPricingConfig" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "algorithm" TEXT NOT NULL DEFAULT 'seeded_random',
    "minPct" DOUBLE PRECISION NOT NULL DEFAULT 5,
    "maxPct" DOUBLE PRECISION NOT NULL DEFAULT 20,
    "cacheTtlHours" INTEGER NOT NULL DEFAULT 4,
    "excludedCategoryIds" TEXT NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DynamicPricingConfig_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "DynamicPricingConfig_storeId_key" ON "DynamicPricingConfig"("storeId");

-- CreateTable Bundle
CREATE TABLE IF NOT EXISTS "Bundle" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "comboPrice" DOUBLE PRECISION NOT NULL,
    "imageUrl" TEXT,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Bundle_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "Bundle_storeId_idx" ON "Bundle"("storeId");

-- CreateTable BundleProduct
CREATE TABLE IF NOT EXISTS "BundleProduct" (
    "id" TEXT NOT NULL,
    "bundleId" TEXT NOT NULL,
    "productId" INTEGER NOT NULL,
    "variantId" INTEGER NOT NULL DEFAULT 0,
    "productName" TEXT NOT NULL,
    "unitPrice" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "quantity" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "BundleProduct_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "BundleProduct_bundleId_idx" ON "BundleProduct"("bundleId");

ALTER TABLE "BundleProduct" ADD CONSTRAINT "BundleProduct_bundleId_fkey"
    FOREIGN KEY ("bundleId") REFERENCES "Bundle"("id") ON DELETE CASCADE ON UPDATE CASCADE;
