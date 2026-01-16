"use strict";

/**
 * REQUEST LOGGER – OMNIUTIL
 * Audit-ready / compatible SIEM
 */

function requestLogger(req, _res, next) {
  console.log(
    `[${new Date().toISOString()}] ${req.method} ${req.originalUrl} | IP=${req.ip}`
  );
  next();
}

module.exports = { requestLogger };
