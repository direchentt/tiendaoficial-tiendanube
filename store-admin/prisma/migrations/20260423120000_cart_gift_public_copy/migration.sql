-- Texto público del beneficio (popup en tienda)
ALTER TABLE "CartGiftRule" ADD COLUMN IF NOT EXISTS "publicBenefitTitle" TEXT;
ALTER TABLE "CartGiftRule" ADD COLUMN IF NOT EXISTS "publicBenefitMessage" TEXT;
