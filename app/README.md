# ScrambleIQ Application Packaging

## Current State of Source Analysis

The ScrambleIQ application source code is **not present in this repository workspace**, and outbound network access is restricted in this execution environment. Because of that, concrete runtime inference from source files (language, package manager, build command, framework internals) is `UNKNOWN` in this change set.

To preserve deterministic deployment, this package expects a pre-built, deterministic runtime bundle staged into `app/src/` and a deterministic startup script at `app/run.sh`.

## Required Inputs

1. `app/src/` directory populated from the ScrambleIQ repository build output.
2. `app/run.sh` executable that starts the application in foreground mode and emits logs to stdout/stderr.

## Build

```bash
docker build -t scrambleiq:local app/
```

## Run

```bash
docker run --rm --env-file app/.env.example -p 8080:8080 scrambleiq:local
```

## Determinism Constraints

- Container image pinning uses `alpine:3.21.3`.
- Runtime user/group IDs are explicit.
- Startup command is explicit and foreground-only.
- Missing runtime bundle fails build deterministically.
