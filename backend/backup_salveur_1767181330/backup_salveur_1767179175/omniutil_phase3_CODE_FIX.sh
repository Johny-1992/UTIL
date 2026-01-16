#!/bin/bash
set -e

echo "🧬 OMNIUTIL — CODE FIX (APP DUPLICATION)"

cd /root/omniutil/backend

# 1️⃣ Fix src/api/index.ts
cat > src/api/index.ts <<'TS'
import express from "express";

const app = express();

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

export default app;
TS

# 2️⃣ Fix src/index.ts
cat > src/index.ts <<'TS'
import app from "./api/index";

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 OMNIUTIL API listening on port ${PORT}`);
});
TS

echo "✅ Source files fixed"

# 3️⃣ Clean build
rm -rf dist
npx tsc

echo "🏗️ Build OK"

# 4️⃣ Restart PM2
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api
pm2 save

sleep 2

# 5️⃣ Test API
echo "🧪 Testing /health..."
curl -s http://127.0.0.1:3000/health || {
  echo "❌ API NOT RESPONDING"
  pm2 logs omniutil-api --lines 50
  exit 1
}

echo "🏆 OMNIUTIL API FULLY OPERATIONAL"
