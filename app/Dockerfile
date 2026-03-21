# syntax=docker/dockerfile:1.7

FROM node:22.14.0-alpine3.21 AS build
WORKDIR /workspace

COPY package.json package-lock.json ./
COPY apps/api/package.json apps/api/package.json
COPY apps/web/package.json apps/web/package.json
COPY packages/shared/package.json packages/shared/package.json

RUN npm ci

COPY . .

RUN npm run build --workspace @scrambleiq/shared \
 && npm run build --workspace @scrambleiq/api

FROM node:22.14.0-alpine3.21 AS runtime
ARG APP_UID=10001
ARG APP_GID=10001

RUN addgroup -g ${APP_GID} -S scrambleiq \
 && adduser -u ${APP_UID} -S -G scrambleiq scrambleiq

WORKDIR /opt/scrambleiq

COPY --from=build /workspace/package.json /workspace/package-lock.json ./
COPY --from=build /workspace/node_modules ./node_modules
COPY --from=build /workspace/apps/api ./apps/api
COPY --from=build /workspace/packages/shared ./packages/shared

ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

USER scrambleiq:scrambleiq
CMD ["npm", "run", "start", "--workspace", "@scrambleiq/api"]
