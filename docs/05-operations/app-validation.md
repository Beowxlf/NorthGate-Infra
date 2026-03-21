# ScrambleIQ Deployment Validation Runbook

## 1. Reachability Validation
1. Verify proxy container is running.
2. Execute HTTP GET against proxy endpoint.
3. Expect `200` or application-defined healthy response code.

## 2. Functional Validation
1. Execute deterministic application smoke path (`/health` or equivalent, `UNKNOWN` until source is available).
2. Validate database dependency by performing one read/write transaction through app API path.
3. Confirm no manual post-deploy step is required.

## 3. Logging Validation
1. Generate at least one normal request.
2. Generate at least one failing request.
3. Generate at least one authentication attempt (success/failure if auth exists).
4. Confirm logs appear in:
   - `docker logs scrambleiq-app`
   - `docker logs scrambleiq-proxy`

## 4. Wazuh Visibility Validation
1. Confirm Wazuh agent active on app-hosting node.
2. Confirm Docker container log file monitoring is enabled in agent config.
3. Confirm request/error/auth events appear in Wazuh index within expected ingestion window.

## 5. Restart Behavior Validation
1. Restart `scrambleiq-app` container.
2. Verify service recovery without config drift.
3. Restart host daemon/service path and confirm `unless-stopped` policy restores containers.

## 6. Rebuild Behavior Validation
1. Rebuild image using deterministic app bundle.
2. Redeploy role/playbook.
3. Validate identical container topology and expected environment variable projection.
4. Verify persistent data remains in `scrambleiq_db_data` volume.

## 7. Deterministic Acceptance Criteria
- All required variables are explicitly set (no placeholders).
- Deployment order remains database -> app -> proxy.
- No manual runtime patching or out-of-band edits.
- Logs are observable locally and in Wazuh pipeline.
