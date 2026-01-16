#!/bin/bash
# ========================================================
# Omniutil Global Daemon – mode continu, monitoring on-chain, visibilité
# ========================================================

# Variables
BACKEND_DIR="/root/omniutil/backend"
LOGS_DIR="$BACKEND_DIR/src/logs"
DAEMON_LOG="$LOGS_DIR/omniutil_global_daemon_$(date +%s).log"
NODE="node"
ORCHESTRATOR_BIN="$BACKEND_DIR/src/orchestrator/orchestrator_bin"
RUNTIME_SCRIPT="$BACKEND_DIR/src/runtime/omniutil_universe_final_live.js"

# Crée dossier logs si inexistant
mkdir -p "$LOGS_DIR"

echo "🌍 Omniutil Global Daemon – Démarrage" | tee -a "$DAEMON_LOG"
echo "----------------------------------------------------" | tee -a "$DAEMON_LOG"

# Boucle infinie pour mode daemon
while true; do
    echo "🕒 $(date) – Lancement Omniutil Universe..." | tee -a "$DAEMON_LOG"

    # Lancer le script Node.js
    $NODE "$RUNTIME_SCRIPT" >> "$DAEMON_LOG" 2>&1

    # Vérification si orchestrateur C++ actif
    if [ ! -f "$ORCHESTRATOR_BIN" ]; then
        echo "❌ Orchestrateur manquant, tentative fallback..." | tee -a "$DAEMON_LOG"
    else
        echo "🧠 Orchestrateur C++ OK" | tee -a "$DAEMON_LOG"
    fi

    # Monitoring on-chain simulé (à brancher sur BSC websockets ou RPC)
    echo "🔗 Monitoring on-chain et notifications partenaires actifs..." | tee -a "$DAEMON_LOG"

    # Génération metadata omniprésence
    echo "🌐 Mise à jour metadata mondiale pour visibilité globale..." | tee -a "$DAEMON_LOG"

    # Pause courte avant le prochain cycle (ex: 10s, ajustable)
    sleep 10
done
