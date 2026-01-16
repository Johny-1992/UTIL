#!/usr/bin/env bash
set -e

echo "🌌 OMNIUTIL RESOLVER LIVE – Initialisation globale"
echo "--------------------------------------------------"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

### 1️⃣ Vérification Node
echo "📦 Vérification Node.js…"
command -v node >/dev/null || { echo "❌ Node manquant"; exit 1; }
node -v

### 2️⃣ Dossiers vitaux
echo "📂 Vérification dossiers…"
for dir in src/logs src/orchestrator src/runtime src/utils; do
  [ -d "$dir" ] || { echo "⚠️ Création $dir"; mkdir -p "$dir"; }
done

### 3️⃣ ABI
ABI_PATH="src/utils/omniutil_abi.json"
[ -f "$ABI_PATH" ] || { echo "❌ ABI introuvable"; exit 1; }
echo "📜 ABI OK → $ABI_PATH"

### 4️⃣ Orchestrateur C++
ORCH_BIN="src/orchestrator/orchestrator_bin"
if [ ! -f "$ORCH_BIN" ]; then
  echo "⚙️ Compilation orchestrateur C++…"
  g++ src/orchestrator/orchestrator.cpp -O2 -std=c++17 -o "$ORCH_BIN"
  chmod +x "$ORCH_BIN"
fi
echo "🧠 Orchestrateur C++ prêt"

### 5️⃣ Test orchestrateur
echo "🧪 Test orchestrateur…"
"$ORCH_BIN" "{}" AUTO_ACCEPTED 50

### 6️⃣ Lancement Universe LIVE
echo "🚀 Lancement Omniutil Universe LIVE…"
node src/runtime/omniutil_universe_final_live.js

echo "🌕 OMNIUTIL RESOLVER LIVE – Infrastructure cohérente et stable ✅"
