#!/bin/bash

# Mettre à jour le code source
cd ~/omniutil
git pull origin main

# Recompiler le projet
cd ~/omniutil/backend
npm install
npx tsc

# Redémarrer PM2
pm2 restart omniutil-api

echo "Backend mis à jour et redémarré."
