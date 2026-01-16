#!/bin/bash
# omniutil_global_final.sh
# Script FINAL : Omniutil omniprésent, vitrine + daemon + Google-ready

# -----------------------
# 1️⃣ Variables
# -----------------------
OMNIUTIL_DIR="/root/omniutil/backend"
PUBLIC_DIR="$OMNIUTIL_DIR/public"
PORT=8080
QR_SRC="$OMNIUTIL_DIR/src/assets/omniutil_qr.png"
DOMAIN="omniutil.example.com"  # Remplace par ton domaine réel

# -----------------------
# 2️⃣ Préparation dossiers et QR
# -----------------------
echo "🌍 Omniutil Final Bootstrap – Initialisation..."
mkdir -p $PUBLIC_DIR/assets
if [[ -f $QR_SRC ]]; then
    cp $QR_SRC $PUBLIC_DIR/assets/
    echo "✅ QR code copié dans assets"
else
    echo "⚠️ QR code manquant : $QR_SRC"
fi

# -----------------------
# 3️⃣ Page vitrine minimale
# -----------------------
cat > $PUBLIC_DIR/index.html <<HTML
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Omniutil – Univers Partenaire</title>
<meta name="description" content="Omniutil – Plateforme globale de partenaires blockchain. Scannez le QR pour rejoindre.">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family:sans-serif; text-align:center; margin-top:50px;">
<h1>Bienvenue dans l'univers Omniutil</h1>
<p>Plateforme mondiale de partenaires blockchain</p>
<img src="assets/omniutil_qr.png" alt="Omniutil QR" style="width:300px;height:300px;">
<p>Scannez le QR pour rejoindre et interagir avec Omniutil.</p>
</body>
</html>
HTML
echo "✅ Page vitrine générée"

# -----------------------
# 4️⃣ Robots.txt et Sitemap
# -----------------------
cat > $PUBLIC_DIR/robots.txt <<ROBOT
User-agent: *
Allow: /
Sitemap: https://$DOMAIN/sitemap.xml
ROBOT

cat > $PUBLIC_DIR/sitemap.xml <<SITEMAP
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://$DOMAIN/</loc>
    <priority>1.0</priority>
  </url>
</urlset>
SITEMAP
echo "✅ Robots et sitemap générés"

# -----------------------
# 5️⃣ Firewall
# -----------------------
sudo ufw allow $PORT/tcp
sudo ufw reload
echo "✅ Port $PORT ouvert"

# -----------------------
# 6️⃣ Installation et configuration Caddy
# -----------------------
if ! command -v caddy &> /dev/null; then
    echo "⚡ Installation de Caddy..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install -y caddy
fi

cat > $OMNIUTIL_DIR/Caddyfile <<CADDY
:80, :443
root * $PUBLIC_DIR
encode gzip
file_server
CADDY

sudo systemctl restart caddy
echo "✅ Caddy lancé – HTTPS activé"

# -----------------------
# 7️⃣ Lancement Omniutil daemon v5
# -----------------------
nohup $OMNIUTIL_DIR/src/runtime/omniutil_global_v5.sh &> $OMNIUTIL_DIR/nohup_omniutil_global_v5.log &
echo "✅ Omniutil daemon v5 lancé – Logs : $OMNIUTIL_DIR/nohup_omniutil_global_v5.log"

# -----------------------
# 8️⃣ Monitoring et confirmation
# -----------------------
echo "🌐 Omniutil final prêt – URL publique : https://$DOMAIN/"
echo "📂 Logs daemon en temps réel : tail -f $OMNIUTIL_DIR/nohup_omniutil_global_v5.log"
