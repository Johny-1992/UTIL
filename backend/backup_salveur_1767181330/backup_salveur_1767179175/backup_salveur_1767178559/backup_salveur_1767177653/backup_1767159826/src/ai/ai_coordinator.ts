import { Router } from 'express';
const router = Router();

// Endpoint test AI Coordinator
router.get('/ai/status', (req, res) => {
    res.json({ status: 'AI Coordinator operational', timestamp: new Date() });
});

// TODO: Ajouter la logique AI centrale ici
export default router;
