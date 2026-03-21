# ScrambleIQ Application Architecture (Infrastructure Integration)

## 1. Application Analysis from Real Source Repository

Source analyzed: `https://github.com/Beowxlf/ScrambleIQ.git` at commit `ca190cc12af74ddb1967bb2148da41cfa24b5b67`.

### 1.1 Application type

| Dimension | Result | Source Evidence |
|---|---|---|
| Repository model | npm workspace monorepo | Root `package.json` defines workspaces `apps/web`, `apps/api`, `packages/shared`. |
| Backend | NestJS API (`@scrambleiq/api`) | `apps/api/package.json` scripts and dependencies. |
| Frontend | React + Vite SPA (`@scrambleiq/web`) | `apps/web/package.json` scripts/dependencies. |
| Service model | Multi-service (web + api + db) | Web calls API base URL; API optionally uses PostgreSQL via `DATABASE_URL`. |

### 1.2 Runtime requirements

| Component | Runtime | Build Steps | Runtime Port |
|---|---|---|---|
| API | Node.js 22, npm workspaces | `npm ci`, build shared package, build API package | `PORT` default `3000` |
| Web | Node.js 22 for build, NGINX for runtime | `npm ci`, build shared package, build web package (`vite build`) | NGINX `80` |
| Shared package | TypeScript workspace | built before API/Web runtime start | N/A |

### 1.3 External dependencies

| Dependency | Required | Details |
|---|---|---|
| PostgreSQL | Optional for runtime, required for persisted mode | API uses PostgreSQL only when `DATABASE_URL` is set; otherwise in-memory fallback. |
| API token | Required for protected API routes | API checks `x-api-key` or `Authorization: Bearer`; `/health` remains public. |
| Storage volume | Required for DB durability | PostgreSQL state persisted via Docker named volume `scrambleiq_db_data`. |

## 2. Deployment Architecture

Deployment model is deterministic multi-container in `app-hosting`:

1. `scrambleiq-db` (PostgreSQL)
2. `scrambleiq-api` (NestJS API)
3. `scrambleiq-web` (NGINX serving frontend and proxying `/api` to API)

### 2.1 Dependency order

`database -> api -> web_proxy`

This order is enforced in deployment playbook pre-task assertions and role sequencing.

## 3. Environment Variable Contract

### API runtime
- `PORT` (default `3000`)
- `WEB_ORIGIN` (CORS origin)
- `API_AUTH_TOKEN` (required non-placeholder)
- `DATABASE_URL` (PostgreSQL DSN)

### Web build/runtime
- `VITE_API_BASE_URL` (defaults to `/api` in this deployment)
- `VITE_API_AUTH_TOKEN` (embedded in frontend build; must match API token contract)

### Database
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD` (required non-placeholder)

## 4. Network Exposure Model

| Component | Network | Exposed |
|---|---|---|
| `scrambleiq-db` | internal Docker network | not host-exposed |
| `scrambleiq-api` | internal Docker network | not host-exposed |
| `scrambleiq-web` | internal + host | host `:80` (configurable) |

This aligns with service-catalog guidance: single ingress path to app-hosting services.

## 5. Logging and Wazuh Integration Model

### 5.1 Request logging
NGINX logs all inbound requests (including `/api`) in JSON to stdout.

### 5.2 Error logging
NGINX error logs go to stderr. API runtime logs/exceptions go to stdout/stderr through container logging.

### 5.3 Authentication event coverage
API token failures produce HTTP `401` responses; these are captured in NGINX JSON request logs via `status` and URI, enabling Wazuh rule correlation for auth failures.

### 5.4 Wazuh ingestion path
Wazuh agent on app-hosting node ingests Docker JSON log files (`/var/lib/docker/containers/*/*.log`) from:
- `scrambleiq-web`
- `scrambleiq-api`

## 6. Deterministic Controls

- Pinned ScrambleIQ source ref for deployment build.
- Explicit Docker image tags per pinned ref.
- Non-placeholder secret/token assertions in Ansible role.
- Declarative container lifecycle (`unless-stopped`) and network topology.
