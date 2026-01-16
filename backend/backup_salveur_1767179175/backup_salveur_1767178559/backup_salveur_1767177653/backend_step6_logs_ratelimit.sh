#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step6] Configuration des logs + rate limit pour omniutil backend"

cd "$BACKEND_DIR"
echo "[step6] Dossier backend : $(pwd)"

# === 1) Backup de sécurité de index.ts ===
if [ -f "index.ts" ] && [ ! -f "index.ts.step6.bak" ]; then
  cp index.ts index.ts.step6.bak
  echo "[step6] Backup créé : index.ts.step6.bak"
fi

# === 2) Middleware de LOGS : src/middleware/logger.ts ===
mkdir -p src/middleware

cat <<'EOF_LOG' > src/middleware/logger.ts
import { Request, Response, NextFunction } from 'express';

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  const { method, originalUrl } = req;
  const ip = (req.headers['x-forwarded-for'] as string) || req.ip || req.socket.remoteAddress || '';

  res.on('finish', () => {
    const durationMs = Date.now() - start;
    const { statusCode } = res;

    const logEntry = {
      time: new Date().toISOString(),
      method,
      path: originalUrl,
      statusCode,
      durationMs,
      ip,
      userAgent: req.headers['user-agent'] || '',
    };

    // Log JSON pour être facilement parsable
    console.log(JSON.stringify(logEntry));
  });

  next();
}
EOF_LOG

echo "[step6] Middleware de logs écrit : src/middleware/logger.ts"

# === 3) Middleware de RATE LIMIT : src/middleware/rateLimit.ts ===

cat <<'EOF_RATE' > src/middleware/rateLimit.ts
import { Request, Response, NextFunction } from 'express';

interface RateInfo {
  count: number;
  resetTime: number;
}

const windowMs = Number(process.env.RATE_LIMIT_WINDOW_MS) || 60_000; // 60s par défaut
const maxRequests = Number(process.env.RATE_LIMIT_MAX) || 60;       // 60 req / fenêtre

const buckets = new Map<string, RateInfo>();

function getClientKey(req: Request): string {
  const apiKey = req.header('x-api-key');
  if (apiKey) {
    return `key:${apiKey}`;
  }
  // Fallback par IP si pas de clé (par ex. si un jour on rate-limit des routes publiques)
  return `ip:${req.ip || req.socket.remoteAddress || 'unknown'}`;
}

export function rateLimiter(req: Request, res: Response, next: NextFunction) {
  const key = getClientKey(req);
  const now = Date.now();

  let info = buckets.get(key);
  if (!info || now > info.resetTime) {
    info = {
      count: 0,
      resetTime: now + windowMs,
    };
    buckets.set(key, info);
  }

  info.count += 1;

  if (info.count > maxRequests) {
    const retryAfterSec = Math.ceil((info.resetTime - now) / 1000);
    res.setHeader('Retry-After', retryAfterSec.toString());
    res.setHeader('X-RateLimit-Limit', String(maxRequests));
    res.setHeader('X-RateLimit-Remaining', '0');
    res.setHeader('X-RateLimit-Reset', Math.floor(info.resetTime / 1000).toString());

    return res.status(429).json({
      error: 'Trop de requêtes',
      details: `Limite de ${maxRequests} requêtes par ${windowMs / 1000}s dépassée.`,
    });
  }

  res.setHeader('X-RateLimit-Limit', String(maxRequests));
  res.setHeader('X-RateLimit-Remaining', String(Math.max(0, maxRequests - info.count)));
  res.setHeader('X-RateLimit-Reset', Math.floor(info.resetTime / 1000).toString());

  next();
}
EOF_RATE

echo "[step6] Middleware de rate limit écrit : src/middleware/rateLimit.ts"

# === 4) Ajouter des valeurs par défaut de rate limit dans .env (si absentes) ===

touch .env
if ! grep -q '^RATE_LIMIT_WINDOW_MS=' .env; then
  echo "RATE_LIMIT_WINDOW_MS=60000" >> .env
  echo "[step6] Ajout de RATE_LIMIT_WINDOW_MS=60000 dans .env (fenêtre 60s)"
fi

if ! grep -q '^RATE_LIMIT_MAX=' .env; then
  echo "RATE_LIMIT_MAX=60" >> .env
  echo "[step6] Ajout de RATE_LIMIT_MAX=60 dans .env (60 requêtes / fenêtre)"
fi

# === 5) Réécriture propre de index.ts avec logger + rate limiter ===

cat <<'EOF_INDEX' > index.ts
import 'dotenv/config';
import express, { Request, Response } from 'express';

import partnerValidation from './partner_validation';
import aiRouter from './ai';
import { apiKeyAuth } from './src/middleware/apiKeyAuth';
import { requestLogger } from './src/middleware/logger';
import { rateLimiter } from './src/middleware/rateLimit';

const app = express();

// PORT configuré via .env ou 3000 par défaut
const PORT: number = Number(process.env.PORT) || 3000;

// 🔍 Logger global de toutes les requêtes
app.use(requestLogger);

// Middleware global pour parser le JSON
app.use(express.json());

// ✅ Route de santé publique (pas d'auth, pas de rate limit)
app.get('/health', (_req: Request, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// ⛓️ À partir d'ici : rate limit + auth par clé API
app.use(rateLimiter);
app.use(apiKeyAuth);

// Routes protégées
app.use('/api/partner', partnerValidation);
app.use('/api/ai', aiRouter);

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
EOF_INDEX

echo "[step6] index.ts mis à jour (logger + rate limit + auth)."

# === 6) Compilation + redémarrage PM2 ===

echo "[step6] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step6] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  echo "[step6] Process PM2 '$PM2_NAME' trouvé, redémarrage avec --update-env"
  pm2 restart "$PM2_NAME" --update-env
else
  echo "[step6] Process PM2 '$PM2_NAME' introuvable, démarrage initial sur dist/index.js..."
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step6] Terminé. Vérifications recommandées :"
echo "1) pm2 status"
echo "2) pm2 logs omniutil-api --lines 20"
echo "3) curl http://127.0.0.1:3000/health"
echo "4) Tester le rate limit sur /api/ai/status avec et sans clé API."
echo "   Exemple (avec clé) :"
echo "   API_KEY=\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo "   for i in \$(seq 1 70); do curl -s -o /dev/null -w \"[%{http_code}]\" -H \"x-api-key: \$API_KEY\" http://127.0.0.1:3000/api/ai/status; done"
echo "============================================================"
