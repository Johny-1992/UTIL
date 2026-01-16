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
