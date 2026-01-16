#!/bin/bash
echo "🚀 Upgrade Backend"
cd /root/omniutil/backend || exit

# Installer les dépendances
npm install

# Test simple du serveur
echo "✅ Backend prêt (à vérifier sur https://omniutil.onrender.com)"
