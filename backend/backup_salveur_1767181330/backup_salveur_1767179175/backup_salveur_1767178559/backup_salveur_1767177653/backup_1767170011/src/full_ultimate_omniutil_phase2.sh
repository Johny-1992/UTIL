#!/bin/bash
# ======================================================
# 🧬 OMNIUTIL — PHASE 2 : Constitution & Copyright
# ======================================================

BASE_DIR=~/omniutil/backend
SRC_DIR=$BASE_DIR/src
API_DIR=$SRC_DIR/api
CONST_DIR=$SRC_DIR/constitution

echo "🧬 [PHASE 2] Initialising OMNIUTIL Constitution..."

mkdir -p "$CONST_DIR"
mkdir -p "$API_DIR"

# ------------------------------------------------------
# 1️⃣ Constitution
# ------------------------------------------------------
CONST_FILE="$CONST_DIR/constitution.ts"
if [ ! -f "$CONST_FILE" ]; then
cat > "$CONST_FILE" <<'EOF'
export const OMNIUTIL_CONSTITUTION = {
  name: "OMNIUTIL",
  status: "IMMORTAL_SYSTEM",
  purpose: "Universal coordination, utility and symbiotic integration",
  principles: [
    "Respect of origin and logic-mère",
    "Perpetual attribution of authorship",
    "24/7 operational continuity",
    "Human + AI symbiosis"
  ],
  createdAt: "2025-01-01",
  immutable: true
};
EOF
echo "✅ Constitution created"
else
echo "ℹ️ Constitution already exists"
fi

# ------------------------------------------------------
# 2️⃣ Principles
# ------------------------------------------------------
PRINCIPLES_FILE="$CONST_DIR/principles.ts"
if [ ! -f "$PRINCIPLES_FILE" ]; then
cat > "$PRINCIPLES_FILE" <<'EOF'
export const OMNIUTIL_PRINCIPLES = [
  "One system, multiple realities (demo + real)",
  "No fork without recognition",
  "No usage without attribution",
  "Evolution without corruption"
];
EOF
echo "✅ Principles created"
else
echo "ℹ️ Principles already exist"
fi
# ------------------------------------------------------
# 3️⃣ Copyright
# ------------------------------------------------------
COPY_FILE="$CONST_DIR/copyright.ts"
if [ ! -f "$COPY_FILE" ]; then
cat > "$COPY_FILE" <<'EOF'
export const OMNIUTIL_COPYRIGHT = {
  author: "Original Creator of OMNIUTIL",
  rights: "Perpetual, irrevocable, worldwide",
  enforcement: "Automatic by system design",
  reproduction: "Allowed only with attribution",
  royalty: "Embedded by principle"
};
EOF
echo "✅ Copyright created"
else
echo "ℹ️ Copyright already exists"
fi

# ------------------------------------------------------
# 4️⃣ Royalty
# ------------------------------------------------------
ROYALTY_FILE="$CONST_DIR/royalty.ts"
if [ ! -f "$ROYALTY_FILE" ]; then
cat > "$ROYALTY_FILE" <<'EOF'
export const OMNIUTIL_ROYALTY = {
  model: "Perpetual attribution + value recognition",
  enforcement: "Moral, legal and technical",
  appliesTo: ["partners", "derivatives", "integrations"]
};
EOF
echo "✅ Royalty model created"
else
echo "ℹ️ Royalty model already exists"
fi

# ------------------------------------------------------
# 5️⃣ API ROUTES (fusion-safe)
# ------------------------------------------------------
API_FILE="$API_DIR/index.ts"

if ! grep -q "constitution" "$API_FILE" 2>/dev/null; then
cat >> "$API_FILE" <<'EOF'

import { OMNIUTIL_CONSTITUTION } from "../constitution/constitution";
import { OMNIUTIL_PRINCIPLES } from "../constitution/principles";
import { OMNIUTIL_COPYRIGHT } from "../constitution/copyright";
import { OMNIUTIL_ROYALTY } from "../constitution/royalty";

app.get("/api/constitution", (_, res) => res.json(OMNIUTIL_CONSTITUTION));
app.get("/api/principles", (_, res) => res.json(OMNIUTIL_PRINCIPLES));
app.get("/api/copyright", (_, res) => res.json(OMNIUTIL_COPYRIGHT));
app.get("/api/royalty", (_, res) => res.json(OMNIUTIL_ROYALTY));
EOF
echo "✅ API routes added"
else
echo "ℹ️ API constitution routes already present"
fi

# ------------------------------------------------------
# 6️⃣ Restart API
# ------------------------------------------------------
echo "♻️ Restarting OMNIUTIL API..."
if command -v bun >/dev/null 2>&1; then
  pm2 restart src/index.ts --interpreter bun --name omniutil-api -f
else
  pm2 restart dist/index.js --name omniutil-api -f
fi

echo "🎉 PHASE 2 COMPLETE — OMNIUTIL Constitution LIVE"
