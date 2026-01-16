#!/bin/bash
# ====================================================
# Omniutil Global All-in-One Script – V1
# Lance daemon, serveur web HTTPS, vitrine, SEO, QR omniprésent
# ====================================================

BASE_DIR=$(dirname "$0")/../..
PUBLIC_DIR="$BASE_DIR/public"
LOG_DIR="$BASE_DIR/src/logs"
DAEMON_LOG="$LOG_DIR/nohup_omniutil_global_final.log"
VITRINE_LOG="$LOG_DIR/nohup_omniutil_vitrine.log"

mkdir -p $LOG_DIR

echo "------------------------------------------------------"
echo "🌍 Lancement Omniutil Global All-in-One"
echo "------------------------------------------------------"

# 1. Vérifie / crée fichiers SEO & vitrine
echo "🔹 Vérification des fichiers SEO et vitrine..."
[ ! -f "$PUBLIC_DIR/index.html" ] && echo "<!DOCTYPE html><html><head><title>Omniutil</title></head><body><h1>Omniutil – QR omniprésent</h1><img src='assets/omniutil_qr.png' alt='QR Omniutil'></body></html>" > "$PUBLIC_DIR/index.html"
[ ! -f "$PUBLIC_DIR/robots.txt" ] && echo -e "User-agent: *\nAllow: /\nSitemap: https://omniutil.example.com/partner-connect/sitemap.xml" > "$PUBLIC_DIR/robots.txt"
[ ! -f "$PUBLIC_DIR/sitemap.xml" ] && echo -e "<?xml version='1.0' encoding='UTF-8'?><urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'><url><loc>https://omniutil.example.com/partner-connect</loc></url><url><loc>https://omniutil.example.com/partner-connect/metadata.json</loc></url></urlset>" > "$PUBLIC_DIR/sitemap.xml"
[ ! -f "$PUBLIC_DIR/metadata.json" ] && echo '{"name":"Omniutil","description":"Infrastructure Omniutil – QR omniprésent","url":"https://omniutil.example.com/partner-connect"}' > "$PUBLIC_DIR/metadata.json"

chmod -R 755 $PUBLIC_DIR

echo "✅ Fichiers vitrine et SEO prêts"

# 2. Lance daemon Omniutil en arrière-plan si pas déjà lancé
DAEMON_PID=$(pgrep -f omniutil_global_final.sh)
if [ -z "$DAEMON_PID" ]; then
    echo "🔹 Lancement daemon Omniutil..."
    nohup $BASE_DIR/src/runtime/omniutil_global_final.sh > $DAEMON_LOG 2>&1 &
else
    echo "🟢 Daemon déjà actif (PID $DAEMON_PID)"
fi

# 3. Lance serveur HTTPS Caddy ou http-server
SERVER_PID=$(pgrep -f "http-server $PUBLIC_DIR")
if [ -z "$SERVER_PID" ]; then
    echo "🔹 Lancement serveur web Node.js sur le port 8082..."
    nohup npx http-server $PUBLIC_DIR -p 8082 -a 0.0.0.0 > $VITRINE_LOG 2>&1 &
else
    echo "🟢 Serveur web déjà actif (PID $SERVER_PID)"
fi

# 4. Affiche URLs publiques pour tests
echo "------------------------------------------------------"
echo "🌐 Omniutil prêt – URLs publiques :"
echo "🔹 Page vitrine HTTP  : http://$(curl -s ifconfig.me):8082"
echo "🔹 Sitemap            : https://omniutil.example.com/partner-connect/sitemap.xml"
echo "🔹 Metadata           : https://omniutil.example.com/partner-connect/metadata.json"
echo "------------------------------------------------------"

# 5. Vérification continue (optionnel)
echo "🟢 Vérification automatique des processus tous les 60s..."
while true; do
    sleep 60
    # Relance daemon si nécessaire
    DAEMON_PID=$(pgrep -f omniutil_global_final.sh)
    [ -z "$DAEMON_PID" ] && echo "⚠️ Daemon Omniutil non trouvé → relance..." && nohup $BASE_DIR/src/runtime/omniutil_global_final.sh > $DAEMON_LOG 2>&1 &
    
    # Relance serveur si nécessaire
    SERVER_PID=$(pgrep -f "http-server $PUBLIC_DIR")
    [ -z "$SERVER_PID" ] && echo "⚠️ Serveur Node.js non trouvé → relance..." && nohup npx http-server $PUBLIC_DIR -p 8082 -a 0.0.0.0 > $VITRINE_LOG 2>&1 &
done
