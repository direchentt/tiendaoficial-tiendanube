# Store admin — reglas avanzadas (Next.js + TypeScript)

Panel y API para reglas que van mas alla del admin estandar de Tiendanube, apoyado en la **API oficial**.

## Requisitos previos (oficiales)

1. **App en el portal de partners** Tiendanube/Nuvemshop, flujo OAuth, scopes minimos:
   - `read_products` / `write_products` — listar productos y `PATCH /products/stock-price`
   - `read_customers` — **wishlist / favoritos** en el tema: el backend valida `customerId` + email contra `GET /customers/{id}` antes de guardar en `WishlistItem`.
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

## Wishlist (favoritos en el PDP)

- **Storefront**: `GET|POST /api/storefront/wishlist` (CORS abierto; mismo `storeId` que el resto de `hache-suite.js`). Si el `storeId` coincide con **`TN_STORE_USER_ID`**, cada request hace **upsert** de `Store` y **renueva `accessToken`** desde env (así no queda un token viejo solo en Postgres). Si el id no coincide con env ni hay fila, **404** `{ "error": "store_not_found", ... }`. `GET ...&details=1` devuelve `items` con `name`, `url` e `image` por producto (API TN `read_products`).
- **Diagnóstico**: `GET /api/storefront/wishlist-ping?storeId=<LS.store.id>` — siempre **HTTP 200** y JSON (`endpoint: "wishlist-ping"`). Si ves la página HTML “This page could not be found”, esa URL no está llegando a este Next (deploy viejo, otro servicio o dominio distinto). Compará con `GET /api/health` en el mismo host.
- **Novedades (header)**: `GET /api/storefront/recent-products?storeId=&days=30&limit=12` — productos publicados creados en ese rango (`read_products`). El tema muestra la campana si `header_notify_enabled` esta activo.
- **Admin**: `GET /api/admin/wishlist-stats` — ranking por `productId` (conteo de filas actuales en favoritos), cantidad de clientes con al menos un item y total de filas.
- Migracion: `WishlistItem` en Postgres (`prisma migrate deploy` en arranque Railway).

## Categorias con contrasena

- La API **Category** no expone “password” como campo nativo. Aqui: tabla `LockedCategory` + verificacion `POST /api/admin/category-gate/verify`. En el **tema**, un script en storefront debe pedir la clave y, si `ok`, mostrar contenido (o redirigir). El hash en BD es SHA256 de ejemplo: **sustituir por bcrypt** antes de produccion.

## Panel web (UI)

1. `npm run dev` y abri **http://localhost:3010/admin/login**
2. Ingresa el valor de `ADMIN_SECRET` del `.env`
3. Desde ahi: reglas de pago, listado de medios de pago, ajuste de precios, categorias bloqueadas

## UI: Kokonut UI + shadcn (Tailwind v4)

El panel incluye la base para usar componentes de **[Kokonut UI](https://github.com/kokonut-labs/kokonutui)** (registro remoto compatible con shadcn CLI), según la [guía oficial](https://kokonutui.com/docs).

- **Tailwind CSS v4** + PostCSS (`postcss.config.mjs`, `src/app/globals.css`).
- **`components.json`**: preset shadcn + registro `"@kokonutui": "https://kokonutui.com/r/{name}.json"`.
- **Tema**: `<html class="dark">` + tokens shadcn en `globals.css` (convive con variables legacy `--surface`, `--accent`, etc. para pantallas que aún usan estilos inline).

Agregar un bloque de Kokonut (ejemplo):

```bash
cd store-admin
npx shadcn@latest add @kokonutui/particle-button -y
```

Luego importá el componente generado (suele quedar bajo `src/components/kokonutui/`) en cualquier página o layout client/server según corresponda. Si el CLI pregunta por sobrescribir archivos, usá `--overwrite`. En monorepos: `npx shadcn@latest add @kokonutui/NOMBRE -c ./store-admin`.

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

- **Rutas `/api/admin/*`**: el servidor acepta cookie de sesión (tras `/admin/login`), header **`x-admin-secret`**, o **`Authorization: Bearer`** con el mismo valor que `ADMIN_SECRET`. El panel envía `x-admin-secret` + `Authorization` desde `sessionStorage` y la cookie httpOnly.
- En **Railway**, que `ADMIN_SECRET` no incluya comillas ni espacios extra (el código hace `trim`). Si cambiaste el secreto, volvé a **login** para alinear cookie y `sessionStorage`. Usá siempre el **HTTPS** del dominio del servicio.
- **Rutas `/api/storefront/*`** (`hache-suite.js`): no usan `ADMIN_SECRET`; revisá `storeId` y la fila `Store` en Postgres.
- Diagnóstico: `GET /api/admin/debug-auth` con **`ALLOW_ADMIN_DEBUG=1`** en prod (y sesión válida), o en `npm run dev`.
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
