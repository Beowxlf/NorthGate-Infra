# app_runtime Role

Deploys ScrambleIQ as a deterministic container workload with optional PostgreSQL and NGINX sidecar services.

## Responsibilities
- Installs Docker runtime.
- Renders environment configuration.
- Deploys database container (optional/required by default).
- Deploys application container.
- Deploys reverse proxy container (optional/enabled by default).

## Inputs
Populate `app_runtime_env.START_COMMAND` and non-placeholder secrets before execution.
