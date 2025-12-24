"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const body_parser_1 = __importDefault(require("body-parser"));
const partner_validation_1 = require("./api/partner_validation");
const ai_1 = require("./api/ai");
const app = (0, express_1.default)();
app.use(body_parser_1.default.json());
// ✅ Route /health si manquante
app.get('/health', (req, res) => res.json({ status: 'ok' }));
// ✅ Routes API
app.use('/api/partner', partner_validation_1.partnerValidation);
app.use('/api/ai', ai_1.aiRouter);
// Lancer le serveur sur le port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
exports.default = app;
