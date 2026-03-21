#!/bin/sh
set -eu

if [ -z "${START_COMMAND:-}" ]; then
  echo "START_COMMAND is required (for example: 'node dist/server.js' or './scrambleiq')." >&2
  exit 20
fi

# shellcheck disable=SC2086
exec sh -c "$START_COMMAND"
