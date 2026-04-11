# Store admin — reglas avanzadas (Next.js + TypeScript)

Panel y API para reglas que van mas alla del admin estandar de Tiendanube, apoyado en la **API oficial**.

## Requisitos previos (oficiales)

1. **App en el portal de partners** Tiendanube/Nuvemshop, flujo OAuth, scopes minimos:
   - `read_products` / `write_products` — listar productos y `PATCH /products/stock-price`
   - `read_payments` — `GET /payment_providers/options` (ids para reglas)
   - **Business Rules (pagos)**: documentacion [Business Rules](https://tiendanube.github.io/api-documentation/resources/business-rules): hay que **pedir habilitacion** a partners@tiendanube.com / partners@nuvemshop.com.br y registrar el callback:
     - Evento: `payments/before-filter`
     - URL publica: `https://TU_DOMINIO/api/tn/payments-before-filter`
2. Header en todas las llamadas REST: `Authentication: bearer ...` y `User-Agent` (ver [Intro API](https://tiendanube.github.io/api-documentation/intro)).

## Cuotas / medios de pago

- **Filtrar que opciones aparecen en checkout**: respuesta del callback con `command: "filter_payments_options"` (ver doc enlazada). Este repo implementa el endpoint y evalua reglas desde SQLite (Prisma).
- **Texto de cuotas / ocultar cuotas en el selector** (gateways transparentes): [Checkout SDK](https://tiendanube.github.io/api-documentation/resources/checkout_sdk) — `changePaymentBenefit`, `hideInstallments`. Requiere **Script** en checkout (`write_scripts`) y un JS desplegado; no esta en este scaffold (se puede anadir otro archivo servido estaticamente).

## Precios dinamicos por %

- Endpoint `POST /api/admin/apply-price-percent` con cuerpo `{ "percent": 10 }` o `{ "percent": -5, "dryRun": true }`.
- Usa `GET /products` paginado y `PATCH /products/stock-price` (maximo **50 variantes por request** en total). Respetar rate limits; en produccion conviene cola de trabajos.

## Categorias con contrasena

- La API **Category** no expone “password” como campo nativo. Aqui: tabla `LockedCategory` + verificacion `POST /api/admin/category-gate/verify`. En el **tema**, un script en storefront debe pedir la clave y, si `ok`, mostrar contenido (o redirigir). El hash en BD es SHA256 de ejemplo: **sustituir por bcrypt** antes de produccion.

## Comandos

```bash
cd store-admin
cp .env.example .env
npm install
npx prisma db push
npm run dev
```

## Modelo de regla de pago (Prisma)

`PaymentRule.excludePairs` es JSON:

```json
[
  { "providerId": "mercadopago", "optionId": "mercadopago_transparent_card" }
]
```

Ids reales: `GET /api/admin/payment-options` con header `x-admin-secret: TU_ADMIN_SECRET`.

`conditions` JSON ejemplo:

```json
{ "minTotal": 0, "maxTotal": 50000, "categoryIdsAny": [1234567] }
```

## Enlaces utiles

- [Product / stock-price](https://tiendanube.github.io/api-documentation/resources/product)
- [Business Rules](https://tiendanube.github.io/api-documentation/resources/business-rules)
- [Checkout SDK](https://tiendanube.github.io/api-documentation/resources/checkout_sdk)
