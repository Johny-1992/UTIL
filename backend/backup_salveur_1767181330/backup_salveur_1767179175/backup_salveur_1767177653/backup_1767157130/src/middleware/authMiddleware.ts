import { Request, Response, NextFunction } from 'express';

export function verifyApiKey(req: Request, res: Response, next: NextFunction) {
  const apiKey = req.headers['x-api-key'];
  console.log("Clé API reçue dans la requête :", apiKey);
  console.log("Clé API attendue :", process.env.API_KEY);

  if (!apiKey || apiKey !== process.env.API_KEY) {
    console.log("Les clés ne correspondent pas.");
    return res.status(401).json({ error: 'Clé API invalide' });
  }
  next();
}
