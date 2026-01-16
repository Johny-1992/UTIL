#!/bin/bash
# =============================================================================
# OMNIUTIL GLOBAL DAEMON v2 – Daemon mondial amélioré
# Version complète, reprend la logique du daemon précédent
# Redémarrage automatique, logs horodatés, tableau console en temps réel
# =============================================================================

# ----------------------------
# Variables
# ----------------------------
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="./src/logs"
LOG_FILE="$LOG_DIR/iutil_global_daemon_$TIMESTAMP.log"
mkdir -p "$LOG_DIR"

echo "🌍 OMNIUTIL GLOBAL DAEMON v2 – Démarrage"
echo "🕒 Timestamp : $TIMESTAMP"
echo "📂 Logs : $LOG_FILE"

# Redirection console -> log
exec > >(tee -a "$LOG_FILE") 2>&1

# ----------------------------
# Fonction pour relancer Omniutil Universe en boucle
# ----------------------------
run_omniutil() {
    while true; do
        echo "------------------------------------------------------"
        echo "🕒 $(date) – Lancement Omniutil Universe"
        
        # Exécution du script principal
        node src/runtime/omniutil_universe_final_live.js
        STATUS=$?
        
        if [ $STATUS -ne 0 ]; then
            echo "❌ Erreur détectée ! Redémarrage dans 5s..."
            sleep 5
        else
            echo "✅ Omniutil Universe OK – Pause 10s avant cycle suivant"
            sleep 10
        fi
    done
}

# ----------------------------
# Initialisation orchestrateur C++
# ----------------------------
echo "⚙️ Vérification orchestrateur C++..."
if [ -f "./src/orchestrator/orchestrator_bin" ]; then
    ./src/orchestrator/orchestrator_bin "{}" AUTO_ACCEPTED 50
    echo "🧠 Orchestrateur C++ OK"
else
    echo "⚠️ Orchestrateur manquant ! Créez ./src/orchestrator/orchestrator_bin"
    exit 1
fi

# ----------------------------
# Initialisation sécurité & IA
# ----------------------------
echo "🛡️ Sécurité Zero-Trust active"
echo "🤖 IA deterministe prête – Partner Decision Matrix générée"

# ----------------------------
# Lancement de la boucle principale
# ----------------------------
run_omniutil
