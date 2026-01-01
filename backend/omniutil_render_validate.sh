#!/usr/bin/env bash
set -e

RENDER_URL="https://omniutil.onrender.com"

echo "🚀 OmniUtil — Validation Render PROD"

curl -fs "$RENDER_URL/health" && echo " ✅ Render backend UP"

curl -fs "$RENDER_URL/api/ai/status" \
  -H "x-api-key: $(grep API_KEY backend/.env | cut -d= -f2-)" \
  && echo " ✅ AI OK"

echo "🎉 Render VALIDÉ"
