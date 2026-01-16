import { Router } from 'express';
import { evaluatePartnershipRequest } from '../services/aiCoordinatorService';

const router = Router();

router.post('/request', async (req, res) => {
  try {
    const { ecosystemId } = req.body;
    if (!ecosystemId) {
      return res.status(400).json({ error: "Ecosystem ID is required" });
    }

    const result = await evaluatePartnershipRequest(ecosystemId);
    res.status(200).json(result);
  } catch (err) {
    console.error("Error processing partnership request:", err);
    res.status(500).json({ error: "Failed to process partnership request" });
  }
});

export default router;

