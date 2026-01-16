#!/bin/bash
# 🌌 OMNIUTIL UNIFY LIVE – Script complet
# Lancement automatique de l'Omniutil Universe

echo "🌌 OMNIUTIL UNIFY LIVE – Démarrage"
echo "--------------------------------------------------------"

# --- Vérification Node.js ---
if ! command -v node &> /dev/null
then
    echo "❌ Node.js non trouvé. Installer Node.js pour continuer."
    exit 1
fi
echo "📦 Dépendances Node OK"

# --- Création dossiers manquants ---
[ ! -d "onboarding" ] && echo "⚠️ Création dossier manquant : onboarding" && mkdir onboarding
[ ! -d "modules" ] && echo "⚠️ Création dossier manquant : modules" && mkdir modules

# --- Log horodaté ---
LOG_FILE="logs/omniutil_live_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

# --- Lancement Node.js ---
echo "🧪 Lancement Omniutil Universe LIVE..." | tee -a $LOG_FILE

node ./src/runtime/omniutil_universe_final.js 2>&1 | tee -a $LOG_FILE

echo "🌕 OMNIUTIL UNIFY LIVE – Fusion complète terminée ✅"
echo "Logs sauvegardés dans : $LOG_FILE"
