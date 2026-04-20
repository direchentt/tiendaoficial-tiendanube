-- CreateTable
CREATE TABLE "WishlistItem" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "tnCustomerId" INTEGER NOT NULL,
    "customerEmail" VARCHAR(320) NOT NULL,
    "productId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "WishlistItem_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "WishlistItem_storeId_tnCustomerId_productId_key" ON "WishlistItem"("storeId", "tnCustomerId", "productId");

-- CreateIndex
CREATE INDEX "WishlistItem_storeId_productId_idx" ON "WishlistItem"("storeId", "productId");

-- CreateIndex
CREATE INDEX "WishlistItem_storeId_tnCustomerId_idx" ON "WishlistItem"("storeId", "tnCustomerId");

-- AddForeignKey
ALTER TABLE "WishlistItem" ADD CONSTRAINT "WishlistItem_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;
