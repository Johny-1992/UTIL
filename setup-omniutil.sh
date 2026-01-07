#!/bin/bash
# ==========================================
# OmniUtil Full Production Setup
# Frontend + Backend + PM2 + HTTPS tunnel
# ==========================================

echo "🚀 Début de la configuration OmniUtil..."

# -----------------------------
# Variables
# -----------------------------
FRONTEND_DIR="/root/omniutil/frontend"
BACKEND_DIR="/root/omniutil/backend"
BACKEND_PORT=8080
FRONTEND_PORT=4000

# -----------------------------
# Backend Setup (PM2)
# -----------------------------
echo "💻 Lancement du Backend..."
cd $BACKEND_DIR

# Installer dépendances si nécessaire
npm install

# Compiler TypeScript
rm -rf dist
npx tsc

# PM2 restart
pm2 delete omniutil-api 2>/dev/null
pm2 start dist/index.js --name omniutil-api
pm2 save

echo "✅ Backend lancé sur localhost:$BACKEND_PORT"

# -----------------------------
# Frontend Setup (PM2)
# -----------------------------
echo "🌐 Lancement du Frontend..."
cd $FRONTEND_DIR

# Installer serve si nécessaire
npm install -g serve

# PM2 restart frontend
pm2 delete omniutil-frontend 2>/dev/null
pm2 start "serve -s build -l $FRONTEND_PORT" --name omniutil-frontend
pm2 save

echo "✅ Frontend lancé sur localhost:$FRONTEND_PORT"

# -----------------------------
# Tunnel HTTPS pour Backend
# -----------------------------
echo "🔐 Configuration tunnel HTTPS pour le backend..."
npm install -g ngrok
NGROK_URL=$(ngrok http $BACKEND_PORT --log=stdout & sleep 5 && curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

echo "🔗 Backend public disponible sur : $NGROK_URL"

# -----------------------------
# SEO et Sitemap (Frontend)
# -----------------------------
echo "📝 Vérification SEO Frontend..."
FRONTEND_INDEX="$FRONTEND_DIR/build/index.html"

if [ -f "$FRONTEND_INDEX" ]; then
    sed -i 's|<title>.*</title>|<title>OmniUtil - Gestion crypto & NFT</title>|' $FRONTEND_INDEX
    sed -i '/<head>/a <meta name="description" content="OmniUtil: Plateforme crypto, NFT, audits et outils blockchain.">\n<meta name="robots" content="index, follow">\n<meta property="og:title" content="OmniUtil"/>\n<meta property="og:description" content="Plateforme crypto et NFT complète"/>\n<meta property="og:url" content="https://omniutil.vercel.app"/>\n<meta property="og:type" content="website"/>' $FRONTEND_INDEX
    echo "✅ SEO tags injectés"
else
    echo "⚠️ Fichier index.html introuvable, SEO non appliqué"
fi

# -----------------------------
# PM2 Status
# -----------------------------
pm2 status

echo "🎉 OmniUtil est maintenant opérationnel !"
echo "Frontend: http://localhost:$FRONTEND_PORT"
echo "Backend (public HTTPS tunnel): $NGROK_URL"
echo "Utilisez ces URLs dans votre navigateur ou pour connecter le frontend au backend."
