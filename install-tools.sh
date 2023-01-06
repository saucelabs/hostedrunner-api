#!/usr/bin/env sh
set -o errexit -eo pipefail

go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@v1.12.4
