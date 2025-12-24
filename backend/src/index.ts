import express from 'express';
import dotenv from 'dotenv';
import { verifyApiKey } from './middleware/authMiddleware';
import apiRouter from './api/index';
import qrRouter from './api/qr';
import rewardsRouter from './api/rewards/rewards';

dotenv.config();

console.log("Clé API chargée depuis .env :", process.env.API_KEY);

const app = express();
const PORT: number = Number(process.env.PORT) || 3000;

app.use(express.json());

// Routes publiques
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// Routes protégées par la clé API
app.use('/api', verifyApiKey, apiRouter); // Utiliser le routeur principal pour /api/partner et /api/ai
app.use('/api/qr', verifyApiKey, qrRouter); // Route pour les QR codes
app.use('/api/rewards', verifyApiKey, rewardsRouter); // Route pour les récompenses

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;

