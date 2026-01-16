"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const partner_onboard_1 = require("./partner.onboard");
const reward_compute_1 = require("./reward.compute");
const util_exchange_1 = require("./util.exchange");
const router = (0, express_1.Router)();
// POST /api/partner/onboard
router.post('/partner/onboard', (req, res) => {
    const partner = req.body;
    try {
        const result = (0, partner_onboard_1.onboardPartner)(partner);
        return res.json(result);
    }
    catch (err) {
        console.error('Erreur dans onboardPartner:', err);
        return res.status(500).json({
            error: 'Erreur interne lors de l’onboarding partenaire',
        });
    }
});
// POST /api/reward/compute
router.post('/reward/compute', (req, res) => {
    const { usage, rate } = req.body;
    if (typeof usage !== 'number' || typeof rate !== 'number') {
        return res.status(400).json({
            error: 'Paramètres invalides',
            details: 'usage et rate doivent être des nombres',
        });
    }
    try {
        const util = (0, reward_compute_1.computeUTIL)(usage, rate);
        return res.json({ usage, rate, util });
    }
    catch (err) {
        console.error('Erreur dans computeUTIL:', err);
        return res.status(500).json({
            error: 'Erreur interne lors du calcul UTIL',
        });
    }
});
// POST /api/util/exchange
router.post('/util/exchange', (req, res) => {
    const { user, service, amount } = req.body;
    if (typeof user !== 'string' || typeof service !== 'string' || typeof amount !== 'number') {
        return res.status(400).json({
            error: 'Paramètres invalides',
            details: 'user et service doivent être des chaînes, amount un nombre',
        });
    }
    try {
        const result = (0, util_exchange_1.exchangeUTIL)(user, service, amount);
        return res.json(result);
    }
    catch (err) {
        console.error('Erreur dans exchangeUTIL:', err);
        return res.status(500).json({
            error: 'Erreur interne lors de l’échange UTIL',
        });
    }
});
exports.default = router;
