#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Construction des images Docker..."
docker build -t microservice/gateway-server:latest -f docker/Dockerfile.gateway .
docker build -t microservice/user-service:latest -f docker/Dockerfile.user .
docker build -t microservice/order-service:latest -f docker/Dockerfile.order .

echo "==> Images construites avec succès."
docker images | grep microservice || true
