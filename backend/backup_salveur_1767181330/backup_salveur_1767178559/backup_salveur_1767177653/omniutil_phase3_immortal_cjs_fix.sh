#!/bin/bash
set -e

echo "🧬 OMNIUTIL PHASE 3 — IMMORTAL CJS FIX"

cd "$HOME/omniutil/backend"

# 1️⃣ Dépendances sûres
npm install --save-dev ts-node typescript --legacy-peer-deps

# 2️⃣ tsconfig FORCÉ COMMONJS
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true
  }
}
EOF

# 3️⃣ API EXPRESS — COMMONJS EXPORT
mkdir -p src/api

cat > src/api/index.ts <<'EOF'
import express = require("express");

const app = express();

app.use(express.json());

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok", service: "omniutil" });
});

module.exports = app;
EOF

# 4️⃣ SERVER ENTRY — COMMONJS REQUIRE
cat > src/index.ts <<'EOF'
const app = require("./api");

const PORT = Number(process.env.PORT) || 3000;

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 OMNIUTIL API listening on port ${PORT}`);
});

process.on("SIGTERM", () => {
  server.close(() => process.exit(0));
});
EOF

# 5️⃣ PM2 RESET TOTAL
pm2 delete omniutil-api || true
pm2 kill || true
pm2 flush || true

# 6️⃣ START IMMORTAL
pm2 start src/index.ts \
  --name omniutil-api \
  --interpreter ./node_modules/.bin/ts-node \
  --node-args="--transpile-only"

pm2 save

# 7️⃣ TEST FINAL
sleep 2
echo "🧪 Testing API..."

curl -s http://127.0.0.1:3000/health || {
  echo "❌ API FAILED"
  pm2 logs omniutil-api --lines 30
  exit 1
}

echo "🏆 OMNIUTIL PHASE 3 — IMMORTAL MODE CONFIRMED"
