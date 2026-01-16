#!/bin/bash
# ============================================
# OmniUtil – Arrache la lune 🚀
# Test et interaction API backend + étapes B → C
# ============================================

BASE_URL="http://localhost:8080"
LOG_FILE="moon_runner.log"

echo "🌙 Arrache‑la‑lune – démarrage..." | tee -a $LOG_FILE

# 1️⃣ Vérifier si backend est actif
curl --silent --max-time 5 "$BASE_URL/health" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠ Backend non trouvé, lancement automatique…" | tee -a $LOG_FILE
    ./start_all_live.sh
    sleep 5
else
    echo "✅ Backend actif sur $BASE_URL" | tee -a $LOG_FILE
fi

# 2️⃣ Tester /api/partner
echo "🔹 Test API Partner…" | tee -a $LOG_FILE
PARTNER_RESP=$(curl --silent -X GET "$BASE_URL/api/partner?test=true")
echo "$PARTNER_RESP" | tee -a $LOG_FILE

# 3️⃣ Tester /api/ai
echo "🔹 Test API AI…" | tee -a $LOG_FILE
AI_RESP=$(curl --silent -X POST "$BASE_URL/api/ai" -H "Content-Type: application/json" -d '{"prompt":"test"}')
echo "$AI_RESP" | tee -a $LOG_FILE

# 4️⃣ Tester /api/util (étape B → C)
echo "🔹 Test API Util (simulé)…" | tee -a $LOG_FILE
UTIL_RESP=$(curl --silent -X POST "$BASE_URL/api/util" -H "Content-Type: application/json" -d '{"action":"simulate","step":"B_to_C"}')
echo "$UTIL_RESP" | tee -a $LOG_FILE

# 5️⃣ Résumé
echo "🌕 Arrache‑la‑lune terminé. Logs disponibles dans $LOG_FILE" | tee -a $LOG_FILE
