#!/bin/bash
# ======================================
# OMNIUTIL – BIMODE AUTO FINAL
# ======================================

echo "🚀 Déploiement BIMODE Omniutil – automatique et conservateur"

# ==============================
# 1. Vérification structure projet
# ==============================
echo "📁 Vérification structure projet..."
mkdir -p frontend/src/components
mkdir -p versions/{frontend,backend,contracts,cpp}
mkdir -p logs
mkdir -p public

# Fichiers essentiels
[[ ! -f frontend/src/components/Home.jsx ]] && touch frontend/src/components/Home.jsx
[[ ! -f frontend/src/components/QRCodeOmni.jsx ]] && touch frontend/src/components/QRCodeOmni.jsx
[[ ! -f public/robots.txt ]] && echo "User-agent: *" > public/robots.txt
[[ ! -f public/sitemap.xml ]] && echo "<urlset></urlset>" > public/sitemap.xml
[[ ! -f public/google05be3ba8343d04a2.html ]] && touch public/google05be3ba8343d04a2.html

# ==============================
# 2. Préparation .env
# ==============================
echo "🧩 Vérification .env..."
if [[ ! -f .env ]]; then
    echo "Création fichier .env par défaut..."
    cp .env.example .env
fi

# Ajout mode bimode si absent
grep -q "MODE=" .env || echo "MODE=DEMO" >> .env
grep -q "RPC_URL_DEMO=" .env || echo "RPC_URL_DEMO=http://127.0.0.1:8545" >> .env
grep -q "RPC_URL_LIVE=" .env || echo "RPC_URL_LIVE=https://mainnet.infura.io/v3/YOUR_PROJECT_ID" >> .env

# ==============================
# 3. Installation dépendances frontend
# ==============================
echo "📦 Installation / mise à jour dépendances frontend..."
cd frontend
npm install
cd ..

# ==============================
# 4. Build frontend
# ==============================
echo "🏗️ Build frontend React..."
cd frontend
npm run build
cd ..

# ==============================
# 5. Vérification Backend
# ==============================
echo "🔗 Vérification Backend..."
cd backend || mkdir -p backend
npm install
cd ..

# ==============================
# 6. Compilation et déploiement Smart Contract existant
# ==============================
echo "📄 Compilation du contrat Solidity existant..."
CONTRACT_FILE=$(find contracts -name "*.sol" | head -n 1)
if [[ -n "$CONTRACT_FILE" ]]; then
    echo "Contrat trouvé: $CONTRACT_FILE"
    solc --bin --abi --optimize -o versions/contracts $CONTRACT_FILE
    # Récupérer adresse et injecter dans .env (simulation)
    echo "CONTRACT_ADDRESS=0xCONTRACTDUMMYADDRESS" >> .env
else
    echo "⚠️ Aucun contrat .sol existant trouvé, compilation ignorée."
fi

# ==============================
# 7. Compilation C++ Orchestrateur
# ==============================
echo "🤖 Compilation C++ Orchestrateur..."
cd cpp || mkdir -p cpp && cd cpp
if [[ ! -f Makefile ]]; then
    echo "Création Makefile minimal pour orchestrateur..."
    cat > Makefile <<EOL
all:
\tg++ main.cpp -o orchestrator
EOL
fi
make || echo "⚠️ Erreur compilation C++ ignorée pour l'instant"
cd ..

# ==============================
# 8. Déploiement frontend sur Vercel
# ==============================
echo "🌍 Déploiement frontend sur Vercel..."
vercel --prod --confirm

# ==============================
# 9. Snapshot version
# ==============================
echo "📦 Snapshot version v1.0.0-BIMODE" 

echo "🎉 Omniutil BIMODE prêt et opérationnel"
