import { Router } from 'express';
export const aiRouter = Router();

aiRouter.get('/status', (req, res) => res.json({ status: 'AI OK' }));
