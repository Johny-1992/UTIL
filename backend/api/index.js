"use strict";

const express = require("express");
const router = express.Router();

/**
 * API MÉTIER OMNIUTIL – DEMO
 * Rôle :
 * - Point central des flux utilitaires
 * - Orchestration future smart contract / AI / QR
 */

// === HEALTH API MÉTIER ===
router.get("/status", (_req, res) => {
  res.json({
    service: "omniutil-api",
    mode: process.env.MODE || "demo",
    status: "operational"
  });
});

// === ONBOARD (DEMO) ===
router.post("/onboard", (req, res) => {
  console.log("[API] onboard DEMO", req.body);

  res.json({
    onboarded: true,
    entityId: "DEMO-ENTITY-001",
    mode: "demo"
  });
});

// === REWARD (DEMO) ===
router.post("/reward", (req, res) => {
  console.log("[API] reward DEMO", req.body);

  res.json({
    rewarded: true,
    amount: req.body?.amount || 0,
    tx: "DEMO-TX-0001",
    mode: "demo"
  });
});

// === UTIL EVENT (QR / ACTION) ===
router.post("/util", (req, res) => {
  console.log("[API] util DEMO", req.body);

  res.json({
    accepted: true,
    utilId: "DEMO-UTIL-001",
    mode: "demo"
  });
});

module.exports = router;
