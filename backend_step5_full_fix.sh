#!/usr/bin/env bash
set -euo pipefail

# === CONFIG GLOBALE ===
BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step5] Démarrage du correcteur complet backend (API key + build + PM2)"

if ! command -v pm2 >/dev/null 2>&1; then
  echo "[step5] ERREUR : pm2 n'est pas installé dans cet environnement."
  echo "        Installe-le d'abord avec : npm install -g pm2"
  exit 1
fi

cd "$BACKEND_DIR"
echo "[step5] Dossier backend : $(pwd)"

# === 1) Backups de sécurité ===
for f in tsconfig.json index.ts; do
  if [ -f "$f" ] && [ ! -f "$f.bak" ]; then
    cp "$f" "$f.bak"
    echo "[step5] Backup créé : $f.bak"
  fi
done

# === 2) tsconfig.json propre ===
cat <<'EOF_TS' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": ".",
    "outDir": "dist",
    "strict": true,
    "esModuleInterop": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "skipLibCheck": true
  },
  "include": [
    "**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "scripts"
  ]
}
EOF_TS
echo "[step5] tsconfig.json mis à jour (build vers dist/, scripts/ exclus)."

# === 3) Gestion / création de la clé API dans .env ===
touch .env

API_KEY_VALUE="${API_KEY:-}"

if [ -z "$API_KEY_VALUE" ]; then
  read -r -p "[step5] Entrez la clé API à utiliser (laisser vide pour génération auto) : " API_KEY_VALUE || true
fi

if [ -z "$API_KEY_VALUE" ]; then
  echo "[step5] Aucune clé saisie, génération automatique..."
  if command -v openssl >/dev/null 2>&1; then
    API_KEY_VALUE="$(openssl rand -hex 32)"
  else
    API_KEY_VALUE="omniutil_$(date +%s)_$RANDOM"
  fi
  echo "[step5] Clé API générée automatiquement."
else
  echo "[step5] Clé API fournie par l'utilisateur ou via la variable d'environnement."
fi

tmpfile="$(mktemp)"
grep -v '^API_KEY=' .env > "$tmpfile" || true
printf 'API_KEY=%s\n' "$API_KEY_VALUE" >> "$tmpfile"
mv "$tmpfile" .env

echo "[step5] Clé API enregistrée dans .env :"
grep '^API_KEY=' .env || true
echo "[step5] Garde cette clé en lieu sûr, elle sera nécessaire côté client."

# === 4) Middleware d'authentification par clé API ===
mkdir -p src/middleware

cat <<'EOF_MW' > src/middleware/apiKeyAuth.ts
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
  const queryKey =
    typeof req.query.api_key === 'string' ? req.query.api_key : undefined;

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
EOF_MW

echo "[step5] Middleware src/middleware/apiKeyAuth.ts écrit."

# === 5) index.ts propre (API + /health public + auth globale) ===
cat <<'EOF_IDX' > index.ts
import 'dotenv/config';
import express, { Request, Response } from 'express';

import partnerValidation from './partner_validation';
import aiRouter from './ai';
import { apiKeyAuth } from './src/middleware/apiKeyAuth';

const app = express();

// PORT configuré via .env ou 3000 par défaut
const PORT: number = Number(process.env.PORT) || 3000;

// Middleware global pour parser le JSON
app.use(express.json());

// ✅ Route de santé publique (pas d'auth par clé ici)
app.get('/health', (_req: Request, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// 🔐 À partir d'ici, toutes les routes nécessitent la clé API
app.use(apiKeyAuth);

// Routes protégées
app.use('/api/partner', partnerValidation);
app.use('/api/ai', aiRouter);

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
EOF_IDX

echo "[step5] index.ts réécrit avec /health public + auth globale par clé."

# === 6) Compilation TypeScript ===
echo "[step5] Compilation TypeScript (npx tsc)..."
npx tsc
echo "[step5] Compilation OK."

# === 7) PM2 : lancement / redémarrage ===
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  echo "[step5] Process PM2 '$PM2_NAME' trouvé, redémarrage avec --update-env..."
  pm2 restart "$PM2_NAME" --update-env
else
  echo "[step5] Process PM2 '$PM2_NAME' introuvable, démarrage initial sur dist/index.js..."
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step5] Terminé."
echo "Vérifications recommandées :"
echo "  1) pm2 status"
echo "  2) pm2 logs $PM2_NAME --lines 30"
echo "  3) curl http://127.0.0.1:3000/health"
echo "     -> doit répondre : {\"status\":\"ok\"}"
echo "  4) curl -H 'x-api-key: <ta_clé_api>' http://127.0.0.1:3000/api/ai"
echo "     -> la route doit répondre (ou au moins ne plus renvoyer 401 sans clé)."
echo "============================================================"
