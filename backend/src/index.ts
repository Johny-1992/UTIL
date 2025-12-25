import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import { verifyApiKey } from './middleware/authMiddleware';
import apiRouter from './api/index';
import qrRouter from './api/qr';
import rewardsRouter from './api/rewards/rewards';
import logger from './utils/logger'; // Ajoutez cette ligne

dotenv.config();

const app = express();
const PORT: number = Number(process.env.PORT) || 10000;

// Configuration CORS
app.use(cors({
  origin: ['https://votre-frontend-vercel.vercel.app'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'x-api-key']
}));

// Middleware pour logger les requêtes
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`);
  next();
});

app.use(express.json());

// Route pour la racine
app.get('/', (req, res) => {
  res.send('Bienvenue sur OmniUtil ! Le backend est opérationnel.');
});

// Routes publiques
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// Routes protégées par la clé API
app.use('/api', verifyApiKey, apiRouter);
app.use('/api/qr', verifyApiKey, qrRouter);
app.use('/api/rewards', verifyApiKey, rewardsRouter);

// Démarrer le serveur
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Server running on port ${PORT}`);
  console.log(`Server running on port ${PORT}`);
});

export default app;

