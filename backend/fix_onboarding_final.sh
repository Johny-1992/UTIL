#!/bin/bash
echo "🚀 Début du fix salvateur ultime Partner Onboarding OmniUtil..."

# Création backup
timestamp=$(date +%s)
backup_dir="backup_$timestamp"
mkdir -p "$backup_dir"
cp -r src "$backup_dir/"
echo "💾 Backup du projet créé dans $backup_dir"

# Nettoyage imports incorrects et correction casse
echo "🔧 Harmonisation des imports PartnerOnboardingService..."
grep -rl "partnerOnboardingService" src/ | while read file; do
    sed -i 's|partnerOnboardingService|PartnerOnboardingService|g' "$file"
    echo "🔹 Correct import dans $file"
done

# Suppression build / cache
echo "🧹 Nettoyage build/dist et cache..."
rm -rf build dist node_modules/.cache

# Compilation TypeScript
echo "🧪 Compilation TypeScript..."
tsc
if [ $? -eq 0 ]; then
    echo "✅ Compilation TypeScript OK"
else
    echo "⚠️ Erreurs TS détectées !"
fi

# Relance validation ultime
echo "🧪 Relance de la validation Partner Onboarding..."
./validate_partner_onboarding_ultimate.sh

echo "🎉 Fix salvateur ultime terminé !"
