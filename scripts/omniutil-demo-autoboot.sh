#!/bin/bash
echo "================================="
echo "🌍 OMNIUTIL – DEMO = LIVE AUTOBOOT"
echo "================================="

export MODE=DEMO
mkdir -p logs

echo "🔗 Backend..."
cd backend
nohup node server.js > ../logs/backend.log 2>&1 &
echo $! > ../logs/backend.pid
cd ..

echo "🧠 Orchestrateur C++..."
cd orchestrator
g++ omni_orchestrator.cpp -o omni_orchestrator
nohup ./omni_orchestrator > ../logs/orchestrator.log 2>&1 &
echo $! > ../logs/orchestrator.pid
cd ..

echo "🌐 Frontend prêt (build existant)"
echo "✅ OMNIUTIL DEMO LIVE OPÉRATIONNEL"
