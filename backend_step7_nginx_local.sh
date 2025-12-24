#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"
NODE_PORT="${NODE_PORT:-3000}"

echo "[step7] Configuration Nginx local (reverse proxy + HTTPS auto-signé) pour omniutil"
cd "$BACKEND_DIR"
echo "[step7] Dossier backend : $(pwd)"

# === 1) Installation de nginx + openssl ===
echo "[step7] Installation de nginx et openssl (si nécessaire)..."
apt-get update -y
apt-get install -y nginx openssl

# === 2) Génération du certificat auto-signé si absent ===
SSL_KEY="/etc/nginx/selfsigned.key"
SSL_CERT="/etc/nginx/selfsigned.crt"

if [ ! -f "$SSL_KEY" ] || [ ! -f "$SSL_CERT" ]; then
  echo "[step7] Génération d'un certificat auto-signé pour HTTPS local..."
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$SSL_KEY" \
    -out "$SSL_CERT" \
    -subj "/CN=localhost"
else
  echo "[step7] Certificat auto-signé déjà présent, pas de régénération."
fi

# === 3) Configuration Nginx : HTTP -> HTTPS + reverse proxy ===
NGINX_CONF="/etc/nginx/sites-available/omniutil-local.conf"

cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name _;

    # Redirige tout HTTP vers HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     $SSL_CERT;
    ssl_certificate_key $SSL_KEY;

    # Proxy vers l'API Node (omniutil) sur $NODE_PORT
    location / {
        proxy_pass http://127.0.0.1:$NODE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # WebSocket / upgrade si un jour tu en utilises
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "[step7] Fichier Nginx écrit : $NGINX_CONF"

# Activer le site et désactiver le default
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/omniutil-local.conf

if [ -f /etc/nginx/sites-enabled/default ]; then
  rm /etc/nginx/sites-enabled/default
  echo "[step7] Site default supprimé de sites-enabled."
fi

# === 4) Tester et (re)lancer Nginx ===
echo "[step7] Test de la configuration Nginx..."
nginx -t

echo "[step7] (Re)démarrage de nginx..."
if pgrep nginx >/dev/null 2>&1; then
  nginx -s reload
else
  nginx
fi

# === 5) Adapter index.ts : app.set('trust proxy', true); ===
cd "$BACKEND_DIR"

if [ -f "index.ts" ] && [ ! -f "index.ts.step7.bak" ]; then
  cp index.ts index.ts.step7.bak
  echo "[step7] Backup créé : index.ts.step7.bak"
fi

if ! grep -q "app.set('trust proxy', true);" index.ts; then
  echo "[step7] Injection de app.set('trust proxy', true); dans index.ts"
  sed -i "s/const app = express();/const app = express();\napp.set('trust proxy', true);/" index.ts
else
  echo "[step7] app.set('trust proxy', true); déjà présent dans index.ts"
fi

# === 6) Rebuild + restart PM2 ===
echo "[step7] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step7] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  echo "[step7] Process PM2 '$PM2_NAME' trouvé, redémarrage avec --update-env"
  pm2 restart "$PM2_NAME" --update-env
else
  echo "[step7] Process PM2 '$PM2_NAME' introuvable, démarrage initial sur dist/index.js..."
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step7] Terminé."
echo "Tests recommandés :"
echo "1) Vérifier que Nginx tourne :   ps aux | grep nginx"
echo "2) Tester HTTP (redirigé vers HTTPS) :"
echo "   curl -i http://127.0.0.1/health"
echo "3) Tester HTTPS (certificat auto-signé, utiliser -k) :"
echo "   curl -k https://127.0.0.1/health"
echo "4) Tester un endpoint protégé via HTTPS + clé API :"
echo "   API_KEY=\\\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo "   curl -k -H \"x-api-key: \\\$API_KEY\" https://127.0.0.1/api/ai/status"
echo "============================================================"
