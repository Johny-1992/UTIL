#!/bin/bash
# ======================================================
# 🚀 OMNIUTIL — Auto-Create Modules + API + Test
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

router.get("/", (_, res) => {
  res.json({ status: "ok", module: "$module", timestamp: Date.now() });
});

export default router;
EOL
        echo "✅ Created $MODULE_FILE"
    else
        echo "ℹ️ $MODULE_FILE already exists"
    fi
done

# --- Step 2: Update api/index.ts ---
cat > "$API_FILE" <<EOL
import { Router } from "express";
import module1 from "../modules/module1";
import module2 from "../modules/module2";

const router = Router();

router.use("/module1", module1);
router.use("/module2", module2);

export default router;
EOL
echo "✅ Updated $API_FILE"

# --- Step 3: Update index.ts ---
cat > "$ENTRY_FILE" <<EOL
import express from "express";
import apiRouter from "./api/index";

const app = express();

app.use("/api", apiRouter);

app.get("/health", (_, res) => {
  res.json({ status: "ok", service: "OMNIUTIL", mode: "demo+real", timestamp: Date.now() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(\`OMNIUTIL API listening on port \${PORT}\`));
EOL
echo "✅ Updated $ENTRY_FILE"

# --- Step 4: Restart PM2 ---
cd $SRC_DIR
if command -v bun >/dev/null 2>&1; then
    pm2 delete omniutil-api 2>/dev/null
    pm2 start index.ts --interpreter bun --name omniutil-api
else
    pm2 delete omniutil-api 2>/dev/null
    pm2 start index.ts --name omniutil-api
fi

# --- Step 5: Test endpoints ---
echo "🧪 Testing OMNIUTIL endpoints..."
echo "====================================="
for endpoint in "${ENDPOINTS[@]}"; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ $endpoint (HTTP $HTTP_STATUS)"
    else
        echo "❌ $endpoint FAILED (HTTP $HTTP_STATUS)"
    fi
done
echo "🌍 OMNIUTIL readiness test complete."
