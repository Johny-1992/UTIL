crrtt#!/usr/bin/env bashg
set -euo pipefail

BACKEND_DIR="/root/omniutilc/backend"
PM2_NAME="omniutil-api"
NODE_PORT="${NODE_PORT:-3000}"

echo "[step7] Configuration de Nginx (reverse proxy) pour omniutil"
cd "$BACKEND_DIR"
echo "[step7] Dossier backend : $(pwd)"

# === 1) Demander le domaine ===
DOMAIN="${DOMAIN:-}"
if [ -z "$DOMAIN" ]; then
  read -r -p "[step7] Nom de domaine complet (FQDN, ex: api.omniutil.com) : " DOMAIN || true
fi

if [ -z "$DOMAIN" ]; then
  echo "[step7] ERREUR : aucun domaine fourni. Relance le script avec DOMAIN=mon.domaine.com ./backend_step7_nginx.sh"
  exit 1
fi

echo "[step7] Domaine utilisé : $DOMAIN"

# === 2) Installer Nginx + Certbot (si nécessaire) ===
echo "[step7] Installation de nginx, certbot, python3-certbot-nginx (si nécessaire)..."
apt-get update -y
apt-get install -y nginx certbot python3-certbot-nginx

# === 3) Générer la configuration Nginx pour omniutil ===
NGINX_CONF="/etc/nginx/sites-available/omniutil.conf"

cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN;

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
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/omniutil.conf
if [ -f /etc/nginx/sites-enabled/default ]; then
  rm /etc/nginx/sites-enabled/default
  echo "[step7] Site default supprimé de sites-enabled."
fi

# === 4) Tester et (re)démarrer Nginx ===
echo "[step7] Test de la configuration Nginx..."
nginx -t

echo "[step7] (Re)démarrage de nginx..."
if pgrep nginx >/dev/null 2>&1; then
  nginx -s reload
  echo "[step7] nginx rechargé."
else
  nginx
  echo "[step7] nginx démarré."
fi

# === 5) Configurer trust proxy dans index.ts (si pas déjà fait) ===
cd "$BACKEND_DIR"

if ! grep -q "app.set('trust proxy'" index.ts; then
  echo "[step7] Ajout de app.set('trust proxy', true); dans index.ts"
  # On insère juste après 'const app = express();'
  sed -i "s/const app = express();/const app = express();\n\napp.set('trust proxy', true);/" index.ts
else
  echo "[step7] app.set('trust proxy', true); déjà présent dans index.ts"
fi

# === 6) Rebuild TypeScript + restart PM2 ===
echo "[step7] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step7] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step7] HTTP reverse proxy configuré."
echo "      - Domaine               : $DOMAIN"
echo "      - Backend Node (interne): http://127.0.0.1:$NODE_PORT"
echo "      - Nginx écoute sur      : port 80"
echo
echo "Tests à faire depuis Ubuntu :"
echo " 1) curl -H \"Host: $DOMAIN\" http://127.0.0.1/health"
echo "    -> doit répondre {\"status\":\"ok\"}"
echo
echo "[step7] Si ton domaine pointe bien vers cette machine et que le port 80"
echo "        est ouvert depuis Internet, tu peux tenter la config HTTPS :"
echo
echo "   certbot --nginx -d $DOMAIN"
echo
echo "   Puis suis les instructions (email, accord, redirection HTTP->HTTPS)."
echo "============================================================"
