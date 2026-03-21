# app_runtime Role

Deploys ScrambleIQ as a deterministic multi-container workload:

1. PostgreSQL (`scrambleiq-db`)
2. API (`scrambleiq-api`)
3. Web + reverse proxy (`scrambleiq-web`)

The role checks out a pinned ScrambleIQ commit, builds API/web images from local packaging Dockerfiles, and starts containers with deterministic configuration.

## Required overrides

- `app_runtime_api_env.API_AUTH_TOKEN`
- `app_runtime_database_env.POSTGRES_PASSWORD`
- `app_runtime_web_build_args.VITE_API_AUTH_TOKEN`
