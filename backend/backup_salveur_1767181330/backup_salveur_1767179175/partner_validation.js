"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const router = (0, express_1.Router)();
// Exemple route
router.get('/onboard', (req, res) => {
    res.json({ message: 'Partner onboard endpoint OK' });
});
exports.default = router;
