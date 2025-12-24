"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// partner_validation.ts
const express_1 = require("express");
const router = (0, express_1.Router)();
router.post('/onboard', (req, res) => {
    const { user_id } = req.body;
    if (!user_id)
        return res.status(400).json({ error: 'user_id manquant' });
    res.json({ message: `Utilisateur ${user_id} onboardé !` });
});
exports.default = router;
