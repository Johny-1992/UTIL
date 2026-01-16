import { Router } from 'express';
export const partnerValidation = Router();

partnerValidation.post('/onboard', (req, res) => res.json({ status: 'Partner onboarded' }));
