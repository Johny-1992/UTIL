#!/bin/bash
# omniutil_ultra_salvateur.sh
# Omniutil Stable 24/7 : HTTPS DuckDNS + Caddy + Localtunnel + SEO + QR

set -e

BASE_DIR="/root/omniutil/backend"
PUBLIC_DIR="$BASE_DIR/public"
LOG_DIR="$BASE_DIR/src/logs"
QR_ASSET="$PUBLIC_DIR/assets/omniutil_qr.png"
DUCKDNS_TOKEN="134b220a-4ba5-46df-91b2-dda983769d7f"
DUCKDNS_DOMAIN="omniutil.duckdns.org"
PORT=8081
CADDYFILE="$BASE_DIR/Caddyfile"

mkdir -p "$LOG_DIR" "$PUBLIC_DIR/assets"

echo "🚀 Démarrage Omniutil Ultra-Salvateur 24/7..."

# --- 1️⃣ Fonction pour vérifier et relancer le serveur ---
check_server() {
    if ! curl -s "http://127.0.0.1:$PORT" > /dev/null; then
        echo "⚠️ Serveur HTTP non détecté, relance..."
        pkill -f "caddy run" || true
        nohup caddy run --config "$CADDYFILE" > "$LOG_DIR/nohup_caddy.log" 2>&1 &
        sleep 5
        echo "✅ Serveur relancé !"
    fi
}

# --- 2️⃣ Mise à jour DuckDNS toutes les 5 min ---
update_duckdns() {
    echo "🌍 Mise à jour DuckDNS..."
    curl -s "https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip=" > "$LOG_DIR/duckdns.log"
}

# --- 3️⃣ Ping Google pour indexation ---
ping_google() {
    echo "📡 Ping Google pour indexation..."
    curl -s "http://www.google.com/ping?sitemap=https://$DUCKDNS_DOMAIN/sitemap.xml" > /dev/null
}

# --- 4️⃣ Génération fichiers de base si absent ---
[[ ! -f "$PUBLIC_DIR/index.html" ]] && echo "⚡ Génération index.html" && \
cat > "$PUBLIC_DIR/index.html" <<HTML
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Omniutil – Passerelle QR Universelle & Écosystème Partenaire</title>
<meta name="description" content="Omniutil est une passerelle universelle basée sur QR code permettant l’accès à un écosystème numérique, des partenariats intelligents et des interactions globales.">
<meta name="robots" content="index, follow">
</head>
<body>
<h1>Bienvenue dans Omniutil</h1>
<p>Scannez le QR code :</p>
<img src="assets/omniutil_qr.png" alt="QR Omniutil">
</body>
</html>
HTML

[[ ! -f "$PUBLIC_DIR/robots.txt" ]] && echo "User-agent: *\nAllow: /\nSitemap: https://$DUCKDNS_DOMAIN/sitemap.xml" > "$PUBLIC_DIR/robots.txt"
[[ ! -f "$PUBLIC_DIR/sitemap.xml" ]] && echo "<?xml version='1.0'?><urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'><url><loc>https://$DUCKDNS_DOMAIN/</loc></url></urlset>" > "$PUBLIC_DIR/sitemap.xml"

# --- 5️⃣ Génération Caddyfile si absent ---
[[ ! -f "$CADDYFILE" ]] && cat > "$CADDYFILE" <<CADDY
$DUCKDNS_DOMAIN {
    root * $PUBLIC_DIR
    encode gzip
    file_server
    log {
        output file $LOG_DIR/caddy_access.log
        format single_field common_log
    }
}
CADDY

# --- 6️⃣ Lancement initial Caddy ---
pkill -f "caddy run" || true
nohup caddy run --config "$CADDYFILE" > "$LOG_DIR/nohup_caddy.log" 2>&1 &

# --- 7️⃣ Boucle infinie de surveillance ---
while true; do
    check_server
    update_duckdns
    ping_google
    sleep 300  # 5 minutes entre chaque cycle
done
