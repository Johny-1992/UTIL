import { Router } from 'express';
import { generateOmniutilQR } from '../qr/omniutil_qr';

const router = Router();

router.get('/generate-omniutil-qr', async (req, res) => {
  try {
    const qrCode = await generateOmniutilQR();
    if (!qrCode) {
      return res.status(500).json({ error: "Failed to generate QR code" });
    }
    res.status(200).json({ qrCode });
  } catch (err) {
    res.status(500).json({ error: "Failed to generate QR code" });
  }
});

export default router;
