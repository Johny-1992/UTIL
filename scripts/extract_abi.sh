#!/bin/bash
set -e

echo "🔧 Extraction ABI OmniUtil..."

CONTRACT_NAME="OmniUtil"
HARDHAT_ARTIFACT="artifacts/contracts/${CONTRACT_NAME}.sol/${CONTRACT_NAME}.json"
DEST="../backend/abi/OmniUtilABI.json"

if [ ! -f "$HARDHAT_ARTIFACT" ]; then
  echo "❌ Artifact introuvable. Compile d'abord."
  exit 1
fi

jq '.abi' "$HARDHAT_ARTIFACT" > "$DEST"

echo "✅ ABI extraite vers backend/abi/OmniUtilABI.json"
