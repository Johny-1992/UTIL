#!/bin/bash
# ==============================
# OmniUtil – Live Local Dev + Auto Ports + Frontend Secure Build
# ==============================

echo "🔹 Arrêt des serveurs existants…"

kill_pid() {
    if [ ! -z "$1" ]; then
        echo "💀 Kill PID $1"
        kill -9 $1 2>/dev/null
    fi
}

# Kill backend / frontend si existants
BACKEND_PID=$(pgrep -f "node dist/index.js")
FRONTEND_PID=$(pgrep -f "python3 -m http.server")
kill_pid $BACKEND_PID
kill_pid $FRONTEND_PID

# Trouver un port libre
get_free_port() {
    local port=$1
    while : ; do
        (echo >/dev/tcp/127.0.0.1/$port) &>/dev/null
        if [ $? -ne 0 ]; then
            echo $port
            return
        fi
        port=$((port+1))
    done
}

BACKEND_PORT=$(get_free_port 8080)
FRONTEND_PORT=$(get_free_port 8081)

# Compilation TypeScript backend
echo "📦 Compilation TypeScript backend…"
node --max-old-space-size=4096 $(which npx) tsc

# Compilation sécurisée du frontend
echo "📦 Compilation frontend sécurisé…"
mkdir -p public
npx esbuild src/test_full_browser.ts \
  --bundle \
  --platform=browser \
  --target=es2020 \
  --format=iife \
  --outfile=public/explorer.js \
  --abs-working-dir=$(pwd)

# Lancer backend Node.js
echo "🚀 Démarrage backend sur le port $BACKEND_PORT…"
node dist/index.js --port $BACKEND_PORT > backend.log 2>&1 &
BACKEND_PID=$!

# Lancer frontend avec hot reload si possible
echo "🌐 Démarrage frontend statique sur le port $FRONTEND_PORT…"
if ! command -v entr &> /dev/null; then
    echo "⚠️ 'entr' n'est pas installé, le hot reload ne sera pas actif."
    python3 -m http.server $FRONTEND_PORT > frontend.log 2>&1 &
    FRONTEND_PID=$!
else
    find ./dist ./public ./index.html ./src -type f | entr -r python3 -m http.server $FRONTEND_PORT &
    FRONTEND_PID=$!
fi

echo "✅ Tout est lancé !"
echo "Backend : http://localhost:$BACKEND_PORT"
echo "Frontend : http://localhost:$FRONTEND_PORT/index.html"
echo ""
echo "💡 Pour stopper proprement, faire : kill $BACKEND_PID $FRONTEND_PID"
