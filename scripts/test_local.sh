#!/bin/bash

# Démarrer le serveur localement
cd ~/omniutil/backend
node dist/index.js &
SERVER_PID=$!

# Attendre que le serveur soit prêt
sleep 3

# Tester la route racine
curl -X GET http://127.0.0.1:10000/

# Arrêter le serveur
kill $SERVER_PID

echo "Test local terminé."
