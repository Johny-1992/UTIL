#!/bin/bash
# ======================================================
# 🚀 OMNIUTIL — Full Ultimate Fix + Auto Modules
# ======================================================

BASE_DIR=~/omniutil/backend
SRC_DIR=$BASE_DIR/src
MODULES_DIR=$SRC_DIR/modules
API_DIR=$SRC_DIR/api
API_FILE=$API_DIR/index.ts
ENTRY_FILE=$SRC_DIR/index.ts
BASE_URL="http://localhost:3000"
ENDPOINTS=("/health" "/api/module1" "/api/module2")

echo "📁 Creating directories..."
mkdir -p $MODULES_DIR
mkdir -p $API_DIR

# --- Step 1: Create module1.ts and module2.ts ---
for module in module1 module2; do
    MODULE_FILE="$MODULES_DIR/$module.ts"
    if [ ! -f "$MODULE_FILE" ]; then
        cat > "$MODULE_FILE" <<EOL
import { Router } from "express";
const router = Router();
router.get("/", (_, res) => res.json({ module: "$module", status: "ok" }));
export default router;
EOL
        echo "✅ Created $MODULE_FILE"
    else
        echo "ℹ️ $MODULE_FILE already exists"
    fi
done

# --- Step 2: Create api/index.ts to mount modules ---
cat > $API_FILE <<EOL
import { Router } from "express";
import module1Router from "../modules/module1";
import module2Router from "../modules/module2";

const router = Router();
router.use("/module1", module1Router);
router.use("/module2", module2Router);

export default router;
EOL
echo "✅ Updated $API_FILE"

# --- Step 3: Create main entry index.ts ---
cat > $ENTRY_FILE <<EOL
import express from "express";
import apiRouter from "./api";

const app = express();
app.use("/api", apiRouter);

app.get("/health", (_, res) => res.json({ status: "ok", service: "OMNIUTIL" }));

app.listen(3000, () => console.log("OMNIUTIL API running on port 3000"));
EOL
echo "✅ Updated $ENTRY_FILE"

# --- Step 4: Restart PM2 with Bun or Node ---
if command -v bun >/dev/null 2>&1; then
    pm2 restart src/index.ts --interpreter bun --name omniutil-api -f || pm2 start src/index.ts --interpreter bun --name omniutil-api
else
    pm2 restart dist/index.js --name omniutil-api -f || pm2 start dist/index.js --name omniutil-api
fi

pm2 ls

# --- Step 5: Test endpoints ---
echo "🧪 Testing OMNIUTIL endpoints..."
echo "====================================="
for endpoint in "${ENDPOINTS[@]}"; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ $endpoint OK (HTTP $HTTP_STATUS)"
    else
        echo "❌ $endpoint FAILED (HTTP $HTTP_STATUS)"
    fi
done
echo "🌍 OMNIUTIL readiness test complete."
