# syntax=docker/dockerfile:1.7
# Deterministic packaging template for ScrambleIQ.
# This Dockerfile intentionally fails fast if runtime artifacts are not staged.

FROM alpine:3.21.3 AS runtime

ARG APP_UID=10001
ARG APP_GID=10001
ARG APP_PORT=8080

RUN addgroup -g ${APP_GID} -S scrambleiq \
    && adduser -u ${APP_UID} -S -G scrambleiq scrambleiq

WORKDIR /opt/scrambleiq

# Required deterministic runtime bundle.
# Expected to be produced from the ScrambleIQ source repository and copied here.
COPY --chown=scrambleiq:scrambleiq src/ ./src/
COPY --chown=scrambleiq:scrambleiq run.sh ./run.sh

RUN test -x ./run.sh || (echo "run.sh must exist and be executable under app/" && exit 10)

ENV APP_PORT=${APP_PORT} \
    TZ=UTC

EXPOSE ${APP_PORT}

USER scrambleiq:scrambleiq
ENTRYPOINT ["/opt/scrambleiq/run.sh"]
