#!/bin/bash
# =================================================================
# Omniutil Global v5 – Daemon + Serveur Web Minimal + QR + SEO
# =================================================================

BASE_DIR=$(pwd)
PUBLIC_DIR="$BASE_DIR/public"
ASSETS_DIR="$PUBLIC_DIR/assets"
LOG_DIR="$BASE_DIR/src/logs"
QR_FILE="$ASSETS_DIR/omniutil_qr.png"

echo "🌍 OMNIUTIL GLOBAL V5 – DÉMARRAGE INTÉGRAL"

# 1️⃣ Vérifications de base
echo "🔍 Vérification Node.js et g++..."
node -v
g++ --version

# 2️⃣ Création dossiers critiques
mkdir -p "$LOG_DIR" "$ASSETS_DIR"

# 3️⃣ Génération QR code unique Omniutil
QR_URL="https://omniutil.example.com/partner-connect"
qrencode -o "$QR_FILE" "$QR_URL" -s 10
echo "✅ QR code généré → $QR_FILE"

# 4️⃣ Génération site vitrine minimal
cat > "$PUBLIC_DIR/index.html" <<EOL
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Omniutil Universe</title>
<style>
body { font-family: Arial, sans-serif; text-align:center; background:#f5f5f5; }
h1 { color:#1e1e2f; }
.qr { margin-top:20px; }
</style>
</head>
<body>
<h1>Bienvenue dans Omniutil Universe</h1>
<p>Scannez ce QR code pour devenir partenaire et interagir avec l'écosystème Omniutil</p>
<img class="qr" src="assets/omniutil_qr.png" alt="QR Omniutil">
</body>
</html>
EOL
echo "✅ Site vitrine minimal généré → $PUBLIC_DIR/index.html"

# 5️⃣ Génération metadata.json
cat > "$PUBLIC_DIR/metadata.json" <<EOL
{
    "name": "Omniutil Universe",
    "description": "Ecosystème mondial de partenaires et utilité tokenisée",
    "qr": "$QR_URL",
    "last_update": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOL
echo "✅ Metadata mondiale générée → $PUBLIC_DIR/metadata.json"

# 6️⃣ Création robots.txt et sitemap.xml pour SEO minimal
echo -e "User-agent: *\nAllow: /\nSitemap: $QR_URL/sitemap.xml" > "$PUBLIC_DIR/robots.txt"
cat > "$PUBLIC_DIR/sitemap.xml" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>$QR_URL</loc></url>
  <url><loc>$QR_URL/metadata.json</loc></url>
</urlset>
EOL
echo "✅ SEO minimal prêt (robots.txt + sitemap.xml)"

# 7️⃣ Lancement serveur web Node.js
cat > "$BASE_DIR/src/runtime/omniutil_server.js" <<'JS'
import express from 'express';
import fs from 'fs';
import path from 'path';
const app = express();
const PORT = process.env.PORT || 8082;
const PUBLIC_DIR = path.join(__dirname, '../../public');
app.use(express.static(PUBLIC_DIR));
app.get('/metadata.json', (req, res) => {
    const meta = fs.readFileSync(path.join(PUBLIC_DIR, 'metadata.json'), 'utf8');
    res.type('application/json').send(meta);
});
app.get('/health', (req, res) => {
    res.send({status:'Omniutil daemon actif', timestamp: Date.now()});
});
app.listen(PORT, () => console.log(`🌐 Omniutil Web Server running on port ${PORT}`));
JS
echo "✅ Serveur web Node.js prêt → port 8082"

# 8️⃣ Lancer le daemon Omniutil + serveur web
echo "🚀 Lancement Omniutil Global Daemon + Serveur Web..."
nohup bash "$BASE_DIR/src/runtime/omniutil_global_daemon_v4.sh" > "$LOG_DIR/daemon.log" 2>&1 &
nohup node "$BASE_DIR/src/runtime/omniutil_server.js" > "$LOG_DIR/server.log" 2>&1 &

echo "✅ Tout est lancé !"
echo "🌐 Page vitrine minimale accessible sur http://<votre-ip>:8082"
echo "📂 Logs daemon → $LOG_DIR/daemon.log"
echo "📂 Logs serveur → $LOG_DIR/server.log"
echo "🎯 Omniutil prêt à être scanné et indexé par Google"
