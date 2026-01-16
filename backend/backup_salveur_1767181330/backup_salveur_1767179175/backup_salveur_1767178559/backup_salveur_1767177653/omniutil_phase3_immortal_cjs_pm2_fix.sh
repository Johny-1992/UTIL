#!/bin/bash
# omniutil_phase3_immortal_cjs_pm2_fix.sh
# Script tout-en-un pour corriger OMNIUTIL PHASE 3 — IMMORTAL (CJS + PM2)

set -e

echo "🧬 OMNIUTIL PHASE 3 — IMMORTAL CJS FIX STARTING..."
echo "📍 Working directory: $(pwd)"

# 1️⃣ Installer ts-node & typescript en bypassant conflits Hardhat
echo "📦 Installing ts-node & typescript (legacy-peer-deps)..."
npm install --save-dev ts-node typescript --legacy-peer-deps

echo "✅ ts-node & typescript OK"

# 2️⃣ Mettre à jour tsconfig.json
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "outDir": "dist",
    "rootDir": ".",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": [
    "src/**/*",
    "api/**/*",
    "services/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF
echo "✅ tsconfig.json updated"

# 3️⃣ Créer src/api/index.ts (CommonJS)
mkdir -p src/api
cat > src/api/index.ts <<'EOF'
import express from 'express';

const app = express();

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

module.exports = app; // CommonJS export
EOF
echo "✅ src/api/index.ts updated"

# 4️⃣ Créer src/index.ts (server entrypoint)
cat > src/index.ts <<'EOF'
const app = require('./api/index');

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 OMNIUTIL API running on port ${PORT}`);
});
EOF
echo "✅ src/index.ts updated"

# 5️⃣ Redémarrer PM2
echo "♻️ Restarting PM2..."
pm2 delete omniutil-api || true
pm2 start src/index.ts --name omniutil-api --interpreter ./node_modules/.bin/ts-node
pm2 save

# 6️⃣ Tester /health endpoint
echo "🧪 Testing /health endpoint..."
sleep 2
if curl -s http://127.0.0.1:3000/health | grep -q "OK"; then
  echo "🏆 PHASE 3 — DIST MODE FULLY OPERATIONAL"
else
  echo "❌ API FAILED — check PM2 logs"
  pm2 logs omniutil-api --lines 40
  exit 1
fi
