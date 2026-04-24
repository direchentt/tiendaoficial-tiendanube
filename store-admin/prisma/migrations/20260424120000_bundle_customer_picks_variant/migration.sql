-- BundleProduct: allow storefront customer to pick variant for a line
ALTER TABLE "BundleProduct" ADD COLUMN "customerPicksVariant" BOOLEAN NOT NULL DEFAULT false;
