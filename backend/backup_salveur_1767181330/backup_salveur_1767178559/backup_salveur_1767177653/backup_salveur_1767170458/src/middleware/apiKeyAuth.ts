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
