#!/bin/bash
# omniutil_oneclick.sh — Lance Omniutil FULL stack en 1 commande

echo "🚀 OMNIUTIL ONE-CLICK LAUNCHER"
echo "================================================="

# 1️⃣ Redémarrage Backend via PM2
echo "🌐 [1/5] Restarting Backend..."
pm2 delete omniutil-api || true
pm2 start /root/omniutil/backend/dist/index.js --name omniutil-api --watch
pm2 save
echo "✅ Backend started via PM2"

# 2️⃣ Vérification API
echo "🔍 [2/5] API health check..."
HEALTH=$(curl -s http://127.0.0.1:3000/health)
if [[ "$HEALTH" == '{"status":"ok"}' ]]; then
    echo "✅ API is healthy"
else
    echo "❌ API check failed: $HEALTH"
fi

# 3️⃣ Lancement Frontend
echo "🖥️ [3/5] Starting Frontend on http://0.0.0.0:8080..."
cd /root/omniutil/frontend/landing
python3 -m http.server 8080 &> /dev/null &
echo "✅ Frontend running"

# 4️⃣ Affichage des logs backend
echo "📜 [4/5] Showing backend logs (PM2)..."
tail -n 20 -f /root/.pm2/logs/omniutil-api-out.log

# 5️⃣ Fin du script
echo "================================================="
echo "🏁 Omniutil FULL stack launched!"
