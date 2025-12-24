#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
NODE_PORT="${NODE_PORT:-3000}"

# Ports non privilégiés pour Nginx (OK dans Termux/proot)
HTTP_PORT=8080
HTTPS_PORT=8443

NGINX_LOCAL_CONF="/root/omniutil/nginx_omniutil_local.conf"
SSL_KEY="/etc/nginx/selfsigned.key"
SSL_CERT="/etc/nginx/selfsigned.crt"

echo "[step7-fix] Configuration Nginx local sur ports $HTTP_PORT / $HTTPS_PORT"

cd "$BACKEND_DIR"
echo "[step7-fix] Dossier backend : $(pwd)"

echo "[step7-fix] Vérification installation nginx + openssl..."
apt-get update -y
apt-get install -y nginx openssl

# Générer un cert auto-signé si absent (on réutilise ceux du premier script si déjà créés)
if [ ! -f "$SSL_KEY" ] || [ ! -f "$SSL_CERT" ]; then
  echo "[step7-fix] Certificat auto-signé absent, génération..."
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$SSL_KEY" \
    -out "$SSL_CERT" \
    -subj "/CN=localhost"
else
  echo "[step7-fix] Certificat auto-signé déjà présent :"
  echo "  - $SSL_KEY"
  echo "  - $SSL_CERT"
fi

echo "[step7-fix] Écriture de la configuration Nginx locale : $NGINX_LOCAL_CONF"

cat > "$NGINX_LOCAL_CONF" <<EOF
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    # Serveur HTTP sur port $HTTP_PORT (reverse proxy vers Node $NODE_PORT)
    server {
        listen $HTTP_PORT;
        server_name localhost;

        location / {
            proxy_pass http://127.0.0.1:$NODE_PORT;
            proxy_http_version 1.1;

            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # Serveur HTTPS sur port $HTTPS_PORT (certificat auto-signé)
    server {
        listen $HTTPS_PORT ssl;
        server_name localhost;

        ssl_certificate     $SSL_CERT;
        ssl_certificate_key $SSL_KEY;

        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://127.0.0.1:$NODE_PORT;
            proxy_http_version 1.1;

            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
EOF

echo "[step7-fix] Arrêt éventuel d'instances Nginx existantes..."
nginx -s stop || true
pkill nginx || true

echo "[step7-fix] Démarrage de Nginx avec la configuration locale : $NGINX_LOCAL_CONF"
nginx -c "$NGINX_LOCAL_CONF"

echo "============================================================"
echo "[step7-fix] Nginx est démarré sur :"
echo "  - HTTP  : http://127.0.0.1:$HTTP_PORT"
echo "  - HTTPS : https://127.0.0.1:$HTTPS_PORT"
echo
echo "[step7-fix] Tests suggérés :"
echo "  1) curl http://127.0.0.1:$HTTP_PORT/health"
echo "  2) curl -k https://127.0.0.1:$HTTPS_PORT/health"
echo "  3) API protégée via Nginx + clé :"
echo "     API_KEY=\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo "     curl -i -H \"x-api-key: \$API_KEY\" http://127.0.0.1:$HTTP_PORT/api/ai/status"
echo "============================================================"
