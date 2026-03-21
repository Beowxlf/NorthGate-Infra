# ScrambleIQ Packaging

This directory packages the real ScrambleIQ monorepo (`Beowxlf/ScrambleIQ`) into deployable container workloads.

## Verified application model

- Monorepo with two primary services:
  - `@scrambleiq/api` (NestJS + Node.js 22)
  - `@scrambleiq/web` (React + Vite)
- Shared workspace package: `@scrambleiq/shared`
- Runtime data store: PostgreSQL when `DATABASE_URL` is set.

## Images

- `app/Dockerfile`: API image build and runtime (`PORT=3000`).
- `app/Dockerfile.web`: Web static build and NGINX runtime (`:80`) with `/api` reverse-proxy to API.

## Deterministic build inputs

Build context must be the ScrambleIQ repository root at pinned ref:

`ca190cc12af74ddb1967bb2148da41cfa24b5b67`

### API image build

```bash
docker build -f app/Dockerfile -t scrambleiq-api:ca190cc .
```

### Web image build

```bash
docker build -f app/Dockerfile.web \
  --build-arg VITE_API_BASE_URL=/api \
  --build-arg VITE_API_AUTH_TOKEN=scrambleiq-local-dev-token \
  -t scrambleiq-web:ca190cc .
```

## Runtime topology

- `scrambleiq-db` (PostgreSQL 16)
- `scrambleiq-api` (NestJS)
- `scrambleiq-web` (NGINX serving web + proxying `/api`)

All request, error, and auth-failure events are observable through container stdout/stderr:

- NGINX JSON access/error logs
- API stdout/stderr (NestJS logger + exceptions)
