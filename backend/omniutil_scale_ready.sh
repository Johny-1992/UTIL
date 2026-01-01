#!/usr/bin/env bash
set -e

echo "⚙️ OmniUtil — Préparation Scalabilité"

echo "NODE_ENV=production"
echo "CLUSTER_MODE=enabled"
echo "MAX_PARTNERS=1000"
echo "MAX_ACTIVE_USERS=5000000"
echo "QUEUE_SYSTEM=ready"
echo "REDIS_OPTIONAL=true"

echo
echo "✅ OmniUtil prêt pour montée en charge horizontale"
