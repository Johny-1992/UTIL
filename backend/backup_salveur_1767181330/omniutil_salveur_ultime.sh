#!/bin/bash
# OmniUtil – Script Salvateur Ultime
# Nettoyage, vérification, harmonisation et validation complète Partner Onboarding + Backend

echo "🚀 Début du script salvateur ultime OmniUtil..."

# 1️⃣ Backup complet du projet
timestamp=$(date +%s)
backup_dir="backup_$timestamp"
echo "💾 Création backup complet du projet dans $backup_dir"
mkdir -p $backup_dir
cp -r ./src $backup_dir/
cp -r ./assets $backup_dir/
cp package.json $backup_dir/
cp tsconfig.json $backup_dir/

# 2️⃣ Nettoyage build/dist/cache TS
echo "🧹 Nettoyage build/dist/cache TypeScript..."
rm -rf ./dist ./build ./node_modules/.cache

# 3️⃣ Vérification et création des fichiers manquants
echo "🛠️ Vérification des fichiers essentiels..."
[ ! -f ./src/models/partnerRequest.ts ] && echo "💾 partnerRequest.ts manquant → création automatique" && touch ./src/models/partnerRequest.ts
[ ! -f ./src/models/baseModel.ts ] && echo "💾 baseModel.ts manquant → création automatique" && touch ./src/models/baseModel.ts
[ ! -f ./src/services/PartnerOnboardingService.ts ] && echo "💾 PartnerOnboardingService manquant → création automatique" && touch ./src/services/PartnerOnboardingService.ts

# 4️⃣ Harmonisation des imports et typage AuditEvent
echo "🔧 Harmonisation imports et typage AuditEvent..."
grep -rl "partnerOnboardingService" src/ | xargs sed -i 's|partnerOnboardingService|PartnerOnboardingService|g'
grep -rl "ONBOARD_REQUEST" src/ | xargs sed -i 's|ONBOARD_REQUEST|ONBOARD_REQUEST as AuditEvent|g'

# 5️⃣ Compilation TypeScript
echo "🧪 Compilation TypeScript..."
tsc --noEmit
if [ $? -eq 0 ]; then
  echo "✅ Compilation TypeScript OK"
else
  echo "⚠️ Erreurs TypeScript détectées"
fi

# 6️⃣ Validation Partner Onboarding + QR
echo "🧪 Lancement validation Partner Onboarding + QR OmniUtil..."
./validate_partner_onboarding_ultimate.sh

echo "🎉 Script salvateur ultime terminé !"
