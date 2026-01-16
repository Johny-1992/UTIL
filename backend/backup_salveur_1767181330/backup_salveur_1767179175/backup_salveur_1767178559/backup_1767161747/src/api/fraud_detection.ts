import { Router } from 'express';
const router = Router();

router.post('/test', (req, res) => {
  const { test } = req.body;
  if (!test) return res.status(400).json({ error: 'Paramètre manquant' });
  res.json({ message: `Test IA reçu : ${test}` });
});

export default router;
