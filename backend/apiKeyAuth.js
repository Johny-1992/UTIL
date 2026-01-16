"use strict";

/**
 * API KEY AUTH – OMNIUTIL
 * DEMO : permissif
 * PROD : header x-api-key obligatoire
 */

function apiKeyAuth(req, res, next) {
  const mode = process.env.MODE || "demo";

  if (mode === "demo") {
    return next();
  }

  const apiKey = req.headers["x-api-key"];
  if (!apiKey) {
    return res.status(401).json({ error: "API key missing" });
  }

  if (apiKey !== process.env.API_KEY) {
    return res.status(403).json({ error: "Invalid API key" });
  }

  next();
}

module.exports = { apiKeyAuth };
