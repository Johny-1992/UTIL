"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// Avant : mélange require / import
const express_1 = __importDefault(require("express"));
const partner_validation_1 = __importDefault(require("./api/partner_validation"));
const ai_1 = __importDefault(require("./api/ai"));
const app = (0, express_1.default)();
const PORT = Number(process.env.PORT) || 3000;
// Middleware / Routes
app.use(express_1.default.json());
app.use('/api/partner', partner_validation_1.default);
app.use('/api/ai', ai_1.default);
// Health endpoint
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));
app.listen(PORT, '0.0.0.0', () => {
    console.log('Server running on port', PORT);
});
exports.default = app;
