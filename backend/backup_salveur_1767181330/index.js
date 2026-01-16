"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const partner_validation_1 = __importDefault(require("./partner_validation"));
const ai_1 = __importDefault(require("./ai"));
const api_1 = __importDefault(require("./api"));
const apiKeyAuth_1 = require("./src/middleware/apiKeyAuth");
const logger_1 = require("./src/middleware/logger");
const rateLimit_1 = require("./src/middleware/rateLimit");
const app = (0, express_1.default)();
// PORT configuré via .env ou 3000 par défaut
const PORT = Number(process.env.PORT) || 3000;
// Faire confiance au proxy (Nginx) pour les IP / X-Forwarded-For
app.set('trust proxy', true);
// Middleware global JSON + logger
app.use(express_1.default.json());
app.use(logger_1.requestLogger);
// Route de santé publique (sans auth, sans rate limit)
app.get('/health', (_req, res) => {
    return res.status(200).json({ status: 'ok' });
});
// À partir d'ici : rate limit + clé API
app.use(rateLimit_1.rateLimiter);
app.use(apiKeyAuth_1.apiKeyAuth);
// Ancienne logique /api/partner (valideur)
app.use('/api/partner', partner_validation_1.default);
// AI coordonnateur
app.use('/api/ai', ai_1.default);
// Nouvelle API métier OMNIUTIL (onboard, reward, util)
app.use('/api', api_1.default);
// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
exports.default = app;
