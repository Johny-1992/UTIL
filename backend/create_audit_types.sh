#!/bin/bash
echo "🛠️ Création du type AuditEvent OmniUtil…"

# Création dossier utils si inexistant
mkdir -p src/utils

# Création / écrasement du fichier audit.d.ts
cat > src/utils/audit.d.ts << 'EOF'
export type AuditEvent =
  | "TRANSFER_UTIL"
  | "EXCHANGE_USDT"
  | "PARTNER_ONBOARD_DECISION"
  | "FRAUD_BLOCK"
  | "ONBOARD_REQUEST";
EOF

echo "💾 audit.d.ts créé avec tous les événements AuditEvent"

# Vérification TypeScript
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

if [ $? -eq 0 ]; then
  echo "🎉 Type AuditEvent opérationnel et TS compilé OK"
else
  echo "⚠️ Erreurs TS détectées, vérifier manuellement"
fi
