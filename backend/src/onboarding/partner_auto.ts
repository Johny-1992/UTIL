import { Router } from 'express';
import { generateOmniutilQR } from '../qr/omniutil_qr.js';

const router = Router();

router.post('/onboard', async (req, res) => {
    const { partner_id } = req.body;
    if (!partner_id) return res.status(400).json({ error: 'partner_id manquant' });

    const qr = await generateOmniutilQR(); 

        res.json({
        message: `Partenaire ${partner_id} onboardé avec succès!`,
        qr
    });
});

export default router;
