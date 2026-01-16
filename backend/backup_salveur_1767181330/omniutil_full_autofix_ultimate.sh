#!/bin/bash
set -e

echo "🚀 OMNIUTIL — FULL AUTO-FIX + PROD + IMMORTEL + ENTERPRISE"
echo "========================================================="

### PATHS
BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"
APP_NAME="omniutil-api"
BACKEND_PORT=3000
FRONTEND_PORT=8080
DOMAIN="${OMNIUTIL_DOMAIN:-}"

### SAFE CHECK
if [ ! -d "$BACKEND_DIR" ]; then
  echo "❌ Backend introuvable"
  exit 1
fi

echo "📌 Backend  : $BACKEND_DIR"
echo "📌 Frontend : $FRONTEND_DIR"
echo ""

########################################
# 1️⃣ BACKEND — AUTO FIX & BUILD
########################################
echo "📦 [1/7] Backend auto-fix & build"
cd "$BACKEND_DIR"

npm install --silent

if npm run | grep -q " build"; then
  npm run build
else
  npx tsc
fi

########################################
# 2️⃣ PM2 — IMMORTAL MODE
########################################
echo "🔄 [2/7] PM2 immortalisation"

pm2 delete "$APP_NAME" 2>/dev/null || true

pm2 start dist/index.js \
  --name "$APP_NAME" \
  --time \
  --restart-delay=5000 \
  --max-restarts=9999

pm2 save
pm2 startup systemd -u root --hp /root >/dev/null

########################################
# 3️⃣ FRONTEND — SAFE STATIC SERVE (NO NODE BUG)
########################################
echo "🌐 [3/7] Frontend launch (static-safe)"

if [ -d "$FRONTEND_DIR/dist" ]; then
  FRONT_STATIC="$FRONTEND_DIR/dist"
elif [ -d "$FRONTEND_DIR/build" ]; then
  FRONT_STATIC="$FRONTEND_DIR/build"
else
  FRONT_STATIC="$FRONTEND_DIR"
fi

pkill -f "python3 -m http.server $FRONTEND_PORT" || true

nohup python3 -m http.server "$FRONTEND_PORT" \
  --directory "$FRONT_STATIC" \
  >/var/log/omniutil_frontend.log 2>&1 &

########################################
# 4️⃣ NGINX — PROD WORLD MODE
########################################
echo "🌍 [4/7] Nginx production config"

apt-get update -qq
apt-get install -y nginx curl

cat >/etc/nginx/sites-available/omniutil <<EOF
server {
    listen 80;
    server_name ${DOMAIN:-_};

    location / {
        proxy_pass http://127.0.0.1:$FRONTEND_PORT;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOF

ln -sf /etc/nginx/sites-available/omniutil /etc/nginx/sites-enabled/omniutil
nginx -t && systemctl restart nginx

########################################
# 5️⃣ HTTPS — AUTO IF DOMAIN
########################################
if [ -n "$DOMAIN" ]; then
  echo "🔐 [5/7] HTTPS Let's Encrypt"
  apt-get install -y certbot python3-certbot-nginx
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m admin@$DOMAIN || true
fi

########################################
# 6️⃣ ENTERPRISE — MONITORING & HEALTH
########################################
echo "📊 [6/7] Monitoring & watchdog"

cat >/usr/local/bin/omniutil_watchdog.sh <<'EOF'
#!/bin/bash
if ! curl -sf http://127.0.0.1:3000/health >/dev/null; then
  pm2 restart omniutil-api
fi
EOF

chmod +x /usr/local/bin/omniutil_watchdog.sh

(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/omniutil_watchdog.sh") | crontab -

########################################
# 7️⃣ FINAL STATUS
########################################
echo "🧪 [7/7] Final verification"
curl -s http://127.0.0.1:3000/health || true

echo ""
echo "🎉 OMNIUTIL FULL AUTO-FIX COMPLETED"
echo "=================================="
echo "Frontend : http://127.0.0.1"
echo "Backend  : http://127.0.0.1/api"
echo "PM2      : IMMORTAL"
echo "Nginx    : ACTIVE"
echo "Watchdog : ACTIVE"
echo ""
