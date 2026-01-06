import { Router, Request, Response } from 'express';
import {
  analyzeUsage,
  analyzePartner,
  evaluateOnboardPartner,
} from './fraud_detection.js';
import { syncRewardDemo, registerPartnerDemo } from './services/sync_chain.js';
import { encodeContext, decodeContext } from './services/qr_service.js';

const router = Router();

// Endpoint principal sur /api/ai
router.get('/', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai' });
});

// Endpoint santé AI
router.get('/status', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai/status' });
});

// Analyse d'un évènement d'usage
router.post('/analyze/usage', (req: Request, res: Response) => {
  const event = req.body;
  try {
    const analysis = analyzeUsage(event);
    return res.json({ event, analysis });
  } catch (err) {
    console.error('Erreur /analyze/usage:', err);
    return res.status(500).json({ error: 'Erreur interne analyse usage' });
  }
});

// Analyse d'un profil partenaire simple
router.post('/analyze/partner', (req: Request, res: Response) => {
  const profile = req.body;
  try {
    const analysis = analyzePartner(profile);
    return res.json({ profile, analysis });
  } catch (err) {
    console.error('Erreur /analyze/partner:', err);
    return res.status(500).json({ error: 'Erreur interne analyse partenaire' });
  }
});

// Onboarding partenaire coordonné par AI
router.post('/onboard/partner', (req: Request, res: Response) => {
  const proposal = req.body;
  try {
    const result: any = evaluateOnboardPartner(proposal);

    if (result.decision === 'auto_accept') {
      const onchainDemo = registerPartnerDemo(result.proposal, result.analysis);
      return res.json({
        ...result,
        onchainDemo,
      });
    }

    return res.json(result);
  } catch (err) {
    console.error('Erreur /onboard/partner:', err);
    return res.status(500).json({ error: 'Erreur interne onboarding partenaire' });
  }
});

// QR encode (contexte campagne/partenaire/utilisateur)
router.post('/qr/encode', (req: Request, res: Response) => {
  const context = req.body;
  try {
    const encoded = encodeContext(context);
    return res.json({ context, encoded });
  } catch (err) {
    console.error('Erreur /qr/encode:', err);
    return res.status(500).json({ error: 'Erreur interne QR encode' });
  }
});

// QR decode
router.post('/qr/decode', (req: Request, res: Response) => {
  const { encoded } = req.body;
  try {
    const decoded = decodeContext(encoded);
    return res.json({ encoded, decoded });
  } catch (err) {
    console.error('Erreur /qr/decode:', err);
    return res.status(500).json({ error: 'Erreur interne QR decode' });
  }
});

// Sync reward DEMO : applique 98% + 2% royalties créateur dans le ledger JSON
router.post('/sync/reward', (req: Request, res: Response) => {
  const { userId, partnerId, utilAmount } = req.body;
  if (
    typeof userId !== 'string' ||
    typeof partnerId !== 'string' ||
    typeof utilAmount !== 'number'
  ) {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'userId, partnerId doivent être des chaînes, utilAmount un nombre.',
    });
  }

  try {
    const result = syncRewardDemo({ userId, partnerId, utilAmount });
    return res.json(result);
  } catch (err) {
    console.error('Erreur /sync/reward:', err);
    return res.status(500).json({ error: 'Erreur interne sync reward DEMO' });
  }
});

export default router;
