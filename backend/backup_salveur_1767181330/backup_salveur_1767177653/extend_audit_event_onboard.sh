#!/bin/bash
echo "🛠️ Extension type AuditEvent pour Partner Onboarding..."

# Sauvegarde
cp src/utils/audit.d.ts src/utils/audit.d.ts.bak
echo "💾 Backup créé : audit.d.ts.bak"

# Ajout ONBOARD_REQUEST au type AuditEvent
cat > src/utils/audit.d.ts << 'EOF'
export type AuditEvent =
  | "TRANSFER_UTIL"
  | "EXCHANGE_USDT"
  | "PARTNER_ONBOARD_DECISION"
  | "FRAUD_BLOCK"
  | "ONBOARD_REQUEST";
EOF

# Vérification TS
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

if [ $? -eq 0 ]; then
  echo "🎉 Type AuditEvent étendu avec ONBOARD_REQUEST et TS compilé OK"
else
  echo "⚠️ Erreurs TS détectées, vérifier manuellement"
fi
