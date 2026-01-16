#!/bin/bash

echo "🚀 Déploiement frontend OmniUtil – CRA"

# Nettoyage
rm -rf .vercel build node_modules
echo "🧹 Nettoyage terminé."

# Installation
npm install
echo "📦 Dépendances installées."

# Build
npm run build
echo "🎨 Build terminé."

# Déploiement sur Vercel (production)
vercel --prod --confirm
echo "🌍 Déploiement terminé."
