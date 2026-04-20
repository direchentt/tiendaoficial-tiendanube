-- Opcional: al agregar al carrito, escribir precio promocional en Tiendanube (PATCH stock-price).
ALTER TABLE "DynamicPricingConfig" ADD COLUMN IF NOT EXISTS "commitOnAddToCart" BOOLEAN NOT NULL DEFAULT false;
