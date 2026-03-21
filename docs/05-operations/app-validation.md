# ScrambleIQ Deployment Validation Runbook

## 1. Application Reachability

1. Confirm containers are running:
   - `scrambleiq-db`
   - `scrambleiq-api`
   - `scrambleiq-web`
2. Execute `GET /` on app-hosting ingress.
3. Expect web UI payload (HTTP 200).

## 2. Functional Validation

1. Execute `GET /api/health` through ingress; expect 200.
2. Execute authenticated API call:
   - Header `x-api-key: <API_AUTH_TOKEN>`
   - Example endpoint: `/api/matches`
3. Execute unauthenticated call to same protected route; expect 401.
4. If PostgreSQL mode enabled, create/update/read one match record and verify persistence after API restart.

## 3. Logging Validation

1. Generate one successful API request.
2. Generate one failed/auth-denied API request.
3. Verify logs from:
   - `docker logs scrambleiq-web`
   - `docker logs scrambleiq-api`
4. Confirm NGINX JSON logs include `status`, `uri`, `remote_addr`, and timing fields.

## 4. Wazuh Visibility Validation

1. Confirm Wazuh agent is active on app-hosting node.
2. Confirm agent monitors Docker container log files.
3. In Wazuh, verify:
   - request events from `scrambleiq-web`
   - auth-failure (`401`) events on protected `/api/*` routes
   - API error events from `scrambleiq-api` stderr/stdout

## 5. Restart Behavior Validation

1. Restart `scrambleiq-api` container.
2. Re-run `/api/health` and one authenticated endpoint.
3. Restart Docker daemon/host and confirm all ScrambleIQ containers auto-recover (`unless-stopped`).

## 6. Rebuild / Redeploy Behavior

1. Re-run `ansible/playbooks/app_deploy.yml` with same pinned `app_runtime_repo_ref`.
2. Validate resulting image tags and container topology are unchanged.
3. Validate database volume `scrambleiq_db_data` persists application data across redeploy.

## 7. Deterministic Acceptance Criteria

- Deployment uses pinned source commit (`app_runtime_repo_ref`).
- No placeholder values remain for auth/database secrets.
- Container dependency order remains `database -> api -> web_proxy`.
- Ingress path remains single-entry through `scrambleiq-web`.
- Request/error/auth-failure events are visible in Wazuh pipeline.
