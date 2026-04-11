# Monorepo: Next.js en store-admin/. Root Directory vacio en Railway.
# npm ci --ignore-scripts: evita postinstall "prisma generate" sin schema (orden de capas Docker).

FROM node:20-bookworm-slim

WORKDIR /app

RUN apt-get update -y && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY store-admin/package.json store-admin/package-lock.json ./
RUN npm ci --ignore-scripts

COPY store-admin/ .

ENV NEXT_TELEMETRY_DISABLED=1
# Prisma valida env("DATABASE_URL") en generate; en build de imagen no hay Postgres aun (Railway la inyecta al correr).
ENV DATABASE_URL="postgresql://build:build@127.0.0.1:5432/build?schema=public"

RUN npx prisma generate && npm run build

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && exec next start -H 0.0.0.0 -p ${PORT:-3000}"]
