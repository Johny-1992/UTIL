#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step5] Configuration de l'authentification par clé API"
cd "$BACKEND_DIR"

# --- 1) Définir / récupérer la clé API ---
# Tu peux lancer le script comme :
#   API_KEY="ma_cle_super_secrete" ./backend_step5_api_key.sh

API_KEY="${API_KEY:-}"

if [ -z "$API_KEY" ]; then
  echo "[step5] Aucune variable API_KEY fournie."
  read -r -p "Entrez la clé API à utiliser (laisser vide pour générer automatiquement) : " API_KEY || true
fi

if [ -z "$API_KEY" ]; then
  echo "[step5] Génération automatique d'une clé API aléatoire..."
  if command -v openssl >/dev/null 2>&1; then
    API_KEY="$(openssl rand -hex 32)"
  else
    # fallback simple si openssl n'est pas dispo
    API_KEY="omniutil_$(date +%s)_$RANDOM"
  fi
  echo "[step5] Clé API générée automatiquement."
fi

touch .env

if grep -q '^API_KEY=' .env; then
  echo "[step5] Mise à jour de API_KEY dans .env"
  sed -i "s/^API_KEY=.*/API_KEY=${API_KEY}/" .env
else
  echo "[step5] Ajout de API_KEY dans .env"
  echo "API_KEY=${API_KEY}" >> .env
fi

echo "[step5] Clé API enregistrée dans .env"
echo "[step5] Tu peux la revoir avec : grep '^API_KEY' .env"
echo "[step5] ATTENTION : garde cette clé secrète."

# --- 2) Créer le middleware TypeScript ---
mkdir -p src/middleware
MIDDLEWARE_FILE="src/middleware/apiKeyAuth.ts"

echo "[step5] (Ré)écriture du middleware $MIDDLEWARE_FILE"

cat <<'EOF_TS' > "$MIDDLEWARE_FILE"
import { Request, Response, NextFunction } from 'express';

const API_KEY_HEADER = 'x-api-key';

export function apiKeyAuth(req: Request, res: Response, next: NextFunction) {
  const configuredKey = process.env.API_KEY;

  if (!configuredKey) {
    console.error('API_KEY non définie dans les variables d’environnement');
    return res.status(500).json({
      error: 'API mal configurée (clé serveur manquante)',
    });
  }

  // 1) Clé dans le header x-api-key
  const headerKey = req.header(API_KEY_HEADER);

  // 2) Optionnel : autoriser aussi ?api_key=... pour faciliter certains tests
  const queryKey = typeof req.query.api_key === 'string' ? req.query.api_key : undefined;

  const providedKey = headerKey || queryKey;

  if (!providedKey) {
    return res.status(401).json({
      error: 'Clé API manquante',
      details: `Fournis la clé via le header '${API_KEY_HEADER}' ou le paramètre de requête 'api_key'.`,
    });
  }

  if (providedKey !== configuredKey) {
    return res.status(401).json({
      error: 'Clé API invalide',
    });
  }

  // OK, on laisse passer
  return next();
}
EOF_TS

# --- 3) Compilation + redémarrage PM2 ---
echo "[step5] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step5] (Re)lancement de l'API avec PM2..."

if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  echo "[step5] Process PM2 '$PM2_NAME' trouvé, redémarrage avec --update-env"
  pm2 restart "$PM2_NAME" --update-env
else
  echo "[step5] Process PM2 '$PM2_NAME' introuvable, démarrage initial"
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step5] PARTIE MANUELLE À FAIRE UNE FOIS dans src/index.ts :"
cat <<'EOF_MSG'
1) En haut de src/index.ts, vérifier/ajouter :
   import 'dotenv/config';
   import { apiKeyAuth } from './middleware/apiKeyAuth';

2) Laisser /health accessible SANS auth, par exemple :
   app.get('/health', (_req, res) => {
     res.json({ status: 'ok' });
   });

3) Juste APRÈS la route /health, activer l'auth globale :
   app.use(apiKeyAuth);

4) Tes autres routes (ex : /hello, /tasks, etc.) seront alors protégées automatiquement.
EOF_MSG

echo "============================================================"
echo "[step5] Terminé côté script. Maintenant :"
echo " - Modifie src/index.ts comme indiqué ci-dessus."
echo " - Si tu modifies index.ts ensuite, pense à relancer :"
echo "     cd $BACKEND_DIR"
echo "     npx tsc"
echo "     pm2 restart $PM2_NAME --update-env"
echo "============================================================"
