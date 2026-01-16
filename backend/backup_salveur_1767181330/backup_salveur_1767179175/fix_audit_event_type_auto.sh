#!/bin/bash
echo "🛠️  Mise à jour type AuditEvent pour ANTI-FRAUDE..."

# Chemin du fichier auditLogger
AUDIT_FILE="src/utils/auditLogger.ts"

# Vérifier si le fichier existe
if [ ! -f "$AUDIT_FILE" ]; then
  echo "❌ Fichier $AUDIT_FILE introuvable !"
  exit 1
fi

# Ajouter "FRAUD_BLOCK" au type AuditEvent si absent
if ! grep -q '"FRAUD_BLOCK"' "$AUDIT_FILE"; then
  sed -i 's/export type AuditEvent = \(.*\);/export type AuditEvent = \1 | "FRAUD_BLOCK";/' "$AUDIT_FILE"
  echo "✅ FRAUD_BLOCK ajouté au type AuditEvent."
else
  echo "ℹ️ FRAUD_BLOCK déjà présent dans AuditEvent."
fi

# Relancer compilation TypeScript
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "🎉 Type AuditEvent mis à jour et compilation TS terminée."
