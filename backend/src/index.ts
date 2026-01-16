import 'dotenv/config';
import express, { Request, Response } from 'express';
import helmet from 'helmet';
import partnerValidation from './partner_validation.js';
import aiRouter from './ai.js';
import apiRouter from './api/index.js';

const app = express();
const PORT: number = Number(process.env.PORT) || 8080;

app.set('trust proxy', true);
app.use(express.json());
app.use(helmet());

// Route racine redirige vers le frontend
app.get('/', (_req: Request, res: Response) => {
  res.redirect('http://localhost:8081/index.html');
});

// Route santé
app.get('/health', (_req: Request, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// APIs
app.use('/api/partner', partnerValidation);
app.use('/api/ai', aiRouter);
app.use('/api', apiRouter);

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
