#!/bin/bash
set -e

echo "🚀 OMNIUTIL — STEP 1: LOGIQUE MÈRE & NORMALISATION"
echo "================================================="

BACKEND="/root/omniutil/backend"
SRC="$BACKEND/src"
CORE="$SRC/core"
API="$SRC/api"

cd $BACKEND

echo "📁 Vérification structure..."
mkdir -p $CORE $API

echo "🧠 Création omniutil.protocol.ts"
cat > $CORE/omniutil.protocol.ts <<'EOF'
export const OMNIUTIL_PROTOCOL = {
  name: "Omniutil",
  version: "1.0.0",
  mode: "REAL",
  automation: "TOTAL",
  logic: "UNIVERSAL_INFRASTRUCTURE"
};
EOF

echo "🔏 Création omniutil.signature.ts"
cat > $CORE/omniutil.signature.ts <<'EOF'
export function omniutilSignature() {
  return {
    poweredBy: "OMNIUTIL",
    protocol: "UNIVERSAL",
    timestamp: new Date().toISOString()
  };
}
EOF

echo "📐 Création omniutil.constants.ts"
cat > $CORE/omniutil.constants.ts <<'EOF'
export const OMNIUTIL_QR_VERSION = "v1";
export const OMNIUTIL_AUTHOR_SHARE = 0.02;
EOF

echo "🩺 Création health.ts"
cat > $SRC/health.ts <<'EOF'
import { Request, Response } from "express";

export function healthCheck(req: Request, res: Response) {
  res.json({ status: "ok", service: "omniutil-backend" });
}
EOF

echo "🌐 Normalisation src/index.ts"
cat > $SRC/index.ts <<'EOF'
import express from "express";
import bodyParser from "body-parser";
import { healthCheck } from "./health";
import apiRoutes from "./api";
import { omniutilSignature } from "./core/omniutil.signature";

const app = express();
app.use(bodyParser.json());

app.get("/health", healthCheck);

app.use((req, res, next) => {
  res.setHeader("X-Omniutil", JSON.stringify(omniutilSignature()));
  next();
});

app.use("/api", apiRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 OMNIUTIL API running on port ${PORT}`);
});
EOF

echo "🔌 Normalisation api/index.ts"
cat > $API/index.ts <<'EOF'
import { Router } from "express";
import partner from "./partner_validation";
import ai from "./ai";

const router = Router();

router.get("/index", (_, res) => {
  res.json({ message: "API fonctionnelle !" });
});

router.use("/partner", partner);
router.use("/ai", ai);

export default router;
EOF

echo "🤝 Création partner_validation.ts"
cat > $API/partner_validation.ts <<'EOF'
import { Router } from "express";
const router = Router();

router.post("/onboard", (req, res) => {
  const { partner_id } = req.body;
  if (!partner_id) return res.status(400).json({ error: "partner_id manquant" });
  res.json({ status: "onboarded", partner_id });
});

export default router;
EOF

echo "🤖 Création ai.ts"
cat > $API/ai.ts <<'EOF'
import { Router } from "express";
const router = Router();

router.post("/test", (req, res) => {
  res.json({ ai: "online", input: req.body });
});

export default router;
EOF

echo "📦 Compilation TypeScript..."
npx tsc

echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api
pm2 save

echo "🧪 Tests API..."
curl -s http://127.0.0.1:3000/health | grep ok
curl -s http://127.0.0.1:3000/api/index | grep API

echo "✅ ÉTAPE 1 TERMINÉE — LOGIQUE MÈRE STABILISÉE"
