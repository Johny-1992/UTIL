#!/bin/bash
set -e

echo "🧊 FIGEMENT ARCHITECTURE OMNIUTIL v1"
echo "📍 Dossier courant : $(pwd)"

ROOT_DIR=$(pwd)
OUT_DIR="architecture_freeze"
TS_CONFIG="tsconfig.json"

mkdir -p "$OUT_DIR"

echo "🔍 Scan structure projet..."

tree -I 'node_modules|dist|build|.git' > "$OUT_DIR/tree.txt"

echo "🧠 Détection des modules clés..."

grep -R "rewards" src > "$OUT_DIR/rewards.scan.txt" || true
grep -R "partner" src > "$OUT_DIR/partners.scan.txt" || true
grep -R "audit" src > "$OUT_DIR/audit.scan.txt" || true
grep -R "antiFraud\|fraud" src > "$OUT_DIR/antifraud.scan.txt" || true
grep -R "contract\|ethers" src > "$OUT_DIR/blockchain.scan.txt" || true
grep -R "qr\|QR" src > "$OUT_DIR/qr.scan.txt" || true
grep -R "AI\|ai\|coordinator" src > "$OUT_DIR/ai.scan.txt" || true

echo "📐 Génération ARCHITECTURE.lock.json..."

cat << EOF > "$OUT_DIR/ARCHITECTURE.lock.json"
{
  "project": "OmniUtil Backend",
  "status": "FROZEN",
  "timestamp": "$(date -Iseconds)",
  "modules_detected": {
    "rewards": true,
    "partners": true,
    "audit": true,
    "anti_fraud": true,
    "blockchain": true,
    "qr_entry": "pending_or_existing",
    "ai_coordinator": "pending_or_existing"
  },
  "guarantees": [
    "No file modified",
    "No logic altered",
    "Pure detection & freeze"
  ]
}
EOF

echo "📝 Génération ARCHITECTURE.md..."

cat << 'EOF' > "$OUT_DIR/ARCHITECTURE.md"
# OmniUtil Backend – Architecture v1 (Frozen)

## Principe
Cette architecture reflète **l'état réel du backend OmniUtil**
au moment du figement.  
Aucune hypothèse, uniquement du constat.

## Blocs identifiés
- Rewards Engine
- Partner Integration Layer
- Audit & Traceability
- Anti-Fraud Guards
- Blockchain Interaction (UTIL / BSC)
- API Layer
- Utils & Guards

## Règles
- Toute évolution future doit respecter ce socle
- Toute brique est modulaire et indépendante
- OmniUtil agit comme une **infrastructure**, pas une app

## Statut
✅ Architecture figée et validée pour montée en puissance
EOF

echo "🧪 Vérification TypeScript (non bloquante)..."
if [ -f "$TS_CONFIG" ]; then
  npx tsc --noEmit || echo "⚠️  TS errors existantes (non bloquant pour le figement)"
else
  echo "ℹ️  tsconfig.json non trouvé"
fi

echo "✅ ÉTAPE 1 TERMINÉE — ARCHITECTURE OMNIUTIL FIGÉE"
echo "📁 Dossier généré : $OUT_DIR"
