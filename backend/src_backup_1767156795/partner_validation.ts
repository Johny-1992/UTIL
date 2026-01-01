import { Router } from 'express';
const router = Router();

// Exemple route
router.get('/onboard', (req, res) => {
  res.json({ message: 'Partner onboard endpoint OK' });
});

export default router;
