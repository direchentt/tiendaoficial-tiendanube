# Monorepo: la app Next.js vive en store-admin/. Railway/Railpack desde la raiz no la encontraba.
# Deja "Root Directory" VACIO en Railway (raiz del repo) para que use este Dockerfile.

FROM node:20-bookworm-slim

WORKDIR /app

RUN apt-get update -y && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY store-admin/package.json store-admin/package-lock.json ./
RUN npm ci

COPY store-admin/ .

ENV NEXT_TELEMETRY_DISABLED=1

RUN npx prisma generate && npm run build

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && exec next start -H 0.0.0.0 -p ${PORT:-3000}"]
