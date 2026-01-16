#!/bin/bash
# omniutil_final_caddy_duckdns.sh
# Omniutil complet : HTTP + HTTPS DuckDNS + Caddy + SEO + QR omniprésent

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

echo "🚀 Démarrage Omniutil Stable HTTPS..."

# --- 1️⃣ Génération index.html SEO complet ---
cat > "$PUBLIC_DIR/index.html" <<HTML
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Omniutil – Passerelle QR Universelle & Écosystème Partenaire</title>
<meta name="description" content="Omniutil est une passerelle universelle basée sur QR code permettant l’accès à un écosystème numérique, des partenariats intelligents et des interactions globales.">
<meta name="keywords" content="Omniutil, QR code universel, passerelle QR, partenariat digital, scan QR intelligent, écosystème numérique">
<meta name="author" content="Omniutil">
<meta name="robots" content="index, follow">
<meta property="og:title" content="Omniutil – Passerelle QR Universelle">
<meta property="og:description" content="Scannez le QR Omniutil pour accéder à un écosystème numérique universel et devenir partenaire.">
<meta property="og:type" content="website">
<meta property="og:url" content="https://$DUCKDNS_DOMAIN/">
<meta property="og:image" content="https://$DUCKDNS_DOMAIN/assets/omniutil_qr.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Omniutil – QR Gateway Universel">
<meta name="twitter:description" content="Une passerelle QR universelle pour connecter humains, services et partenaires.">
<meta name="twitter:image" content="https://$DUCKDNS_DOMAIN/assets/omniutil_qr.png">

<style>
body { font-family: Arial, Helvetica, sans-serif; background:#f5f5f5; margin:0; padding:0; color:#1e1e2f; text-align:center; }
header { padding:40px 20px 20px; }
h1 { font-size:2.2em; margin-bottom:10px; }
p { font-size:1.1em; max-width:700px; margin:0 auto 20px; line-height:1.6; }
.qr-container { margin:30px 0; }
.qr-container img { width:240px; max-width:80%; height:auto; }
.cta { margin-top:20px; font-weight:bold; }
footer { margin-top:50px; padding:20px; font-size:0.9em; color:#666; }
a { color:#1e1e2f; text-decoration:none; font-weight:bold; }
</style>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Omniutil",
  "url": "https://$DUCKDNS_DOMAIN/",
  "description": "Passerelle universelle basée sur QR code pour partenariats et interactions numériques.",
  "inLanguage": "fr"
}
</script>
</head>
<body>
<header>
<h1>Bienvenue dans Omniutil</h1>
<p>Omniutil est une passerelle universelle basée sur QR code, conçue pour connecter partenaires, services et humains au sein d’un écosystème numérique global.</p>
</header>

<section class="qr-container">
<p class="cta">Scannez le QR code ci-dessous pour entrer dans l’univers Omniutil :</p>
<img src="assets/omniutil_qr.png" alt="QR code Omniutil – Accès universel">
</section>

<section>
<p>Chaque scan est une porte d’entrée vers des opportunités, des collaborations et des interactions intelligentes.</p>
</section>

<footer>
<p>© Omniutil – Passerelle QR Universelle<br>
<a href="metadata.json">Metadata</a> · <a href="sitemap.xml">Sitemap</a></p>
</footer>
</body>
</html>
HTML

# --- 2️⃣ robots.txt & sitemap.xml ---
cat > "$PUBLIC_DIR/robots.txt" <<TXT
User-agent: *
Allow: /
Sitemap: https://$DUCKDNS_DOMAIN/sitemap.xml
TXT

cat > "$PUBLIC_DIR/sitemap.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://$DUCKDNS_DOMAIN/</loc></url>
  <url><loc>https://$DUCKDNS_DOMAIN/metadata.json</loc></url>
</urlset>
XML

# --- 3️⃣ Configuration Caddyfile ---
cat > "$CADDYFILE" <<CADDY
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

# --- 4️⃣ Mise à jour DuckDNS ---
echo "🌍 Mise à jour DuckDNS..."
curl -s "https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip=" > "$LOG_DIR/duckdns.log"

# --- 5️⃣ Lancement Caddy HTTPS stable ---
echo "🌐 Lancement Caddy HTTPS sur $DUCKDNS_DOMAIN..."
pkill -f "caddy run" || true
nohup caddy run --config "$CADDYFILE" > "$LOG_DIR/nohup_caddy.log" 2>&1 &

# --- 6️⃣ Ping Google pour indexation ---
echo "📡 Ping Google pour indexation..."
curl -s "http://www.google.com/ping?sitemap=https://$DUCKDNS_DOMAIN/sitemap.xml" > /dev/null

# --- 7️⃣ Récap ---
echo "✅ Omniutil Stable HTTPS lancé !"
echo "🔗 Local       : http://127.0.0.1:$PORT"
echo "🔗 Public DuckDNS : https://$DUCKDNS_DOMAIN"
echo "📂 Logs       : $LOG_DIR"
