#!/bin/bash
# ==========================================
# start_all.sh – OmniUtil
# Compile TS, démarre backend (8080) et frontend statique (8081)
# ==========================================

echo "🔹 Arrêt des serveurs existants sur 8080 et 8081…"

# Fonction pour tuer un processus sur un port
kill_port() {
    PORT=$1
    PID=$(lsof -ti tcp:$PORT)
    if [ ! -z "$PID" ]; then
        echo "  - Kill PID $PID sur le port $PORT"
        kill -9 $PID
    fi
}

kill_port 8080
kill_port 8081

# Compilation TypeScript
echo "📦 Compilation TypeScript..."
node --max-old-space-size=4096 $(which npx) tsc || { echo "❌ Erreur compilation TS"; exit 1; }

# Lancement backend Node.js
echo "🚀 Démarrage backend sur le port 8080..."
node dist/index.js &
BACKEND_PID=$!

# Lancement frontend statique Python
echo "🌐 Démarrage frontend statique sur le port 8081..."
python3 -m http.server 8081 &
FRONTEND_PID=$!

# Affichage infos
echo "✅ Tout est lancé !"
echo "Backend : http://localhost:8080"
echo "Frontend : http://localhost:8081/index.html"
echo ""
echo "💡 Pour arrêter, faire : kill $BACKEND_PID $FRONTEND_PID"
