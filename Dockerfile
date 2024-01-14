FROM node:18-alpine as base
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /app
COPY package*.json ./
# EXPOSE 3000

FROM base as builder
WORKDIR /app
COPY app ./app
COPY public ./public
COPY next.config.js .
COPY tsconfig.json .
COPY postcss.config.js .
COPY tailwind.config.ts .
RUN npm i

RUN npm run build

FROM node:18-alpine as prod
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
CMD ["node", "server.js"]

FROM base as dev
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm i
COPY . .
CMD npm run dev

