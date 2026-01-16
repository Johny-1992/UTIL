"use strict";

/**
 * RATE LIMIT – OMNIUTIL
 * DEMO : soft
 * PROD : durcissable
 */

const rateLimit = require("express-rate-limit");

const rateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: process.env.MODE === "demo" ? 1000 : 100,
  standardHeaders: true,
  legacyHeaders: false
});

module.exports = { rateLimiter };
