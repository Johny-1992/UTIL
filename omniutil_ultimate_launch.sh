#!/bin/bash
# 🚀 OmniUtil Ultimate Orchestrator v1.0
set -e

ROOT_DIR=$(pwd)
echo "📂 Initialisation OmniUtil Ultimate depuis $ROOT_DIR"

echo "📁 Création des dossiers..."
mkdir -p contracts/core
mkdir -p contracts/_legacy
mkdir -p backend/api
mkdir -p frontend/qr
mkdir -p cpp
mkdir -p scripts
mkdir -p logs
mkdir -p environments

# Déplacer OmniUtilCore.sol si encore dans legacy
if [ -f contracts/_legacy/core/OmniUtilCore.sol ]; then
  mv contracts/_legacy/core/OmniUtilCore.sol contracts/core/
fi

# Backend ESM
cat > backend/api/server.js <<'EOF'
import express from "express";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({ status: "OmniUtil backend OK" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 OmniUtil backend running on port", PORT);
});
EOF

# Frontend
cat > frontend/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>OmniUtil</title>
</head>
<body>
<h1>OmniUtil – Mode DEMO / RÉEL</h1>
<p>Scanner le QR pour devenir partenaire</p>
</body>
</html>
EOF

# Orchestrateur C++
cat > cpp/orchestrator.cpp <<'EOF'
#include <iostream>
int main() {
  std::cout << "🧠 OmniUtil AI Coordinator actif" << std::endl;
  return 0;
}
EOF

# Script de déploiement
cat > scripts/deploy.sh <<'EOF'
#!/bin/bash
npx hardhat compile
npx hardhat run scripts/deploy.ts --network sepolia
EOF

chmod +x scripts/deploy.sh
chmod +x omniutil_ultimate_launch.sh

echo "✅ Structure OmniUtil prête"
echo "➡️ Étape suivante : compléter .env puis lancer deploy.sh"
