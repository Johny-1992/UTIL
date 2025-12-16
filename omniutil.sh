#!/bin/bash
set -e

echo "🚀 OMNIUTIL – FULL AUTONOMOUS BOOTSTRAP"

./scripts/01_env_setup.sh
./scripts/02_contracts.sh
./scripts/03_backend.sh
./scripts/04_ai.sh
./scripts/05_frontend.sh
./scripts/06_deploy.sh
./scripts/07_verify.sh

echo "✅ OMNIUTIL SYSTEM FULLY OPERATIONAL"
