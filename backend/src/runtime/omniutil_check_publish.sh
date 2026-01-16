#!/bin/bash
# ==========================================================
# OMNIUTIL – CHECK & PUBLISH
# Script self-healing pour serveur + indexation Google
# ==========================================================

BASE_DIR=$(pwd)
PUBLIC_DIR="$BASE_DIR/public"
ASSETS_DIR="$BASE_DIR/src/assets"
LOGS_DIR="$BASE_DIR/src/logs"
DAEMON_SCRIPT="$BASE_DIR/src/runtime/omniutil_global_final.sh"
SERVER_PORT=8082

echo "🌍 Vérification infrastructure Omniutil…"

# 1️⃣ Créer dossiers si manquants
mkdir -p "$PUBLIC_DIR/assets"
mkdir -p "$LOGS_DIR"

# 2️⃣ Générer QR code si absent
QR_FILE="$ASSETS_DIR/omniutil_qr.png"
if [ ! -f "$QR_FILE" ]; then
    echo "🔹 QR code manquant → génération..."
    mkdir -p "$ASSETS_DIR"
    qrencode -o "$QR_FILE" "https://omniutil.example.com/partner-connect" -s 10
fi

# Copier dans public/assets
cp "$QR_FILE" "$PUBLIC_DIR/assets/"

# 3️⃣ Générer page vitrine minimale si absente
INDEX_FILE="$PUBLIC_DIR/index.html"
if [ ! -f "$INDEX_FILE" ]; then
    echo "🔹 Page vitrine minimale manquante → génération..."
    cat > "$INDEX_FILE" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Omniutil Partner Connect</title>
<meta name="description" content="Omniutil – Infrastructure globale, QR scannable et partenaire connecté.">
<link rel="canonical" href="https://omniutil.example.com/partner-connect">
</head>
<body>
<h1>Bienvenue sur Omniutil</h1>
<p>Scannez le QR code ci-dessous pour devenir partenaire :</p>
<img src="assets/omniutil_qr.png" alt="Omniutil QR Code" style="max-width:300px;">
</body>
</html>
EOF
fi

# 4️⃣ Générer metadata.json si absent
METADATA_FILE="$PUBLIC_DIR/metadata.json"
if [ ! -f "$METADATA_FILE" ]; then
    echo "🔹 Metadata mondiale manquante → génération..."
    cat > "$METADATA_FILE" <<EOF
{
  "name": "Omniutil Universe",
  "description": "Infrastructure Omniutil – partenaire global, QR scannable omniprésent",
  "url": "https://omniutil.example.com/partner-connect",
  "partner_request_endpoint": "/partner-connect"
}
EOF
fi

# 5️⃣ Générer robots.txt et sitemap.xml si absents
ROBOTS_FILE="$PUBLIC_DIR/robots.txt"
SITEMAP_FILE="$PUBLIC_DIR/sitemap.xml"

if [ ! -f "$ROBOTS_FILE" ]; then
    echo "🔹 robots.txt manquant → génération..."
    cat > "$ROBOTS_FILE" <<EOF
User-agent: *
Allow: /
Sitemap: https://omniutil.example.com/partner-connect/sitemap.xml
EOF
fi

if [ ! -f "$SITEMAP_FILE" ]; then
    echo "🔹 sitemap.xml manquant → génération..."
    cat > "$SITEMAP_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://omniutil.example.com/partner-connect</loc></url>
  <url><loc>https://omniutil.example.com/partner-connect/metadata.json</loc></url>
</urlset>
EOF
fi

# 6️⃣ Lancer daemon Omniutil si non actif
DAEMON_PID=$(pgrep -f $(basename $DAEMON_SCRIPT))
if [ -z "$DAEMON_PID" ]; then
    echo "🔹 Daemon Omniutil non trouvé → lancement..."
    nohup "$DAEMON_SCRIPT" > "$LOGS_DIR/nohup_omniutil_final.log" 2>&1 &
else
    echo "✅ Daemon Omniutil déjà actif → PID $DAEMON_PID"
fi

# 7️⃣ Lancer serveur web Node.js si non actif
SERVER_PID=$(lsof -ti tcp:$SERVER_PORT)
if [ -z "$SERVER_PID" ]; then
    echo "🔹 Serveur web Node.js non trouvé → lancement sur port $SERVER_PORT..."
    nohup npx http-server "$PUBLIC_DIR" -p $SERVER_PORT -a 0.0.0.0 > "$LOGS_DIR/nohup_omniutil_server.log" 2>&1 &
else
    echo "✅ Serveur web Node.js déjà actif → PID $SERVER_PID"
fi

# 8️⃣ Résumé final
echo "------------------------------------------------------"
echo "🌐 Omniutil prêt pour Google et moteurs de recherche"
echo "🔗 Page vitrine minimale : http://$(curl -s ifconfig.me):$SERVER_PORT"
echo "📂 Logs daemon : $LOGS_DIR/nohup_omniutil_final.log"
echo "📂 Logs serveur : $LOGS_DIR/nohup_omniutil_server.log"
echo "------------------------------------------------------"
