#!/bin/bash
# Omniutil – Omniprésence Totale
# Lancement du daemon + serveur web + SEO automatique

BASE_DIR=/root/omniutil/backend
PUBLIC_DIR=$BASE_DIR/public
ASSETS_DIR=$PUBLIC_DIR/assets
LOG_DIR=$BASE_DIR/src/logs
PORT=8082

mkdir -p $ASSETS_DIR $LOG_DIR

# Générer QR code si absent
QR_FILE=$ASSETS_DIR/omniutil_qr.png
if [ ! -f "$QR_FILE" ]; then
  qrencode -o $QR_FILE "http://41.243.58.116:$PORT/partner-connect" -s 10
fi

# Générer page vitrine minimale
INDEX_FILE=$PUBLIC_DIR/index.html
cat > $INDEX_FILE <<EOL
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Omniutil – Partenaires</title>
</head>
<body>
  <h1>Bienvenue sur Omniutil</h1>
  <p>Scannez le QR code ci-dessous pour vous connecter et devenir partenaire :</p>
  <img src="assets/omniutil_qr.png" alt="QR Omniutil" width="300">
</body>
</html>
EOL

# Générer sitemap.xml et robots.txt
cat > $PUBLIC_DIR/sitemap.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>http://41.243.58.116:$PORT/</loc></url>
  <url><loc>http://41.243.58.116:$PORT/metadata.json</loc></url>
</urlset>
EOL

cat > $PUBLIC_DIR/robots.txt <<EOL
User-agent: *
Allow: /
Sitemap: http://41.243.58.116:$PORT/sitemap.xml
EOL

# Metadata minimale
cat > $PUBLIC_DIR/metadata.json <<EOL
{
  "name": "Omniutil",
  "description": "Infrastructure mondiale de gestion de partenaires",
  "url": "http://41.243.58.116:$PORT/",
  "qr_code": "http://41.243.58.116:$PORT/assets/omniutil_qr.png"
}
EOL

# Lancer le daemon Omniutil
nohup bash $BASE_DIR/src/runtime/omniutil_global_final.sh > $LOG_DIR/nohup_omniutil_final.log 2>&1 &

# Lancer serveur web Node.js (http-server)
nohup npx http-server $PUBLIC_DIR -p $PORT -a 0.0.0.0 > $LOG_DIR/nohup_omniutil_server.log 2>&1 &

echo "✅ Omniutil Omniprésence lancé !"
echo "🌐 Page vitrine accessible sur : http://41.243.58.116:$PORT"
echo "📂 Logs daemon : $LOG_DIR/nohup_omniutil_final.log"
echo "📂 Logs serveur : $LOG_DIR/nohup_omniutil_server.log"
