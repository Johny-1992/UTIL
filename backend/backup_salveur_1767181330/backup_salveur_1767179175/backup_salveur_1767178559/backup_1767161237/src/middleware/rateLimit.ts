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
