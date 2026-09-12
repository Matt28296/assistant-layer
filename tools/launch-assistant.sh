#!/usr/bin/env bash
# Starts the ASSISTANT seat from the correct folder.
# Identity = hostname + working directory, so starting from the wrong folder makes the seat stop.
cd "$(dirname "$0")/.." || exit 1
exec claude
