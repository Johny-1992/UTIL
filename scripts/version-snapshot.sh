#!/bin/bash
set -e

VERSION_TAG=$1
[ -z "$VERSION_TAG" ] && echo "❌ Version manquante (ex: v1.0.1)" && exit 1

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="logs/version-$VERSION_TAG-$TIMESTAMP.log"

echo "📦 Snapshot version $VERSION_TAG" | tee -a "$LOG_FILE"

tar -czf "versions/frontend/frontend-$VERSION_TAG.tar.gz" frontend
tar -czf "versions/backend/backend-$VERSION_TAG.tar.gz" backend
tar -czf "versions/contracts/contracts-$VERSION_TAG.tar.gz" contracts
tar -czf "versions/cpp/cpp-$VERSION_TAG.tar.gz" cpp

echo "✅ Version $VERSION_TAG sauvegardée" | tee -a "$LOG_FILE"
