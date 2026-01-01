import 'dotenv/config';
import express, { Request, Response } from 'express';
import partnerValidation from './partner_validation';
import aiRouter from './ai';
import apiRouter from './api';

const app = express();

// PORT configuré via .env ou 3000 par défaut
const PORT: number = Number(process.env.PORT) || 3000;

// Faire confiance au proxy (Nginx) pour les IP / X-Forwarded-For
app.set('trust proxy', true);

// Middleware global JSON + logger
app.use(express.json());

// Route de santé publique (sans auth, sans rate limit)
app.get('/health', (_req: Request, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// À partir d'ici : rate limit + clé API

// Ancienne logique /api/partner (valideur)
app.use('/api/partner', partnerValidation);

// AI coordonnateur
app.use('/api/ai', aiRouter);

// Nouvelle API métier OMNIUTIL (onboard, reward, util)
app.use('/api', apiRouter);

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
