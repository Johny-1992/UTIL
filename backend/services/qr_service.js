"use strict";

/**
 * QR SERVICE – DEMO STUB
 * Conforme à la logique OMNIUTIL :
 * - QR = point d’entrée physique → API → AI → Orchestrateur
 * - Ici : simulation contrôlée
 */

module.exports = {
  generateQR: async (payload = {}) => {
    console.log("[qr_service] DEMO generateQR stub", payload);

    return {
      qrId: "DEMO-QR-0001",
      payload,
      status: "generated",
      mode: "demo"
    };
  },

  validateQR: async (qrId) => {
    console.log("[qr_service] DEMO validateQR stub", qrId);

    return {
      qrId,
      valid: true,
      consumed: false,
      mode: "demo"
    };
  }
};
