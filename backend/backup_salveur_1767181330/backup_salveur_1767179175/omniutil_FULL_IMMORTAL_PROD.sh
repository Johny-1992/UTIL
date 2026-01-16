#!/bin/bash
set -e

echo "🧬 OMNIUTIL — FULL IMMORTAL PROD START"

############################
# 0️⃣ PRÉREQUIS
############################
apt update -y
apt install -y nginx curl

############################
# 1️⃣ TYPESCRIPT / BUILD
############################
echo "📦 Installing deps..."
npm install --save-dev typescript ts-node
npm install --production

echo "🛠️ Fix tsconfig.json"
cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
EOF

echo "🏗️ Building project..."
rm -rf dist
npx tsc

############################
# 2️⃣ PORT AUTO-LIBRE
############################
echo "🔎 Finding free port..."
PORT=3000
while ss -tuln | grep -q ":$PORT "; do
  PORT=$((PORT+1))
done
echo "✅ Using port $PORT"

############################
# 3️⃣ PATCH index.ts (BOOTSTRAP)
############################
cat > src/index.ts <<EOF
import app from "./api";

const BASE_PORT = $PORT;
let port = BASE_PORT;

const server = app.listen(port, () => {
  console.log("🚀 OMNIUTIL API running on port " + port);
});

server.on("error", (err: any) => {
  if (err.code === "EADDRINUSE") {
    port++;
    server.listen(port);
  }
});
EOF

############################
# 4️⃣ REBUILD DIST
############################
rm -rf dist
npx tsc

############################
# 5️⃣ PM2 IMMORTEL
############################
echo "♻️ PM2 restart..."
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api
pm2 save

############################
# 6️⃣ NGINX REVERSE PROXY
############################
echo "🌍 Configuring NGINX..."
cat > /etc/nginx/sites-available/omniutil <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /health {
        proxy_pass http://127.0.0.1:$PORT/health;
    }
}
EOF

ln -sf /etc/nginx/sites-available/omniutil /etc/nginx/sites-enabled/omniutil
nginx -t
systemctl reload nginx

############################
# 7️⃣ TEST FINAL
############################
sleep 2
echo "🧪 Testing /health..."
curl -s http://localhost/health || true

echo "🏆 OMNIUTIL FULL IMMORTAL PROD READY"
