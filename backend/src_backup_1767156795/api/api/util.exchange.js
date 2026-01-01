"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.exchangeUTIL = exchangeUTIL;
function exchangeUTIL(user, service, amount) {
    return { user, service, amount, status: "exchanged" };
}
