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

- **Filtrar que opciones aparecen en checkout**: respuesta del callback con `command: "filter_payments_options"` (ver doc enlazada). Este repo implementa el endpoint y evalua reglas desde **PostgreSQL** (Prisma).
- **Texto de cuotas / ocultar cuotas en el selector** (gateways transparentes): [Checkout SDK](https://tiendanube.github.io/api-documentation/resources/checkout_sdk) — `changePaymentBenefit`, `hideInstallments`. Requiere **Script** en checkout (`write_scripts`) y un JS desplegado; no esta en este scaffold (se puede anadir otro archivo servido estaticamente).

## Precios dinamicos por %

- Endpoint `POST /api/admin/apply-price-percent` con cuerpo `{ "percent": 10 }` o `{ "percent": -5, "dryRun": true }`.
- Usa `GET /products` paginado y `PATCH /products/stock-price` (maximo **50 variantes por request** en total). Respetar rate limits; en produccion conviene cola de trabajos.

## Categorias con contrasena

- La API **Category** no expone “password” como campo nativo. Aqui: tabla `LockedCategory` + verificacion `POST /api/admin/category-gate/verify`. En el **tema**, un script en storefront debe pedir la clave y, si `ok`, mostrar contenido (o redirigir). El hash en BD es SHA256 de ejemplo: **sustituir por bcrypt** antes de produccion.

## Panel web (UI)

1. `npm run dev` y abri **http://localhost:3010/admin/login**
2. Ingresa el valor de `ADMIN_SECRET` del `.env`
3. Desde ahi: reglas de pago, listado de medios de pago, ajuste de precios, categorias bloqueadas

## Despliegue en Railway

1. Subi el repo a GitHub (o conecta el repo que ya uses).
2. En [Railway](https://railway.app): **New project** → **Deploy from GitHub** → elegi el repo.
3. **Root Directory**: dejalo **vacío** (raiz del repo). El `Dockerfile` de la raiz construye `store-admin/`; si pones solo `store-admin`, Railpack/Nixpacks suele funcionar, pero si ves *Error creating build plan with Railpack*, usa raiz + Dockerfile.
4. **Create** → **Database** → **Add PostgreSQL**.
5. En la base Postgres: pestaña **Variables** → **Connect** (o **Raw** `DATABASE_URL`) y **referenciá** esa variable en el servicio web:
   - En el servicio Next.js: **Variables** → **Add variable** → **Reference** → elegi Postgres → `DATABASE_URL`.
6. En el mismo servicio web agrega variables **manuales**:
   - `ADMIN_SECRET` — clave larga para el panel (**obligatoria**). Si falta o está vacía, `/api/admin/*` responde error (antes parecía siempre `401 Unauthorized`; ahora también puede ser `503` con mensaje explícito). El script del tema `hache-suite.js` llama solo a `/api/storefront/*`, que **no** usa este secreto.
   - `TN_STORE_USER_ID`, `TN_ACCESS_TOKEN`, `TN_USER_AGENT`
   - `NEXT_PUBLIC_APP_URL` — URL publica del servicio (ej. `https://store-admin-production-xxxx.up.railway.app`; copiala de **Settings → Networking → Generate domain**)

### Si ves `{"error":"Unauthorized"}` en el panel o en Postman

- **Rutas `/api/admin/*`**: tenés que (1) abrir `/admin/login` en el mismo dominio del backend e ingresar el valor de `ADMIN_SECRET`, o (2) enviar `x-admin-secret: <mismo valor que ADMIN_SECRET>` en cada request.
- **Rutas `/api/storefront/*`** (las que usa `hache-suite.js`): no llevan secreto; si fallan, revisá `storeId` (debe coincidir con `tiendanubeUserId` en la tabla `Store` de Postgres) y que la tienda exista en la base.
- Diagnóstico: `GET /api/admin/debug-auth` y `debug-store` solo en **desarrollo** (`npm run dev`) o en producción si definís **`ALLOW_ADMIN_DEBUG=1`** (y estás logueado en el panel). Sin el flag, responden **404** para no exponer rutas de diagnóstico.
7. **Deploy**: el build en Docker solo hace `prisma generate` + `next build` (sin tocar la DB). Al **arrancar** el contenedor, `npm run start:railway` ejecuta `prisma migrate deploy` y luego Next. En Railway marcá `DATABASE_URL` como disponible en **build** si el generate lo requiere en tu versión de Prisma.

Archivos relevantes: `railway.toml`, `package.json` (`start:railway`, `postinstall`).

Callback Tiendanube (Business Rules): `https://TU_DOMINIO_RAILWAY/api/tn/payments-before-filter`

### Supabase + Railway (`P1001 Can't reach database server`)

Desde contenedores (Railway) la conexion **directa** `db.PROJECT.supabase.co:5432` a veces **no responde** (IPv4/IPv6). En Supabase: **Project Settings → Database → Connection string** y elegi **Session pooler** (recomendado para migraciones Prisma) o **Transaction pooler**. El host debe ser algo como `aws-0-REGION.pooler.supabase.com`, **no** `db.*.supabase.co`. Pegá esa URI completa en Railway como `DATABASE_URL` y agregá `?sslmode=require` si la UI no lo incluye. Comprobá que el proyecto Supabase no este **pausado**.

## Comandos (local con Postgres)

```bash
cd store-admin
docker compose up -d
cp .env.example .env
# DATABASE_URL=postgresql://store:store@localhost:5433/storeadmin?schema=public
npm install
npx prisma migrate deploy
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
