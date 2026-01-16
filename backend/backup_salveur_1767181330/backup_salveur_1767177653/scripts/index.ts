import express from 'express';
import bodyParser from 'body-parser';
import { partnerValidation } from './api/partner_validation';
import { aiRouter } from './api/ai';

const app = express();
app.use(bodyParser.json());

// ✅ Route /health si manquante
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// ✅ Routes API
app.use('/api/partner', partnerValidation);
app.use('/api/ai', aiRouter);

// Lancer le serveur sur le port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

export default app;
