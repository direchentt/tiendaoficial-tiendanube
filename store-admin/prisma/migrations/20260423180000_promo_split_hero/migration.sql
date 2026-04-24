-- Banner + 2x2 productos por categoría (PromoSplitHero)
CREATE TABLE "PromoSplitHero" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "bannerUrl" TEXT,
    "categoryId" INTEGER NOT NULL,
    "showOnHome" BOOLEAN NOT NULL DEFAULT true,
    "showOnCategory" BOOLEAN NOT NULL DEFAULT true,
    "showOnProduct" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PromoSplitHero_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PromoSplitHero_storeId_key" ON "PromoSplitHero"("storeId");

ALTER TABLE "PromoSplitHero" ADD CONSTRAINT "PromoSplitHero_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
