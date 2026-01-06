import { Router, Request, Response } from 'express';
import { onboardPartner } from './partner.onboard.js';
import { computeUTIL } from './reward.compute.js';
import { exchangeUTIL } from './util.exchange.js';

const router = Router();

// POST /api/partner/onboard
router.post('/partner/onboard', (req: Request, res: Response) => {
  const partner = req.body;
  try {
    const result = onboardPartner(partner);
    return res.json(result);
  } catch (err) {
    console.error('Erreur dans onboardPartner:', err);
    return res.status(500).json({
      error: 'Erreur interne lors de l’onboarding partenaire',
    });
  }
});

// POST /api/reward/compute
router.post('/reward/compute', (req: Request, res: Response) => {
  const { usage, rate } = req.body;

  if (typeof usage !== 'number' || typeof rate !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'usage et rate doivent être des nombres',
    });
  }

  try {
    const util = computeUTIL(usage, rate);
    return res.json({ usage, rate, util });
  } catch (err) {
    console.error('Erreur dans computeUTIL:', err);
    return res.status(500).json({
      error: 'Erreur interne lors du calcul UTIL',
    });
  }
});

// POST /api/util/exchange
router.post('/util/exchange', (req: Request, res: Response) => {
  const { user, service, amount } = req.body;

  if (typeof user !== 'string' || typeof service !== 'string' || typeof amount !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'user et service doivent être des chaînes, amount un nombre',
    });
  }

  try {
    const result = exchangeUTIL(user, service, amount);
    return res.json(result);
  } catch (err) {
    console.error('Erreur dans exchangeUTIL:', err);
    return res.status(500).json({
      error: 'Erreur interne lors de l’échange UTIL',
    });
  }
});

export default router;
