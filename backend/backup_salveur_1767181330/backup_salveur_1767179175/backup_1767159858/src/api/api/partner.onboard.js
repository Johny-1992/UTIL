"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onboardPartner = onboardPartner;
function onboardPartner(partner) {
    if (partner.score >= 80) {
        return { status: "accepted", partner };
    }
    return { status: "rejected", partner };
}
