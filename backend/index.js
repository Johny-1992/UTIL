// backend/index.js
import "dotenv/config";
import express from 'express';

// Import des modules internes (ES Module)
import partnerValidation from './partner_validation.js';
import ai from './ai.js';
import api from './api/index.js';  // pointe explicitement vers index.js dans le dossier api

import { apiKeyAuth } from './src/middleware/apiKeyAuth.js';
import { requestLogger } from './src/middleware/logger.js';
import { rateLimiter } from './src/middleware/rateLimit.js';

const app = express();

// PORT configuré via .env ou 3000 par défaut
const PORT = Number(process.env.PORT) || 3000;

// Faire confiance au proxy (Nginx) pour les IP / X-Forwarded-For
app.set('trust proxy', true);

// Middleware global JSON + logger
app.use(express.json());
app.use(requestLogger);

// Route de santé publique (sans auth, sans rate limit)
app.get('/health', (_req, res) => {
    return res.status(200).json({ status: 'ok' });
});

// À partir d'ici : rate limit + clé API
app.use(rateLimiter);
app.use(apiKeyAuth);

// Ancienne logique /api/partner (valideur)
app.use('/api/partner', partnerValidation);

// AI coordonnateur
app.use('/api/ai', ai);

// Nouvelle API métier OMNIUTIL (onboard, reward, util)
app.use('/api', api);

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});

export default app;
