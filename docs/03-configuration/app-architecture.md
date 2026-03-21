# ScrambleIQ Application Architecture (Infrastructure Integration)

## 1. Application Source Analysis Outcome

| Analysis Dimension | Result | Evidence Status |
|---|---|---|
| Repository path available in workspace | `UNKNOWN` | ScrambleIQ source repository not present in provided filesystem snapshot. |
| Runtime language/framework | `UNKNOWN` | No application source files available for direct inspection. |
| Monolith vs multi-service implementation | `UNKNOWN` | No executable source manifest available. |
| Build toolchain | `UNKNOWN` | No package/build descriptors available. |
| Native service ports | `UNKNOWN` | No server bootstrap code available. |

## 2. Deterministic Deployment Model Implemented

Given source availability gap, this repository now defines a deterministic **hosting envelope** for ScrambleIQ:

1. Reverse proxy container (NGINX) for ingress and request logging.
2. Application runtime container (`scrambleiq-app`).
3. PostgreSQL container (`scrambleiq-db`) for persistent application data.

### 2.1 Service and Dependency Model

| Service | Depends On | Dependency Type |
|---|---|---|
| `scrambleiq-db` | Docker runtime, storage volume | Hard |
| `scrambleiq-app` | `scrambleiq-db`, runtime env variables | Hard |
| `scrambleiq-proxy` | `scrambleiq-app` | Hard |

Order is enforced in Ansible workflow: database -> app -> proxy.

## 3. Runtime Configuration Contract

Environment variables are declared in:
- `app/.env.example`
- `ansible/roles/app_runtime/defaults/main.yml`

Mandatory pre-deployment substitutions:
- `DB_PASSWORD`
- `POSTGRES_PASSWORD`
- `START_COMMAND`
- Auth-related placeholders if identity integration is enabled.

## 4. Network and Port Model

| Component | Internal Port | External Exposure |
|---|---|---|
| Reverse proxy | 80 | Host port 80 (default configurable) |
| Application | 8080 | Internal Docker network only |
| PostgreSQL | 5432 | Internal Docker network only |

This enforces single-ingress behavior aligned with catalog guidance.

## 5. Logging Model and Wazuh Ingestibility

### 5.1 Application
- Application process must log to stdout/stderr (foreground command via `START_COMMAND`).
- Role config enables Docker JSON logging driver for structured collection.

### 5.2 Reverse proxy
- NGINX access logs emitted in JSON to `/dev/stdout`.
- NGINX errors emitted to `/dev/stderr`.

### 5.3 Security event expectations
Authentication event logging is enforced by contract variable `LOG_AUTH_EVENTS=true`. Exact event schema remains `UNKNOWN` until source-level instrumentation is validated.

### 5.4 Wazuh integration path
Wazuh agent on app-hosting node can ingest Docker container logs from host log paths (`/var/lib/docker/containers/*/*.log`) and forward to manager/indexer pipeline defined in security services model.

## 6. Gap Register

| Gap | Impact | Remediation |
|---|---|---|
| ScrambleIQ repository unavailable | Cannot derive concrete runtime/build metadata from code | Import repository into controlled source path; update this document with concrete evidence in same change set. |
| Auth event schema unknown | Rule mapping in Wazuh incomplete | Add source-based auth logging field mapping and detection rules. |
