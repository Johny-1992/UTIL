#!/bin/bash

echo "🚀 Démarrage de Omniutil..."

BASE_DIR="/root/omniutil/backend"
PUBLIC_DIR="$BASE_DIR/public"
LOG_DIR="$BASE_DIR/src/logs"
PORT=8081

mkdir -p "$LOG_DIR"

echo "🌐 Lancement du serveur HTTP sur 0.0.0.0:$PORT"
nohup python3 -m http.server $PORT \
  --bind 0.0.0.0 \
  --directory "$PUBLIC_DIR" \
  > "$LOG_DIR/nohup_http.log" 2>&1 &

sleep 2

echo "🌍 Lancement du tunnel Localtunnel..."
nohup lt --port $PORT --subdomain omniutil \
  > "$LOG_DIR/nohup_localtunnel.log" 2>&1 &

echo "✅ Omniutil lancé"
echo "🔗 Local : http://127.0.0.1:$PORT"
echo "🔗 Public: https://omniutil.loca.lt"
