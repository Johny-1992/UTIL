#!/bin/bash
# Omniutil Global Final avec Caddy + SEO + QR omniprésent
# 2026 – Version finale

# ---------------------------
# Variables
# ---------------------------
BASE_DIR="$(pwd)"
PUBLIC_DIR="$BASE_DIR/public"
LOG_DIR="$BASE_DIR/src/logs"
QR_FILE="$PUBLIC_DIR/assets/omniutil_qr.png"
CADDY_FILE="$BASE_DIR/Caddyfile"
PORT=443  # HTTPS

mkdir -p "$PUBLIC_DIR/assets" "$LOG_DIR"

# ---------------------------
# Génération QR code si absent
# ---------------------------
if [ ! -f "$QR_FILE" ]; then
    echo "🔹 Génération QR code Omniutil..."
    qrencode -o "$QR_FILE" "https://omniutil.example.com/partner-connect" -s 10
fi

# ---------------------------
# Fichiers SEO & Metadata
# ---------------------------
# index.html
cat > "$PUBLIC_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Omniutil – Partenariats et Ecosystème UTIL</title>
<meta name="description" content="Omniutil Universe – Plateforme de partenariat et distribution de UTIL">
<meta name="robots" content="index, follow">
<link rel="icon" href="assets/omniutil_qr.png">
</head>
<body style="font-family:sans-serif;text-align:center;margin-top:50px;">
<h1>Omniutil Universe</h1>
<p>Scan QR pour rejoindre ou demander un partenariat :</p>
<img src="assets/omniutil_qr.png" alt="Omniutil QR Code" width="300"/>
<p>Page minimale officielle – SEO prêt pour Google et moteurs de recherche.</p>
</body>
</html>
EOF

# robots.txt
cat > "$PUBLIC_DIR/robots.txt" <<EOF
User-agent: *
Allow: /
Sitemap: https://omniutil.example.com/sitemap.xml
EOF

# sitemap.xml
cat > "$PUBLIC_DIR/sitemap.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://omniutil.example.com/</loc></url>
  <url><loc>https://omniutil.example.com/metadata.json</loc></url>
</urlset>
EOF

# metadata.json
cat > "$PUBLIC_DIR/metadata.json" <<EOF
{
  "name": "Omniutil Universe",
  "description": "Plateforme de partenariat et distribution de UTIL",
  "image": "assets/omniutil_qr.png",
  "url": "https://omniutil.example.com/"
}
EOF

# ---------------------------
# Caddyfile pour HTTPS automatique
# ---------------------------
cat > "$CADDY_FILE" <<EOF
https://omniutil.example.com {
    root * $PUBLIC_DIR
    file_server
    encode gzip
    log {
        output file $LOG_DIR/caddy_access.log
        format single_field common_log
    }
}
EOF

# ---------------------------
# Lancer Caddy
# ---------------------------
echo "🚀 Lancement Caddy pour HTTPS et SEO..."
caddy start --config "$CADDY_FILE" --adapter caddyfile

# ---------------------------
# Lancer Omniutil daemon
# ---------------------------
DAEMON_LOG="$LOG_DIR/nohup_omniutil_global_final.log"
echo "🟢 Lancement Omniutil Global Daemon..."
nohup bash "$BASE_DIR/src/runtime/omniutil_global_final.sh" > "$DAEMON_LOG" 2>&1 &

# ---------------------------
# Confirmation
# ---------------------------
echo "✅ Omniutil final prêt !"
echo "🌐 Page vitrine minimale : https://omniutil.example.com/"
echo "📂 Logs daemon : $DAEMON_LOG"
echo "📂 Logs Caddy : $LOG_DIR/caddy_access.log"
