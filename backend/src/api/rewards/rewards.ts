import { Router } from 'express';
import { calculateRewards, transferUtil, convertToUSDT } from '../../services/rewardsService';

const router = Router();

// Calcul des récompenses
router.post('/calculate', async (req, res) => {
  try {
    const { partnerId, userId, amountSpent, currency, utilPrice } = req.body;
    const result = await calculateRewards(partnerId, userId, amountSpent, currency, utilPrice);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Transfert d'UTIL
router.post('/transfer', async (req, res) => {
  try {
    const { fromUserId, toUserId, amount } = req.body;
    const result = await transferUtil(fromUserId, toUserId, amount);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Conversion UTIL → USDT
router.post('/convert', async (req, res) => {
  try {
    const { userId, amount } = req.body;
    const result = await convertToUSDT(userId, amount);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
