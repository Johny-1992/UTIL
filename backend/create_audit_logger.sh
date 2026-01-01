#!/bin/bash
set -e

echo "📡 Création Audit Logger OmniUtil (canonique)..."

# Dossier utils garanti
mkdir -p src/utils

# Création du logger
cat << 'EOF' > src/utils/auditLogger.ts
export type AuditEvent =
  | "CALCULATE_REWARDS"
  | "TRANSFER_UTIL"
  | "CONVERT_TO_USDT"
  | "BLOCKCHAIN_SYNC"
  | "SECURITY_ALERT";

export function audit(
  event: AuditEvent,
  payload: Record<string, any>
): void {
  const entry = {
    event,
    payload,
    timestamp: new Date().toISOString()
  };

  // Output actuel (extensible DB / Blockchain / SIEM)
  console.log("[AUDIT]", entry);
}
EOF

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ AUDIT LOGGER CRÉÉ — BASE SAINE"
