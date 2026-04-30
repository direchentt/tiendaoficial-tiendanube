-- CreateTable
CREATE TABLE "ComboLandingPage" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "slug" VARCHAR(120) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "intro" TEXT,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ComboLandingPage_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ComboLandingPage_storeId_slug_key" ON "ComboLandingPage"("storeId", "slug");

CREATE INDEX "ComboLandingPage_storeId_idx" ON "ComboLandingPage"("storeId");

ALTER TABLE "ComboLandingPage" ADD CONSTRAINT "ComboLandingPage_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Bundle" ADD COLUMN "landingPageId" TEXT;

CREATE INDEX "Bundle_landingPageId_idx" ON "Bundle"("landingPageId");

ALTER TABLE "Bundle" ADD CONSTRAINT "Bundle_landingPageId_fkey" FOREIGN KEY ("landingPageId") REFERENCES "ComboLandingPage"("id") ON DELETE SET NULL ON UPDATE CASCADE;
