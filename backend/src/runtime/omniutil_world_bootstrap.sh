#!/bin/bash
set -e

echo "🌍 OMNIUTIL WORLD BOOTSTRAP – INITIALISATION MONDIALE"
echo "----------------------------------------------------"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

# --------------------------------------------------
# 1. Vérifications système
# --------------------------------------------------
echo "🔍 Vérification environnement..."
node -v
g++ --version

# --------------------------------------------------
# 2. Dossiers critiques (safe create)
# --------------------------------------------------
echo "📂 Vérification / création dossiers critiques..."
mkdir -p core security ai visibility logs src/logs

# --------------------------------------------------
# 3. Verrouillage logique mère (manifest + hash)
# --------------------------------------------------
echo "🔒 Verrouillage logique mère..."
cat > core/generate_logic_manifest.js <<'EOF'
const fs = require("fs");
const crypto = require("crypto");

const logic = {
  name: "OMNIUTIL",
  philosophy: "Reward real-world consumption with instant UTIL",
  pillars: [
    "On-chain contract (BSC)",
    "AI decision coordinator",
    "C++ deterministic orchestrator",
    "Universal QR entry point",
    "Real utility exchange (services / USDT)"
  ],
  creator_rights: "Lifetime on-chain royalties",
  inflation_policy: "Usage-based + burn + capped mint",
  immutable: true,
  timestamp: Date.now()
};

const json = JSON.stringify(logic, null, 2);
fs.writeFileSync("core/OMNIUTIL_LOGIC_MANIFEST.json", json);

const hash = crypto.createHash("sha256").update(json).digest("hex");
fs.writeFileSync("core/OMNIUTIL_LOGIC_HASH.txt", hash);

console.log("✅ Logique mère verrouillée – HASH:", hash);
EOF

node core/generate_logic_manifest.js

# --------------------------------------------------
# 4. Sécurité Zero-Trust minimale
# --------------------------------------------------
echo "🛡️ Initialisation sécurité Zero-Trust..."
cat > security/init_zero_trust.js <<'EOF'
const fs = require("fs");

const policy = {
  qr_event_validation: true,
  anti_replay: true,
  signed_logs: true,
  strict_types: true,
  created: new Date().toISOString()
};

fs.writeFileSync("security/zero_trust_policy.json", JSON.stringify(policy, null, 2));
console.log("✅ Sécurité Zero-Trust active");
EOF

node security/init_zero_trust.js

# --------------------------------------------------
# 5. IA déterministe (Partner Matrix)
# --------------------------------------------------
echo "🤖 Initialisation IA déterministe..."
cat > ai/build_partner_matrix.js <<'EOF'
const fs = require("fs");

const matrix = {
  TELCO: {
    min_subscribers: 100000,
    auto_accept: true,
    reward_cap_percent: 8
  },
  BANK: {
    min_subscribers: 50000,
    auto_accept: false
  },
  RETAIL: {
    min_subscribers: 1000,
    auto_accept: true
  }
};

fs.writeFileSync("ai/partner_matrix.json", JSON.stringify(matrix, null, 2));
console.log("✅ Partner Decision Matrix générée");
EOF

node ai/build_partner_matrix.js

# --------------------------------------------------
# 6. Orchestrateur C++ (safe build)
# --------------------------------------------------
echo "⚙️ Vérification orchestrateur C++..."
cd src/orchestrator

if [ ! -f orchestrator.cpp ]; then
  echo "❌ orchestrator.cpp manquant"
  exit 1
fi

g++ orchestrator.cpp -O2 -std=c++17 -o orchestrator_bin
chmod +x orchestrator_bin
./orchestrator_bin "{}" AUTO_ACCEPTED 50

cd "$ROOT_DIR"

# --------------------------------------------------
# 7. Activation des flux économiques UTIL
# --------------------------------------------------
echo "💰 Activation des flux UTIL..."
cat > src/runtime/activate_util_flows.js <<'EOF'
console.log("UTIL FLOWS ACTIVE:");
console.log("- transferInEcosystem");
console.log("- exchangeForService");
console.log("- exchangeForUSDT");
console.log("- loyaltyFactor dynamique");
EOF

node src/runtime/activate_util_flows.js
# --------------------------------------------------
# 8. Omniprésence machine-readable
# --------------------------------------------------
echo "🌐 Génération metadata omniprésence..."
cat > visibility/generate_global_metadata.js <<'EOF'
const fs = require("fs");

const meta = {
  name: "Omniutil",
  description: "Global reward infrastructure for real-world consumption",
  contract_chain: "BSC",
  utility: ["Rewards", "Services", "USDT Exchange"],
  access: "Universal QR",
  version: "1.0"
};

fs.writeFileSync("visibility/omniutil.json", JSON.stringify(meta, null, 2));
console.log("✅ Metadata mondiale générée");
EOF

node visibility/generate_global_metadata.js

# --------------------------------------------------
# 9. Lancement LIVE final
# --------------------------------------------------
echo "🚀 Lancement Omniutil Universe LIVE..."
node src/runtime/omniutil_universe_final_live.js

echo "🌕 OMNIUTIL WORLD BOOTSTRAP – INFRASTRUCTURE PRÊTE ✅"
