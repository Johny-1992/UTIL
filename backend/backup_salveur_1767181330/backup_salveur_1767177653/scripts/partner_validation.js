"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.partnerValidation = void 0;
const express_1 = require("express");
exports.partnerValidation = (0, express_1.Router)();
exports.partnerValidation.post('/onboard', (req, res) => res.json({ status: 'Partner onboarded' }));
