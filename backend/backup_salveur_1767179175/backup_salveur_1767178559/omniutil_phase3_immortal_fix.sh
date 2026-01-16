#!/bin/bash
# OMNIUTIL – PHASE 3 IMMORTAL AUTO-FIX
# Corrige Express / TypeScript / PM2 / Binding réseau
set -e

echo "🧬 OMNIUTIL PHASE 3 — IMMORTAL FIX STARTING..."

BASE_DIR="$HOME/omniutil/backend"
API_DIR="$BASE_DIR/src/api"

cd "$BASE_DIR"

echo "📍 Working directory: $(pwd)"

# 1️⃣ Dépendances critiques
echo "📦 Installing ts-node & typescript (safe mode)..."
npm install --save-dev ts-node typescript --legacy-peer-deps

# 2️⃣ Vérification ts-node
if [ ! -x "./node_modules/.bin/ts-node" ]; then
  echo "❌ ts-node not found. Abort."
  exit 1
fi
echo "✅ ts-node OK"

# 3️⃣ Création API EXPRESS PROPRE
echo "🧠 Writing Express API (src/api/index.ts)..."
mkdir -p "$API_DIR"

cat > "$API_DIR/index.ts" <<'EOF'
import express from "express";

const app = express();

app.use(express.json());

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok", service: "omniutil" });
});

export default app;
EOF

# 4️⃣ Création SERVER RÉSEAU
echo "🌐 Writing server entrypoint (src/index.ts)..."

cat > "$BASE_DIR/src/index.ts" <<'EOF'
import app from "./api";

const PORT = Number(process.env.PORT) || 3000;

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 OMNIUTIL API listening on port ${PORT}`);
});

process.on("SIGTERM", () => {
  server.close(() => {
    console.log("🛑 Server closed");
    process.exit(0);
  });
});
EOF

# 5️⃣ PM2 CLEAN RESTART
echo "♻️ Restarting PM2 cleanly..."
pm2 delete omniutil-api || true
pm2 flush || true

pm2 start src/index.ts \
  --name omniutil-api \
  --interpreter ./node_modules/.bin/ts-node

pm2 save

# 6️⃣ TEST RÉSEAU
echo "🧪 Testing /health endpoint..."
sleep 2

if curl -s http://127.0.0.1:3000/health | grep -q "ok"; then
  echo "✅ SUCCESS — OMNIUTIL API IS LIVE"
else
  echo "❌ FAILURE — API NOT RESPONDING"
  pm2 logs omniutil-api --lines 20
  exit 1
fi

echo "🏆 OMNIUTIL PHASE 3 — IMMORTAL FIX COMPLETE"
