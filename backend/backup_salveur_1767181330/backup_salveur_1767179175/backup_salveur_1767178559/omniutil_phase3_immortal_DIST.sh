#!/bin/bash
set -e

echo "🧬 OMNIUTIL PHASE 3 — DIST MODE (FINAL)"

cd "$HOME/omniutil/backend"

# 1️⃣ Dépendances sûres
npm install --save-dev typescript --legacy-peer-deps

# 2️⃣ tsconfig PROD
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true
  }
}
EOF

# 3️⃣ API EXPRESS (DEFAULT EXPORT POUR COMPAT)
mkdir -p src/api

cat > src/api/index.ts <<'EOF'
import express from "express";

const app = express();

app.use(express.json());

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok", service: "omniutil" });
});

export default app;
EOF

# 4️⃣ ENTRYPOINT
cat > src/index.ts <<'EOF'
import app from "./api";

const PORT = Number(process.env.PORT) || 3000;

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 OMNIUTIL API listening on port ${PORT}`);
});

process.on("SIGTERM", () => {
  server.close(() => process.exit(0));
});
EOF

# 5️⃣ BUILD
echo "🏗️ Building TypeScript → JavaScript..."
npx tsc

# 6️⃣ PM2 RESET
pm2 delete omniutil-api || true
pm2 kill || true
pm2 flush || true

# 7️⃣ START JS PUR (AUCUN ts-node)
pm2 start dist/index.js \
  --name omniutil-api \
  --interpreter node

pm2 save

# 8️⃣ TEST
sleep 2
echo "🧪 Testing API..."
curl -s http://127.0.0.1:3000/health || {
  echo "❌ API FAILED"
  pm2 logs omniutil-api --lines 40
  exit 1
}

echo "🏆 OMNIUTIL PHASE 3 — IMMORTAL MODE CONFIRMED (DIST)"
