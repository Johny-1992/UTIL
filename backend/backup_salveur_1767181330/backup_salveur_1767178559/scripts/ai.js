"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiRouter = void 0;
const express_1 = require("express");
exports.aiRouter = (0, express_1.Router)();
exports.aiRouter.get('/status', (req, res) => res.json({ status: 'AI OK' }));
