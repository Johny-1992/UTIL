#!/bin/bash

PORT=8082
DUCKDNS_TOKEN="134b220a-4ba5-46df-91b2-dda983769d7f"
DUCKDNS_SUBDOMAIN="omniutil"
LOCALTUNNEL_SUBDOMAIN="omniutil"

LOG_DIR="src/logs"
mkdir -p $LOG_DIR

echo "🚀 Démarrage Omniutil + Tunnel public (mode compatible Android/proot)"

# 1️⃣ Lancer Omniutil (backend)
echo "⚙️ Lancement du backend Omniutil..."
nohup npm start > $LOG_DIR/nohup_omniutil.log 2>&1 &

sleep 3

# 2️⃣ Lancer Localtunnel (sans vérification système)
echo "🌐 Lancement de Localtunnel..."
nohup lt --port $PORT --subdomain $LOCALTUNNEL_SUBDOMAIN \
  > $LOG_DIR/nohup_localtunnel.log 2>&1 &

sleep 5

# 3️⃣ Mise à jour DuckDNS
echo "🌍 Mise à jour DuckDNS..."
DUCK_RESULT=$(curl -s "https://www.duckdns.org/update?domains=$DUCKDNS_SUBDOMAIN&token=$DUCKDNS_TOKEN&ip=")

if [[ "$DUCK_RESULT" == "OK" ]]; then
    echo "✅ DuckDNS OK : https://$DUCKDNS_SUBDOMAIN.duckdns.org"
else
    echo "❌ DuckDNS ERREUR : $DUCK_RESULT"
    echo "⚠️ Vérifie que le domaine '$DUCKDNS_SUBDOMAIN' existe sur DuckDNS"
fi

# 4️⃣ Test HTTP externe
echo "🔎 Test HTTP public..."
HTTP_TEST=$(curl -s --max-time 10 https://$LOCALTUNNEL_SUBDOMAIN.loca.lt)

if [ -n "$HTTP_TEST" ]; then
    echo "✅ Omniutil accessible publiquement"
else
    echo "⚠️ Tunnel lancé mais réponse vide (normal au 1er démarrage)"
fi

echo ""
echo "🔗 URL principale : https://$LOCALTUNNEL_SUBDOMAIN.loca.lt"
echo "🔗 URL DuckDNS    : https://$DUCKDNS_SUBDOMAIN.duckdns.org"
echo "📂 Logs           : $LOG_DIR/"
