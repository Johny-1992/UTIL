"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.decodeContext = exports.encodeContext = void 0;
exports.encodeQrContext = encodeQrContext;
exports.decodeQrContext = decodeQrContext;
const buffer_1 = require("buffer");
function encodeQrContext(ctx) {
    const json = JSON.stringify(ctx);
    return buffer_1.Buffer.from(json, 'utf-8').toString('base64url');
}
function decodeQrContext(payload) {
    const json = buffer_1.Buffer.from(payload, 'base64url').toString('utf-8');
    return JSON.parse(json);
}
// Alias pour compatibilité avec ai.ts
exports.encodeContext = encodeQrContext;
exports.decodeContext = decodeQrContext;
