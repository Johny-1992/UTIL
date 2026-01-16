#!/bin/bash
set -e

echo "🧯 Extension type AuditEvent (ANTI-FRAUDE)..."

FILE="src/utils/auditLogger.ts"

# Ajout de FRAUD_BLOCK si absent
if ! grep -q "FRAUD_BLOCK" "$FILE"; then
  sed -i 's/export type AuditEvent = \([^;]*\);/export type AuditEvent = \1 | "FRAUD_BLOCK";/' "$FILE"
fi

echo "🧪 Vérification TypeScript..."
rm -rf dist
npx tsc --noEmit

echo "✅ AUDIT EVENT étendu — ANTI-FRAUDE OFFICIELLE & SÛRE"
