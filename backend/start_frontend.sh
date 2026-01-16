#!/bin/bash
PORT=8081
DIR=$(pwd)

# 1️⃣ Vérifier si le port est occupé
PID=$(lsof -t -i :$PORT)

if [ -n "$PID" ]; then
  echo "⚠️ Port $PORT occupé par PID $PID. On tue le processus..."
  kill -9 $PID
  sleep 1
fi

# 2️⃣ Lancer le serveur statique Python
echo "🚀 Démarrage du serveur statique sur le port $PORT..."
cd $DIR
python3 -m http.server $PORT
