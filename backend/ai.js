"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const fraud_detection_1 = require("./fraud_detection");
const sync_chain_1 = require("./services/sync_chain");
const qr_service_1 = require("./services/qr_service");
const router = (0, express_1.Router)();
// Endpoint principal sur /api/ai
router.get('/', (_req, res) => {
    res.json({ status: 'AI endpoint OK', route: '/api/ai' });
});
// Endpoint santé AI
router.get('/status', (_req, res) => {
    res.json({ status: 'AI endpoint OK', route: '/api/ai/status' });
});
// Analyse d'un évènement d'usage
router.post('/analyze/usage', (req, res) => {
    const event = req.body;
    try {
        const analysis = (0, fraud_detection_1.analyzeUsage)(event);
        return res.json({ event, analysis });
    }
    catch (err) {
        console.error('Erreur /analyze/usage:', err);
        return res.status(500).json({ error: 'Erreur interne analyse usage' });
    }
});
// Analyse d'un profil partenaire simple
router.post('/analyze/partner', (req, res) => {
    const profile = req.body;
    try {
        const analysis = (0, fraud_detection_1.analyzePartner)(profile);
        return res.json({ profile, analysis });
    }
    catch (err) {
        console.error('Erreur /analyze/partner:', err);
        return res.status(500).json({ error: 'Erreur interne analyse partenaire' });
    }
});
// Onboarding partenaire coordonné par AI
router.post('/onboard/partner', (req, res) => {
    const proposal = req.body;
    try {
        const result = (0, fraud_detection_1.evaluateOnboardPartner)(proposal);
        if (result.decision === 'auto_accept') {
            const onchainDemo = (0, sync_chain_1.registerPartnerDemo)(result.proposal, result.analysis);
            return res.json({
                ...result,
                onchainDemo,
            });
        }
        return res.json(result);
    }
    catch (err) {
        console.error('Erreur /onboard/partner:', err);
        return res.status(500).json({ error: 'Erreur interne onboarding partenaire' });
    }
});
// QR encode (contexte campagne/partenaire/utilisateur)
router.post('/qr/encode', (req, res) => {
    const context = req.body;
    try {
        const encoded = (0, qr_service_1.encodeContext)(context);
        return res.json({ context, encoded });
    }
    catch (err) {
        console.error('Erreur /qr/encode:', err);
        return res.status(500).json({ error: 'Erreur interne QR encode' });
    }
});
// QR decode
router.post('/qr/decode', (req, res) => {
    const { encoded } = req.body;
    try {
        const decoded = (0, qr_service_1.decodeContext)(encoded);
        return res.json({ encoded, decoded });
    }
    catch (err) {
        console.error('Erreur /qr/decode:', err);
        return res.status(500).json({ error: 'Erreur interne QR decode' });
    }
});
// Sync reward DEMO : applique 98% + 2% royalties créateur dans le ledger JSON
router.post('/sync/reward', (req, res) => {
    const { userId, partnerId, utilAmount } = req.body;
    if (typeof userId !== 'string' ||
        typeof partnerId !== 'string' ||
        typeof utilAmount !== 'number') {
        return res.status(400).json({
            error: 'Paramètres invalides',
            details: 'userId, partnerId doivent être des chaînes, utilAmount un nombre.',
        });
    }
    try {
        const result = (0, sync_chain_1.syncRewardDemo)({ userId, partnerId, utilAmount });
        return res.json(result);
    }
    catch (err) {
        console.error('Erreur /sync/reward:', err);
        return res.status(500).json({ error: 'Erreur interne sync reward DEMO' });
    }
});
exports.default = router;
